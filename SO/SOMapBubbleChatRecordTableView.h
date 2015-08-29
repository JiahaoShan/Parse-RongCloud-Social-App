//
//  SOMapBubbleChatRecordTableView.h
//  SO
//
//  Created by Jiahao Shan on 8/24/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOMapBubbleChatRecordTableViewCell.h"
#import <RongIMKit/RongIMKit.h>


@interface SOMapBubbleChatRecordTableView : UITableView
-(void)insertMessage:(RCTextMessage*)message withUserInfo:(RCUserInfo*) userInfo;

@property (weak, nonatomic) id attributeLabelDelegate;

@end
