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

@interface SOImageViewController () <UIScrollViewDelegate>
@property (nonatomic) PFImageView* imageView;
@property (nonatomic) UILongPressGestureRecognizer* longPress;
@property (nonatomic, strong) UIScrollView* scrollView;
@end

@implementation SOImageViewController

-(PFImageView*)imageView{
    if (!_imageView) {
        _imageView = [[PFImageView alloc] initWithFrame:self.view.bounds];
        //_imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        [self.scrollView addSubview:_imageView];
    }
    return _imageView;
}

-(UIScrollView*)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (void)setImage:(PFFile*)image WithPlaceholder:(PFImageView*) placeholder {
    UIImage * placeholderImage = placeholder.image;
    [self.imageView setImage:placeholderImage];
    // 现在看上去可能比较大 因为Playgournd现在没有加载thumbnail
    _imageView.frame = CGRectMake(0, 0, placeholder.bounds.size.width, placeholder.bounds.size.height);
    _imageView.center = [UIApplication sharedApplication].keyWindow.center;
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
        self.scrollView.contentSize = self.imageView.image.size;
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:0
                         animations:^{
                             _imageView.transform = CGAffineTransformIdentity;
                             _imageView.alpha = 1.0;
                             _imageView.frame = frame;
                             _imageView.center = [UIApplication sharedApplication].keyWindow.center;
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
    UITapGestureRecognizer* singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:_longPress];
    [self.view addGestureRecognizer:singleTapRecognizer];
    [self.view addGestureRecognizer:doubleTapRecognizer];
    [singleTapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
}

-(void)viewWillAppear:(BOOL)animated{
    if (!self.disablesNavigationBarHiddenControl)
    [self.navigationController setNavigationBarHidden:true animated:animated];
    
    // Set up the minimum & maximum zoom scales
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat maxScale = MAX(scaleWidth, scaleHeight);
    
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = maxScale;
    self.scrollView.zoomScale = 1;
    
//    NSLog(@"Show self.view.frame from ImageView: %@", NSStringFromCGRect(self.view.frame));  // as a string
//    NSLog(@"Show self.imageView from ImagePageView: %@", NSStringFromCGRect(self.imageView.frame));  // as a string
//    NSLog(@"================================");

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
    [self.delegate backFromImageView:self.imageView withFrame:self.returnToFrame];
    [[self navigationController] popViewControllerAnimated:NO];
}


-(void)doubleTapped:(UITapGestureRecognizer*)t{
    
    float newScale = self.scrollView.maximumZoomScale;;
    
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
    {
        [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
    else
    {
        CGRect zoomRect = [self zoomRectForScale:newScale
                                      withCenter:[t locationInView:self.scrollView]];
        [self.scrollView zoomToRect:zoomRect animated:YES];
    }

}


- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = [_imageView frame].size.height / scale;
    zoomRect.size.width  = [_imageView frame].size.width  / scale;
    center = [_imageView convertPoint:center fromView:self.scrollView];
    zoomRect.origin.x    = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y    = center.y - ((zoomRect.size.height / 2.0));
    return zoomRect;
}




/*
#pragma mark - Navigation
*/

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = MAX((self.scrollView.bounds.size.width - self.scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((self.scrollView.bounds.size.height - self.scrollView.contentSize.height) * 0.5, 0.0);
    self.imageView.center = CGPointMake(self.scrollView.contentSize.width * 0.5 + offsetX,
                                 self.scrollView.contentSize.height * 0.5 + offsetY);
}


@end
