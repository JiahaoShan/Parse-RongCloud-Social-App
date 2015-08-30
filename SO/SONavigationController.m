//
//  SONavigationController.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SONavigationController.h"
#import "SOUICommons.h"

@implementation SONavigationController
-(void)awakeFromNib{
    [super awakeFromNib];
    [[self navigationBar] setBarTintColor:[SOUICommons primaryTintColor]];
    [[self navigationBar] setTintColor:[SOUICommons textColor]];
    [[self navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName:[SOUICommons textColor]}];
    [self setExtendedLayoutIncludesOpaqueBars:false];
}
@end
