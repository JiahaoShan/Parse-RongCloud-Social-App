//
//  User.h
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Parse/Parse.h>
#import "University.h"

@interface User : PFUser <PFSubclassing>

@property PFFile *portrait;
@property PFFile *portraitThumbnail;
@property NSDate *yearOfEnrollment;
@property University *university;
@property NSString *major;
@property NSNumber *point;
@property NSArray *userPortraits;
@property NSArray *userPortraitsThumbnails;
@property BOOL male;
@property BOOL isFeature;


@end
