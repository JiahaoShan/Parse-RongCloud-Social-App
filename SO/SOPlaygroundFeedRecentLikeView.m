//
//  SOPlaygroundFeedRecentLikeView.m
//  SO
//
//  Created by Guanqing Yan on 8/5/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedRecentLikeView.h"
@interface SOPlaygroundFeedRecentLikeView()
@property (nonatomic,strong) NSMutableArray* _likes;//array of recently liked users
@property (nonatomic) int likeCount;//total count
@property (nonatomic,strong) UITextRange* promptRange;
@property (nonatomic,strong) NSMutableArray* nameRanges;
@property (nonatomic,strong) UITapGestureRecognizer* tap;
@property (nonatomic,strong) PlaygroundFeed* feed;
@property (nonatomic) CGFloat width; //saves the width that is passed in
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

-(void)setLikes:(NSArray*)likes totalCount:(int)totalCount feed:(PlaygroundFeed*)feed width:(CGFloat)width{
    NSAssert(feed, @"feed is nil");
    NSAssert(likes.count<=totalCount, @"count more than total");
    
    if (likes!=self._likes) {
        self._likes = [NSMutableArray arrayWithArray:likes];
    }
    self.likeCount = totalCount;
    self.feed = feed;
    self.width = width;
    [self.nameRanges removeAllObjects];
    
    if (likes.count==0) {
        [self.heightConstraint setConstant:0];
        return;
    }
    
    NSMutableAttributedString* likeString = [[NSMutableAttributedString alloc] init];
    NSMutableArray* ranges = [NSMutableArray array];
    NSRange promptRange;
    int count = (int)likes.count;
    for (int i=0; i<count; i++) {
        User* user = likes[i];
        [user fetchIfNeeded];
        NSString* name = [user username];
        
        [ranges addObject:[NSValue valueWithRange:NSMakeRange(likeString.length, name.length)]];
        [likeString appendAttributedString:[[NSAttributedString alloc] initWithString:name attributes:@{NSForegroundColorAttributeName:[SOUICommons activeButtonColor]}]];
        
        if (i!=count-1) {
            [likeString appendAttributedString:[[NSAttributedString alloc] initWithString:@", "]];
        }
    }
    NSString* prompt;
    if (totalCount>likes.count) {
        prompt = [NSString stringWithFormat:@" 等%d人都觉得这个挺牛逼的",totalCount];
    }else{
        prompt = @" 觉得这个挺牛逼的";
    }
    promptRange = NSMakeRange(likeString.length, prompt.length);
    [likeString appendAttributedString:[[NSAttributedString alloc] initWithString:prompt attributes:@{NSForegroundColorAttributeName:[SOUICommons descriptiveTextColor]}]];
    self.attributedText = likeString;//need to be there for positions to be calculate
    
    UITextPosition *beginning = [self beginningOfDocument];
    for (NSValue* v in ranges) {\
        NSRange r = [v rangeValue];
        UITextPosition *start = [self positionFromPosition:beginning offset:r.location];
        UITextPosition *end = [self positionFromPosition:start offset:r.length];
        [self.nameRanges addObject:[self textRangeFromPosition:start toPosition:end]];
    }
    UITextPosition *start = [self positionFromPosition:beginning offset:promptRange.location];
    UITextPosition *end = [self positionFromPosition:start offset:promptRange.length];
    self.promptRange = [self textRangeFromPosition:start toPosition:end];
    CGSize size = [self sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    
    [self.heightConstraint setConstant:size.height];
}

-(void)didTap:(UITapGestureRecognizer*)tap{
    CGPoint p = [tap locationInView:self];
    
    //fucking workaround. I'm absolutly fucking speechless
    //using self instead of v will not fucking work
    UITextView* v = [[UITextView alloc] initWithFrame:self.bounds];
    [v setAttributedText:self.attributedText];
    
    CGRect promptRect = [v firstRectForRange:self.promptRange];
    if (CGRectContainsPoint(promptRect, p)) {
        if ([(NSObject*)self.soDelegate respondsToSelector:@selector(userDidTapViewAllCommentForFeed:)]) {
            [self.soDelegate userDidTapViewAllCommentForFeed:self.feed];
                    return;
        }
    }
    
    for (int i=0;i<self.nameRanges.count;i++) {
        UITextRange* range = self.nameRanges[i];
        CGRect rect = [v firstRectForRange:range];
        if (CGRectContainsPoint(rect, p)) {
            if ([(NSObject*)self.soDelegate respondsToSelector:@selector(userDidTapNameOfUser:)]) {
                [self.soDelegate userDidTapNameOfUser:self._likes[i]];
                return;
            }
        }
    }
}
@end
