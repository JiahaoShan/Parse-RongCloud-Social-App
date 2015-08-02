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
        primaryTint = [UIColor colorWithRed:232.0/255 green:32.0/255 blue:32.0/255 alpha:1];
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
+(UIColor*)activeButtonColor{
    static dispatch_once_t onceToken;
    static UIColor* activeButtonColor = nil;
    dispatch_once(&onceToken,^{
        activeButtonColor = [UIColor blueColor];
    });
    return activeButtonColor;
}
+(CGFloat)screenHeight{
    return [[UIScreen mainScreen] bounds].size.height;
}
+(CGFloat)screenWidth{
    return [[UIScreen mainScreen] bounds].size.width;
}
@end
