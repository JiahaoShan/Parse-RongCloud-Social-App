//
//  SOMapBubbleChatRecordTableViewCell.m
//  SO
//
//  Created by Jiahao Shan on 8/24/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOMapBubbleChatRecordTableViewCell.h"
#import "SOUICommons.h"
#import <ParseUI/ParseUI.h>

@interface SOMapBubbleChatRecordTableViewCell()
@property (nonatomic,strong) UILabel* commentLabel;
@property (nonatomic,strong) UITapGestureRecognizer* tap;
@property (nonatomic,strong) RCTextMessage* message;
@property (nonatomic,strong) RCUserInfo* userInfo;
@end

@implementation SOMapBubbleChatRecordTableViewCell

-(void)configureWithMessage:(RCTextMessage*)message userInfo:(RCUserInfo*)userInfo width:(CGFloat)width{
        self.message = message;
        self.userInfo = userInfo;
        self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:self.tap];
        
        self.commentLabel = [[UILabel alloc] init];
        [self.commentLabel setFont:[UIFont systemFontOfSize:12]];
        [self.commentLabel setNumberOfLines:0];
        NSMutableAttributedString* str = [[NSMutableAttributedString alloc] init];
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:userInfo.name attributes:@{NSForegroundColorAttributeName:[SOUICommons activeButtonColor]}]];
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@": %@",message.content]]];
        [self.commentLabel setAttributedText:str];
        CGSize fitSize = [self.commentLabel textRectForBounds:CGRectMake(0, 0, width-16, CGFLOAT_MAX) limitedToNumberOfLines:0].size;
        [self.commentLabel setFrame:CGRectMake(0, 0, fitSize.width+1, fitSize.height+1)];
        [self.contentView addSubview:self.commentLabel];
        CGRect frame = self.frame;
        [self setFrame:CGRectMake(0, 0, frame.size.width, self.commentLabel.frame.size.height)];
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
    CGRect nameRect = [self boundingRectForCharacterRange:NSMakeRange(0, [self.userInfo.name length])];
    if (CGRectContainsPoint(nameRect, p)) {
        NSLog(@"tapped Name");
        if ([[self delegate] respondsToSelector:@selector(userDidTapNameOfUser:)]) {
            [[self delegate] userDidTapNameOfUser:self.userInfo];
            return;
        }
    }
}


@end
