//
//  PlaygroundFeed.h
//  SO
//
//  Created by Jiahao Shan on 7/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Parse/Parse.h>

@interface PlaygroundFeed : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property NSString* feedOwnerId;
@property NSNumber* likeCount;
@property NSNumber* commentCount;
@property NSString* message;
@property NSArray* photos;
@property NSArray* thumbnails;


@end
