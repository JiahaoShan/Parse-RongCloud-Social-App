//
//  SOPlaygroundFeedComposeImageView.m
//  SO
//
//  Created by Guanqing Yan on 8/21/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedComposeImageView.h"
@interface SOPlaygroundFeedComposeImageView()
@property (nonatomic) NSMutableArray* images;
@property (nonatomic) NSMutableArray* imageViews;//may contain addMore
@property (nonatomic) UIImageView* addMore;
@property (nonatomic) UITapGestureRecognizer* tapGesture;
@end

@implementation SOPlaygroundFeedComposeImageView
-(UITapGestureRecognizer*)tapGesture{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    }
    return _tapGesture;
}
-(void)awakeFromNib{
    self.images = [NSMutableArray array];
    self.imageViews = [NSMutableArray array];
    self.maxNumberOfImages = 9;
    [self addGestureRecognizer:self.tapGesture];
    self.addMore = [[UIImageView alloc] init];
    [self.addMore setBackgroundColor:[UIColor redColor]];
    [self addSubview:self.addMore];
    [self.imageViews addObject:self.addMore];
}

-(void)appendImages:(NSArray*)images{
    [self.images addObjectsFromArray:images];
    for (NSInteger i=images.count-1; i>= 0;i--) {
        UIImage* image = images[i];
        UIImageView* iv = [[UIImageView alloc] initWithImage:image];
        [iv setContentMode:UIViewContentModeScaleAspectFill];
        [iv setClipsToBounds:true];
        [self.imageViews insertObject:iv atIndex:0];
        [self addSubview:iv];
    }
    if (self.imageViews.count>=self.maxNumberOfImages){
        [self.imageViews removeObject:self.addMore];
    }
    int numRow = (int)ceil(self.imageViews.count/3.0);
    [self.delegate didChangeHeightTo:numRow * kPlaygroundMultipleImageSize + (numRow-1)*kPlaygroundImagePadding];
}

//-(void)createViews{
//    for (UIImage* image in self.images) {
//        UIImageView* iv = [[UIImageView alloc] initWithImage:image];
//        [iv setContentMode:UIViewContentModeScaleAspectFill];
//        [self.imageViews addObject:iv];
//    }
//    if (self.imageViews.count<self.maxNumberOfImages) {
//        [self.imageViews addObject:self.addMore];
//    }
//}

-(void)layoutSubviews{
        for (int i=0;i<self.imageViews.count;i++) {
            UIImageView* iv = self.imageViews[i];
            int x = i%3;
            int y = i/3;
            CGRect frame = CGRectMake(x*kPlaygroundMultipleImageSize+x*kPlaygroundImagePadding, y*kPlaygroundMultipleImageSize+y*kPlaygroundImagePadding, kPlaygroundMultipleImageSize, kPlaygroundMultipleImageSize);
            [iv setFrame:frame];
        }
}

-(void)tapped:(UIGestureRecognizer*)tap{
    CGPoint p = [tap locationInView:self];
    __block NSUInteger index = NSNotFound;
    [self.imageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint([obj frame], p)) {
            index = idx;
            *stop = true;
        }
    }];
    if (index==NSNotFound) {
        return;
    }
    if (index==self.imageViews.count-1 && self.images.count<self.imageViews.count) {
        [self.delegate didRequestMoreImage];
    }
}

@end
