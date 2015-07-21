//
//  PlaygroundLike.m
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "PlaygroundLike.h"
#import <Parse/PFObject+Subclass.h>

@implementation PlaygroundLike

@dynamic likeOwnerId;
@dynamic likeReceiverId;
@dynamic playgroundFeedId;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"PlaygroundLike";
}

@end
