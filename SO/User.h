//
//  User.h
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Parse/Parse.h>

@interface User : PFUser <PFSubclassing>

@property PFFile *userPortrait;
@property PFFile *portraitThumbnail;
@property NSDate *yearOfEnrollment;
@property NSString *school;
@property NSString *major;
@property NSNumber *point;
@property NSArray *userPortraits;
@property NSArray *userPortraitsThumbnails;
@property BOOL male;
@property BOOL isFeature;

@end
