//
//  SOPlaygroundFeedLikeView.h
//  SO
//
//  Created by Guanqing Yan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaygroundFeed.h"
#import "SOPlaygroundFeedInteractionDelegate.h"
#import "SOPlaygroundFeedRecentLikeView.h"
//size should be set to 24*80
@interface SOPlaygroundFeedLikeView : UIView
@property (nonatomic) PlaygroundFeed* feed;
@property (nonatomic) BOOL liked; //setting this property will not invoke delegate method don
-(void)setLiked:(BOOL)liked animated:(BOOL)animated;
@property (nonatomic) int count; //like count
@property (nonatomic,assign) id<SOPlaygroundFeedInteractionDelegate> delegate;
@property (nonatomic,weak) SOPlaygroundFeedRecentLikeView* recentLikeView;//when likes or cancles like, update recentlikeview immediately, and wait for server response to cancle it or not.
@end
