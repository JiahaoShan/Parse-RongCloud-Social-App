//
//  SOImagePageViewController.m
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOImagePageViewController.h"
#import "SOImageViewController.h"

@interface SOImagePageViewController () <UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic) NSInteger startIndex;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableDictionary* ifVisited;
@property (nonatomic, strong) NSMutableArray* frames;
@end

@implementation SOImagePageViewController

-(NSMutableDictionary*) ifVisited{
    if (!_ifVisited) {
        _ifVisited = [[NSMutableDictionary alloc] init];
    }
    return _ifVisited;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (id)initWithImages: (NSArray*) images AndThumbnails: (NSArray*) thumbnails AtIndex:(NSInteger) index FromParent: (id) parent{
    self = [super init];
    if(self) {
        self.parent = parent;
        self.pageImages = images;
        self.pageImagesThumbnails = thumbnails;
        self.startIndex = index;
        [self initFrames];
        [self createPageViewControllerWithInitImageAtIndex: index];
        [self setupPageControl];
    }
    return self;
}

- (void) initFrames {
    self.frames = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [self.pageImagesThumbnails count]; i++) {
        PFImageView* pageImagesThumbnailView = (PFImageView*)self.pageImagesThumbnails[i];
        [self.frames addObject:[NSValue valueWithCGRect:[pageImagesThumbnailView.superview convertRect:pageImagesThumbnailView.frame toView:[[UIApplication sharedApplication] keyWindow]]]];
    }
}

- (void)createPageViewControllerWithInitImageAtIndex: (NSInteger) index
{
    UIPageViewController *pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    pageController.dataSource = self;
    
    if([self.pageImages count])
    {
        NSArray *startingViewControllers = @[[self imageControllerForIndex: index]];
        [pageController setViewControllers: startingViewControllers
                                 direction: UIPageViewControllerNavigationDirectionForward
                                  animated: NO
                                completion: nil];
    }
    
    self.pageViewController = pageController;
    [self addChildViewController: self.pageViewController];
    [self.view addSubview: self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController: self];
}

- (void) setupPageControl
{
    [[UIPageControl appearance] setPageIndicatorTintColor: [UIColor grayColor]];
    [[UIPageControl appearance] setCurrentPageIndicatorTintColor: [UIColor whiteColor]];
    [[UIPageControl appearance] setBackgroundColor: [UIColor clearColor]];
    [[UIPageControl appearance] setOpaque:NO];
}

#pragma mark UIPageViewControllerDataSource

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerBeforeViewController:(UIViewController *) viewController
{
    SOImageViewController *imageController = (SOImageViewController *) viewController;
    
    if (imageController.imageIndex > 0)
    {
        return [self imageControllerForIndex: imageController.imageIndex - 1];
    }
    
    return nil;
}

- (UIViewController *) pageViewController: (UIPageViewController *) pageViewController viewControllerAfterViewController:(UIViewController *) viewController
{
    SOImageViewController *imageController = (SOImageViewController *) viewController;
    
    if (imageController.imageIndex + 1 < [self.pageImages count])
    {
        return [self imageControllerForIndex: imageController.imageIndex + 1];
    }
    
    return nil;
}

- (SOImageViewController *) imageControllerForIndex: (NSUInteger) imageIndex
{
    if (imageIndex < [self.pageImages count])
    {
        PFImageView* pageImagesThumbnailView = (PFImageView*)self.pageImagesThumbnails[imageIndex];
        SOImageViewController *imageController = [[SOImageViewController alloc] init];
        imageController.imageIndex = imageIndex;
        imageController.disablesNavigationBarHiddenControl = YES;
        [imageController setImage:self.pageImages[imageIndex] WithPlaceholder:self.pageImagesThumbnails[imageIndex]];
        self.currentIndex = imageIndex;
        imageController.delegate = self.parent;
        CGRect frameInWindow = [[self.frames objectAtIndex:imageIndex] CGRectValue];
        imageController.returnToFrame = frameInWindow;
        return imageController;
    }
    
    return nil;
}

#pragma mark -
#pragma mark Page Indicator

- (NSInteger) presentationCountForPageViewController: (UIPageViewController *) pageViewController
{
    return [self.pageImages count];
}

- (NSInteger) presentationIndexForPageViewController: (UIPageViewController *) pageViewController
{
    return self.startIndex;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
