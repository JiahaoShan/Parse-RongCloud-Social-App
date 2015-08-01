//
//  ViewController.m
//  SOBetterTableViewDevelopment
//
//  Created by Guanqing Yan on 8/1/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "ViewController.h"
#import "VariableSizeCell.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) NSMutableDictionary* cellCache;
@end

@implementation ViewController

- (void)viewDidLoad {
    self.cellCache = [[NSMutableDictionary alloc] init];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 20;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat t1 = CFAbsoluteTimeGetCurrent();
    VariableSizeCell* cell = [self.cellCache objectForKey:indexPath];
    if (cell) {
        return cell.frame.size.height;
    }
    cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [self.cellCache setObject:cell forKey:indexPath];
    CGFloat t2 = CFAbsoluteTimeGetCurrent();
    NSLog(@"height:%f for %d : %f",cell.frame.size.height,indexPath.row,(t2-t1)*1000);
    return cell.frame.size.height;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat t1 = CFAbsoluteTimeGetCurrent();
    VariableSizeCell* cell = [self.cellCache objectForKey:indexPath];
    if (cell) {
        return cell;
    }
    cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[VariableSizeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    [cell setContent1:@"********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************" andContent2:@"1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111"];
    [cell layoutIfNeeded];
    [cell layoutIfNeeded];
    [self.cellCache setObject:cell forKey:indexPath];
    CGFloat t2 = CFAbsoluteTimeGetCurrent();
    //NSLog(@"cell for %@ : %f",indexPath,(t2-t1)*1000);
    return cell;
}

@end
