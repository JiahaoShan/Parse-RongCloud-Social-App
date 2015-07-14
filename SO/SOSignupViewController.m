//
//  SOSignupViewController.m
//  SO
//
//  Created by Jiahao Shan on 7/13/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOSignupViewController.h"

@interface SOSignupViewController ()

@end

@implementation SOSignupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
//    UIImageView *logoView = [[UIImageView alloc] initWithImage:@"logo.png"];
//    self.signUpView.logo = logoView; // logo can be any UIView
    //self.signUpView.usernameField.placeholder = @"phone";
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //self.signUpView.signUpButton.frame = CGRectMake(...); // Set a different frame.
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
