//
//  PlaygroundComment.h
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Parse/Parse.h>
@class PlaygroundFeed;
@class User;
@interface PlaygroundComment : PFObject <PFSubclassing>
+ (NSString *)parseClassName;
@property NSString* playgroundFeedId;
@property NSString* message;
@property User* commentOwner;
@property User* targetUser;
@end
