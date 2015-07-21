//
//  PlaygroundImage.m
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "PlaygroundImage.h"
#import <Parse/PFObject+Subclass.h>

@implementation PlaygroundImage 
@dynamic imageThumbnailFile;
@dynamic imageFile;
@dynamic imageOwnerId;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"PlaygroundImage";
}
@end
