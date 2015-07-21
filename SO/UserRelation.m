//
//  UserRelation.m
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "UserRelation.h"
#import <Parse/PFObject+Subclass.h>

@implementation UserRelation

@dynamic userAId;
@dynamic userBId;
@dynamic relation;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"UserRelation";
}
@end
