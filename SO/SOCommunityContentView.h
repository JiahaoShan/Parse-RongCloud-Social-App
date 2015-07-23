//
//  SOCommunityContentView.h
//  SO
//
//  Created by Guanqing Yan on 7/21/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SOCommunityContentViewDelegate
-(void)didDoubleTapViewAtIndex:(NSInteger)index;
@end

@interface SOCommunityContentView : UIScrollView
@property CGFloat contentRadius;
@property (nonatomic,assign) id<SOCommunityContentViewDelegate> communityViewDelegate;
@end
