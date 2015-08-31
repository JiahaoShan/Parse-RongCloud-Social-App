//
//  UIView+Sizing.m
//  SO
//
//  Created by Guanqing Yan on 8/30/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "UIView+Sizing.h"

@implementation UIView (Sizing)
-(void)extendUpToHeight:(CGFloat)height{
    CGRect r = self.frame;
    CGFloat previousHeight = CGRectGetHeight(self.frame);
    CGFloat d = previousHeight-height;
    r.origin.y += d;
    r.size.height -= d;
    [self setFrame:r];
}
@end
