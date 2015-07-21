//
//  SOImageViewController.h
//  SO
//
//  Created by Guanqing Yan on 7/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOBaseViewController.h"
#import <ParseUI/ParseUI.h>

@interface SOImageViewController : SOBaseViewController
-(void)setImage:(PFFile*)image;
-(void)setImage:(PFFile*)image WithPlaceholder:(UIImage*) placeholder;

//todo:
-(void)setImages:(NSArray*)images startIndex:(NSUInteger)index;

@property (nonatomic) NSUInteger imageIndex;
@property (nonatomic) BOOL disablesNavigationBarHiddenControl;

@end
