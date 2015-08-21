//
//  SOPlaygroundFeedCommentPreviewView.m
//  SO
//
//  Created by Guanqing Yan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedCommentPreviewView.h"
#import "SOUICommons.h"
#import "SOPlaygroundFeedCommentPreviewViewCell.h"

@interface SOPlaygroundFeedCommentPreviewView()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray* comments;//visible comments
@property (nonatomic) int commentCount;//total count
@property (nonatomic,strong) PlaygroundFeed* feed;
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic,strong) NSMutableArray* cells;
@end

@implementation SOPlaygroundFeedCommentPreviewView
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setScrollEnabled:false];
    [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.cells = [NSMutableArray array];
    self.delegate = self;
    self.dataSource = self;
}

-(CGFloat)setComments:(NSArray*)comments totalCount:(int)totalCount feed:(PlaygroundFeed*)feed width:(CGFloat)width soDelegate:(id<SOPlaygroundFeedInteractionDelegate>)soDelegate{
    NSAssert(feed, @"feed is nil");
    self.comments = comments;
    self.commentCount = totalCount;
    self.feed = feed;
    self.width = width;
    self.soDelegate = soDelegate;
    [self createCells];
    [self reloadData];
    return self.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.cells[indexPath.row] frame].size.height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.cells[indexPath.row];
}
-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.comments.count;
}
-(void)createCells{
    [self.cells removeAllObjects];
    self.height = 0;
    for (int i=0; i<self.comments.count; i++) {
        SOPlaygroundFeedCommentPreviewViewCell* c = [[SOPlaygroundFeedCommentPreviewViewCell alloc] initWithComment:self.comments[i] width:self.width];
        [c setDelegate:self.soDelegate];
        [self.cells addObject:c];
        self.height+=c.frame.size.height;
    }
}

@end
