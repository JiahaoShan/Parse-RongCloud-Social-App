//
//  PlaygroundLike.h
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Parse/Parse.h>

@interface PlaygroundLike : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property NSString* likeOwnerId;
@property NSString* likeReceiverId;
@property NSString* playgroundFeedId;

@end
