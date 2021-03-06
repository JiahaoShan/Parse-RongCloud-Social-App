//
//  UIView+ActivityIndicator.h
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ActivityIndicator)
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicator;
-(void)showActivityIndicator;
-(void)hideActivityIndicator;
@end
