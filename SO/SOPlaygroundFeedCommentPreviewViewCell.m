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
@interface SOPlaygroundFeedCommentPreviewViewCell()
@property (nonatomic,strong) PlaygroundComment* comment;
@property (nonatomic,strong) UILabel* commentLabel;
@property (nonatomic,strong) UILabel* deleteLabel;
@property (nonatomic,strong) UITapGestureRecognizer* tap;
@end

@implementation SOPlaygroundFeedCommentPreviewViewCell
-(instancetype)initWithComment:(PlaygroundComment*)comment deletable:(BOOL)deletable width:(CGFloat)width{
    self = [super init];
    self.comment = comment;
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:self.tap];
    
    self.commentLabel = [[UILabel alloc] init];
    [self.commentLabel setFont:[UIFont systemFontOfSize:12]];
    NSMutableAttributedString* str = [[NSMutableAttributedString alloc] init];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[[self.comment commentOwner] username] attributes:@{NSForegroundColorAttributeName:[SOUICommons activeButtonColor]}]];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": %@",[comment message]]]];
    [self.commentLabel setAttributedText:str];
    [self.commentLabel sizeToFit];
    [self.contentView addSubview:self.commentLabel];
    CGRect frame = self.frame;
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
        [self.deleteLabel setFrame:CGRectMake(self.bounds.size.width - deleteButtonSize.width, CGRectGetMinY(lastRect), deleteButtonSize.width, deleteButtonSize.height)];
    }else{
        [self.deleteLabel setFrame:CGRectMake(0, CGRectGetMaxY(self.commentLabel.frame), deleteButtonSize.width, deleteButtonSize.height)];
    }
    [self.contentView addSubview:self.deleteLabel];
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
