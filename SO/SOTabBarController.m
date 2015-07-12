//
//  SOTabBarController.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOTabBarController.h"
#import "SOUICommons.h"

@implementation SOTabBarController
-(void)awakeFromNib{
    [super awakeFromNib];
    [[self tabBar] setBarTintColor:[SOUICommons primaryTintColor]];
    [[self tabBar] setTintColor:[SOUICommons textColor]];
}
@end
