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
    if ([gender isEqualToString:kSOGenderMale]) {
        self.image = [UIImage imageNamed:@"gender-male"];
    }else if([gender isEqualToString:kSOGenderFemale]){
        self.image = [UIImage imageNamed:@"gender-female"];
    }else{
        self.image = [UIImage imageNamed:@"gender-notspecified"];
    }
}
@end
