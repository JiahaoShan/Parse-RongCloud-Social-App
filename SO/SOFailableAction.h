//
//  SOFailableAction.h
//  SO
//
//  Created by Guanqing Yan on 8/9/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^SOFailableActionHandler)();

@interface SOFailableAction : NSObject
-(instancetype)initWithSucceed:(SOFailableActionHandler)succeed failed:(SOFailableActionHandler)failed;
-(void)addFailHandler:(SOFailableActionHandler)failed;
-(void)succeed;
-(void)failed;
@end
