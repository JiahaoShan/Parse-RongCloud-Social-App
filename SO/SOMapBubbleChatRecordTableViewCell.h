//
//  SOMapBubbleChatRecordTableViewCell.h
//  SO
//
//  Created by Jiahao Shan on 8/24/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOMapBubbleChatRecordInteractionDelegate.h"
#import <RongIMKit/RongIMKit.h>


@interface SOMapBubbleChatRecordTableViewCell : UITableViewCell

@property (nonatomic,assign) id<SOMapBubbleChatRecordInteractionDelegate> delegate;

-(void)configureWithMessage:(RCTextMessage*)message userInfo:(RCUserInfo*)userInfo width:(CGFloat)width;

@end
