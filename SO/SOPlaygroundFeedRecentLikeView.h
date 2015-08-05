//
//  SOPlaygroundFeedRecentLikeView.h
//  SO
//
//  Created by Guanqing Yan on 8/5/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOPlaygroundFeedInteractionDelegate.h"
#import "SOUICommons.h"
#import "PlaygroundFeed.h"
#import "User.h"

@interface SOPlaygroundFeedRecentLikeView : UITextView
@property (nonatomic,assign) id<SOPlaygroundFeedInteractionDelegate> soDelegate;
/*
 Array of recently liked users, maximum 8
 */
-(CGFloat)setLikes:(NSArray*)likes totalCount:(int)totalCount feed:(PlaygroundFeed*)feed width:(CGFloat)width;//returns height, takes container width as parameter only pass in the comments that you want to be visible;
@end
