//
//  SOPersonalInfoTableViewController.h
//  SO
//
//  Created by Jiahao Shan on 7/26/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOTableViewController.h"

@interface SOPersonalInfoTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *loveLabel;
@property (weak, nonatomic) IBOutlet UILabel *hometownLabel;
@property (weak, nonatomic) IBOutlet UILabel *schoolLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *dormLabel;

@end
