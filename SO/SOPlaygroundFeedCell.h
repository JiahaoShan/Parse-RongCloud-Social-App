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

@interface SOPlaygroundFeedCell : PFTableViewCell
+(CGFloat)estimatedHeightForData:(PFObject*)data;

-(void)configureWithData:(PFObject*)data;
@end
