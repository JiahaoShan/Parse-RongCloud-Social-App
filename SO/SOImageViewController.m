//
//  SOImageViewController.m
//  SO
//
//  Created by Guanqing Yan on 7/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOImageViewController.h"
#import "SOActionSheetManager.h"
#import "UIView+ActivityIndicator.h"

@interface SOImageViewController ()
@property (nonatomic) PFImageView* imageView;
@property (nonatomic) UILongPressGestureRecognizer* longPress;
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

- (void)setImage:(PFFile*)image WithPlaceholder:(PFImageView*) placeholder {
    UIImage * placeholderImage = placeholder.image;
    [self.imageView setImage:placeholderImage];
    // 现在看上去可能比较大 因为Playgournd现在没有加载thumbnail
    _imageView.frame = CGRectMake(0, 0, placeholderImage.size.width, placeholderImage.size.height);
    _imageView.center = self.view.center;
    _imageView.clipsToBounds = YES;
    _imageView.alpha = 0.7;
    //[self.view showActivityIndicator];
    [self setImage:image];
}

-(void)setImage:(PFFile*)image{
    [self.imageView setFile:image];
    [self.imageView loadInBackground:^(UIImage *image,  NSError *error){
    //[self.view hideActivityIndicator];

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
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:0
                         animations:^{
                             _imageView.transform = CGAffineTransformIdentity;
                             _imageView.alpha = 1.0;
                             _imageView.frame = frame;
                             _imageView.center = self.view.center;
                         }
                         completion:^(BOOL finished){
                             
                         }];
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setExtendedLayoutIncludesOpaqueBars:false];
    [self.view setBackgroundColor:[UIColor blackColor]];
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [_longPress setMinimumPressDuration:0.7];
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:_longPress];
    [self.view addGestureRecognizer:tap];
}

-(void)viewWillAppear:(BOOL)animated{
    if (!self.disablesNavigationBarHiddenControl)
    [self.navigationController setNavigationBarHidden:true animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    if (!self.disablesNavigationBarHiddenControl)
    [self.navigationController setNavigationBarHidden:false animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)longPressed:(UILongPressGestureRecognizer*)g{
    NSLog(@"longPressed");
    [g setEnabled:false];
    SOActionSheetManager* actionSheet = [[SOActionSheetManager alloc] init];
    [actionSheet addAction:@"Save" type:SOActionTypeDefault handler:^{
        NSLog(@"should save");
    }];
    [actionSheet addAction:@"Cancel" type:SOActionTypeCancel handler:^{
         self.longPress.enabled = true;
    }];
    [actionSheet showInViewController:self];
}

-(void)tapped:(UITapGestureRecognizer*)t{
    [[self navigationController] popViewControllerAnimated:NO];
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
