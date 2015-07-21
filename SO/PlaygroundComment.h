//
//  PlaygroundComment.h
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Parse/Parse.h>

@interface PlaygroundComment : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property NSString* playgroudFeedId;
@property NSString* commentOwnerId;
@property NSString* commentReceiverId;
@property NSString* message;


@end
