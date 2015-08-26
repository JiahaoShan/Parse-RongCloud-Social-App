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
@end

static NSString * const MapChatCellIdentifier = @"MapBubbleChatRecordCell";

@implementation SOMapBubbleChatRecordTableView

-(void)insertMessage:(RCTextMessage*)message withUserInfo:(RCUserInfo*) userInfo
{
    [self.messages addObject:message];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.delegate = self;
    self.dataSource = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightForChatRecordCellAtIndexPath:indexPath];
}

- (CGFloat)heightForChatRecordCellAtIndexPath:(NSIndexPath *)indexPath {
    static SOMapBubbleChatRecordTableViewCell *sizingCell = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sizingCell = [self dequeueReusableCellWithIdentifier:MapChatCellIdentifier];
    });
    
    sizingCell.textLabel.text = @"Nigulars";
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    return 30;
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SOMapBubbleChatRecordTableViewCell* cell = (SOMapBubbleChatRecordTableViewCell*)[self dequeueReusableCellWithIdentifier:MapChatCellIdentifier];
    if (cell == nil) {
        cell = [[SOMapBubbleChatRecordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MapChatCellIdentifier];
    }
    cell.textLabel.text = @"Nigulars";
    cell.detailTextLabel.text = @"Fuck you";
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(SOMapBubbleChatRecordTableViewCell*)configureCellForMessage:(RCTextMessage*)message
{
    return nil;
}

@end
