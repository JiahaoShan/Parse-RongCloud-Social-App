//
//  SOPlaygroundFeedImageView.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedImageView.h"
#import <ParseUI/ParseUI.h>

@interface SOPlaygroundFeedImageView()
@property (nonatomic) BOOL visible;
@property (nonatomic) NSArray* images; //an array of PFFiles
@property (nonatomic) NSMutableArray* imageViews;
@property (nonatomic) UITapGestureRecognizer* tapGesture;
@end

@implementation SOPlaygroundFeedImageView
-(NSMutableArray*)imageViews{
    if (!_imageViews) {
        _imageViews = [[NSMutableArray alloc] init];
    }
    return _imageViews;
}

-(UITapGestureRecognizer*)tapGesture{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    }
    return _tapGesture;
}

-(void)tapped:(UIGestureRecognizer*)tap{
    CGPoint p = [tap locationInView:self];
    [self.imageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (CGRectContainsPoint([obj frame], p)) {
            if (self.delegate) {
                [self.delegate didTapImageAtIndex:idx];
            }
            NSLog(@"tapped image at index: %d",idx);
            *stop = true;
        }
    }];
}

-(void)layoutSubviews{
    if (self.imageViews.count==1) {
        PFImageView* iv = [self.imageViews firstObject];
        CGRect frame = CGRectMake(0,0,kPlaygroundSingleImageHeight,kPlaygroundSingleImageHeight);
        [iv setFrame:frame];
    }else{
        for (int i=0;i<self.imageViews.count;i++) {
            PFImageView* iv = self.imageViews[i];
            int x = i%3;
            int y = i/3;
            CGRect frame = CGRectMake(x*kPlaygroundMultipleImageSize+x*kPlaygroundImagePadding, y*kPlaygroundMultipleImageSize+y*kPlaygroundImagePadding, kPlaygroundMultipleImageSize, kPlaygroundMultipleImageSize);
            [iv setFrame:frame];
        }
    }
}

-(CGFloat)setImagesWithFiles:(NSArray*)files{
    if (files.count == 0) {
        [self setVisible:NO];
        return 0;
    }
    if (!_tapGesture) {
        [self addGestureRecognizer:self.tapGesture];
    }
    
    [self setVisible:true];
    [self.imageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.imageViews removeAllObjects];
    
    _images = files;
    if (files.count==1) {
        PFImageView* iv = [[PFImageView alloc] initWithImage:[UIImage imageNamed:@"placeholderImage"]];
        [iv setImage:[UIImage imageNamed:@"placeholderImage"]];
        [iv setFile:files[0]];
        [iv loadInBackground];
        [self addSubview:iv];
        [self.imageViews addObject:iv];
    }else{
        for (int i=0;i<files.count;i++) {
            PFImageView* iv = [[PFImageView alloc] initWithImage:[UIImage imageNamed:@"placeholderImage"]];
            [iv setImage:[UIImage imageNamed:@"placeholderImage"]];
            [iv setFile:files[i]];
            [iv loadInBackground: ^(UIImage *image, NSError *error) {
                if (!error) {
                    // Configure your image view in here
                    
                }
            }];
            [self addSubview:iv];
            [self.imageViews addObject:iv];
        }
    }
    
    if (files.count==1) {
        return kPlaygroundSingleImageHeight;
    }else if(files.count>0){
        int numRow = (int)ceil(files.count/3.0);
        return numRow * kPlaygroundMultipleImageSize + (numRow-1)*kPlaygroundImagePadding;
    }
    return 0;
}

//different from setHidden
//a hidden view will still occupy the frame,
//but a not visible view will have a height of 0
//if self is set to visible, then caller is still responsible for
//setting the height of the view
-(void)setVisible:(BOOL)visible{
    if (self.visible == visible) {
        return;
    }
    if(visible){
        self.hidden = false;
    }else{
        CGRect frame = self.frame;
        frame.size.height = 0;
        self.frame = frame;
        self.hidden = true;
    }
    _visible = visible;
}

- (NSMutableArray*) getImageViews {
    return self.imageViews;
}
@end
