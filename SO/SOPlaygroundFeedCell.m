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
#import "PlaygroundComment.h"

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
    self.feedPosterAvatartView.layer.cornerRadius = 30;
}

-(void)configureWithFeed:(PlaygroundFeed*)data{
    User* user = data.poster;
    [user fetchIfNeeded];
    CGFloat h1 = [self.feedImageView setImagesWithFiles:data.images];
    self.feedImageView.delegate = self;
    [self.feedImageViewHeightConstraint setConstant:h1];
    
    [self.feedGenderView setGender:kSOGenderNotSpecified];
    
    [self.feedPosterNameView setText:user.username];
    
    [self.feedPosterAvatartView setFile:user.portraitThumbnail];
    [self.feedPosterAvatartView loadInBackground];
    
    [self.feedTextView setText:data.text];
    CGSize size = [self.feedTextView sizeThatFits:CGSizeMake([SOUICommons screenWidth]-32, CGFLOAT_MAX)];//-32 might depend on screen scale
    [self.feedTextViewHeightConstraint setConstant:size.height+1];//ios bug
    [self.feedPostedTimeLabel setText:[SOUICommons descriptionForDate:data.createdAt]];
    
    [self.feedLikeView setLiked:false];
    [self.feedLikeView setCount:8927];
    
    NSMutableArray* commentPreviewArr = [[NSMutableArray alloc] init];
    if (data.latestComment) {
        PlaygroundComment* c = data.latestComment;
        [c fetchIfNeeded];
        [commentPreviewArr addObject:@{kSOPlaygroundFeedCommentPreviewViewUserKey:c.commentOwner,kSOPlaygroundFeedCommentPreviewViewMessageKey:c.message}];
    }
    if (data.firstComment) {
        PlaygroundComment* c = data.firstComment;
        [c fetchIfNeeded];
        [commentPreviewArr addObject:@{kSOPlaygroundFeedCommentPreviewViewUserKey:c.commentOwner,kSOPlaygroundFeedCommentPreviewViewMessageKey:c.message}];
    }
    CGFloat h2 = [self.commentPreviewView setComments:commentPreviewArr totalCount:[data.commentCount intValue] feed:data width:[SOUICommons screenWidth]];
    self.commentPreviewViewHeightConstraint.constant = h2;
}

-(void)didTapImageAtIndex:(NSUInteger)index{
    [self.delegate cell:self didTapImageAtIndex:index];
}

- (NSMutableArray*) getFeedImageViews {
    return self.feedImageView.getImageViews;
}
@end
