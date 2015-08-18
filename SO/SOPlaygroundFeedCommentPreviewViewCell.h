//
//  SOPlaygroundFeedCommentPreviewViewCell.h
//  SO
//
//  Created by Guanqing Yan on 8/9/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOPlaygroundFeedInteractionDelegate.h"
#import "PlaygroundComment.h"

@interface SOPlaygroundFeedCommentPreviewViewCell : UITableViewCell
-(instancetype)initWithComment:(NSDictionary*)comment width:(CGFloat)width;
@property (nonatomic,assign) id<SOPlaygroundFeedInteractionDelegate> delegate;
@end
