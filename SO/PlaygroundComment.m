//
//  PlaygroundComment.m
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "PlaygroundComment.h"
#import <Parse/PFObject+Subclass.h>

@implementation PlaygroundComment

@dynamic playgroudFeed;
@dynamic commentOwner;
//@dynamic commentReceiverId;
@dynamic message;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"PlaygroundComment";
}

@end
