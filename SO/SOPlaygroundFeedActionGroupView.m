//
//  SOPlaygroundFeedLikeView.m
//  SO
//
//  Created by Guanqing Yan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedActionGroupView.h"
#import "SOUICommons.h"

@interface SOPlaygroundFeedActionGroupView()
@property (nonatomic,strong) UIButton* likedButton;
@property (nonatomic,strong) UIButton* notLikedButton;
@property (nonatomic,strong) UIButton* commentButton;

@property (nonatomic,strong) UITapGestureRecognizer* tap;
@end

@implementation SOPlaygroundFeedActionGroupView

-(void)awakeFromNib{
    self.likedButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, 76, 16)];
    [self.likedButton setImage:[SOUICommons likeRedImage] forState:UIControlStateNormal];
    [self.likedButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.likedButton setTitle:@"  喜欢  " forState:UIControlStateNormal];
    [[self.likedButton titleLabel] setFont:[UIFont systemFontOfSize:12]];
    [self.likedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.notLikedButton = [[UIButton alloc] initWithFrame:CGRectMake(4, 4, 76, 16)];
    [self.notLikedButton setImage:[SOUICommons likeGrayImage] forState:UIControlStateNormal];
    [self.notLikedButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.notLikedButton setTitle:@"  取消  " forState:UIControlStateNormal];
    [[self.notLikedButton titleLabel] setFont:[UIFont systemFontOfSize:12]];
    [self.notLikedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.likedButton addTarget:self action:@selector(toggleLike:) forControlEvents:UIControlEventTouchUpInside];
    [self.notLikedButton addTarget:self action:@selector(toggleLike:) forControlEvents:UIControlEventTouchUpInside];
    
    self.commentButton = [[UIButton alloc] initWithFrame:CGRectMake(80, 4,76, 16)];
    [self.commentButton setImage:[SOUICommons feedCommentImage] forState:UIControlStateNormal];
    [self.commentButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.commentButton addTarget:self action:@selector(commentTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.commentButton setTitle:@"  评论  " forState:UIControlStateNormal];
    [[self.commentButton titleLabel] setFont:[UIFont systemFontOfSize:12]];
    [self.commentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self addSubview:self.commentButton];
    
    self.backgroundColor = [SOUICommons lightBackgroundGray];
    self.layer.cornerRadius = 4;
}

-(void)setLiked:(BOOL)liked{
    [self setLiked:liked animated:NO completion:NULL];
}
-(void)setLiked:(BOOL)liked animated:(BOOL)animated{
    [self setLiked:liked animated:animated completion:NULL];
}

-(void)setLiked:(BOOL)liked animated:(BOOL)animated completion:(SOplaygroundFeedActionGroupCompletion)completion{
    _liked = liked;
    if (animated) {
        [self.tap setEnabled:false];
        if (self.liked) {
            self.likedButton.alpha = 0;
            [UIView animateWithDuration:0.2 animations:^{
                [self addSubview:self.likedButton];
                [self.notLikedButton setTransform:CGAffineTransformScale(self.notLikedButton.transform, 2, 2)];
                self.notLikedButton.alpha = 0;
                self.likedButton.alpha = 1;
            } completion:^(BOOL finished) {
                [self.notLikedButton setTransform:CGAffineTransformIdentity];
                [self.notLikedButton removeFromSuperview];
                [self.tap setEnabled:true];
                if (completion) {
                    completion();
                }
            }];
        }
        else{
            self.notLikedButton.alpha = 0;
            [UIView animateWithDuration:0.2 animations:^{
                [self addSubview:self.notLikedButton];
                [self.likedButton setTransform:CGAffineTransformScale(self.notLikedButton.transform, 2, 2)];
                self.likedButton.alpha = 0;
                self.notLikedButton.alpha = 1;
            } completion:^(BOOL finished) {
                [self.likedButton setTransform:CGAffineTransformIdentity];
                [self.likedButton removeFromSuperview];
                [self.tap setEnabled:true];
                if (completion) {
                    completion();
                }
            }];
        }
    }else{
        if (liked) {
            self.likedButton.alpha = 1;
            [self addSubview:self.likedButton];
            [self.notLikedButton removeFromSuperview];
        }else{
            self.notLikedButton.alpha = 1;
            [self addSubview:self.notLikedButton];
            [self.likedButton removeFromSuperview];
        }
        if (completion) {
            completion();
        }
    }
}

-(void)toggleLike:(UIButton*)tap{
    BOOL oldValue = self.liked;
    SOFailableAction* action = [[SOFailableAction alloc] initWithSucceed:NULL failed:^{
        [self setLiked:oldValue animated:false];
    }];
    __weak typeof(self) wSelf = self;
    [self setLiked:!oldValue animated:true completion:^{
        if ([(NSObject*)wSelf.delegate respondsToSelector:@selector(feed:didChangeLikeStatusTo:action:)]) {
            [wSelf.delegate feed:wSelf.feed didChangeLikeStatusTo:wSelf.liked action:action];
        }
    }];
}

-(void)commentTapped:(UIButton*)b{
    if ([(NSObject*)self.delegate respondsToSelector:@selector(userDidWishComment:)]) {
        [self.delegate userDidWishComment:self.feed];
    }
}

-(CGSize)intrinsicContentSize{
    return CGSizeMake(160, 24);
}

@end
