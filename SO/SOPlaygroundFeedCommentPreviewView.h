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

@interface SOPlaygroundFeedCommentPreviewView : UITableView
@property (nonatomic,assign) id<SOPlaygroundFeedInteractionDelegate> soDelegate;
/*
 Array of NSDictionarys, like:
 @[ @{@"user":A, message:@"xxxx"}, @{@"user":A, message:@"xxxx"}];
 order will be respected
 */
-(CGFloat)setComments:(NSArray*)comments totalCount:(int)totalCount feed:(PlaygroundFeed*)feed width:(CGFloat)width soDelegate:(id<SOPlaygroundFeedInteractionDelegate>)soDelegate;//returns height, takes container width as parameter only pass in the comments that you want to be visible;
@end
