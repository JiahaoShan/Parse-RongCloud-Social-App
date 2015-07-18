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

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface SOPlaygroundMainController()<UITableViewDataSource,UITableViewDelegate,SOPlaygroundFeedCellDelegate>
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

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
                        object:(PFObject *)object {
    if (indexPath.row>=self.objects.count) {
        return nil;//[tableView dequeueReusableCellWithIdentifier:@"loadMore"];
    }
    SOPlaygroundFeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    [cell configureWithData:object];
    cell.delegate = self;
    return cell;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if (indexPath.row == self.objects.count && self.paginationEnabled) {
//        // Load More Cell
//        [self loadNextPage];
//    }
//    else{
//        PFObject *selectedObject = [self objectAtIndexPath:indexPath];
//        // ... do something else
//    }
//}

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
#pragma mark - UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.objects.count && self.paginationEnabled) {
        return 44;
    }
    return [SOPlaygroundFeedCell estimatedHeightForData:[self.objects objectAtIndex:indexPath.row]];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.objects.count && self.paginationEnabled) {
        return 44;
    }
    return [SOPlaygroundFeedCell estimatedHeightForData:[self.objects objectAtIndex:indexPath.row]];
}
#pragma mark - SOPlaygroundFeedCellDelegate

-(void)cell:(SOPlaygroundFeedCell *)cell didTapImageAtIndex:(NSUInteger)index{
    NSIndexPath* cellIndex = [self.tableView indexPathForCell:cell];
    PFFile* image = self.objects[cellIndex.row][@"images"][index];
    SOImageViewController* iv = [[SOImageViewController alloc] init];
    [iv setImage:image];
    [self.navigationController pushViewController:iv animated:true];
}

#pragma mark - Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@""])
    {
    }
}


@end
