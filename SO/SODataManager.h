//
//  SODataManager.h
//  SO
//
//  Created by Jiahao Shan on 7/30/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMKit/RongIMKit.h>
#import <Parse/Parse.h>

#define SODataSource [SODataManager sharedInstance]


@interface SODataManager : NSObject<RCIMUserInfoDataSource>
//,RCIMGroupInfoDataSource>

+ (SODataManager*)sharedInstance;

/**
 *  同步自己的所属群组到融云服务器,修改群组信息后都需要调用同步
 */
-(void) syncGroups;

/*
 * 当客户端第一次运行时，调用此接口初始化所有用户数据。
 */
- (void)cacheAllData:(void (^)())completion;
/*
 * 获取所有用户信息
 */
- (NSArray *)getAllUserInfo:(void (^)())completion;
/*
 * 获取所有群组信息
 */
- (NSArray *)getAllGroupInfo:(void (^)())completion;
/*
 * 获取所有好友信息
 */
- (NSArray *)getAllFriends:(void (^)())completion;
@end
