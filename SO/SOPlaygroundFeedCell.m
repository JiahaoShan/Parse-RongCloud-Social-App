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
#import "SOPlaygroundFeedResponseView.h"
#import "SOPlaygroundFeedActionGroupView.h"
#import "SOUICommons.h"
#import <ParseUI/ParseUI.h>
#import "User.h"
#import "TTTAttributedLabel.h"
#import "PlaygroundComment.h"

@interface SOPlaygroundFeedCell()<SOPlaygroundFeedImageViewDelegate>
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedGenderView *feedGenderView;
@property (weak, nonatomic) IBOutlet UILabel *feedPosterNameView;
@property (weak, nonatomic) IBOutlet UILabel *feedPostedTimeLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *feedTextView;
@property (weak, nonatomic) IBOutlet PFImageView* feedPosterAvatartView;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedActionGroupView *actionGroupView;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedResponseView *commentPreviewView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedImageView *feedImageView;
@property (nonatomic) PlaygroundFeed* feed;
@end

@implementation SOPlaygroundFeedCell

-(void)awakeFromNib {
    self.feedPosterAvatartView.layer.masksToBounds = YES;
    //self.feedPosterAvatartView.layer.cornerRadius = 15;
}

-(void)configureWithFeed:(PlaygroundFeed*)data{
    self.feed = data;
    User* user = data.poster;
    [user fetchIfNeeded];
    
    if ([user male]) {
        [self.feedGenderView setGender:kSOGenderMale];
    }else{
        [self.feedGenderView setGender:kSOGenderFemale];
    }
    
    [self.feedPosterNameView setText:user.username];
    [self.feedPosterAvatartView setFile:user.portraitThumbnail];
    [self.feedPosterAvatartView loadInBackground];
    
    [self.feedTextView setNumberOfLines:0];
    [self.feedTextView setPreferredMaxLayoutWidth:[SOUICommons screenWidth]-36];//36 is the final width of the the textfield
    [self.feedTextView setText:data.text];
    [self.feedTextView layoutIfNeeded];
    
    //time label
    [self.feedPostedTimeLabel setText:[SOUICommons descriptionForDate:data.createdAt]];
    
    //like/comment
    [self.actionGroupView setLiked:[data liked]];
    [self.actionGroupView setFeed:data];
    [self.actionGroupView setDelegate:self.mainController];
    
    //commentPreviewView
    [self.commentPreviewView setFeed:data width:[SOUICommons screenWidth] soDelegate:self.mainController];
    [self.commentPreviewView invalidateIntrinsicContentSize];
    
    //feed image view
        [self.feedImageView setImagesWithThumbNails:data.thumbnails files:data.images];
        self.feedImageView.clipsToBounds=true;
        self.feedImageView.delegate = self;
    [self.feedImageView invalidateIntrinsicContentSize];
    
    //feed delete button
    if ([[PFUser currentUser].objectId isEqualToString:user.objectId]) {
        self.deleteButton.hidden=false;
        [self.deleteButton addTarget:self action:@selector(feedDeleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.deleteButton.hidden=true;
        [self.deleteButton removeTarget:self action:@selector(feedDeleteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)feedDeleteButtonTapped:(UIButton*)b{
    [self.mainController didTapDeleteFeed:self.feed];
}

-(void)didTapImageAtIndex:(NSUInteger)index{
    [self.mainController cell:self didTapImageAtIndex:index];
}

- (NSMutableArray*) getFeedImageViews {
    return self.feedImageView.getImageViews;
}
@end
