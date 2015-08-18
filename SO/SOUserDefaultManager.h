//
//  SOUserDefaultManager.h
//  SO
//
//  Created by Jiahao Shan on 8/18/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOUserDefaultManager : NSObject

+ (SOUserDefaultManager*)sharedInstance;

- (id)userDefaultsForKey:(NSString*)key;
- (BOOL)setUserDefaultsObject:(NSObject *)object forKey:(NSString*)key;

- (id) getRongCloudToken;
- (BOOL) setRongCloudToken:(NSString*)token;

@end
