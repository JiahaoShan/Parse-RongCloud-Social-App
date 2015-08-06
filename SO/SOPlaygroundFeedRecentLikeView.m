//
//  SOPlaygroundFeedRecentLikeView.m
//  SO
//
//  Created by Guanqing Yan on 8/5/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedRecentLikeView.h"
@interface SOPlaygroundFeedRecentLikeView()
@property (nonatomic,strong) NSArray* _likes;//array of recently liked users
@property (nonatomic) int likeCount;//total count
@property (nonatomic,strong) UITextRange* promptRange;
@property (nonatomic,strong) NSMutableArray* nameRanges;
@property (nonatomic,strong) UITapGestureRecognizer* tap;
@property (nonatomic,strong) PlaygroundFeed* feed;
@end

@implementation SOPlaygroundFeedRecentLikeView
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setScrollEnabled:false];
    [self setEditable:false];
    [self setSelectable:false];
    self.tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:self.tap];
    self.nameRanges = [[NSMutableArray alloc] init];
}

-(CGFloat)setLikes:(NSArray*)likes totalCount:(int)totalCount feed:(PlaygroundFeed*)feed width:(CGFloat)width{
    NSAssert(feed, @"feed is nil");
    NSAssert(likes.count<=totalCount, @"count eror");
    self.feed = feed;
    
    if (likes.count==0) {
        return 0;
    }
    
    NSMutableAttributedString* likeString = [[NSMutableAttributedString alloc] init];
    
    int count = (int)likes.count;
    for (int i=0; i<count; i++) {
        User* user = likes[i];
        NSString* name = [user username];
        
        UITextPosition *beginning = self.beginningOfDocument;
        UITextPosition *start = [self positionFromPosition:beginning offset:name.length];
        
        [likeString appendAttributedString:[[NSAttributedString alloc] initWithString:name attributes:@{NSForegroundColorAttributeName:[SOUICommons activeButtonColor]}]];
        
        UITextPosition *end = [self positionFromPosition:start offset:user.username.length];
        UITextRange *textRange = [self textRangeFromPosition:start toPosition:end];
        [self.nameRanges addObject:textRange];
        
        if (i!=count-1) {
            [likeString appendAttributedString:[[NSAttributedString alloc] initWithString:@", "]];
        }
        else{
            [likeString appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
        }
    }
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *start = [self positionFromPosition:beginning offset:likeString.length];
    NSString* prompt;
    if (totalCount>likes.count) {
        prompt = [NSString stringWithFormat:@"等%d人都觉得这个挺牛逼的",totalCount];
    }else{
        prompt = @"觉得这个挺牛逼的";
    }
    [likeString appendAttributedString:[[NSAttributedString alloc] initWithString:prompt attributes:@{NSForegroundColorAttributeName:[SOUICommons activeButtonColor]}]];
    UITextPosition *end = [self positionFromPosition:start offset:prompt.length];
    self.promptRange = [self textRangeFromPosition:start toPosition:end];
    self.attributedText = likeString;
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
                [self.soDelegate userDidTapNameOfUser:self._likes[i]];
            }
            return;
        }
    }
}
@end
