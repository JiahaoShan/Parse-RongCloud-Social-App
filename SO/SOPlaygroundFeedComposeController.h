//
//  SOPlaygroundFeedComposeController.h
//  SO
//
//  Created by Guanqing Yan on 8/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaygroundFeed.h"

@protocol SOPlaygroundFeedComposeControllerDelegate
-(void)userDidTapCancel;
-(void)userDidFinishComposingFeed:(PlaygroundFeed*)feed;
@end
@interface SOPlaygroundFeedComposeController : UIViewController
@property (assign,nonatomic) id<SOPlaygroundFeedComposeControllerDelegate>delegate;
@end
