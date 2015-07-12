//
//  SODefines.h
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#ifndef SO_SODefines_h
#define SO_SODefines_h

typedef enum{
    Male,
    Female,
    NotSpecified
}SOGender;

@interface SOImageURL : NSObject
@property NSURL* thumbnailURL;
@property NSURL* imageURL;
@end

#endif
