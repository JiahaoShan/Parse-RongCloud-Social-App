//
//  SOPlaygroundFeedCommentPreviewView.h
//  SO
//
//  Created by Guanqing Yan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOPlaygroundFeedInteractionDelegate.h"
#import "PlaygroundFeed.h"
#import "User.h"

@interface SOPlaygroundFeedResponseCell : UITableViewCell
@end

@interface SOPlaygroundFeedResponseView : UITableView
@property (nonatomic,assign) id<SOPlaygroundFeedInteractionDelegate> soDelegate;
-(void)setFeed:(PlaygroundFeed*)feed width:(CGFloat)width soDelegate:(id<SOPlaygroundFeedInteractionDelegate>)soDelegate;
@end
