//
//  SOPlaygroundFeedImageView.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedImageView.h"
#import "SOUICommons.h"
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
@interface SOPlaygroundFeedImageView()
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

-(CGSize)intrinsicContentSize{
    //return CGSizeZero;
    CGSize size = CGSizeMake([SOUICommons screenWidth], 0);
    if (self.images.count==1) {
        size.height= kPlaygroundSingleImageHeight;
    }else if(self.images.count>0){
        int numRow = (int)ceil(self.images.count/3.0);
        size.height= numRow * kPlaygroundMultipleImageSize + (numRow-1)*kPlaygroundImagePadding;
    }else{
        size.height=0;
    }
    //size.height=80;
    return size;
}

-(void)setImagesWithThumbNails:(NSArray*)thumbnails files:(NSArray*)files{
    _images = files;
    [self.imageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [self.imageViews removeAllObjects];
    
    if (files.count == 0) {
        return;
    }
    
    if (!_tapGesture) {
        [self addGestureRecognizer:self.tapGesture];
    }
    
    if (files.count==1) {
        PFFile* f = thumbnails[0];
        if (![f isDataAvailable]) {
            f = files[0];
            if (![f isDataAvailable]) {
                f = thumbnails[0];
            }
        }
        UIImageView* iv;
        if ([f isDataAvailable]) {
            UIImage* image = [UIImage imageWithData:[f getData]];
            iv = [[UIImageView alloc] initWithImage:image];
        }else{
            iv = [[PFImageView alloc] initWithImage:[UIImage imageNamed:@"placeholderImage"]];
            [(PFImageView*)iv setFile:f];
            [(PFImageView*)iv loadInBackground];
        }
        [self addSubview:iv];
        [self.imageViews addObject:iv];
    }else{
        for (int i=0;i<files.count;i++) {
            PFFile* f = thumbnails[i];
            if (![f isDataAvailable]) {
                f = files[i];
                if (![f isDataAvailable]) {
                    f = thumbnails[i];
                }
            }
            UIImageView* iv;
            if ([f isDataAvailable]) {
                UIImage* image = [UIImage imageWithData:[f getData]];
                iv = [[UIImageView alloc] initWithImage:image];
            }else{
                iv = [[PFImageView alloc] initWithImage:[UIImage imageNamed:@"placeholderImage"]];
                [(PFImageView*)iv setFile:f];
                [(PFImageView*)iv loadInBackground];
            }
            [self addSubview:iv];
            [self.imageViews addObject:iv];
        }
    }
}

//different from setHidden
//a hidden view will still occupy the frame,
//but a not visible view will have a height of 0
//if self is set to visible, then caller is still responsible for
//setting the height of the view

- (NSMutableArray*) getImageViews {
    return self.imageViews;
}
@end
