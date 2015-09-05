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
typedef void (^SOplaygroundFeedActionGroupCompletion)();

@interface SOPlaygroundFeedActionGroupView : UIView
@property (nonatomic) PlaygroundFeed* feed;
@property (nonatomic) BOOL liked; //setting this property will not invoke delegate method don
-(void)setLiked:(BOOL)liked animated:(BOOL)animated;
-(void)setLiked:(BOOL)liked animated:(BOOL)animated completion:(SOplaygroundFeedActionGroupCompletion)completion;
@property (nonatomic,assign) id<SOPlaygroundFeedInteractionDelegate> delegate;
@end
