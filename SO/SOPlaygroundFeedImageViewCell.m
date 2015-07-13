//
//  SOPlaygroundFeedImageViewCell.m
//  SO
//
//  Created by Guanqing Yan on 7/14/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedImageViewCell.h"

@implementation SOPlaygroundFeedImageViewCell
-(UIImageView*)imageView{
    if(!_imageView){
        _imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    return _imageView;
}
-(void)layoutSubviews{
    self.imageView.frame = self.bounds;
}
@end
