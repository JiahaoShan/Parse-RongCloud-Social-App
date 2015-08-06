//
//  SOMapBubbleAnnotationView.m
//  SO
//
//  Created by Jiahao Shan on 8/5/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOMapBubbleAnnotationView.h"

@implementation SOMapBubbleAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImage *blipImage = [UIImage imageNamed:@"pin.png"];
        CGRect frame = [self frame];
        frame.size = [blipImage size];
        [self setFrame:frame];
        [self setCenterOffset:CGPointMake(0.0, -7.0)];
        [self setImage:blipImage];
    }
    return self;
}

@end
