//
//  UIView+ActivityIndicator.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "UIView+ActivityIndicator.h"

@implementation UIView (ActivityIndicator)
@dynamic activityIndicator;

-(void)showActivityIndicator{
    if (!self.activityIndicator) {
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:self.activityIndicator];
        self.activityIndicator.center = self.center;
    }
    //todo:optionally gray out current view
    [self.activityIndicator startAnimating];
}
-(void)hideActivityIndicator{
    [self.activityIndicator stopAnimating];
}
@end
