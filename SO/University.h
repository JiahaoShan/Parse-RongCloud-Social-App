//
//  University.h
//  SO
//
//  Created by Jiahao Shan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Parse/Parse.h>


@interface University : PFObject <PFSubclassing>
@property NSString* city;
@property NSString* state;
@property NSString* country;
@property NSString* domain;
@property NSString* name;
@property University* aliasPointer;

@end
