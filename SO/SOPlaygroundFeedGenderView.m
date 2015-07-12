//
//  SOPlaygroundFeedGenderView.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedGenderView.h"

@implementation SOPlaygroundFeedGenderView
-(void)setGender:(SOGender)gender{
    switch (gender) {
        case Male:
            self.image = [UIImage imageNamed:@"gender-male"];
            break;
        case Female:
            self.image = [UIImage imageNamed:@"gender-female"];
            break;
        case NotSpecified:
            self.image = [UIImage imageNamed:@"gender-notspecified"];
            break;
        default:
            break;
    }
}
@end
