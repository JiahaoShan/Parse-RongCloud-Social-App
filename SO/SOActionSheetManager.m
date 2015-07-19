//
//  SOActionSheetManager.m
//  SO
//
//  Created by Guanqing Yan on 7/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOActionSheetManager.h"

@interface SOActionSheetManager() <UIActionSheetDelegate>
@property (nonatomic) NSMutableArray* titles;
@property (nonatomic) NSMutableArray* types;
@property (nonatomic) NSMutableArray* handlers;
@property (nonatomic) UIActionSheet* actionSheet;
@property (nonatomic) UIAlertController* alertController;
@end

@implementation SOActionSheetManager
-(instancetype)init{
    self = [super init];
    if (!_titles) {
        _titles = [[NSMutableArray alloc] init];
    }else {
        [_titles removeAllObjects];
    }
    if (!_types) {
        _types = [[NSMutableArray alloc] init];
    }else {
        [_types removeAllObjects];
    }
    if (!_handlers) {
        _handlers = [[NSMutableArray alloc] init];
    }else {
        [_handlers removeAllObjects];
    }
    return self;
}
-(void)addAction:(NSString*)title type:(SOActionType)type handler:(SOActionHandler)handler{
    [self.titles addObject:title];
    [self.types addObject:@(type)];
    [self.handlers addObject:handler];
}
-(void)showInViewController:(UIViewController*)viewController{
    if ([[UIDevice currentDevice].systemVersion floatValue]<8) {
        self.actionSheet = [[UIActionSheet alloc] init];
        self.actionSheet.delegate = self;
        for (int i = 0; i<self.titles.count; i++) {
            [self.actionSheet addButtonWithTitle:self.titles[i]];
            if ([self.types[i] integerValue]==SOActionTypeDestructive) {
                [self.actionSheet setDestructiveButtonIndex:i];
            }else if ([self.types[i] integerValue]==SOActionTypeCancel){
                [self.actionSheet setCancelButtonIndex:i];
            }
        }
        [self.actionSheet showInView:viewController.view];
    }else{
        self.alertController = [[UIAlertController alloc] init];
        for (int i = 0; i<self.titles.count; i++) {
            UIAlertActionStyle style;
            switch ([self.types[i] integerValue]) {
                case SOActionTypeDestructive:
                    style = UIAlertActionStyleDestructive;
                    break;
                case SOActionTypeCancel:
                    style = UIAlertActionStyleCancel;
                    break;
                default:
                    style = UIAlertActionStyleDefault;
                    break;
            }
            UIAlertAction* action = [UIAlertAction actionWithTitle:self.titles[i] style:style handler:^(UIAlertAction *action) {
                SOActionHandler handler = self.handlers[i];
                handler();
            }];
            [self.alertController addAction:action];
        }
        [viewController presentViewController:self.alertController animated:true completion:nil];
    }
}
-(void)dismiss{
    if ([[UIDevice currentDevice].systemVersion floatValue]<8) {
        [self.actionSheet dismissWithClickedButtonIndex:[self.actionSheet cancelButtonIndex] animated:true];
    }else{
        [self.alertController.presentingViewController dismissViewControllerAnimated:true completion:nil];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    SOActionHandler handler = self.handlers[buttonIndex];
    handler();
}

@end
