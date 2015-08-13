//
//  SOPlaygroundFeedLikeView.m
//  SO
//
//  Created by Guanqing Yan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedLikeView.h"
@interface SOPlaygroundFeedLikeView()
@property (nonatomic,strong) UIImageView* redView; //red heart
@property (nonatomic,strong) UIImageView* grayView; //gray heart
@property (nonatomic,strong) UILabel* countLabel;
@property (nonatomic,strong) UITapGestureRecognizer* tap;
@end

@implementation SOPlaygroundFeedLikeView

-(void)awakeFromNib{
    self.redView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [self.redView setImage:[UIImage imageNamed:@"like"]];
    self.grayView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [self.grayView setImage:[UIImage imageNamed:@"like_gray"]];
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 56, 24)];
    [self.countLabel setAdjustsFontSizeToFitWidth:true];
    [self.countLabel setMinimumScaleFactor:0.5];
    [self addSubview:self.countLabel];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleLike:)];
    [self addGestureRecognizer:self.tap];
}

-(void)setLiked:(BOOL)liked{
    [self setLiked:liked animated:NO];
}
-(void)setLiked:(BOOL)liked animated:(BOOL)animated{
    _liked = liked;
    if (animated) {
        [self.tap setEnabled:false];
        if (self.liked) {
            self.redView.alpha = 0;
            [UIView animateWithDuration:0.2 animations:^{
                [self addSubview:self.redView];
                self.grayView.frame = CGRectInset(self.grayView.frame, -12, -12);
                self.grayView.alpha = 0;
                self.redView.alpha = 1;
            } completion:^(BOOL finished) {
                self.grayView.frame = CGRectMake(0, 0, 24, 24);
                [self.grayView removeFromSuperview];
                [self.tap setEnabled:true];
            }];
        }
        else{
            
            self.grayView.alpha = 0;
            [UIView animateWithDuration:0.2 animations:^{
                [self addSubview:self.grayView];
                self.redView.frame = CGRectInset(self.redView.frame, -12, -12);
                self.redView.alpha = 0;
                self.grayView.alpha = 1;
            } completion:^(BOOL finished) {
                self.redView.frame = CGRectMake(0, 0, 24, 24);
                [self.redView removeFromSuperview];
                [self.tap setEnabled:true];
            }];
        }
    }else{
        if (liked) {
            self.redView.alpha = 1;
            [self addSubview:self.redView];
            [self.grayView removeFromSuperview];
        }else{
            self.grayView.alpha = 1;
            [self addSubview:self.grayView];
            [self.redView removeFromSuperview];
        }
    }
}

-(void)setCount:(int)count{
    _count = count;
    [self.countLabel setText:[NSString stringWithFormat:@" %d",count]];
}

-(void)toggleLike:(UIGestureRecognizer*)tap{
    BOOL oldValue = self.liked;
    [self setLiked:!oldValue animated:true];
    
    SOFailableAction* action = [[SOFailableAction alloc] initWithSucceed:NULL failed:^{
        [self setLiked:oldValue animated:false];
    }];
    if ([(NSObject*)self.delegate respondsToSelector:@selector(feed:didChangeLikeStatusTo:action:)]) {
        [self.delegate feed:self.feed didChangeLikeStatusTo:self.liked action:action];
    }
}

@end
