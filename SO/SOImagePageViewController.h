//
//  SOImagePageViewController.h
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOBaseViewController.h"

@interface SOImagePageViewController : SOBaseViewController

@property (nonatomic, strong) NSArray *pageImages;
@property (nonatomic, strong) NSArray *pageImagesThumbnails;

- (id)initWithImages: (NSArray*) images AndThumbnails: (NSArray*) thumbnails AtIndex:(NSInteger) index;

@end
