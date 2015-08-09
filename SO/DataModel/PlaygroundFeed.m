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

@dynamic poster;
@dynamic text;
@dynamic images;
@dynamic thumbnails;
@dynamic firstComment;
@dynamic latestComment;
@dynamic commentCount;
@dynamic likeCount;
@dynamic recentLikeUsers;
@synthesize liked = _liked;
+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"PlaygroundFeed";
}


@end
