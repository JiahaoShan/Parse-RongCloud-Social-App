//
//  SOPlaygroundFeedImageView.h
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SODefines.h"

#define kPlaygroundSingleImageHeight 150.0f

//if more than one image, each image is cropped as square
#define kPlaygroundMultipleImageSize 70.0f

@protocol SOPlaygroundFeedImageViewDelegate
//called when user tap an image, the image itself is provided(though it can still be nil)
//the url is also included for downloading high resolution images is user prefers
@required
-(void)didTapImage:(UIImage*)image url:(SOImageURL*)url;
@end

@interface SOPlaygroundFeedImageView : UIView
//if passed only 1 url, the view shows a large image
//if passed more than 1 url, the view shows a few thubmnail images
//however, thumbnail messages should still be provided
//expected an array of SOImageURL object
-(void)setImages:(NSArray*)urls;
@end
