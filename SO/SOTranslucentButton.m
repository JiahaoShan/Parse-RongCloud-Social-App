//
//  SOTranslucentButton.m
//  SO
//
//  Created by Guanqing Yan on 8/30/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOTranslucentButton.h"

@implementation SOTranslucentButton
-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (CGRectContainsPoint(self.frame, point)) {
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
    return nil;
}
@end
