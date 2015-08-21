//
//  SOImageProvider.h
//  SO
//
//  Created by Guanqing Yan on 8/21/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "ELCImagePickerHeader.h"
@protocol SOImageProviderProtocol
@required
-(void)providerDidGetPhotos:(NSArray*)photos;
@end
@interface SOImageProvider : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ELCImagePickerControllerDelegate>
@property (nonatomic,assign) id<SOImageProviderProtocol>delegate;
-(instancetype)initWithViewController:(UIViewController*)vc;
@property (nonatomic) NSInteger limit;
-(void)present;//present the action sheet to choose/take pictures
@end
