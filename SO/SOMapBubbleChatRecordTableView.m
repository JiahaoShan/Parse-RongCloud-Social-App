//
//  SOMapBubbleChatRecordTableView.m
//  SO
//
//  Created by Jiahao Shan on 8/24/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOMapBubbleChatRecordTableView.h"
#import "SOMapBubbleChatRecord.h"

@interface SOMapBubbleChatRecordTableView() <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSMutableArray* messages;
@property (nonatomic) int messageCount;//total count
@property (nonatomic, strong) NSString* currentUserId;
@end

static NSString * const MapChatCellIdentifier = @"MapBubbleChatRecordCell";


@implementation SOMapBubbleChatRecordTableView

-(void)insertMessage:(RCTextMessage*)message withUserInfo:(RCUserInfo*) userInfo
{
    SOMapBubbleChatRecord* record = [[SOMapBubbleChatRecord alloc] init];
    record.message = message.content;
    record.userId = userInfo.userId;
    record.userName = userInfo.name;

    BOOL isSelf = NO;
    if ([self.currentUserId isEqualToString:userInfo.userId]) {
        isSelf = YES;
    }
    [self.messages addObject:record];
    self.messageCount++;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (isSelf) {
            [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }
        else {
            [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        }
        [self setContentOffset:CGPointZero animated:YES];
    });
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.messageCount = 0;
    self.messages = [[NSMutableArray alloc] init];
    self.delegate = self;
    self.dataSource = self;
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.currentUserId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
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
    
    [self configureCell:sizingCell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    //    [sizingCell setNeedsLayout];
    //    [sizingCell layoutIfNeeded];
    if (![sizingCell isKindOfClass:[SOMapBubbleChatRecordTableViewCell class]]) {
        return 16.0f;
    }
    SOMapBubbleChatRecordTableViewCell* attributeSizingCell = (SOMapBubbleChatRecordTableViewCell*) sizingCell;
        attributeSizingCell.attributeLabel.preferredMaxLayoutWidth = self.frame.size.width - 16;
        [attributeSizingCell setNeedsLayout];
        [attributeSizingCell layoutIfNeeded];
    CGSize size = [attributeSizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    //    return size.height;
    return size.height + 5;
}

- (SOMapBubbleChatRecordTableViewCell*)configureCell:(SOMapBubbleChatRecordTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath {
    cell.attributeLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink; // Automatically detect links when the label text is subsequently changed
    cell.attributeLabel.delegate = self.attributeLabelDelegate; // Delegate methods are called when the user taps on a link (see `TTTAttributedLabelDelegate` protocol)
    SOMapBubbleChatRecord* record = [self.messages objectAtIndex:self.messageCount - indexPath.row - 1];
    cell.attributeLabel.text = [NSString stringWithFormat:@"%@: %@", record.userName, record.message];
    NSRange range = [cell.attributeLabel.text rangeOfString: record.userName];
    [cell.attributeLabel addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",record.userId]] withRange:range]; // Embedding a custom link in a substring
    return cell;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SOMapBubbleChatRecordTableViewCell* cell = (SOMapBubbleChatRecordTableViewCell*)[self dequeueReusableCellWithIdentifier:MapChatCellIdentifier];
    if (cell == nil) {
        cell = [[SOMapBubbleChatRecordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MapChatCellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messageCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
