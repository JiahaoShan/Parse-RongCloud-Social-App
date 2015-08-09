//
//  SOBaseViewController.h
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SOLabelView.h"

@interface SOBaseViewController : UIViewController
@property (nonatomic,strong) SOLabelView* messageOverlay;
-(void) hideMessage;
-(void) showMesssage: (NSString*) message;
@end
