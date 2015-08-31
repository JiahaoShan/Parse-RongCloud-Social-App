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
@property (weak, nonatomic) IBOutlet UILabel *recentLikeView;
@property (weak, nonatomic) IBOutlet PFImageView* feedPosterAvatartView;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedActionGroupView *actionGroupView;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedCommentPreviewView *commentPreviewView;
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
    
    //recent like view
    if (data.recentLikeUsers.count>0 || [data.likeCount integerValue]>0) {
        [self.recentLikeView setNumberOfLines:0];
        NSMutableString* likeString = [[NSMutableString alloc] init];
        NSMutableArray* likeNameRanges = [NSMutableArray array];
        for (int i=0; i<data.recentLikeUsers.count; i++) {
            User* liker = data.recentLikeUsers[i];
            [liker fetchIfNeeded];
            if (i!=data.recentLikeUsers.count-1) {
                [likeNameRanges addObject:[NSValue valueWithRange:NSMakeRange(likeString.length, liker.username.length)]];
                [likeString appendFormat:@"%@, ",liker.username];
            }
            else{
                [likeNameRanges addObject:[NSValue valueWithRange:NSMakeRange(likeString.length, liker.username.length)]];
                [likeString appendFormat:@"%@ ",liker.username];
            }
        }
        if ([data.likeCount integerValue] > data.recentLikeUsers.count) {
            [likeString appendFormat:@"等%ld个人",(long)[data.likeCount integerValue]];
        }
        [likeString appendFormat:@"觉得这个好厉害的"];
        [self.recentLikeView setText:likeString];
        [self.recentLikeView setPreferredMaxLayoutWidth:[SOUICommons screenWidth]-36];
    }
    else{
        [self.recentLikeView setText:@""];
    }
    
    //commentPreviewView
    [self.commentPreviewView setComments:data.recentComments totalCount:[data.commentCount intValue] feed:data width:[SOUICommons screenWidth] soDelegate:self.mainController];
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
