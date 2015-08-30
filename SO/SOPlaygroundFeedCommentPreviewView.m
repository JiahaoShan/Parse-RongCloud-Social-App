//
//  SOPlaygroundFeedCommentPreviewView.m
//  SO
//
//  Created by Guanqing Yan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedCommentPreviewView.h"
#import "SOUICommons.h"
#import "TTTAttributedLabel.h"
#import "PlaygroundComment.h"

@interface SOPlaygroundFeedCommentPreviewView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray* comments;//visible comments
@property (nonatomic) int commentCount;//total count
@property (nonatomic,strong) PlaygroundFeed* feed;
@property (nonatomic) CGFloat height;
@end

@implementation SOPlaygroundFeedCommentPreviewView
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setScrollEnabled:false];
    [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.delegate = self;
    self.dataSource = self;
    [self registerNib:[UINib nibWithNibName:@"SOPlaygroundFeedCommentPreviewViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"c"];
}

-(CGFloat)setComments:(NSArray*)comments totalCount:(int)totalCount feed:(PlaygroundFeed*)feed width:(CGFloat)width soDelegate:(id<SOPlaygroundFeedInteractionDelegate>)soDelegate{
    NSAssert(feed, @"feed is nil");
    self.comments = comments;
    self.commentCount = totalCount;
    self.feed = feed;
    self.soDelegate = soDelegate;
    self.height=0;
    [self reloadData];
    return self.height;
}

-(CGSize)intrinsicContentSize{
    //return CGSizeMake(375, 200);
    //return CGSizeMake(self.width, self.height+1);
    NSUInteger numCells = [self numberOfRowsInSection:0];
    for (NSUInteger i=0; i<numCells; i++) {
        self.height+=[self getHeightForRow:i];
    }
    return CGSizeMake([SOUICommons screenWidth], self.height);
}

-(CGFloat)getHeightForRow:(NSUInteger)row{
    static dispatch_once_t t;
    static SOPlaygroundFeedCommentPreviewViewCell* c;
    dispatch_once(&t, ^{
        c = [self dequeueReusableCellWithIdentifier:@"c"];
    });
    if (row==self.comments.count) {
        [self configureCell:c withViewAllCount:self.commentCount];
    }else{
        [self configureCell:c withComment:self.comments[row]];
    }
    CGSize size = [c.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getHeightForRow:indexPath.row];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SOPlaygroundFeedCommentPreviewViewCell* c = [self dequeueReusableCellWithIdentifier:@"c"];
    if (indexPath.row==self.comments.count) {
        [self configureCell:c withViewAllCount:self.commentCount];
    }else{
        [self configureCell:c withComment:self.comments[indexPath.row]];
    }
    return c;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.commentCount>self.comments.count) {
        return self.comments.count+1;
    }
    return self.comments.count;
}

-(void)configureCell:(SOPlaygroundFeedCommentPreviewViewCell*)cell withComment:(PlaygroundComment*)comment{
    [comment fetchIfNeeded];
    [[comment commentOwner] fetchIfNeeded];
    TTTAttributedLabel* label = [cell.contentView viewWithTag:1];
    [label setPreferredMaxLayoutWidth:[SOUICommons screenWidth]-16];
    NSString* text = [NSString stringWithFormat:@"%@: %@",[[comment commentOwner] username],[comment message]];
    [label setText:text];
}

-(void)configureCell:(SOPlaygroundFeedCommentPreviewViewCell*)cell withViewAllCount:(NSInteger)count{
    TTTAttributedLabel* label = [cell.contentView viewWithTag:1];
    [label setPreferredMaxLayoutWidth:[SOUICommons screenWidth]-32];
    [label setText:[NSString stringWithFormat:@"点击此处查看全部%d条评论",self.commentCount]];
}

@end
