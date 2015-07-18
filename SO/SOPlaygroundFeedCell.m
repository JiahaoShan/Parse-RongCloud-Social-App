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
#import <ParseUI/ParseUI.h>

@interface SOPlaygroundFeedCell()<SOPlaygroundFeedImageViewDelegate>
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedGenderView *feedGenderView;
@property (weak, nonatomic) IBOutlet UILabel *feedPosterNameView;
@property (weak, nonatomic) IBOutlet UILabel *feedPostedTimeLabel;
@property (weak, nonatomic) IBOutlet PFImageView* feedPosterAvatartView;
@property (weak, nonatomic) IBOutlet UITextView *feedTextView;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedImageView *feedImageView;
@end

@implementation SOPlaygroundFeedCell

+(CGFloat)estimatedHeightForData:(PFObject*)data{
    return 60 + 16 + 48 + 16 + [SOPlaygroundFeedImageView estimatedHeightForImages:[data objectForKey:@"images"]] + [self heightForText:[data objectForKey:@"text"]];
}

+ (CGFloat)heightForText:(NSString *)text
{
    //    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    //    {
    UIFont* font = [UIFont systemFontOfSize:14];
    CGSize size = CGSizeMake([[UIScreen mainScreen] bounds].size.width-48, FLT_MAX);
    CGRect frame = [text boundingRectWithSize:size
                                      options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
    return (frame.size.height - frame.origin.y)*0.75;
//        }
//        else
//        {
//            return [text sizeWithFont:font constrainedToSize:size];
//        }
}

-(void)configureWithData:(PFObject*)data{
    PFUser* user = [data objectForKey:@"poster"];
    [self.feedImageView setImages:[data objectForKey:@"images"]];
    self.feedImageView.delegate = self;
    
    [self.feedGenderView setGender:kSOGenderNotSpecified];
    
    [self.feedPosterNameView setText:user[@"username"]];
    
    [self.feedPosterAvatartView setImage:[UIImage imageNamed:@"placeholderImage"]];
    [self.feedPosterAvatartView setFile:user[@"portraitThumbnail"]];
    [self.feedPosterAvatartView loadInBackground];
    
    [self.feedTextView setText:[data objectForKey:@"text"]];
    [self.feedPostedTimeLabel setText:[[data updatedAt] description]];
    
}

-(void)didTapImageAtIndex:(NSUInteger)index{
    [self.delegate cell:self didTapImageAtIndex:index];
}
@end
