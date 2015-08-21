//
//  SOPlaygroundFeedComposeImageView.h
//  SO
//
//  Created by Guanqing Yan on 8/21/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SODefines.h"
@protocol SOPlaygroundFeedComposeImageViewDelegate
-(void)didRequestMoreImage;
-(void)didChangeHeightTo:(CGFloat)height;
@end

@interface SOPlaygroundFeedComposeImageView : UIView
-(void)appendImages:(NSArray*)images;//returns new height don't append directly
//-(CGFloat)removeImage:(UIImage*)image;//returns new height
@property (nonatomic) NSInteger maxNumberOfImages;
@property (nonatomic) id<SOPlaygroundFeedComposeImageViewDelegate> delegate;
-(NSMutableArray*)images;
@end
