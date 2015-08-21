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
#import "SOUICommons.h"
#import "PlaygroundComment.h"
#import "SOQuickCommentView.h"
#import "SOPlaygroundFeedComposeController.h"

@interface SOPlaygroundMainController()<UITableViewDataSource,UITableViewDelegate, imageViewDelegate,SOQuickCommentViewDelegate,SOPlaygroundFeedComposeControllerDelegate>
@property (nonatomic) BOOL initialized;
@property (nonatomic) NSMutableArray* likeHistory;
@property (nonatomic) UIBarButtonItem* composeItem;
@property (nonatomic,weak) PlaygroundFeed* currentCommentingFeed;
@property (nonatomic) UITextView* dummyComment;
@property (nonatomic) SOQuickCommentView* commentAccessory;
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
    }
}

- (PFQuery *)queryForTable {
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        //query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query includeKey:@"poster"];
    [query includeKey:@"images"];
    [query includeKey:@"thumbnails"];
    [query orderByDescending:@"createdAt"];
    return query;
}

-(void)viewWillAppear:(BOOL)animated{
    self.tabBarController.navigationItem.title = @"操场";
    if (!self.composeItem) {
        self.composeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(didTapComposeFeed:)];
    }
    self.tabBarController.navigationItem.rightBarButtonItem=self.composeItem;
}


-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SOPlaygroundFeedCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"feedCell"];
    NSError* e;
    if([PFUser currentUser]){
    NSString* response = [PFCloud callFunction:@"PlaygroundGetLikeHistory" withParameters:@{@"userId":[[PFUser currentUser] objectId]} error:&e];
    if (response) {
        self.likeHistory = [NSJSONSerialization JSONObjectWithData:[response dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    }
    }
}

- (void)didTapComposeFeed:(UIBarButtonItem *)sender{
    SOPlaygroundFeedComposeController* composer = [self.storyboard instantiateViewControllerWithIdentifier:@"feedCompose"];
    [composer setDelegate:self];
    [self presentViewController:composer animated:true completion:nil];
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
                        object:(PlaygroundFeed *)object {
    if (indexPath.row>=self.objects.count) {
        return [tableView dequeueReusableCellWithIdentifier:@"loadMore"];
    }
    //[object pinInBackground];
    SOPlaygroundFeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    cell.delegate = self;
    cell.mainController = self;
    [object setLiked:[self likedForFeed:object]];
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
-(void)feed:(PlaygroundFeed *)feed didChangeLikeStatusTo:(BOOL)like action:(SOFailableAction *)action{
    [feed setLiked:like];
    [self cacheFeed:feed liked:like];
    if (![feed.recentLikeUsers isKindOfClass:[NSMutableArray class]]) {
        feed.recentLikeUsers = [NSMutableArray arrayWithArray:feed.recentLikeUsers];
    }
    if (like) {
        [(NSMutableArray*)feed.recentLikeUsers insertObject:[PFUser currentUser] atIndex:0];
        int count = feed.likeCount.intValue;
        feed.likeCount = @(++count);
    }else{
        [(NSMutableArray*)feed.recentLikeUsers removeObject:[PFUser currentUser]];
        int count = feed.likeCount.intValue;
        feed.likeCount = @(--count);
    }
    [action addFailHandler:^{
        if (like) {
            [(NSMutableArray*)feed.recentLikeUsers removeObjectAtIndex:0];
            int count = feed.likeCount.intValue;
            feed.likeCount = @(--count);
        }else{
            [(NSMutableArray*)feed.recentLikeUsers insertObject:[PFUser currentUser] atIndex:0];
            int count = feed.likeCount.intValue;
            feed.likeCount = @(++count);
        }
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.objects indexOfObject:feed] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.objects indexOfObject:feed] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    //[self.tableView reloadData];//maybe too much? optimizaiton needed//hides animation! bad
    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
    if (like) {
        [PFCloud callFunctionInBackground:@"PlaygroundAddLike"
                           withParameters:@{@"feedId": feed.objectId,@"userId":[PFUser currentUser].objectId}
                                    block:^(id response, NSError *error) {
                                        if (error) {
                                            [overlay postImmediateMessage:[NSString stringWithFormat:@"error:%@",error] duration:2];
                                            [action failed];
                                        }else{
                                            [overlay postImmediateMessage:@"like success" duration:2];
                                            [action succeed];
                                        }
                                    }];
    }else{
        [PFCloud callFunctionInBackground:@"PlaygroundRemoveLike"
                           withParameters:@{@"feedId": feed.objectId,@"userId":[PFUser currentUser].objectId}
                                    block:^(id response, NSError *error) {
                                        if (error) {
                                            [overlay postImmediateMessage:[NSString stringWithFormat:@"error:%@",error] duration:2];
                                            [action failed];
                                        }else{
                                            [overlay postImmediateMessage:@"delete like success" duration:2];
                                            [action succeed];
                                        }
                                    }];
    }
}

-(void)userDidWishComment:(PlaygroundFeed *)feed{
    if (!self.dummyComment) {
        self.dummyComment = [[UITextView alloc] init];
        self.dummyComment.hidden = true;
        [self.view addSubview:self.dummyComment];
    }
    if (!self.commentAccessory) {
        self.commentAccessory = [[SOQuickCommentView alloc] initWithFrame:CGRectMake(0, 0, [SOUICommons screenWidth], 44)];
        [self.commentAccessory setDelegate:self];
    }
    [self.dummyComment setInputAccessoryView:self.commentAccessory];
    [self.dummyComment becomeFirstResponder];
    [self.commentAccessory becomeFirstResponder];
    self.currentCommentingFeed = feed;
}

-(void)userDidTapDeleteComment:(PlaygroundComment *)comment{
    //find cell index by comment
    NSString* feedId = comment.playgroundFeedId;
    int i=0;
    for (; i<self.objects.count; i++) {
        if ([[(PlaygroundFeed*)self.objects[i] objectId] isEqualToString:feedId]) {
            break;
        }
    }
    NSArray* comments = [(PlaygroundFeed*)self.objects[i] recentComments];
    NSUInteger index;
    if ([comments containsObject:comment]) {
        if (![comment isKindOfClass:[NSMutableArray class]]) {
            comments = [NSMutableArray arrayWithArray:comments];
        }
        index = [comments indexOfObject:comment];
        [(NSMutableArray*)comments removeObjectAtIndex:index];
    }
    [(PlaygroundFeed*)self.objects[i] setRecentComments:comments];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [PFCloud callFunctionInBackground:@"PlaygroundRemoveComment" withParameters:@{@"commentId":comment.objectId} block:^(NSString* response, NSError * error){
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        if (error) {
            NSString* msg = [NSString stringWithFormat:@"delete failed:%@",error];
            [overlay postImmediateMessage:msg animated:true];
            [(NSMutableArray*)comments insertObject:comment atIndex:index];
            [(PlaygroundFeed*)self.objects[i] setRecentComments:comments];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [overlay postImmediateMessage:@"delete comment succeed" animated:true];
        }
    }];
}

-(void)userDidTapNameOfUser:(User *)user{
    UIViewController* c = [self.storyboard instantiateViewControllerWithIdentifier:@"userDetail"];
    [self.navigationController pushViewController:c animated:true];
}

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

-(void)didTapDeleteFeed:(PlaygroundFeed *)feed{
    NSUInteger index = [self.objects indexOfObject:feed];
    //NSLog(@"%d",[self.objects isKindOfClass:[NSMutableArray class]]);
    [feed deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * error){
        NSLog(@"%d,%@",succeeded,error);
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        if (error) {
            [overlay postImmediateMessage:[NSString stringWithFormat:@"delete feed failed:%@",error] duration:2];
            [(NSMutableArray*)self.objects insertObject:feed atIndex:index];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            [overlay postImmediateMessage:@"delete feed succeed" duration:2];
        }
    }];
    //!!!!!!!!!!!!!!!!!!!!!
    //i assume self.objects will always be mutable, as it is in this version
    [(NSMutableArray*)self.objects removeObject:feed];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - SOQuickCommentView
-(void)commentViewDidReturnWithText:(NSString *)text{
    [self.dummyComment resignFirstResponder];
    PlaygroundComment* comment = (PlaygroundComment*)[PFObject objectWithClassName:@"PlaygroundComment"];
    comment.playgroundFeedId = self.currentCommentingFeed.objectId;
    comment.commentOwner = (User*)[PFUser currentUser];
    comment.message = text;
    if (![self.currentCommentingFeed.recentComments isKindOfClass:[NSMutableArray class]]) {
        self.currentCommentingFeed.recentComments = [NSMutableArray arrayWithArray:self.currentCommentingFeed.recentComments];
    }
    [(NSMutableArray*)self.currentCommentingFeed.recentComments insertObject:comment atIndex:0];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.objects indexOfObject:self.currentCommentingFeed] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error){
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        if (error) {
            [overlay postImmediateMessage:[error localizedDescription] duration:2];
            [(NSMutableArray*)self.currentCommentingFeed.recentComments removeObject:comment];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.objects indexOfObject:self.currentCommentingFeed] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        else{
            [overlay postImmediateMessage:@"post comment success" duration:2];
        }
    }];
}

#pragma mark - feed compose controller delegate
-(void)userDidTapCancel{
    NSLog(@"user cancelled composing feed");
}
-(void)userDidFinishComposingFeed:(PlaygroundFeed *)feed{
    NSLog(@"user finished composing feed");
    [(NSMutableArray*)self.objects insertObject:feed atIndex:0];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.objects indexOfObject:self.currentCommentingFeed] inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    [feed saveInBackgroundWithBlock:^(BOOL success, NSError *error){
        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        if (error) {
            [overlay postImmediateMessage:[error localizedDescription] duration:2];
            NSUInteger index = [self.objects indexOfObject:feed];
            [(NSMutableArray*)self.objects removeObjectAtIndex:index];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        else{
            [overlay postImmediateMessage:@"post comment success" duration:2];
        }
    }];
}

#pragma mark - Segue
//- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@""])
//    {
//    }
//}

#pragma mark - Caching
-(void)cacheFeed:(PlaygroundFeed*)feed liked:(BOOL)liked{
    if (liked) {
        if (![self likedForFeed:feed]) {
            [self.likeHistory addObject:feed.objectId];
        }
    }else{
        [self.likeHistory removeObject:feed.objectId];
    }
}
-(BOOL)likedForFeed:(PlaygroundFeed*)feed{
    return [self.likeHistory containsObject:[feed objectId]];
}
@end
