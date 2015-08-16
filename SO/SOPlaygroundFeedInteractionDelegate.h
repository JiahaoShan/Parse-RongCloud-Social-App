//
//  SOPlaygroundFeedInteractionDelegate.h
//  SO
//
//  Created by Guanqing Yan on 8/5/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOFailableAction.h"
@class PlaygroundFeed;
@class User;
@class PlaygroundComment;
@protocol SOPlaygroundFeedInteractionDelegate <NSObject>

-(void)userDidTapViewAllCommentForFeed:(PlaygroundFeed*)feed;
-(void)userDidTapDeleteComment:(PlaygroundComment*)comment;

-(void)userDidTapViewAllLikeForFeed:(PlaygroundFeed *)feed;
-(void)feed:(PlaygroundFeed*)feed didChangeLikeStatusTo:(BOOL)like action:(SOFailableAction*)action;
-(void)userDidWishComment:(PlaygroundFeed*)feed;

-(void)userDidTapNameOfUser:(User*)user;
@end
