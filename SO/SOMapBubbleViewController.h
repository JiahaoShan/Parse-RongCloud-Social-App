//
//  SOMapBubbleViewController.h
//  SO
//
//  Created by Jiahao Shan on 7/30/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOBaseViewController.h"
#import "SOMapBubbleButtonView.h"
#import "SOMapBubbleChatRecordTableView.h"

@interface SOMapBubbleViewController : SOBaseViewController 
@property (weak, nonatomic) IBOutlet SOMapBubbleButtonView *addButton;
@property (weak, nonatomic) IBOutlet SOMapBubbleChatRecordTableView *recordTable;
@property (weak, nonatomic) IBOutlet SOMapBubbleChatRecordTableView *chatRecordTableView;
@end
