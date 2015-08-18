//
//  SOUserDefaultManager.m
//  SO
//
//  Created by Jiahao Shan on 8/18/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOUserDefaultManager.h"
#import <Parse/Parse.h>
#import "User.h"
#import "SOCommonStrings.h"


@implementation SOUserDefaultManager

+ (SOUserDefaultManager*)sharedInstance
{
    static SOUserDefaultManager *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[SOUserDefaultManager alloc] init];
    });
    return _sharedInstance;
}

- (id) getRongCloudToken {
    return [self userDefaultsForKey:DEFAULTS_RONG_DEVICE_TOKEN_KEY];
}

- (BOOL)setRongCloudToken:(NSString*)token {
    return [self setUserDefaultsObject:token forKey:DEFAULTS_RONG_DEVICE_TOKEN_KEY];
}

- (id)userDefaultsForKey:(NSString*)key {
    NSMutableDictionary *userInfo = [self getCurrentUserDefaults];
    return [userInfo objectForKey:key];
}

- (BOOL)setUserDefaultsObject:(NSObject *)object forKey:(NSString*)key{
    NSMutableDictionary *userInfo = [self getCurrentUserDefaults];
    [userInfo setObject:object forKey:key];
    return [self saveUserDefaults:userInfo];
}

- (NSMutableDictionary*)getCurrentUserDefaults {
    User * currentUser = [User currentUser];
    NSString* JSONDefault = [[NSUserDefaults standardUserDefaults] objectForKey:currentUser.objectId];
    NSMutableDictionary *userInfo;
    if (!JSONDefault) {
        // NOT EXISTED
        userInfo = [[NSMutableDictionary alloc] init];
    }
    else {
        // EXISTED
        NSError *jsonError;
        NSData *dataDefault = [JSONDefault dataUsingEncoding:NSUTF8StringEncoding];
        userInfo = [NSJSONSerialization JSONObjectWithData:dataDefault
                                                                        options:NSJSONReadingMutableContainers
                                                                          error:&jsonError];
        // WHAT IF ERRORS?
        if (jsonError) return nil;
    }
    return userInfo;
}

- (BOOL) saveUserDefaults: (NSMutableDictionary*)userDefaults {
    if (!userDefaults) return NO;
    User * currentUser = [User currentUser];
    NSError *error = nil;
    NSData *json;
    
    // Dictionary convertable to JSON ?
    if ([NSJSONSerialization isValidJSONObject:userDefaults])
    {
        // Serialize the dictionary
        json = [NSJSONSerialization dataWithJSONObject:userDefaults options:NSJSONWritingPrettyPrinted error:&error];
        
        // If no errors, let's view the JSON
        if (json != nil && error == nil)
        {
            NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            [[NSUserDefaults standardUserDefaults] setObject:jsonString forKey:currentUser.objectId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return YES;
        }
    }
    return NO;
}

@end
