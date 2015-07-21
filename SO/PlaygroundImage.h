//
//  PlaygroundImage.h
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Parse/Parse.h>

@interface PlaygroundImage : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property NSString* imageOwnerId;
@property PFFile* imageFile;
@property PFFile* imageThumbnailFile;

@end
