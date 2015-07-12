//
//  SOUICommons.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOUICommons.h"

@interface SOUICommons(){
}
@end

@implementation SOUICommons

+(UIColor*)primaryTintColor{
    static dispatch_once_t onceToken;
    static UIColor* primaryTint = nil;
    dispatch_once(&onceToken,^{
        primaryTint = [UIColor colorWithRed:0.78 green:0.23 blue:0.63 alpha:1];
    });
    return primaryTint;
}

+(UIColor*)textColor{
    static dispatch_once_t onceToken;
    static UIColor* primaryTint = nil;
    dispatch_once(&onceToken,^{
        primaryTint = [UIColor whiteColor];
    });
    return primaryTint;
}
@end
