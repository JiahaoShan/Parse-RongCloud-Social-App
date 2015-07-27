//
//  SOPersonalInfoTableViewController.m
//  SO
//
//  Created by Jiahao Shan on 7/26/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPersonalInfoTableViewController.h"
#import "PersonalInfoSettingTableViewCell.h"

@interface SOPersonalInfoTableViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) BOOL initialized;

@end

@implementation SOPersonalInfoTableViewController

static NSString *PersonalInfoSettingTableViewCellIdentifier = @"kPersonalInfoSettingTableViewCell";

//- (instancetype) init {
//    if (self = [self initWithStyle:UITableViewStyleGrouped]) {
//        // DO SOMETHING
//    }
//    return self;
//}
//
//- (instancetype)initWithStyle:(UITableViewStyle)style {
//    self = [super initWithStyle:style];
//    if (self) {
//        //[self initialize];
//    }
//    return self;
//}

-(void)awakeFromNib{
    [super awakeFromNib];
    //[self initialize];
}

//-(void)initialize{
//    if (!_initialized) {
//        _initialized = true;
//        self.parseClassName = @"PlaygroundFeed";
//        self.pullToRefreshEnabled = YES;
//        self.paginationEnabled = YES;
//        self.objectsPerPage = 10;
//    }
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self.tableView registerNib:[UINib nibWithNibName:@"PersonalInfoSettingTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:PersonalInfoSettingTableViewCellIdentifier];

    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(reloadPersonalInfo:)
                  forControlEvents:UIControlEventValueChanged];
    self.edgesForExtendedLayout = UIRectEdgeAll;
    // TODO: HARD CODE : NOT GOOD
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 49 , 0.0f);
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
//-(BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
//    return false;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//
//}
//
//#pragma mark - UITableViewDataSource
//
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [super tableView:tableView
                       cellForRowAtIndexPath:indexPath];

    
    if (!self.initialized && indexPath.row + indexPath.section == 0) {
        UIImageView *pic = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gender-male"]];
        UIView *picContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 74)];
        picContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        picContainer.contentMode = UIViewContentModeRight;
        pic.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin ;
        pic.center = CGPointMake(0, 74/2);
        [picContainer addSubview:pic];
        [cell.contentView addSubview:picContainer];
        self.initialized = YES;
       // cell = [[PersonalInfoSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PersonalInfoSettingTableViewCellIdentifier];
    }

    
   // cell.attributeLabel.text = @"123";
   // cell.valueLabel.text = @"234";
    
    return cell;
}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (indexPath.section + indexPath.row == 0) {
//        return 64;
//    }
//    return 44;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 2;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 8;
//}

- (void) reloadPersonalInfo: (id) sender {
    [self reloadData];
}

- (void)reloadData
{
    // Reload table data
    [self.tableView reloadData];
    
    // End the refreshing
    if (self.refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Last update: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        [self.refreshControl endRefreshing];
    }
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
