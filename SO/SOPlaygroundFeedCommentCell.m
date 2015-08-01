//
//  SOPlaygroundFeedCommentCell.m
//  SO
//
//  Created by Guanqing Yan on 8/1/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedCommentCell.h"
#import "SOUICommons.h"

@interface SOPlaygroundFeedCommentCell()
@property (nonatomic) UITextView* commentTextView;
@end

@implementation SOPlaygroundFeedCommentCell
+(CGFloat)heightForCommentCellForComment:(PlaygroundComment*)comment{
    NSString* text = [NSString stringWithFormat:@"%@: %@",[[comment commentOwner] username],[comment message]];
    UIFont* font = [UIFont systemFontOfSize:14];
    CGSize size = CGSizeMake([SOUICommons screenWidth]-16, FLT_MAX);
    CGRect frame = [text boundingRectWithSize:size
                                      options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                   attributes:@{NSFontAttributeName:font}
                                      context:nil];
    CGFloat messageHeight = (frame.size.height - frame.origin.y)*0.75;
    return messageHeight + 12;
}

- (void)awakeFromNib {
    self.commentTextView = [[UITextView alloc] init];
}

-(void)loadComment:(PlaygroundComment*)comment{
    CGFloat screenWidth = [SOUICommons screenWidth];
    NSString* text = [NSString stringWithFormat:@"%@: %@",[[comment commentOwner] username],[comment message]];
    [self.commentTextView setText:text];
    [self.commentTextView setFont:[UIFont systemFontOfSize:14]];
    [self.commentTextView sizeToFit];
}

@end
