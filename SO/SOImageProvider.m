//
//  SOImageProvider.m
//  SO
//
//  Created by Guanqing Yan on 8/21/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOImageProvider.h"
#import "SOAlert.h"
@interface SOImageProvider()
@property (nonatomic,weak) UIViewController* wvc;
@property (nonatomic,strong) SOAlert* choice;
@property (nonatomic,strong) UIImagePickerController* cameraPicker;
@property (nonatomic,strong) ELCImagePickerController* photoPicker;
@end

@implementation SOImageProvider
-(ELCImagePickerController*)photoPicker{
    if (!_photoPicker) {
        _photoPicker = [[ELCImagePickerController alloc] initImagePicker];
        _photoPicker.maximumImagesCount = 9; //Set the maximum number of images to select to 100
        _photoPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
        _photoPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
        _photoPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
        _photoPicker.mediaTypes = @[(NSString *)kUTTypeImage]; //Supports image and movie types
        _photoPicker.imagePickerDelegate = self;
    }
    return _photoPicker;
}
-(UIImagePickerController*)cameraPicker{
    if (!_cameraPicker) {
        self.cameraPicker = [[UIImagePickerController alloc] init];
        [self.cameraPicker setDelegate:self];
        [self.cameraPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    return self.cameraPicker;
}
-(instancetype)initWithViewController:(UIViewController*)vc{
    if (self = [super init]) {
        self.wvc=vc;
        self.limit=9;
        __weak SOImageProvider* wself=self;
        NSArray* items;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            items=@[
                    @{@"title":@"拍一张照片",@"handler":^{
                        [wself.wvc presentViewController:wself.cameraPicker animated:true completion:nil];
                    }},
                    @{@"title":@"从相簿选择照片",@"handler":^{
                        [wself.photoPicker setMaximumImagesCount:wself.limit];
                        [wself.wvc presentViewController:wself.photoPicker animated:true completion:nil];
                    }},
                    [SOAlert SOActionItemSeperator],
                    @{@"title":@"取消"},
                    ];
        }else{
            items=@[
                    @{@"title":@"从相簿选择照片",@"handler":^{
                        [wself.photoPicker setMaximumImagesCount:wself.limit];
                        [wself.wvc presentViewController:wself.photoPicker animated:true completion:nil];
                    }},
                    [SOAlert SOActionItemSeperator],
                    @{@"title":@"取消"},
                    ];
        }
        self.choice = [[SOAlert alloc] initWithType:SOAlertTypeActionSheet title:@"选择一种方式获得图片" message:nil items:items didDismiss:NULL];
    }
    return self;
}
-(void)present{
    [self.choice show];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self.delegate providerDidGetPhotos:@[chosenImage]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self.wvc dismissViewControllerAnimated:YES completion:nil];
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:[info count]];
    for (NSDictionary *dict in info) {
        if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
            if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
                UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
                [images addObject:image];
            } else {
                NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
            }
        }
    }
    [self.delegate providerDidGetPhotos:images];
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self.wvc dismissViewControllerAnimated:YES completion:nil];
}

@end
