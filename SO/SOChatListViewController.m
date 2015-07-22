//
//  SOChatListViewController.m
//  SO
//
//  Created by Jiahao Shan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOChatListViewController.h"
#import "SOConversationViewController.h"
#import "SOUICommons.h"
#import <RongIMKit/RongIMKit.h>
#import <RongIMKit/RCConversationListViewController.h>
#import <RongIMKit/RCConversationViewController.h>


@interface SOChatListViewController ()


@end

@implementation SOChatListViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self =[super initWithCoder:aDecoder];
    if (self) {
        //设置要显示的会话类型
        [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE),@(ConversationType_SYSTEM)]];
        
        //聚合会话类型
        [self setCollectionConversationType:@[]];
        
        //设置为不用默认渲染方式
//        self.tabBarItem.image = [[UIImage imageNamed:@"icon_chat"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        self.tabBarItem.selectedImage = [[UIImage imageNamed:@"icon_chat_hover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        
        // _myDataSource = [NSMutableArray new];
        
        // [self setConversationAvatarStyle:RCUserAvatarCycle];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [SOUICommons primaryTintColor];
    self.navigationController.navigationBar.tintColor = [SOUICommons textColor];
    
    //自定义导航标题颜色
    //[self setNavigationTitle:@"会话" textColor:[UIColor whiteColor]];
    //[self.navigationItem.rightBarButtonItem.customView setHidden:YES];
    //自定义导航左右按钮
//    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(leftBarButtonItemPressed:)];
//    [leftButton setTintColor:[UIColor whiteColor]];
//    self.navigationItem.leftBarButtonItem = leftButton;
//    
//    //自定义导航左右按钮
//    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]initWithTitle:@"选择" style:UIBarButtonItemStyleBordered target:self action:@selector(rightBarButtonItemPressed:)];
//    [rightButton setTintColor:[UIColor whiteColor]];
//    self.navigationItem.rightBarButtonItem = rightButton;
    
    //自定义backGroundView
//    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 640)];
//    [v setBackgroundColor:[UIColor lightGrayColor]];
//    [self setBackgroundView:v];
//    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //设置tableView样式
    self.conversationListTableView.separatorColor = [UIColor redColor];
    self.conversationListTableView.tableFooterView = [UIView new];
    //    self.conversationListTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 12)];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UILabel *titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    titleView.font = [UIFont boldSystemFontOfSize:19];
    titleView.textColor = [UIColor whiteColor];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.text = @"会话";
    self.tabBarController.navigationItem.titleView = titleView;
    
//    //自定义rightBarButtonItem
//    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 17, 17)];
//    [rightBtn setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
//    [rightBtn addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
//    [rightBtn setTintColor:[UIColor whiteColor]];
//    self.tabBarController.navigationItem.rightBarButtonItem = rightButton;
    [self notifyUpdateUnreadMessageCount];
    
}

- (void)updateBadgeValueForTabBarItem
{
    __weak typeof(self) __weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        int count = [[RCIMClient sharedRCIMClient]getUnreadCount:self.displayConversationTypeArray];
        if (count>0) {
            __weakSelf.tabBarItem.badgeValue = [[NSString alloc]initWithFormat:@"%d",count];
        }else
        {
            __weakSelf.tabBarItem.badgeValue = nil;
        }
        
    });
}

//*********************插入自定义Cell*********************//

//插入自定义会话model
-(NSMutableArray *)willReloadTableData:(NSMutableArray *)dataSource
{
    
    for (int i=0; i<dataSource.count; i++) {
        RCConversationModel *model = dataSource[i];
        //筛选请求添加好友的系统消息，用于生成自定义会话类型的cell
        if(model.conversationType == ConversationType_SYSTEM && [model.lastestMessage isMemberOfClass:[RCContactNotificationMessage class]])
        {
            model.conversationModelType = RC_CONVERSATION_MODEL_TYPE_CUSTOMIZATION;
        }
    }
    
    return dataSource;
}

////左滑删除
-(void)rcConversationListTableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //可以从数据库删除数据
    //RCConversationModel *model = self.conversationListDataSource[indexPath.row];
    //[_myDataSource removeObject:model];
    //[[RCIMClient sharedRCIMClient] removeConversation:ConversationType_SYSTEM targetId:model.targetId];
    [self.conversationListDataSource removeObjectAtIndex:indexPath.row];
    [self.conversationListTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onSelectedTableRow:(RCConversationModelType)conversationModelType conversationModel:(RCConversationModel *)model atIndexPath:(NSIndexPath *)indexPath
{
    SOConversationViewController *conversationVC = [[SOConversationViewController alloc]init];
    conversationVC.conversationType =model.conversationType;
    conversationVC.targetId = model.targetId;
    conversationVC.userName =model.conversationTitle;
    conversationVC.title = model.conversationTitle;
    conversationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:conversationVC animated:YES];
}

-(void)rightBarButtonItemPressed:(id)sender
{
    // 您需要根据自己的 App 选择场景触发聊天。这里的例子是一个 Button 点击事件。
    SOConversationViewController *conversationVC = [[SOConversationViewController alloc]init];
    conversationVC.conversationType =ConversationType_PRIVATE; //会话类型，这里设置为 PRIVATE 即发起单聊会话。
    conversationVC.targetId = @"WMCqSrLKU0"; // 接收者的 targetId，这里为举例。
    conversationVC.userName = @"GuanqingYan"; // 接受者的 username，这里为举例。
    conversationVC.title = @"name_xxx"; // 会话的 title。
    
    // 把单聊视图控制器添加到导航栈。
    [self.navigationController pushViewController:conversationVC animated:YES];
    
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
