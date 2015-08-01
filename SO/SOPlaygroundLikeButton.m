//
//  SOPlaygroundLikeButton.m
//  SO
//
//  Created by Guanqing Yan on 8/1/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundLikeButton.h"
@interface SOPlaygroundLikeButton()
@property (nonatomic,strong) UIImageView* heartView;
@property (nonatomic,strong) UILabel* countLabel;
@property (nonatomic,strong) UITapGestureRecognizer* tap;
@end

@implementation SOPlaygroundLikeButton

-(void)awakeFromNib{
    self.heartView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(24, 0, 36, 24)];
    [self addSubview:self.heartView];
    [self addSubview:self.countLabel];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleLike:)];
    [self addGestureRecognizer:self.tap];
}

-(void)setLike:(BOOL)like{
    _like = like;
    if (self.like) {
        [self.heartView setImage:[UIImage imageNamed:@"like"]];
    }
    else{
        [self.heartView setImage:[UIImage imageNamed:@"like_gray"]];
    }
}

-(void)setCount:(int)count{
    _count = count;
    [self.countLabel setText:[NSString stringWithFormat:@"%d",count]];
}

-(void)toggleLike:(UIGestureRecognizer*)tap{
    [self setLike:!self.like];
    if ([(NSObject*)self.delegate respondsToSelector:@selector(likeButtonDidToggleToState:)]) {
        [self.delegate likeButtonDidToggleToState:self.like];
    }
}

@end
