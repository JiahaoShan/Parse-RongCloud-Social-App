//
//  SOMapBubbleChatRecord.h
//  SO
//
//  Created by Jiahao Shan on 8/29/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SOMapBubbleChatRecord : NSObject

@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSString* userId;
@property (nonatomic, strong) NSString* userName;
@property (nonatomic, strong) UIColor* color;

@end
