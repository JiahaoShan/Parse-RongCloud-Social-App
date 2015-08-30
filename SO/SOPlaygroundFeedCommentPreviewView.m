//
//  SOPlaygroundFeedCommentPreviewView.m
//  SO
//
//  Created by Guanqing Yan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedCommentPreviewView.h"
#import "SOPlaygroundFeedCommentPreviewViewCell.h"
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

//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    static dispatch_once_t token;
//    static NSMutableDictionary* cells;
//    dispatch_once(&token, ^{
//        cells=[[NSMutableDictionary alloc] init];
//    });
//        for (NSValue* value in [cells allKeys]) {
//            const void* pointer = [value pointerValue];
//            if (cell==pointer) {
//                [cell.contentView setBackgroundColor:[cells objectForKey:value]];
//                return;
//            }
//        }
//        UIColor* rdColor = [SOUICommons randomColor];
//        [cells setObject:rdColor forKey:[NSValue valueWithPointer:(__bridge const void *)(cell)]];
//        [cell.contentView setBackgroundColor:rdColor];
//}
//-(void)createCells{
//    [self.cells removeAllObjects];
//    self.height = 0;
//    for (int i=0; i<self.comments.count; i++) {
//        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//        PlaygroundComment* comment = self.comments[i];
//        [comment fetchIfNeeded];
//        [[comment commentOwner] fetchIfNeeded];
//        TTTAttributedLabel* label = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
//        
//        NSString* text = [NSString stringWithFormat:@"%@: %@",[[comment commentOwner] username],[comment message]];
//        [label setText:text];
//        [label setTranslatesAutoresizingMaskIntoConstraints:false];
//        [label setPreferredMaxLayoutWidth:[SOUICommons screenWidth]-16];
//        [label setNumberOfLines:0];
//        [label setLineBreakMode:NSLineBreakByWordWrapping];
//        [label setBackgroundColor:[SOUICommons randomColor]];
//        [cell.contentView addSubview:label];
//        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"v":label}]];
//        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"v":label}]];
//        [self.cells addObject:cell];
//        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//        self.height+=size.height;
//        [self.cellHeights addObject:@(size.height)];
//    }
//    if (self.commentCount>self.comments.count) {
//        UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//        TTTAttributedLabel* label = [[TTTAttributedLabel alloc] initWithFrame:cell.contentView.bounds];
//        [label setText:[NSString stringWithFormat:@"点击此处查看全部%d条评论",self.commentCount]];
//        [label setTranslatesAutoresizingMaskIntoConstraints:false];
//        //[label setPreferredMaxLayoutWidth:[SOUICommons screenWidth]];
//        [label setNumberOfLines:0];
//        [label setLineBreakMode:NSLineBreakByWordWrapping];
//        [cell.contentView addSubview:label];
//        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[v]|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:@{@"v":label}]];
//        [cell.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[v]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:@{@"v":label}]];
//        [self.cells addObject:cell];
//        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//        self.height+=size.height;
//        [self.cellHeights addObject:@(size.height)];
//    }
//}

//-(SOPlaygroundFeedCommentPreviewViewCell*)configuredCellForIndexPath:(NSIndexPath*)indexPath{
//
//}

-(void)configureCell:(SOPlaygroundFeedCommentPreviewViewCell*)cell withComment:(PlaygroundComment*)comment{
    [comment fetchIfNeeded];
    [[comment commentOwner] fetchIfNeeded];
    TTTAttributedLabel* label = [cell.contentView viewWithTag:1];
    [label setPreferredMaxLayoutWidth:[SOUICommons screenWidth]-16];
    NSString* text = [NSString stringWithFormat:@"%@: %@",[[comment commentOwner] username],[comment message]];
    [label setText:text];
    
    //[label setBackgroundColor:[SOUICommons randomColor]];
//    [label setNeedsDisplay];
//    [label layoutIfNeeded];
//    [label setNeedsLayout];
}

-(void)configureCell:(SOPlaygroundFeedCommentPreviewViewCell*)cell withViewAllCount:(NSInteger)count{
    TTTAttributedLabel* label = [cell.contentView viewWithTag:1];
    [label setPreferredMaxLayoutWidth:[SOUICommons screenWidth]-32];
    [label setText:[NSString stringWithFormat:@"点击此处查看全部%d条评论",self.commentCount]];
    //[label setLineBreakMode:NSLineBreakByWordWrapping];
}

@end
