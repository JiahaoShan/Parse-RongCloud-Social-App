//
//  SOMapBubbleChatRecordTableView.h
//  SO
//
//  Created by Jiahao Shan on 8/24/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOMapBubbleChatRecordTableViewCell.h"
#import "SOMapBubbleChatRecordInteractionDelegate.h"

@interface SOMapBubbleChatRecordTableView : UITableView

@property (nonatomic,assign) id<SOMapBubbleChatRecordInteractionDelegate> soDelegate;


@end
