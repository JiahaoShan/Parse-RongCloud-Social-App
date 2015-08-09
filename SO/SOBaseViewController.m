//
//  SOBaseViewController.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOBaseViewController.h"

@implementation SOBaseViewController
const CGFloat messageOverlayWidth = 100.0f;

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void) showMesssage: (NSString*) message {
    UIEdgeInsets insets = {40,15,15,15};
    _messageOverlay = [[SOLabelView alloc] initWithFrame:CGRectMake(0, 0, messageOverlayWidth, messageOverlayWidth) AndUIEdgeInsets:insets];
    _messageOverlay.text = message;
    _messageOverlay.numberOfLines = 0;
    _messageOverlay.lineBreakMode = NSLineBreakByWordWrapping;
    _messageOverlay.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f];
    _messageOverlay.center = self.view.center;
    _messageOverlay.alpha = 0.0f;
    _messageOverlay.textColor = [UIColor whiteColor];
    _messageOverlay.layer.cornerRadius = 8.0f;
    _messageOverlay.clipsToBounds = YES;
    _messageOverlay.textAlignment = NSTextAlignmentCenter;
    
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.center = CGPointMake(messageOverlayWidth/2, 35);
    [activityIndicator startAnimating];
    
    [_messageOverlay addSubview:activityIndicator];

    [self.view addSubview:_messageOverlay];
    
    [UIView animateWithDuration:0.4
                         animations:^{
                             _messageOverlay.alpha = 1.0f;
                         }
                         completion:^(BOOL finished){
                             
                         }];
}

-(void) hideMessage {
    [UIView animateWithDuration:0.4
                     animations:^{
                         _messageOverlay.alpha = 0.0f;
                     }
                     completion:^(BOOL finished){
                         [_messageOverlay removeFromSuperview];
                         _messageOverlay = nil;
                     }];
}

@end
