//
//  SOPersonAvatarView.h
//  SO
//
//  Created by Guanqing Yan on 7/21/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface SOPersonAvatarView : UIView
-(instancetype)initWithFrame:(CGRect)frame;
-(void)setAvatar:(PFFile*)file;
-(void)setName:(NSString*)name;
@end
