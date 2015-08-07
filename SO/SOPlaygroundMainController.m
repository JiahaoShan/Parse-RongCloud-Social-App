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
#import "MTStatusBarOverlay.h"
#import "User.h"

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
    
//    UIImage* sampleImage = [UIImage imageNamed:@"sampleImage2.png"];
//    NSData* imageData = UIImagePNGRepresentation(sampleImage);
//    PFFile* image1 = [PFFile fileWithName:@"sampleImage2.png" data:imageData];
//    
//    UIImage* sampleImage2 = [UIImage imageNamed:@"sampleImage3.png"];
//    NSData* imageData2 = UIImagePNGRepresentation(sampleImage2);
//    PFFile* image2 = [PFFile fileWithName:@"sampleImage3.png" data:imageData2];
//    //[image1 saveInBackground];
//    
//    PFObject* sampleFeed = [PFObject objectWithClassName:@"PlaygroundFeed"];
//    sampleFeed[@"poster"] = [PFUser currentUser];
//    sampleFeed[@"text"] = @"这是一段超级长的文字。我就是想看看它能不能被正常显示出来。-- 并不能。";
//    sampleFeed[@"images"] = @[image1,image2];
//    [sampleFeed saveInBackground];
    
    
    
//    PFUser *user = [PFUser user];
//    user.username = @"Shawn";
//    user.password = @"12345678";
//    user.email = @"shawn.shan@wisc.edu";
//    
//    UIImage* sampleImage2 = [UIImage imageNamed:@"sampleImage2.png"];
//    NSData* imageData2 = UIImagePNGRepresentation(sampleImage2);
//    PFFile* image2 = [PFFile fileWithName:@"sampleImage2.png" data:imageData2];
//    
//    // other fields can be set just like with PFObject
//    user[@"portrait"] = image2;
//    user[@"male"] = @YES;
//    
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {   // Hooray! Let them use the app now.
//        } else {   NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
//        }
//    }];
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
    cell.delegate = self;
    cell.mainController = self;
    [cell configureWithFeed:object];
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

#pragma mark SOPlaygroundFeedInteractionDelegate
-(void)feed:(PlaygroundFeed *)feed didChangeLikeStatusTo:(BOOL)like{
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    overlay.animation = MTStatusBarOverlayAnimationFallDown;  // MTStatusBarOverlayAnimationShrink
    overlay.detailViewMode = MTDetailViewModeHistory;         // enable automatic history-tracking and
    if (like) {
        [PFCloud callFunctionInBackground:@"PlaygroundAddLike"
                   withParameters:@{@"feedId": feed.objectId,@"userId":[PFUser currentUser].objectId}
                            block:^(id response, NSError *error) {
            if (error) {
                [overlay postMessage:[NSString stringWithFormat:@"error:%@",error]];
            }else{
                [overlay postMessage:@"like success"];
            }
        }];
    }else{
        [PFCloud callFunctionInBackground:@"PlaygroundRemoveLike"
                withParameters:@{@"feedId": feed.objectId,@"userId":[PFUser currentUser].objectId}
                        block:^(id response, NSError *error) {
            if (error) {
                [overlay postMessage:[NSString stringWithFormat:@"error:%@",error]];
            }else{
                [overlay postMessage:@"delete like success"];
            }
        }];
    }
}

#pragma mark - Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@""])
    {
    }
}


@end
