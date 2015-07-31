//
//  User.m
//
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "User.h"
#import <Parse/PFObject+Subclass.h>

@implementation User

@dynamic userPortrait;
@dynamic portraitThumbnail;
@dynamic yearOfEnrollment;
@dynamic school;
@dynamic major;
@dynamic point;
@dynamic male;
@dynamic isFeature;
@dynamic userPortraits;
@dynamic userPortraitsThumbnails;

+ (void)load {
    [self registerSubclass];
}

@end
