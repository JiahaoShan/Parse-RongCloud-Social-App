//
//  SOQuickCommentView.m
//  SO
//
//  Created by Guanqing Yan on 8/18/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOQuickCommentView.h"
@interface SOQuickCommentView()
@property (nonatomic) CSGrowingTextView* tv;
@end

@implementation SOQuickCommentView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor lightGrayColor]];
        self.tv = [[CSGrowingTextView alloc] init];
        [self.tv.layer setCornerRadius:3];
        [self.tv.internalTextView setTextColor:[UIColor blackColor]];
        [self.tv.layer setBorderWidth:1];
        [self.tv setDelegate:self];
        [self.tv setBackgroundColor:[UIColor whiteColor]];
        CGSize f = self.frame.size;
        [self.tv setFrame:CGRectMake(8, 8, f.width-16, f.height-16)];
        [self addSubview:self.tv];
    }
    return self;
}

-(BOOL)growingTextViewShouldReturn:(CSGrowingTextView *)textView{
    [textView resignFirstResponder];
    if (self.delegate) {
        [self.delegate commentViewDidReturnWithText:self.tv.internalTextView.text];
    }
    return true;
}

-(void)growingTextView:(CSGrowingTextView *)growingTextView didChangeHeight:(CGFloat)height{
    //CGSize s = growingTextView.frame.size;
    CGRect f = self.frame;
    CGFloat max = CGRectGetMaxY(f);
    f.origin.y = max-height-16;
    f.size.height = height+16;
    [self setFrame:f];
    [self.tv setFrame:CGRectMake(8, 8, f.size.width-16, height)];
}

-(BOOL)becomeFirstResponder{
    return [self.tv becomeFirstResponder];
}

@end
