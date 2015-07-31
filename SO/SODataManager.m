//
//  SODataManager.m
//  SO
//
//  Created by Jiahao Shan on 7/30/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SODataManager.h"
#import "User.h"
#import "SOCommonStrings.h"


@implementation SODataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        //设置信息提供者
        [[RCIM sharedRCIM] setUserInfoDataSource:self];
       // [[RCIM sharedRCIM] setGroupInfoDataSource:self];
        
        //同步群组
       // [self syncGroups];
    }
    return self;
}

+ (SODataManager*)sharedInstance
{
    static SODataManager *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[SODataManager alloc] init];
    });
    return _sharedInstance;
}

-(void) syncGroups
{
    //开发者调用自己的服务器接口获取所属群组信息，同步给融云服务器，也可以直接
    //客户端创建，然后同步
//    [RCDHTTPTOOL getMyGroupsWithBlock:^(NSMutableArray *result) {
//        if ([result count]) {
//            //同步群组
//            [[RCIMClient sharedRCIMClient] syncGroups:result
//                                              success:^{
//                                                  //DebugLog(@"同步成功!");
//                                              } error:^(RCErrorCode status) {
//                                                  //DebugLog(@"同步失败!  %ld",(long)status);
//                                                  
//                                              }];
//        }
//    }];
//    
//    [RCDHTTPTOOL getAllGroupsWithCompletion:^(NSMutableArray *result) {
//        
//    }];
    
}

/**
 *此方法中要提供给融云用户的信息，建议缓存到本地，然后改方法每次从您的缓存返回
 */
- (void)getUserInfoWithUserId:(NSString *)userId completion:(void(^)(RCUserInfo* userInfo))completion
{
    RCUserInfo *user = nil;
    PFQuery *query = [User query];
    [query fromLocalDatastore];
    User* targetUser = (User *)[query getObjectWithId:userId];
    if (!targetUser) {
        // Error, Fetch???
        PFQuery *query = [User query];
        //        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        User* targetUser = (User *)[query getObjectWithId:userId];
        if (!targetUser) {
            // User does not even exist online, must be an Error, Fetch???
            NSLog(@"userId not even existed online.");
        }
        else {
            user = [[RCUserInfo alloc] initWithUserId:targetUser.objectId
                                                 name:[targetUser objectForKey:UserNameKey]
                                             portrait:@"http://img.135q.com/2015-06/20/14348061890006.jpg"];
        }
    }
    else {
        user = [[RCUserInfo alloc] initWithUserId:targetUser.objectId
                                             name:[targetUser objectForKey:UserNameKey]
                                         portrait:@"http://img.135q.com/2015-06/20/14348061890006.jpg"];
    }
    return completion(user);
}

- (void)getGroupInfoWithGroupId:(NSString*)groupId completion:(void (^)(RCGroup*))completion
{
    if ([groupId length] == 0)
        return;
    
//    //开发者调自己的服务器接口根据userID异步请求数据
//    [RCDHTTPTOOL getGroupByID:groupId
//            successCompletion:^(RCGroup *group)
//     {
//         completion(group);
//     }];
}

- (NSArray *)getAllUserInfo:(void (^)())completion
{
//    NSArray *allUserInfo = [[RCDataBaseManager shareInstance] getAllUserInfo];
//    if (!allUserInfo.count) {
//        [self cacheAllUserInfo:^{
//            completion();
//        }];
//    }
//    return allUserInfo;
    return nil;
}
/*
 * 获取所有群组信息
 */
- (NSArray *)getAllGroupInfo:(void (^)())completion
{
//    NSArray *allUserInfo = [[RCDataBaseManager shareInstance] getAllGroup];
//    if (!allUserInfo.count) {
//        [self cacheAllGroup:^{
//            completion();
//        }];
//    }
//    return allUserInfo;
    return nil;
}

- (NSArray *)getAllFriends:(void (^)())completion
{
//    NSArray *allUserInfo = [[RCDataBaseManager shareInstance] getAllFriends];
//    if (!allUserInfo.count) {
//        [self cacheAllFriends:^{
//            completion();
//        }];
//    }
//    return allUserInfo;
    return nil;
}

@end
