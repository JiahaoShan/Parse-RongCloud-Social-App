
//
//  University.m
//  SO
//
//  Created by Jiahao Shan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "University.h"
#import <Parse/PFObject+Subclass.h>

@implementation University

@dynamic city;
@dynamic state;
@dynamic country;
@dynamic name;
@dynamic domain;
@dynamic aliasPointer;


+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"University";
}

@end
