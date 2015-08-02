//
//  SOPlaygroundFeedCommentPreviewView.h
//  SO
//
//  Created by Guanqing Yan on 8/2/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaygroundFeed.h"
#import "User.h"
#define kSOPlaygroundFeedCommentPreviewViewUserKey @"u"
#define kSOPlaygroundFeedCommentPreviewViewMessageKey @"m"

@protocol SOPlaygroundFeedCommentPreviewViewDelegate
-(void)userDidTapViewAllForFeed:(PlaygroundFeed*)feed;
-(void)userDidTapNameOfUser:(User*)user;
@end

@interface SOPlaygroundFeedCommentPreviewView : UITextView
@property (nonatomic,assign) id<SOPlaygroundFeedCommentPreviewViewDelegate> soDelegate;
/*
 Array of NSDictionarys, like:
 @[ @{@"user":A, message:@"xxxx"}, @{@"user":A, message:@"xxxx"}];
 order will be respected
 */
-(CGFloat)setComments:(NSArray*)comments totalCount:(int)totalCount feed:(PlaygroundFeed*)feed width:(CGFloat)width;//returns height, takes container width as parameter only pass in the comments that you want to be visible;
@end
