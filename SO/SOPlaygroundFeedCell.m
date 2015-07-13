//
//  SOPlaygroundFeedCell.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedCell.h"
#import "SOPlaygroundFeedImageView.h"

@interface SOPlaygroundFeedCell()
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedImageView *feedImageView;
@end

@implementation SOPlaygroundFeedCell
-(void)configureWithData:(NSDictionary*)data{
    [(SOPlaygroundFeedImageView*)self.feedImageView setImages:[data objectForKey:@"images"]];
}
@end
