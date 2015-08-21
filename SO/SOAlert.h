//
//  SOActionSheetManager.h
//  SO
//
//  Created by Guanqing Yan on 7/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SOUICommons.h"

typedef void (^SOActionHandler) ();
typedef NS_ENUM(NSUInteger, SOAlertType) {
    SOAlertTypeAlert,//if buttons count is less than 2, then buttons are horizontal, other wise buttons are vertically stacked
    SOAlertTypeActionSheet
};

@interface SOAlert : UIView
-(instancetype)initWithType:(SOAlertType)type title:(NSString*)title message:(NSString*)message items:(NSArray*)items didDismiss:(SOActionHandler)dismissAction;
-(void)show;
-(void)dismiss;

+(id)SOActionTypeDefault;
+(id)SOActionTypeDestructive;
+(id)SOActionItemSeperator;
@end
