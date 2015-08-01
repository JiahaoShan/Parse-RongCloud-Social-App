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
#import "SOPlaygroundLikeButton.h"
#import "SOPlaygroundFeedCommentCell.h"
#import <ParseUI/ParseUI.h>
#import "SOUICommons.h"

#import "User.h"
#import "PlaygroundComment.h"

#define kCommentHeight 20
#define kPaddingHeight 10

@interface SOPlaygroundFeedCell()<SOPlaygroundFeedImageViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedGenderView *feedGenderView;
@property (weak, nonatomic) IBOutlet UILabel *feedPosterNameView;
@property (weak, nonatomic) IBOutlet UILabel *feedPostedTimeLabel;
@property (weak, nonatomic) IBOutlet PFImageView* feedPosterAvatartView;
@property (weak, nonatomic) IBOutlet UITextView *feedTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *feedCommentTableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *feedCommentTableView;
@property (weak, nonatomic) IBOutlet SOPlaygroundLikeButton *feedLikeButton;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedImageView *feedImageView;
@end

@implementation SOPlaygroundFeedCell

+(CGFloat)estimatedHeightForData:(PFObject*)data{
    return 60 +
    16 +
    48 +
    16 +
    24 +
    [SOPlaygroundFeedImageView estimatedHeightForImages:[data objectForKey:@"images"]] +
    [self heightForText:[data objectForKey:@"text"]] +
    [self heightForCommentCount:3] +
    kPaddingHeight;
}

+ (CGFloat)heightForText:(NSString *)text
{
    UIFont* font = [UIFont systemFontOfSize:14];
    CGSize size = CGSizeMake([SOUICommons screenWidth]-16, FLT_MAX);
    CGRect frame = [text boundingRectWithSize:size
                                      options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
    return (frame.size.height - frame.origin.y)*0.75;
}

+(CGFloat)heightForCommentCount:(NSInteger)count{
    if (count>3) {
        return 3*kCommentHeight;
    }
    else{
        return count*kCommentHeight;
    }
}

-(void)awakeFromNib {
    self.feedPosterAvatartView.layer.masksToBounds = YES;
    self.feedPosterAvatartView.layer.cornerRadius = self.feedPosterAvatartView.frame.size.width / 2;
    self.feedCommentTableView.dataSource = self;
    self.feedCommentTableView.delegate = self;
    [self.feedCommentTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

-(void)configureWithData:(PFObject*)data{
    User* user = [data objectForKey:@"poster"];
    [user fetchIfNeeded];
    [self.feedImageView setImages:[data objectForKey:@"images"]];
    
    [self.feedGenderView setGender:kSOGenderNotSpecified];
    
    [self.feedPosterNameView setText:user[@"username"]];
    
    [self.feedPosterAvatartView setFile:user[@"portraitThumbnail"]];
    [self.feedPosterAvatartView loadInBackground];
    
    [self.feedTextView setText:[data objectForKey:@"text"]];
    [self.feedPostedTimeLabel setText:[[data updatedAt] description]];
    
    [self.feedLikeButton setLike:false];
    [self.feedLikeButton setCount:453];
    
    [self.feedCommentTableViewHeightConstraint setConstant:[SOPlaygroundFeedCell heightForCommentCount:4]];
    [self.feedCommentTableView reloadData];
}

-(void)didTapImageAtIndex:(NSUInteger)index{
    [self.delegate cell:self didTapImageAtIndex:index];
}

- (NSMutableArray*) getFeedImageViews {
    return self.feedImageView.getImageViews;
}

#pragma mark tableViewDataSource & delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    [SOPlaygroundFeedCommentCell heightForCommentCellForComment:<#(PlaygroundComment *)#>]
//    return kCommentHeight;
//}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"commentCell"];
    }
    [[cell imageView] setImage:[UIImage imageNamed:@"placeholderImage"]];
    [[cell textLabel] setText:@"WO"];
    return cell;
}
@end
