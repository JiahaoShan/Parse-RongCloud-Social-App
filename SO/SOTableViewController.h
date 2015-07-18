//
//  SOTableViewController.h
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface SOTableViewController : PFQueryTableViewController
@property (nonatomic) BOOL pullToLoadMoreEnabled;
@end
