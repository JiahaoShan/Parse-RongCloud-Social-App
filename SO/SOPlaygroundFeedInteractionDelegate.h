//
//  SOPlaygroundFeedInteractionDelegate.h
//  SO
//
//  Created by Guanqing Yan on 8/5/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PlaygroundFeed;
@class User;
@protocol SOPlaygroundFeedInteractionDelegate <NSObject>
-(void)userDidTapViewAllCommentForFeed:(PlaygroundFeed*)feed;
-(void)userDidTapViewAllLikeForFeed:(PlaygroundFeed *)feed;
-(void)userDidTapNameOfUser:(User*)user;
@end
