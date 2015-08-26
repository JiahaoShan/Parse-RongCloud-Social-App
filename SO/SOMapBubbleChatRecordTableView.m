//
//  SOMapBubbleChatRecordTableView.m
//  SO
//
//  Created by Jiahao Shan on 8/24/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOMapBubbleChatRecordTableView.h"

@interface SOMapBubbleChatRecordTableView() <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSMutableArray* messages;
@property (nonatomic) int messageCount;//total count
@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;
@property (nonatomic,strong) NSMutableArray* cells;
@end

@implementation SOMapBubbleChatRecordTableView

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setScrollEnabled:YES];
    [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.delegate = self;
    self.dataSource = self;
}

-(CGFloat)setMessages:(NSMutableArray*)messages width:(CGFloat)width soDelegate:(id<SOMapBubbleChatRecordInteractionDelegate>)soDelegate{
    self.messages = messages;
    self.messageCount = 0;
    self.width = width;
    self.soDelegate = soDelegate;
//    [self createCells];
    [self reloadData];
    return self.height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.cells[indexPath.row] frame].size.height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* identifier = @"MapBubbleChatRecordCell";
    SOMapBubbleChatRecordTableViewCell* cell = (SOMapBubbleChatRecordTableViewCell*)[self dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[SOMapBubbleChatRecordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return self.cells[self.messageCount - indexPath.row];
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.messageCount>self.messages.count) {
        return self.messages.count+1;
    }
    return self.messages.count;
}

-(void)insertMessage:(RCTextMessage*)message withUserInfo:(RCUserInfo*) userInfo
{
    [self.messages addObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(SOMapBubbleChatRecordTableViewCell*)configureCellForMessage:(RCTextMessage*)message
{
    return nil;
}
//-(void)createCells{
//    [self.cells removeAllObjects];
//    self.height = 0;
//    for (int i=0; i<self.messages.count; i++) {
//        SOMapBubbleChatRecordTableViewCell* c = [[SOMapBubbleChatRecordTableViewCell alloc] initWithComment:self.messages[i] width:self.width];
//        [c setDelegate:self.soDelegate];
//        [self.cells addObject:c];
//        self.height+=c.frame.size.height;
//    }
//    if (self.messageCount>self.messages.count) {
//        SOMapBubbleChatRecordTableViewCell* c = [[SOMapBubbleChatRecordTableViewCell alloc] initWithViewAllCount:self.messageCount feed:self.feed];
//        [c setDelegate:self.soDelegate];
//        [self.cells addObject:c];
//        self.height+=c.frame.size.height;
//    }
//}

@end
