//
//  SOActionSheetManager.h
//  SO
//
//  Created by Guanqing Yan on 7/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^SOActionHandler) ();
typedef NS_ENUM(NSUInteger, SOActionType) {
    SOActionTypeDefault,
    SOActionTypeDestructive,
    SOActionTypeCancel
};

//UIActionSheet deprecated in ios8, use this to support all versions

//todo: need testing for ios7 support
@interface SOActionSheetManager : NSObject
-(void)addAction:(NSString*)title type:(SOActionType)type handler:(SOActionHandler)handler;
-(void)showInViewController:(UIViewController*)viewController;
-(void)dismiss;
@end
