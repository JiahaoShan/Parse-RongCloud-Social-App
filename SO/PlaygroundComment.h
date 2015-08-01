//
//  PlaygroundComment.h
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Parse/Parse.h>
#import "User.h"
#import "PlaygroundFeed.h"

@interface PlaygroundComment : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property PlaygroundFeed* playgroudFeed;
@property User* commentOwner;
//@property User* commentReceiver;
@property NSString* message;


@end
