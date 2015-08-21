//
//  SODefines.h
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#ifndef SO_SODefines_h
#define SO_SODefines_h

typedef NSString* SOGender;
static NSString* kSOGenderMale = @"Male";
static NSString* kSOGenderFemale = @"Female";
static NSString* kSOGenderNotSpecified = @"NotSpecified";

@interface SOImageURL : NSObject
@property NSURL* thumbnailURL;
@property NSURL* imageURL;
@end

#define kPlaygroundSingleImageHeight 100.0f
//if more than one image, each image is cropped as square
#define kPlaygroundMultipleImageSize 60.0f
#define kPlaygroundImagePadding 8.0f

#endif
