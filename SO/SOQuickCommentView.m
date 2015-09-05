//
//  SOQuickCommentView.m
//  SO
//
//  Created by Guanqing Yan on 8/18/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOQuickCommentView.h"
#import "SOUICommons.h"
@interface SOQuickCommentView()
@property (nonatomic) CSGrowingTextView* tv;
@property (nonatomic) CGFloat textViewHeight;
@end

@implementation SOQuickCommentView

//-(instancetype)initWithFrame:(CGRect)frame{
//    if (self=[super initWithFrame:frame]) {
//        [self setBackgroundColor:[SOUICommons lightBackgroundGray]];
//        self.tv = [[CSGrowingTextView alloc] init];
//        [self.tv.layer setCornerRadius:3];
//        [self.tv.internalTextView setTextColor:[UIColor blackColor]];
//        [self.tv.layer setBorderWidth:1];
//        [self.tv.layer setBorderColor:[SOUICommons descriptiveTextColor].CGColor];
//        [self.tv setDelegate:self];
//        [self.tv setBackgroundColor:[UIColor whiteColor]];
//        [self addSubview:self.tv];
//        
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-6-[v]-6-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:@{@"v":self.tv}]];
//        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-6-[v]-6-|" options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"v":self.tv}]];
//    }
//    return self;
//}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setBackgroundColor:[SOUICommons lightBackgroundGray]];
    self.tv = [self viewWithTag:1];
            [self.tv.layer setCornerRadius:3];
            [self.tv.internalTextView setTextColor:[UIColor blackColor]];
            [self.tv.layer setBorderWidth:1];
            [self.tv.layer setBorderColor:[SOUICommons descriptiveTextColor].CGColor];
            [self.tv setDelegate:self];
            [self.tv setBackgroundColor:[UIColor whiteColor]];
}

-(BOOL)growingTextViewShouldReturn:(CSGrowingTextView *)textView{
    [textView resignFirstResponder];
    if (self.delegate) {
        [self.delegate commentViewDidReturnWithText:self.tv.internalTextView.text];
    }
    return true;
}

-(void)growingTextView:(CSGrowingTextView *)growingTextView willChangeHeight:(CGFloat)height{
    self.textViewHeight=height;
    [UIView animateWithDuration:0.1 animations:^{
        [self invalidateIntrinsicContentSize];
        [self.superview layoutIfNeeded];
    }];
}

-(void)clearText{
    [self.tv.internalTextView setText:@""];
}

-(CGSize)intrinsicContentSize{
    return CGSizeMake(UIViewNoIntrinsicMetric, self.textViewHeight+12);
}

-(BOOL)becomeFirstResponder{
    return [self.tv becomeFirstResponder];
}

-(BOOL)resignFirstResponder{
    return [self.tv resignFirstResponder];
}

@end
