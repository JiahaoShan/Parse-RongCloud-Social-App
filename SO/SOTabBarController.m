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
    self.delegate = self;
    [[self tabBar] setBarTintColor:[SOUICommons primaryTintColor]];
    [[self tabBar] setTintColor:[SOUICommons textColor]];
    self.navigationController.navigationBarHidden = NO;
    
    UIViewController* vc = self.viewControllers[0];
    
    UILabel* label = [[UILabel alloc] init];
    [SOUICommons configureNavigationBarLabel:label];
    [label setText:[vc title]];
    [label sizeToFit];
    self.navigationItem.titleView = label;
    self.navigationItem.title=[vc title];
    
    if ([vc respondsToSelector:@selector(rightBarButtonItem)]) {
        self.navigationItem.rightBarButtonItem = [vc performSelector:@selector(rightBarButtonItem)];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
}

-(void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    
    UILabel* label = self.navigationItem.titleView;
    [SOUICommons configureNavigationBarLabel:label];
    [label setText:[viewController title]];
    [label sizeToFit];
    self.navigationItem.titleView = label;
    self.navigationItem.title=[viewController title];
    
    if ([viewController respondsToSelector:@selector(rightBarButtonItem)]) {
        self.navigationItem.rightBarButtonItem = [viewController performSelector:@selector(rightBarButtonItem)];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
}
@end
