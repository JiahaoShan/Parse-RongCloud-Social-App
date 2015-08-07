//
//  SOPlaygroundFeedCell.h
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "SOPlaygroundFeedImageView.h"
#import "SOPlaygroundMainController.h"
#import "PlaygroundFeed.h"
@class SOPlaygroundFeedCell;
@protocol SOPlaygroundFeedCellDelegate
//called when user tap an image, the image itself is provided(though it can still be nil)
//the url is also included for downloading high resolution images is user prefers
@required
-(void)cell:(SOPlaygroundFeedCell*)cell didTapImageAtIndex:(NSUInteger)index;
@end

@interface SOPlaygroundFeedCell : PFTableViewCell
@property (weak,nonatomic) SOPlaygroundMainController* mainController;//also serve as delegate, consider merge with delegate
@property (nonatomic,assign) id<SOPlaygroundFeedCellDelegate> delegate;
-(void)configureWithFeed:(PlaygroundFeed*)feed;//returns height
-(NSMutableArray*) getFeedImageViews;
@end
