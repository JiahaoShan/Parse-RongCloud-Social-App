//
//  SOUICommons.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOUICommons.h"
#import <CoreGraphics/CoreGraphics.h>

@interface SOUICommons(){
}
@end

@implementation SOUICommons

+(UIColor*)primaryTintColor{
    static dispatch_once_t onceToken;
    static UIColor* primaryTint = nil;
    dispatch_once(&onceToken,^{
        primaryTint = [UIColor colorWithRed:149.0/255 green:165.0/255 blue:165.0/255 alpha:1];
        //primaryTint = [UIColor blackColor];
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
+(UIColor*)destructiveButtonColor{
    static dispatch_once_t onceToken;
    static UIColor* destructiveButtonColor = nil;
    dispatch_once(&onceToken,^{
        destructiveButtonColor = [UIColor redColor];
    });
    return destructiveButtonColor;
}
+(UIColor*)descriptiveTextColor{
    static dispatch_once_t onceToken;
    static UIColor* descriptiveTextColor = nil;
    dispatch_once(&onceToken,^{
        descriptiveTextColor = [UIColor grayColor];
    });
    return descriptiveTextColor;
}
+(UIColor*)translucentWhite{
    static dispatch_once_t onceToken;
    static UIColor* translucentWhite = nil;
    dispatch_once(&onceToken,^{
        translucentWhite = [UIColor colorWithWhite:1 alpha:1];
    });
    return translucentWhite;
}
+(UIColor*)unavailableMask{
    static dispatch_once_t onceToken;
    static UIColor* unavailableMask = nil;
    dispatch_once(&onceToken,^{
        unavailableMask = [UIColor colorWithWhite:0.1 alpha:0.9];
    });
    return unavailableMask;
}
+(UIColor*)backgroundGray{
    static dispatch_once_t onceToken;
    static UIColor* backgroundGray = nil;
    dispatch_once(&onceToken,^{
        backgroundGray = [UIColor grayColor];
    });
    return backgroundGray;
}
+(UIColor*)lightBackgroundGray{
    static dispatch_once_t onceToken;
    static UIColor* backgroundGray = nil;
    dispatch_once(&onceToken,^{
        backgroundGray = [UIColor colorWithWhite:0.8 alpha:1];
    });
    return backgroundGray;
}
+(CGFloat)screenHeight{
    return [[UIScreen mainScreen] bounds].size.height;
}
+(CGFloat)screenWidth{
    return [[UIScreen mainScreen] bounds].size.width;
}
+(NSString*)descriptionForDate:(NSDate*)date{
    NSDate* now = [[NSDate alloc] init];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* comp = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date toDate:now options:0];
    if (comp.year!=0) {
        return [NSString stringWithFormat:@"%ld年前",(long)comp.year];
    }else if(comp.month!=0){
        return [NSString stringWithFormat:@"%ld月前",(long)comp.month];
    }else if(comp.day!=0){
        return [NSString stringWithFormat:@"%ld天前",(long)comp.day];
    }
    else if(comp.hour!=0){
        return [NSString stringWithFormat:@"%ld小时前",(long)comp.hour];
    }
    else if(comp.minute!=0){
        return [NSString stringWithFormat:@"%ld分钟前",(long)comp.minute];
    }
    return @"刚刚";
}
+(UIColor*)randomColor{
    CGFloat r = (CGFloat)(arc4random()%255/255.0);
    return [UIColor colorWithHue:r saturation:1 brightness:1 alpha:1];
}
+(UIImage*)opaqueImageOfColor:(UIColor*)color size:(CGSize)size{
    UIImage* image;
    UIGraphicsBeginImageContext(size);
    [color setFill];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+(void)configureNavigationBarLabel:(UILabel*)label{
    label.font = [UIFont boldSystemFontOfSize:19];
    label.textColor = [self textColor];
    label.textAlignment = NSTextAlignmentCenter;
}
@end
