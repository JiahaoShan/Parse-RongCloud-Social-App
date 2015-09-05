//
//  SOUICommons.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOUICommons.h"
#import <CoreGraphics/CoreGraphics.h>
#define SINGLETON_CGFLOAT_IMPLEMENTATION(Name,Expression) \
+(CGFloat)Name{\
static dispatch_once_t onceToken;\
static CGFloat Name = 0.0f; \
dispatch_once(&onceToken,^{\
Name = Expression;\
});\
return Name;\
}
#define SINGLETON_OBJECT_IMPLEMENTATION(Type,Name,Expression) \
    +(Type)Name{\
        static dispatch_once_t onceToken;\
        static Type Name = nil; \
    dispatch_once(&onceToken,^{\
        Name = Expression;\
    });\
    return Name;\
}
#define SINGLETON_OBJECT_IMPLEMENTATION_FAST(Name,Expression) SINGLETON_OBJECT_IMPLEMENTATION(SOUICOMMONS_DECLARATION_TYPE,Name,Expression)

@interface SOUICommons(){
}
@end

@implementation SOUICommons
#define SOUICOMMONS_DECLARATION_TYPE UIColor*
SINGLETON_OBJECT_IMPLEMENTATION_FAST(primaryTintColor, [UIColor colorWithRed:149.0/255 green:165.0/255 blue:165.0/255 alpha:1]);
SINGLETON_OBJECT_IMPLEMENTATION_FAST(textColor, [UIColor whiteColor])
SINGLETON_OBJECT_IMPLEMENTATION_FAST(activeButtonColor, [UIColor blueColor])
SINGLETON_OBJECT_IMPLEMENTATION_FAST(destructiveButtonColor, [UIColor redColor])
SINGLETON_OBJECT_IMPLEMENTATION_FAST(translucentWhite, [UIColor colorWithWhite:1 alpha:1])
SINGLETON_OBJECT_IMPLEMENTATION_FAST(descriptiveTextColor, [UIColor grayColor])
SINGLETON_OBJECT_IMPLEMENTATION_FAST(unavailableMask, [UIColor colorWithWhite:0.1 alpha:0.9])
SINGLETON_OBJECT_IMPLEMENTATION_FAST(backgroundGray, [UIColor grayColor])
SINGLETON_OBJECT_IMPLEMENTATION_FAST(lightBackgroundGray, [UIColor colorWithWhite:0.8 alpha:1])
#undef SOUICOMMONS_DECLARATION_TYPE

#define SOUICOMMONS_DECLARATION_TYPE UIImage*
SINGLETON_OBJECT_IMPLEMENTATION_FAST(likeRedImage, [UIImage imageNamed:@"like"])
SINGLETON_OBJECT_IMPLEMENTATION_FAST(likeGrayImage, [UIImage imageNamed:@"like_gray"])
SINGLETON_OBJECT_IMPLEMENTATION_FAST(feedCommentImage, [UIImage imageNamed:@"comment"])
#undef SOUICOMMONS_DECLARATION_TYPE

SINGLETON_CGFLOAT_IMPLEMENTATION(screenHeight, [[UIScreen mainScreen] bounds].size.height);
SINGLETON_CGFLOAT_IMPLEMENTATION(screenWidth, [[UIScreen mainScreen] bounds].size.width);

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
