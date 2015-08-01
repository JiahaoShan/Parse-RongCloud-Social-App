//
//  SOPlaygroundLikeButton.h
//  SO
//
//  Created by Guanqing Yan on 8/1/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SOPlaygroundLikeButtonProtocol
-(void)likeButtonDidToggleToState:(BOOL)like;
@end

//size 24*60
@interface SOPlaygroundLikeButton : UIView
@property (nonatomic) BOOL like;
@property (nonatomic) int count;
@property (nonatomic, assign) id<SOPlaygroundLikeButtonProtocol> delegate;
@end
