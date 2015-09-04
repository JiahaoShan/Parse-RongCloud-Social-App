//
//  SOPlaygroundFeedCommentPreviewView.m
//  SO
//
//  Created by Guanqing Yan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedResponseView.h"
#import "SOUICommons.h"
#import "TTTAttributedLabel.h"
#import "PlaygroundComment.h"

typedef NS_OPTIONS(NSUInteger, SOPlaygroundFeedResponseViewType) {
    SOPlaygroundFeedResponseCellTypeNone = 0,
    SOPlaygroundFeedResponseCellTypeLikes = 1 << 0,
    SOPlaygroundFeedResponseCellTypeViewAllComments = 1 << 1,
    SOPlaygroundFeedResponseCellTypeComment = 1 << 2,
};

@interface SOPlaygroundFeedResponseView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray* comments;//visible comments
@property (nonatomic) int commentCount;//total tomment count

@property (nonatomic,strong) UIImageView* littleHeartView;
@property (nonatomic,strong) NSArray* recentLikes;
@property (nonatomic) int likeCount;

@property (nonatomic,weak) PlaygroundFeed* feed;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic) SOPlaygroundFeedResponseViewType type;
@property (nonatomic) NSInteger numCells;
@end

@implementation SOPlaygroundFeedResponseView
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setScrollEnabled:false];
    [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.delegate = self;
    self.dataSource = self;
    [self registerNib:[UINib nibWithNibName:@"SOPlaygroundFeedCommentPreviewViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"c"];
}

-(void)setFeed:(PlaygroundFeed*)feed width:(CGFloat)width soDelegate:(id<SOPlaygroundFeedInteractionDelegate>)soDelegate{
    NSAssert(feed, @"feed is nil");
    self.comments = [feed recentComments];
    self.commentCount = [[feed commentCount] intValue];
    self.recentLikes = [feed recentLikeUsers];
    self.likeCount = [[feed likeCount] intValue];
    self.soDelegate = soDelegate;
    self.feed = feed;
    self.height=0;
    self.width=width;
    self.numCells = 0;

    self.type=SOPlaygroundFeedResponseCellTypeNone;
    if (self.recentLikes.count>0 || self.likeCount>0) {
        self.type |= SOPlaygroundFeedResponseCellTypeLikes;
    }
    if (self.comments.count>0) {
        self.type |= SOPlaygroundFeedResponseCellTypeComment;
    }
    if (self.comments.count < self.commentCount) {
        self.type |= SOPlaygroundFeedResponseCellTypeViewAllComments;
    }
    [self.littleHeartView removeFromSuperview];
    self.littleHeartView = nil;
    [self reloadData];
}


-(CGSize)intrinsicContentSize{
    NSUInteger numCells = [self numberOfRowsInSection:0];
    for (NSUInteger i=0; i<numCells; i++) {
        self.height+=[self getHeightForRow:i];
    }
    return CGSizeMake(self.width, self.height);
}

-(CGFloat)getHeightForRow:(NSUInteger)row{
    static dispatch_once_t t;
    static SOPlaygroundFeedResponseCell* c;
    dispatch_once(&t, ^{
        c = [self dequeueReusableCellWithIdentifier:@"c"];
    });
    [self configureCell:c forRow:row];
    CGSize size = [c.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getHeightForRow:indexPath.row];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SOPlaygroundFeedResponseCell* c = [self dequeueReusableCellWithIdentifier:@"c"];
    [self configureCell:c forRow:indexPath.row];
    return c;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger num = 0;
    if (self.type & SOPlaygroundFeedResponseCellTypeComment) {
        num += self.comments.count;
    }
    if (self.type & SOPlaygroundFeedResponseCellTypeLikes) {
        num += 1;
    }
    if (self.type & SOPlaygroundFeedResponseCellTypeViewAllComments) {
        num += 1;
    }
    self.numCells = num;
    return num;
}


-(SOPlaygroundFeedResponseCell*)configureCell:(SOPlaygroundFeedResponseCell*)cell forRow:(NSInteger)row{
    SOPlaygroundFeedResponseViewType cellType = [self typeForCellAtIndex:row];
    NSInteger index = row;
    switch (cellType) {
        case SOPlaygroundFeedResponseCellTypeLikes:
            [self configureCell:cell withRecentLikes:self.recentLikes likeCount:self.likeCount];
            break;
        case SOPlaygroundFeedResponseCellTypeComment:
            if (self.type & SOPlaygroundFeedResponseCellTypeLikes) {
                index--;
            }
            [self configureCell:cell withComment:self.comments[index]];
            break;
        case SOPlaygroundFeedResponseCellTypeViewAllComments:
            [self configureCell:cell withViewAllCount:self.commentCount];
            break;
        default:
            NSAssert(true, @"error occured");
            break;
    }
    return cell;
}

-(SOPlaygroundFeedResponseViewType)typeForCellAtIndex:(NSInteger)index{
    if (index==0 && (self.type & SOPlaygroundFeedResponseCellTypeLikes)) {
        return SOPlaygroundFeedResponseCellTypeLikes;
    }else if(index==self.numCells-1 && (self.type & SOPlaygroundFeedResponseCellTypeViewAllComments)){
        return SOPlaygroundFeedResponseCellTypeViewAllComments;
    }else{
        return SOPlaygroundFeedResponseCellTypeComment;
    }
    return SOPlaygroundFeedResponseCellTypeNone;
}

-(void)configureCell:(SOPlaygroundFeedResponseCell*)cell withComment:(PlaygroundComment*)comment{
    [comment fetchIfNeeded];
    [[comment commentOwner] fetchIfNeeded];
    TTTAttributedLabel* label = (TTTAttributedLabel*)[cell.contentView viewWithTag:1];
    [label setPreferredMaxLayoutWidth:self.width];
    NSString* text = [NSString stringWithFormat:@"%@: %@",[[comment commentOwner] username],[comment message]];
    [label setText:text];
}

//view all comment cell
-(void)configureCell:(SOPlaygroundFeedResponseCell*)cell withViewAllCount:(NSInteger)count{
    TTTAttributedLabel* label = (TTTAttributedLabel*)[cell.contentView viewWithTag:1];
    [label setPreferredMaxLayoutWidth:self.width];
    [label setText:[NSString stringWithFormat:@"点击此处查看全部%d条评论",self.commentCount]];
}

-(void)configureCell:(SOPlaygroundFeedResponseCell*)cell withRecentLikes:(NSArray*)likes likeCount:(NSInteger)count{
    
    TTTAttributedLabel* label = (TTTAttributedLabel*)[cell.contentView viewWithTag:1];
    
    if (!self.littleHeartView) {
        self.littleHeartView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"like"]];
        CGFloat lineHeight = [label.font lineHeight];
        [self.littleHeartView setFrame:CGRectMake(2, 2, lineHeight-4, lineHeight-4)];
        [self addSubview:self.littleHeartView];
    }
    
    NSMutableString* likeString = [[NSMutableString alloc] initWithString:@"     "];
    NSMutableArray* likeNameRanges = [NSMutableArray array];
    for (int i=0; i<self.recentLikes.count; i++) {
        User* liker = self.recentLikes[i];
        [liker fetchIfNeeded];
        if (i!=self.recentLikes.count-1) {
            [likeNameRanges addObject:[NSValue valueWithRange:NSMakeRange(likeString.length, liker.username.length)]];
            [likeString appendFormat:@"%@, ",liker.username];
        }
        else{
            [likeNameRanges addObject:[NSValue valueWithRange:NSMakeRange(likeString.length, liker.username.length)]];
            [likeString appendFormat:@"%@ ",liker.username];
        }
    }
    if (self.likeCount > self.recentLikes.count) {
        [likeString appendFormat:@"等%d个人",self.likeCount];
    }
    [likeString appendFormat:@"觉得这个好厉害的"];

    [label setPreferredMaxLayoutWidth:self.width];
    [label setText:likeString];

}

@end
