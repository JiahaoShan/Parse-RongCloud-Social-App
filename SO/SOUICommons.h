//
//  SOUICommons.h
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SOUICommons : NSObject
+(UIColor*)primaryTintColor;
+(UIColor*)textColor;
+(UIColor*)activeButtonColor;//indicated tappable text
+(CGFloat)screenHeight;
+(CGFloat)screenWidth;
+(NSString*)descriptionForDate:(NSDate*)date;
@end
