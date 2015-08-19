//
//  SOPlaygroundFeedCommentPreviewViewCell.m
//  SO
//
//  Created by Guanqing Yan on 8/9/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedCommentPreviewViewCell.h"
#import "SOPlaygroundFeedCommentPreviewView.h"
#import "SOUICommons.h"
#import "User.h"
@interface SOPlaygroundFeedCommentPreviewViewCell()
@property (nonatomic,strong) PlaygroundComment* comment;
@property (nonatomic,strong) UILabel* commentLabel;
@property (nonatomic,strong) UILabel* deleteLabel;
@property (nonatomic,strong) UITapGestureRecognizer* tap;
@end

@implementation SOPlaygroundFeedCommentPreviewViewCell
-(instancetype)initWithComment:(PlaygroundComment*)comment width:(CGFloat)width{
    self = [super init];
    self.comment = comment;
    NSLog(@"comment:%@ start fetching",comment);
    [self.comment fetchIfNeeded];
    //[self.comment fetchFromLocalDatastore];
    NSLog(@"fecthing finished");
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:self.tap];
    
    self.commentLabel = [[UILabel alloc] init];
    [self.commentLabel setFont:[UIFont systemFontOfSize:12]];
    [self.commentLabel setNumberOfLines:0];
    NSMutableAttributedString* str = [[NSMutableAttributedString alloc] init];
    User* commentOwner = [self.comment commentOwner];
    [commentOwner fetchIfNeeded];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[commentOwner username] attributes:@{NSForegroundColorAttributeName:[SOUICommons activeButtonColor]}]];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": %@",[comment message]]]];
    [self.commentLabel setAttributedText:str];
    CGSize fitSize = [self.commentLabel textRectForBounds:CGRectMake(0, 0, width-16, CGFLOAT_MAX) limitedToNumberOfLines:0].size;
    [self.commentLabel setFrame:CGRectMake(0, 0, fitSize.width+1, fitSize.height+1)];
    [self.contentView addSubview:self.commentLabel];
    CGRect frame = self.frame;
    BOOL deletable = [[PFUser currentUser].objectId isEqualToString:commentOwner.objectId];
    //BOOL deletable = true;
    if (deletable) {
        NSRange lastRange = NSMakeRange(self.commentLabel.text.length-1,1);
        CGRect lastRect = [self boundingRectForCharacterRange:lastRange];
        CGFloat trailing = CGRectGetMaxX(lastRect);
        self.deleteLabel = [[UILabel alloc] init];
        [self.deleteLabel setFont:[UIFont systemFontOfSize:12]];
        [self.deleteLabel setText:@"删除"];
        [self.deleteLabel setTextColor:[SOUICommons activeButtonColor]];
        [self.deleteLabel sizeToFit];
        CGSize deleteButtonSize = [self.deleteLabel frame].size;
        if (width-trailing>deleteButtonSize.width) {
            //delete button in same line
            [self.deleteLabel setFrame:CGRectMake(width -16 - deleteButtonSize.width, CGRectGetMinY(lastRect), deleteButtonSize.width, deleteButtonSize.height)];
        }else{
            [self.deleteLabel setFrame:CGRectMake(0, CGRectGetMaxY(self.commentLabel.frame), deleteButtonSize.width, deleteButtonSize.height)];
        }
        [self.contentView addSubview:self.deleteLabel];
    }
    [self setFrame:CGRectMake(0, 0, frame.size.width, self.commentLabel.frame.size.height)];
    return self;
}

- (CGRect)boundingRectForCharacterRange:(NSRange)range
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:[[self commentLabel] text]];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:[self bounds].size];
    textContainer.lineFragmentPadding = 0;
    [layoutManager addTextContainer:textContainer];
    
    NSRange glyphRange;
    
    // Convert the range for glyphs.
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    
    return [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
}
-(void)tapped:(UITapGestureRecognizer*)tap{
    CGPoint p = [tap locationInView:self];
    CGRect nameRect = [self boundingRectForCharacterRange:NSMakeRange(0, [[[self.comment commentOwner] username] length])];
    if (CGRectContainsPoint(nameRect, p)) {
        NSLog(@"tapped Name");
        if ([[self delegate] respondsToSelector:@selector(userDidTapNameOfUser:)]) {
            [[self delegate] userDidTapNameOfUser:[self.comment commentOwner]];
            return;
        }
    }else if(CGRectContainsPoint(self.deleteLabel.frame, p)){
        if ([[self delegate] respondsToSelector:@selector(userDidTapDeleteComment:)]) {
            [self.delegate userDidTapDeleteComment:self.comment];
            return;
        }
    }
}

@end
