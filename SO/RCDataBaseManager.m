//
//  RCDataBaseManager.m
//  RCloudMessage
//
//  Created by 杜立召 on 15/6/3.
//  Copyright (c) 2015年 dlz. All rights reserved.
//

#import "RCDataBaseManager.h"
//#import "RCDGroupInfo.h"
//#import "RCDUserInfo.h"
#import "RCDHttpTool.h"
#import "DBHelper.h"

@implementation RCDataBaseManager

static NSString * const userTableName = @"USERTABLE";
static NSString * const groupTableName = @"GROUPTABLEV2";
static NSString * const friendTableName = @"FRIENDTABLE";

+ (RCDataBaseManager*)shareInstance
{
    static RCDataBaseManager* instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[[self class] alloc] init];
        [instance CreateUserTable];
    });
    return instance;
}

//创建用户存储表
-(void)CreateUserTable
{
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        if (![DBHelper isTableOK: userTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE USERTABLE (id integer PRIMARY KEY autoincrement, userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE unique INDEX idx_userid ON USERTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
        
        if (![DBHelper isTableOK: groupTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE GROUPTABLEV2 (id integer PRIMARY KEY autoincrement, groupId text,name text, portraitUri text,inNumber text,maxNumber text ,introduce text ,creatorId text,creatorTime text, isJoin text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE unique INDEX idx_groupid ON GROUPTABLEV2(groupId);";
            [db executeUpdate:createIndexSQL];
        }
        if (![DBHelper isTableOK: friendTableName withDB:db]) {
            NSString *createTableSQL = @"CREATE TABLE FRIENDTABLE (id integer PRIMARY KEY autoincrement, userid text,name text, portraitUri text)";
            [db executeUpdate:createTableSQL];
            NSString *createIndexSQL=@"CREATE unique INDEX idx_friendId ON FRIENDTABLE(userid);";
            [db executeUpdate:createIndexSQL];
        }
    }];
    
}

//存储用户信息
-(void)insertUserToDB:(RCUserInfo*)user
{
    NSString *insertSql = @"REPLACE INTO USERTABLE (userid, name, portraitUri) VALUES (?, ?, ?)";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:insertSql,user.userId,user.name,user.portraitUri];
    }];
    });
}
//从表中获取用户信息
-(RCUserInfo*) getUserByUserId:(NSString*)userId
{
    __block RCUserInfo *model = nil;
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE where userid = ?",userId];
        while ([rs next]) {
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
        }
        [rs close];
    }];
    return model;
}

//从表中获取所有用户信息
-(NSArray *) getAllUserInfo
{
    NSMutableArray *allUsers = [NSMutableArray new];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM USERTABLE"];
        while ([rs next]) {
            RCUserInfo *model;
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

//存储好友信息
-(void)insertFriendToDB:(RCUserInfo *)friend
{
    NSString *insertSql = @"REPLACE INTO FRIENDTABLE (userid, name, portraitUri) VALUES (?, ?, ?)";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
        [queue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:insertSql,friend.userId, friend.name, friend.portraitUri];
        }];
    });
    
    
}

//从表中获取所有好友信息 //RCUserInfo
-(NSArray *) getAllFriends
{
    NSMutableArray *allUsers = [NSMutableArray new];
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM FRIENDTABLE"];
        while ([rs next]) {
            RCUserInfo *model;
            model = [[RCUserInfo alloc] init];
            model.userId = [rs stringForColumn:@"userid"];
            model.name = [rs stringForColumn:@"name"];
            model.portraitUri = [rs stringForColumn:@"portraitUri"];
            [allUsers addObject:model];
        }
        [rs close];
    }];
    return allUsers;
}

//清空群组缓存数据
-(void)clearGroupsData
{
    NSString *deleteSql = @"DELETE FROM GROUPTABLEV2";
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

//清空好友缓存数据
-(void)clearFriendsData
{
    NSString *deleteSql = @"DELETE FROM FRIENDTABLE";
    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
    [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:deleteSql];
    }];
}

////存储群组信息
//-(void)insertGroupToDB:(RCDGroupInfo *)group
//{
//    NSString *insertSql = @"REPLACE INTO GROUPTABLEV2 (groupId, name,portraitUri,inNumber,maxNumber,introduce,creatorId,creatorTime,isJoin) VALUES (?,?,?,?,?,?,?,?,?)";
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
//    [queue inDatabase:^(FMDatabase *db) {
//        [db executeUpdate:insertSql,group.groupId, group.groupName,group.portraitUri,group.number,group.maxNumber,group.introduce,group.creatorId,group.creatorTime,[NSString stringWithFormat:@"%d",group.isJoin]];
//    }];
//    });
//
//}
////从表中获取群组信息
//-(RCDGroupInfo*) getGroupByGroupId:(NSString*)groupId
//{
//    __block RCDGroupInfo *model = nil;
//    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
//    [queue inDatabase:^(FMDatabase *db) {
//        FMResultSet *rs = [db executeQuery:@"SELECT * FROM GROUPTABLEV2 where groupId = ?",groupId];
//        while ([rs next]) {
//            model = [[RCDGroupInfo alloc] init];
//            model.groupId = [rs stringForColumn:@"groupId"];
//            model.groupName = [rs stringForColumn:@"name"];
//            model.portraitUri = [rs stringForColumn:@"portraitUri"];
//            model.number=[rs stringForColumn:@"inNumber"];
//            model.maxNumber=[rs stringForColumn:@"maxNumber"];
//            model.introduce=[rs stringForColumn:@"introduce"];
//            model.creatorId=[rs stringForColumn:@"creatorId"];
//            model.creatorTime=[rs stringForColumn:@"creatorTime"];
//            model.isJoin=[rs boolForColumn:@"isJoin"];
//
//        }
//        [rs close];
//    }];
//    return model;
//}
//
////从表中获取所有群组信息
//-(NSArray *) getAllGroup
//{
//    NSMutableArray *allUsers = [NSMutableArray new];
//    FMDatabaseQueue *queue = [DBHelper getDatabaseQueue];
//    [queue inDatabase:^(FMDatabase *db) {
//        FMResultSet *rs = [db executeQuery:@"SELECT * FROM GROUPTABLEV2"];
//        while ([rs next]) {
//            RCDGroupInfo *model;
//            model = [[RCDGroupInfo alloc] init];
//            model.groupId = [rs stringForColumn:@"groupId"];
//            model.groupName = [rs stringForColumn:@"name"];
//            model.portraitUri = [rs stringForColumn:@"portraitUri"];
//            model.number=[rs stringForColumn:@"inNumber"];
//            model.maxNumber=[rs stringForColumn:@"maxNumber"];
//            model.introduce=[rs stringForColumn:@"introduce"];
//            model.creatorId=[rs stringForColumn:@"creatorId"];
//            model.creatorTime=[rs stringForColumn:@"creatorTime"];
//            model.isJoin=[rs boolForColumn:@"isJoin"];
//            [allUsers addObject:model];
//        }
//        [rs close];
//    }];
//    return allUsers;
//}
@end
