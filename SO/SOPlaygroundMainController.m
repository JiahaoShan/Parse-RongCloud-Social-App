//
//  SOPlaygroundMainController.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundMainController.h"
#import "SOPlaygroundFeedCell.h"
#import "SODefines.h"
#import "SOImageViewController.h"
#import "SOImagePageViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>


@interface SOPlaygroundMainController()<UITableViewDataSource,UITableViewDelegate,SOPlaygroundFeedCellDelegate, imageViewDelegate>
@property (nonatomic) NSMutableDictionary* feedsCellCache;
@property (nonatomic) NSArray* feedsData;
@property (nonatomic) BOOL initialized;
@end

@implementation SOPlaygroundMainController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [self initialize];
}

-(void)initialize{
    if (!_initialized) {
        _initialized = true;
        self.parseClassName = @"PlaygroundFeed";
        self.pullToRefreshEnabled = YES;
        self.paginationEnabled = YES;
        self.objectsPerPage = 10;
        self.feedsCellCache = [[NSMutableDictionary alloc] init];
    }
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        //query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"createdAt"];
    return query;
}


-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SOPlaygroundFeedCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"feedCell"];
    
//    UIImage* sampleImage = [UIImage imageNamed:@"sampleImage"];
//    NSData* imageData = UIImagePNGRepresentation(sampleImage);
//    PFFile* image1 = [PFFile fileWithName:@"sampleImage.png" data:imageData];
//    //[image1 saveInBackground];
//    
//    PFObject* sampleFeed = [PFObject objectWithClassName:@"PlaygroundFeed"];
//    sampleFeed[@"poster"] = [PFUser currentUser];
//    sampleFeed[@"text"] = @"这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。这是一段超级长的文字。我就是想看看它能不能被正常显示出来。";
//    sampleFeed[@"images"] = @[image1];
//    [sampleFeed saveInBackground];
}

#pragma mark - UITableViewDelegate
-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return false;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == self.objects.count && self.paginationEnabled) {
        // Load More Cell
        [self loadNextPage];
    }
    else{
        PFObject *selectedObject = [self objectAtIndexPath:indexPath];
        // ... do something else
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {
    if (indexPath.row>=self.objects.count) {
        return [tableView dequeueReusableCellWithIdentifier:@"loadMore"];
    }
    SOPlaygroundFeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    [cell configureWithData:object];
    cell.delegate = self;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.objects.count && self.paginationEnabled) {
        return 44;
    }
    UITableViewCell* cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize: UILayoutFittingCompressedSize];
    return size.height;
}
#pragma mark - SOPlaygroundFeedCellDelegate

-(void)cell:(SOPlaygroundFeedCell *)cell didTapImageAtIndex:(NSUInteger)index{
//    PlaygroundFeed * feed = [PlaygroundFeed object];
//    feed.message = @"Hahahahah";
    NSIndexPath* cellIndex = [self.tableView indexPathForCell:cell];
    NSArray* images = self.objects[cellIndex.row][@"images"];
    NSMutableArray* feedImageView = cell.getFeedImageViews;
    PFImageView* imageView = (PFImageView*)feedImageView[index];
    
    CGRect frameInWindow = [imageView.superview convertRect:imageView.frame toView:[[UIApplication sharedApplication] keyWindow]];

    UIView * blackOverlay = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    blackOverlay.backgroundColor = [UIColor clearColor];
    
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:blackOverlay];
    
    UIImageView* imageAnimationView = [[UIImageView alloc] initWithImage:imageView.image];
    imageAnimationView.frame = frameInWindow;
    [currentWindow addSubview:imageAnimationView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         blackOverlay.backgroundColor = [UIColor blackColor];
                         imageAnimationView.center = currentWindow.center;
                         imageAnimationView.alpha = 0.5;
                     } completion:^(BOOL finished) {
                         [blackOverlay removeFromSuperview];
                         [imageAnimationView removeFromSuperview];
                         UIViewController* imageViewController = nil;
                         if ([images count] > 1) {
                             imageViewController = (SOImagePageViewController*)[[SOImagePageViewController alloc] initWithImages:images AndThumbnails:feedImageView AtIndex:index FromParent:self];
                         }
                         else {
                             PFFile* image = images[index];
                             imageViewController = (SOImageViewController*)[[SOImageViewController alloc] init];
                             [(SOImageViewController*)imageViewController setImage:image WithPlaceholder:[feedImageView firstObject]];
                             ((SOImageViewController*)imageViewController).returnToFrame = frameInWindow;
                             ((SOImageViewController*)imageViewController).delegate = self;
                         }
                             [self.navigationController pushViewController:imageViewController animated:NO];
                     }];
    blackOverlay = nil;
    imageAnimationView = nil;
}

#pragma mark - SOImageViewController Delegate

-(void)backFromImageView:(PFImageView *)imageView withFrame:(CGRect)frame{
    UIView * blackOverlay = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    blackOverlay.backgroundColor = [UIColor blackColor];
    
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:blackOverlay];
    
    imageView.frame = [imageView.superview convertRect:imageView.frame toView:[[UIApplication sharedApplication] keyWindow]];
    
    [currentWindow addSubview:imageView];

    [UIView animateWithDuration:0.4
                     animations:^{
                         blackOverlay.backgroundColor = [UIColor clearColor];
                         imageView.frame = frame;
                     } completion:^(BOOL finished) {
                         [blackOverlay removeFromSuperview];
                         [imageView removeFromSuperview];
                     }];
    blackOverlay = nil;
    imageView = nil;
}

#pragma mark - Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@""])
    {
    }
}


@end
