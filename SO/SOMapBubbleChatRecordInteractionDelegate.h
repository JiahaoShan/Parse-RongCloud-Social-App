//
//  SOMapBubbleChatRecordInteractionDelegate.h
//  SO
//
//  Created by Jiahao Shan on 8/24/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RCUserInfo;

@protocol SOMapBubbleChatRecordInteractionDelegate <NSObject>
-(void)userDidTapNameOfUser:(RCUserInfo*)userInfo;
@end
