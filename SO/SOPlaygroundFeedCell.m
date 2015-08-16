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
#import "SOPlaygroundFeedActionGroupView.h"
#import "SOPlaygroundFeedRecentLikeView.h"
#import "SOUICommons.h"
#import <ParseUI/ParseUI.h>
#import "User.h"
#import "PlaygroundComment.h"

@interface SOPlaygroundFeedCell()<SOPlaygroundFeedImageViewDelegate>
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedGenderView *feedGenderView;
@property (weak, nonatomic) IBOutlet UILabel *feedPosterNameView;
@property (weak, nonatomic) IBOutlet UILabel *feedPostedTimeLabel;
@property (weak, nonatomic) IBOutlet PFImageView* feedPosterAvatartView;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedActionGroupView *actionGroupView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *feedTextViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITextView *feedTextView;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedRecentLikeView *recentLikeView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *recentLikeViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentPreviewViewHeightConstraint;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedCommentPreviewView *commentPreviewView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *feedImageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedImageView *feedImageView;
@end

@implementation SOPlaygroundFeedCell

-(void)awakeFromNib {
    self.feedPosterAvatartView.layer.masksToBounds = YES;
    self.feedPosterAvatartView.layer.cornerRadius = 30;
}

-(void)configureWithFeed:(PlaygroundFeed*)data{
    User* user = data.poster;
    [user fetchIfNeeded];
    
    CGFloat h1 = [self.feedImageView setImagesWithFiles:data.images];
    self.feedImageView.delegate = self;
    [self.feedImageViewHeightConstraint setConstant:h1];
    
    if ([user male]) {
        [self.feedGenderView setGender:kSOGenderMale];
    }else{
        [self.feedGenderView setGender:kSOGenderFemale];
    }
    
    [self.feedPosterNameView setText:user.username];
    
    [self.feedPosterAvatartView setFile:user.portraitThumbnail];
    [self.feedPosterAvatartView loadInBackground];
    
    [self.feedTextView setText:data.text];
    CGSize size = [self.feedTextView sizeThatFits:CGSizeMake([SOUICommons screenWidth]-32, CGFLOAT_MAX)];//-32 might depend on screen scale
    [self.feedTextViewHeightConstraint setConstant:size.height+1];//ios bug
    [self.feedPostedTimeLabel setText:[SOUICommons descriptionForDate:data.createdAt]];
    
    [self.actionGroupView setLiked:[data liked]];
    [self.actionGroupView setFeed:data];
    [self.actionGroupView setDelegate:self.mainController];
    
    //recent like view
    [self.recentLikeView setHeightConstraint:self.recentLikeViewHeightConstraint];
    [self.recentLikeView setLikes:[data recentLikeUsers] totalCount:[[data likeCount] intValue] feed:data width:[SOUICommons screenWidth]-16];
    [self.recentLikeView setSoDelegate:self.mainController];
    
    //commentPreviewView
    CGFloat h3 = [self.commentPreviewView setComments:data.recentComments totalCount:[data.commentCount intValue] feed:data width:[SOUICommons screenWidth]-16 soDelegate:self.mainController];
    self.commentPreviewViewHeightConstraint.constant = h3;
}

-(void)didTapImageAtIndex:(NSUInteger)index{
    [self.delegate cell:self didTapImageAtIndex:index];
}

- (NSMutableArray*) getFeedImageViews {
    return self.feedImageView.getImageViews;
}
@end
