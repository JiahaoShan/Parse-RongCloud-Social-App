//
//  SOLabelView.m
//  SO
//
//  Created by Jiahao Shan on 8/9/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOLabelView.h"

@interface SOLabelView()
@property (nonatomic) UIEdgeInsets insets;
@end

@implementation SOLabelView

-(id) initWithUIEdgeInsets:(UIEdgeInsets) insets{
    if (self = [super init]) {
        _insets = insets;
    }
    return self;
}

-(id) initWithFrame:(CGRect)frame AndUIEdgeInsets:(UIEdgeInsets) insets {
    if (self = [super initWithFrame:frame]) {
        _insets = insets;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _insets)];
}

@end
