//
//  SOSettingViewController.m
//  SO
//
//  Created by Jiahao Shan on 7/26/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOSettingViewController.h"
#import "SOPlaygroundMainController.h"
#import "SOPersonalInfoTableViewController.h"

@interface SOSettingViewController ()
@property (nonatomic) CAPSPageMenu *pageMenu;
@end

@implementation SOSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PAGE MENU";
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0];
//    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor orangeColor]};
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"<-" style:UIBarButtonItemStyleDone target:self action:@selector(didTapGoToLeft)];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"->" style:UIBarButtonItemStyleDone target:self action:@selector(didTapGoToRight)];
    
    UIViewController *controller1 = [[SOPlaygroundMainController alloc] init];
    controller1.title = @"新鲜事";
    UIViewController *controller2 = [[SOPlaygroundMainController alloc] init];
    controller2.title = @"我的状态";
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller3 = [storyboard instantiateViewControllerWithIdentifier:@"personInfoViewController"];
    
    controller3.title = @"个人信息";
    
    NSArray *controllerArray = @[controller1, controller2, controller3];
    NSDictionary *parameters = @{
                                 CAPSPageMenuOptionScrollMenuBackgroundColor: [UIColor colorWithRed:30.0/255.0 green:30.0/255.0 blue:30.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionViewBackgroundColor: [UIColor colorWithRed:20.0/255.0 green:20.0/255.0 blue:20.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionSelectionIndicatorColor: [UIColor orangeColor],
                                 CAPSPageMenuOptionBottomMenuHairlineColor: [UIColor colorWithRed:70.0/255.0 green:70.0/255.0 blue:70.0/255.0 alpha:1.0],
                                 CAPSPageMenuOptionMenuItemFont: [UIFont fontWithName:@"HelveticaNeue" size:13.0],
                                 CAPSPageMenuOptionMenuHeight: @(40.0),
                                 CAPSPageMenuOptionMenuItemWidth: @(90.0),
                                 CAPSPageMenuOptionUseMenuLikeSegmentedControl: @(YES)
                                // CAPSPageMenuOptionCenterMenuItems: @(YES)
                                 };
    
    _pageMenu = [[CAPSPageMenu alloc] initWithViewControllers:controllerArray frame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height) options:parameters];
    [self.view addSubview:_pageMenu.view];
}

//-(void)viewWillAppear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:true];
//}
//-(void)viewWillDisappear:(BOOL)animated{
//    [self.navigationController setNavigationBarHidden:false];
//}

- (void)didTapGoToLeft {
    NSInteger currentIndex = self.pageMenu.currentPageIndex;
    
    if (currentIndex > 0) {
        [_pageMenu moveToPage:currentIndex - 1];
    }
}

- (void)didTapGoToRight {
    NSInteger currentIndex = self.pageMenu.currentPageIndex;
    
    if (currentIndex < self.pageMenu.controllerArray.count) {
        [self.pageMenu moveToPage:currentIndex + 1];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
