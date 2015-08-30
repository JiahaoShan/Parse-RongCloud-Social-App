//
//  SOTableViewController.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOTableViewController.h"
#import "SOUICommons.h"

@interface SOTableViewController()<UITableViewDelegate>
@end

@implementation SOTableViewController

-(void)viewDidLoad{
    [super viewDidLoad];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([scrollView contentOffset].y + scrollView.bounds.size.height >= [scrollView contentSize].height-20) {
        //简单的判断一下接下来还有没有吧，要不然每到最后一卡一卡的也不好
        if((self.objects.count % self.objectsPerPage)==0){
            NSLog(@"should refresh");
            [self loadNextPage];
        }
    }
}
@end
