//
//  SOMapBubbleTextLabel.m
//  SO
//
//  Created by Jiahao Shan on 8/9/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOMapBubbleTextLabel.h"

@implementation SOMapBubbleTextLabel

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {5, 5, 5, 5};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
