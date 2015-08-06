//
//  SOMapBubbleButtonView.m
//  SO
//
//  Created by Jiahao Shan on 8/5/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOMapBubbleButtonView.h"


@implementation SOMapBubbleButtonView


- (void)drawRect:(CGRect)rect {
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    [self.fillColor setFill];
    [bezierPath fill];
    
    CGFloat plusHeight = 3.0;
    CGFloat plusWidth = MIN(self.bounds.size.width, self.bounds.size.height) * 0.6;
    
    UIBezierPath *plusPath = [UIBezierPath bezierPath];
    [plusPath setLineWidth:plusHeight];
    [plusPath moveToPoint:CGPointMake(self.bounds.size.width/2 - plusWidth/2 + 0.5,
                                     self.bounds.size.height/2 + 0.5)];
    [plusPath addLineToPoint:CGPointMake(self.bounds.size.width/2 + plusWidth/2 + 0.5,
                                         self.bounds.size.height/2 + 0.5)];
    
    if (_isAddButton) {
        [plusPath moveToPoint:CGPointMake(self.bounds.size.width/2 + 0.5,
                                          self.bounds.size.height/2 - plusWidth/2 + 0.5)];
        [plusPath addLineToPoint:CGPointMake(self.bounds.size.width/2 + 0.5, self.bounds.size.height/2 + plusWidth/2 + 0.5)];
    }
    
    [[UIColor whiteColor] setStroke];
    [plusPath stroke];
    
}

@end
