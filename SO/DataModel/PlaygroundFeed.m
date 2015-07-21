//
//  PlaygroundFeed.m
//  SO
//
//  Created by Jiahao Shan on 7/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "PlaygroundFeed.h"
#import <Parse/PFObject+Subclass.h>

@implementation PlaygroundFeed

@dynamic feedOwnerId;
@dynamic likeCount;
@dynamic commentCount;
@dynamic message;
@dynamic photos;
@dynamic thumbnails;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"PlaygroundFeed";
}


@end
