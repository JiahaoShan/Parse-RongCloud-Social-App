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
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:_imageView];
    }
    return _imageView;
}

-(void)setImage:(PFFile*)image{
    [self.imageView setFile:image];
    [self.imageView loadInBackground:^(UIImage *image,  NSError *error){
        CGFloat height = image.size.height;
        CGFloat width = image.size.width;
        CGFloat ratio = height/width;
        
        
        CGSize screen = [UIScreen mainScreen].bounds.size;
        CGFloat sRatio = screen.height / screen.width;
        
        CGRect frame = _imageView.frame;
        if (ratio>sRatio) {
            frame.size = CGSizeMake( width * screen.height / height , screen.height);
        }else{
            frame.size = CGSizeMake(screen.width, height * screen.width / width);
        }
        
        _imageView.frame = frame;
        _imageView.center = self.view.center;
    }];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setExtendedLayoutIncludesOpaqueBars:false];
    [self.view setBackgroundColor:[UIColor blackColor]];
    UILongPressGestureRecognizer* lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [lp setMinimumPressDuration:1];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:lp];
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:true animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:false animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)longPressed:(UILongPressGestureRecognizer*)g{
    NSLog(@"longPressed");
}

-(void)tapped:(UITapGestureRecognizer*)t{
    [[self navigationController] popViewControllerAnimated:true];
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
