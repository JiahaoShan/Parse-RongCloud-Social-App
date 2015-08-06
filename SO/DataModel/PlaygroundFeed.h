//
//  PlaygroundFeed.h
//  SO
//
//  Created by Jiahao Shan on 7/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Parse/Parse.h>
@class User;
@class PlaygroundComment;
@interface PlaygroundFeed : PFObject <PFSubclassing>
+ (NSString *)parseClassName;
@property User* poster;
@property NSString* text;
@property NSArray* images;
@property NSArray* thumbnails;
@property PlaygroundComment* firstComment;
@property PlaygroundComment* latestComment;
@property NSNumber* commentCount;

@property NSNumber* likeCount;
@property NSArray* recentLikeUsers;
@end
