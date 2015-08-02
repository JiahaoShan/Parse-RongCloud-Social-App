//
//  SOPlaygroundFeedCell.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedCell.h"
#import "SOPlaygroundFeedImageView.h"
#import "SOPlaygroundFeedGenderView.h"
#import "SOPlaygroundFeedCommentPreviewView.h"
#import "SOPlaygroundFeedLikeView.h"
#import "SOUICommons.h"
#import <ParseUI/ParseUI.h>
#import "User.h"

@interface SOPlaygroundFeedCell()<SOPlaygroundFeedImageViewDelegate>
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedGenderView *feedGenderView;
@property (weak, nonatomic) IBOutlet UILabel *feedPosterNameView;
@property (weak, nonatomic) IBOutlet UILabel *feedPostedTimeLabel;
@property (weak, nonatomic) IBOutlet PFImageView* feedPosterAvatartView;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedLikeView *feedLikeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *feedTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *feedTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentPreviewViewHeightConstraint;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedCommentPreviewView *commentPreviewView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *feedImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedImageView *feedImageView;
@end

@implementation SOPlaygroundFeedCell

-(void)awakeFromNib {
    self.feedPosterAvatartView.layer.masksToBounds = YES;
    self.feedPosterAvatartView.layer.cornerRadius = self.feedPosterAvatartView.frame.size.width / 2;
}

-(void)configureWithFeed:(PlaygroundFeed*)data{
    User* user = [data objectForKey:@"poster"];
    [user fetchIfNeeded];
    CGFloat h1 = [self.feedImageView setImagesWithFiles:[data objectForKey:@"images"]];
    self.feedImageView.delegate = self;
    [self.feedImageViewHeightConstraint setConstant:h1];
    
    [self.feedGenderView setGender:kSOGenderNotSpecified];
    
    [self.feedPosterNameView setText:user[@"username"]];
    
    [self.feedPosterAvatartView setFile:user[@"portraitThumbnail"]];
    [self.feedPosterAvatartView loadInBackground];
    
    [self.feedTextView setText:[data objectForKey:@"text"]];
    CGSize size = [self.feedTextView sizeThatFits:CGSizeMake([SOUICommons screenWidth]-16, CGFLOAT_MAX)];
    [self.feedTextViewHeightConstraint setConstant:size.height];
    [self.feedPostedTimeLabel setText:[[data updatedAt] description]];
    
    [self.feedLikeView setLiked:false];
    [self.feedLikeView setCount:8927];
    
    CGFloat h2 = [self.commentPreviewView setComments:@[@{kSOPlaygroundFeedCommentPreviewViewUserKey:user,kSOPlaygroundFeedCommentPreviewViewMessageKey:@"哇塞碉堡了,刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕，刷爆你的屏幕"},@{kSOPlaygroundFeedCommentPreviewViewUserKey:user,kSOPlaygroundFeedCommentPreviewViewMessageKey:@"哇塞好牛逼"},
                                                        @{kSOPlaygroundFeedCommentPreviewViewUserKey:user,kSOPlaygroundFeedCommentPreviewViewMessageKey:@"哇塞超级棒"}] totalCount:23 feed:data width:[SOUICommons screenWidth]];
    self.commentPreviewViewHeightConstraint.constant = h2;
}

-(void)didTapImageAtIndex:(NSUInteger)index{
    [self.delegate cell:self didTapImageAtIndex:index];
}

- (NSMutableArray*) getFeedImageViews {
    return self.feedImageView.getImageViews;
}
@end
