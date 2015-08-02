//
//  SOPlaygroundFeedCommentPreviewView.m
//  SO
//
//  Created by Guanqing Yan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedCommentPreviewView.h"
#import "SOUICommons.h"

@interface SOPlaygroundFeedCommentPreviewView()
@property (nonatomic,strong) NSArray* _comments;//visible comments
@property (nonatomic) int commentCount;//total count
@property (nonatomic,strong) UITextRange* promptRange;
@property (nonatomic,strong) NSMutableArray* nameRanges;
@property (nonatomic,strong) UITapGestureRecognizer* tap;
@property (nonatomic,strong) PlaygroundFeed* feed;
@end

@implementation SOPlaygroundFeedCommentPreviewView
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setScrollEnabled:false];
    [self setEditable:false];
    [self setSelectable:false];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:self.tap];
    self.nameRanges = [[NSMutableArray alloc] init];
}

-(CGFloat)setComments:(NSArray*)comments totalCount:(int)totalCount feed:(PlaygroundFeed*)feed width:(CGFloat)width{
    NSAssert(feed, @"feed is nil");
    self.feed = feed;
    
    NSMutableAttributedString* commentString = [[NSMutableAttributedString alloc] init];
    if (totalCount>comments.count) {
        UITextPosition *beginning = self.beginningOfDocument;
        UITextPosition *start = [self positionFromPosition:beginning offset:commentString.length];
        NSString* prompt = [NSString stringWithFormat:@"查看全部%d条评论>>>\n",totalCount];
        [commentString appendAttributedString:[[NSAttributedString alloc] initWithString:prompt attributes:@{NSForegroundColorAttributeName:[SOUICommons activeButtonColor]}]];
        UITextPosition *end = [self positionFromPosition:start offset:prompt.length];
        self.promptRange = [self textRangeFromPosition:start toPosition:end];
    }
    
    int count = (int)comments.count;
    for (int i=0; i<count; i++) {
        NSDictionary* dic = comments[i];
        User* user = dic[kSOPlaygroundFeedCommentPreviewViewUserKey];
        NSString* message = dic[kSOPlaygroundFeedCommentPreviewViewMessageKey];
        
        UITextPosition *beginning = self.beginningOfDocument;
        UITextPosition *start = [self positionFromPosition:beginning offset:commentString.length];
        
        [commentString appendAttributedString:[[NSAttributedString alloc] initWithString:user.username attributes:@{NSForegroundColorAttributeName:[SOUICommons activeButtonColor]}]];
        
        UITextPosition *end = [self positionFromPosition:start offset:user.username.length];
        UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
        [self.nameRanges addObject:textRange];
        
        [commentString appendAttributedString:[[NSAttributedString alloc] initWithString:@": "]];
        [commentString appendAttributedString:[[NSAttributedString alloc] initWithString:message]];
        if (i!=count-1) {
            [commentString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
    }
    self.attributedText = commentString;
    CGSize size = [self sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    return size.height;
}

-(void)didTap:(UITapGestureRecognizer*)tap{
    CGPoint p = [tap locationInView:self];
    
    CGRect promptRect = [self firstRectForRange:self.promptRange];
    if (CGRectContainsPoint(promptRect, p)) {
        if ([(NSObject*)self.soDelegate respondsToSelector:@selector(userDidTapViewAllCommentForFeed:)]) {
            [self.soDelegate userDidTapViewAllCommentForFeed:self.feed];
        }
        return;
    }
    
    for (int i=0;i<self.nameRanges.count;i++) {
        UITextRange* range = self.nameRanges[i];
        CGRect rect = [self firstRectForRange:range];
        if (CGRectContainsPoint(rect, p)) {
            if ([(NSObject*)self.soDelegate respondsToSelector:@selector(userDidTapNameOfUser:)]) {
                [self.soDelegate userDidTapNameOfUser:self._comments[i][kSOPlaygroundFeedCommentPreviewViewUserKey]];
            }
            return;
        }
    }
}

@end
