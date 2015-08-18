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
#import <RongIMLib/RongIMLib.h>
#import "DBHelper.h"
#import "RCDataBaseManager.h"


@implementation SODataManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        //设置信息提供者
        [[RCIM sharedRCIM] setUserInfoDataSource:self];
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

- (void)getUserInfoWithUserId:(NSString *)userId completion:(void(^)(RCUserInfo* userInfo))completion
{
    if ([userId length] == 0) return;
    RCUserInfo *userInfo=[[RCDataBaseManager shareInstance] getUserByUserId:userId];
    if (userInfo==nil) {
            PFQuery *query = [User query];
//            query.cachePolicy = kPFCachePolicyNetworkElseCache;
            [query selectKeys:@[UserNameKey, UserPortraitUriKey]];
            [query getObjectInBackgroundWithId:userId block:^(PFObject *object, NSError *error) {
            if (object == nil) return;
            User* user = (User *)object;
            PFFile* imageFile = [user objectForKey:UserPortraitUriKey];
            RCUserInfo *person = [[RCUserInfo alloc] initWithUserId:[user objectId] name:[user objectForKey:UserNameKey] portrait:imageFile.url];
            [[RCDataBaseManager shareInstance] insertUserToDB:person];
            completion(person);
        }];
    }
    else {
        completion(userInfo);
    };
}

- (void)cacheAllUserInfo:(void (^)())completion
{
    PFQuery *query = [User query];
    [query whereKey:@"University" equalTo:[User currentUser].university];
    [query selectKeys:@[UserNameKey, UserPortraitUriKey]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error) {
            [[RCDataBaseManager shareInstance] clearFriendsData];
            [users enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
                PFFile* imageFile = [user objectForKey:UserPortraitUriKey];
                RCUserInfo *person = [[RCUserInfo alloc] initWithUserId:[user objectId] name:[user objectForKey:UserNameKey] portrait:imageFile.url];
                [[RCDataBaseManager shareInstance] insertUserToDB:person];
            }];
            completion();
            
        }
    }];
}

- (void)cacheAllFriends:(void (^)())completion
{
    PFQuery *query = [User query];
    [query whereKey:@"University" equalTo:[User currentUser].university];
    [query selectKeys:@[UserNameKey, UserPortraitUriKey]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
        if (!error) {
            [[RCDataBaseManager shareInstance] clearFriendsData];
            [users enumerateObjectsUsingBlock:^(User *user, NSUInteger idx, BOOL *stop) {
                PFFile* imageFile = [user objectForKey:UserPortraitUriKey];
                RCUserInfo *person = [[RCUserInfo alloc] initWithUserId:[user objectId] name:[user objectForKey:UserNameKey] portrait:imageFile.url];
                [[RCDataBaseManager shareInstance] insertFriendToDB:person];
            }];
            completion();

        }
    }];
}

- (void)cacheAllData:(void (^)())completion
{
    __weak SODataManager *weakSelf = self;
    [self cacheAllUserInfo:^{
            [weakSelf cacheAllFriends:^{
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notFirstTimeLogin"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                completion();
            }];
    }];
}

- (NSArray *)getAllUserInfo:(void (^)())completion
{
    NSArray *allUserInfo = [[RCDataBaseManager shareInstance] getAllUserInfo];
    if (!allUserInfo.count) {
        [self cacheAllUserInfo:^{
            completion();
        }];
    }
    return allUserInfo;
    return nil;
}


- (NSArray *)getAllFriends:(void (^)())completion
{
    NSArray *allUserInfo = [[RCDataBaseManager shareInstance] getAllFriends];
    if (!allUserInfo.count) {
        [self cacheAllFriends:^{
            completion();
        }];
    }
    return allUserInfo;
    return nil;
}

@end
