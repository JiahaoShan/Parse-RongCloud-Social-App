//
//  SOQuickCommentView.h
//  SO
//
//  Created by Guanqing Yan on 8/18/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSGrowingTextView.h"
@protocol SOQuickCommentViewDelegate
-(void)commentViewDidReturnWithText:(NSString*)text;
@end

@interface SOQuickCommentView : UIView<CSGrowingTextViewDelegate>
@property (assign,nonatomic) id<SOQuickCommentViewDelegate> delegate;
@end
