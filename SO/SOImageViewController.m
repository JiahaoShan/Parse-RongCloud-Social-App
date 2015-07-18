//
//  SOImageViewController.m
//  SO
//
//  Created by Guanqing Yan on 7/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOImageViewController.h"

@interface SOImageViewController ()
@property (nonatomic) PFImageView* imageView;
@end

@implementation SOImageViewController

-(PFImageView*)imageView{
    if (!_imageView) {
        _imageView = [[PFImageView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

-(void)setImage:(PFFile*)image{
    [self.imageView setFile:image];
    [self.imageView loadInBackground];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setExtendedLayoutIncludesOpaqueBars:false];
    [self.view setBackgroundColor:[UIColor blackColor]];
    UILongPressGestureRecognizer* lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [lp setMinimumPressDuration:1];
    [self.view addGestureRecognizer:lp];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setHidesBarsOnTap:true];
    [self.navigationController setNavigationBarHidden:true animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)longPressed:(UILongPressGestureRecognizer*)g{
    NSLog(@"longPressed");
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
