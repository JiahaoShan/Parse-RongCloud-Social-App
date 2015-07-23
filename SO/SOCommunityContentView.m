//
//  SOCommunityContentView.m
//  SO
//
//  Created by Guanqing Yan on 7/21/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOCommunityContentView.h"
@interface SOCommunityContentView()
@property (nonatomic) UITapGestureRecognizer* doubleTap;
@end

@implementation SOCommunityContentView
- (void)awakeFromNib{
    [super awakeFromNib];
    self.doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
    self.doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:self.doubleTap];
}

-(void)onDoubleTap:(UITapGestureRecognizer*)tap{
    CGPoint position = [tap locationInView:self];
    position = [self convertPoint:position toView:[self.subviews lastObject]];
    for (UIView* v in [[self.subviews lastObject] subviews]) {
        if (CGRectContainsPoint(v.frame, position)) {
            [v setBackgroundColor:[UIColor redColor]];
            if (self.communityViewDelegate) {
                [self.communityViewDelegate didDoubleTapViewAtIndex:[[[self.subviews lastObject] subviews] indexOfObject:v]];
            }
            break;
        }
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    
    CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGFloat centerX = self.contentSize.width/2;
    CGFloat centerY = self.contentSize.height/2;
    
    CGContextFillEllipseInRect(context, CGRectMake(centerX-self.contentRadius, centerY-self.contentRadius, 2*self.contentRadius, 2*self.contentRadius));
    
//    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
//    CGContextSetLineWidth(context, 2.0f);
//    for (UIView* view in [[self.subviews lastObject] subviews]) {
//        CGPoint p = view.center;
//        p = [self convertPoint:p fromView:[self.subviews lastObject]];
//        CGContextMoveToPoint(context, centerX, centerY); //start at this point
//        CGContextAddLineToPoint(context, p.x, p.y); //draw to this point
//        CGContextStrokePath(context);
//    }
}

@end
