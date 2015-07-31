//
//  SOCommunityTest.m
//  SO
//
//  Created by Guanqing Yan on 8/1/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface SOCommunityTest : XCTestCase

@end

@implementation SOCommunityTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFrameGeneration {
    CGFloat avatarRadius = 95;
    
    int count = 5;
    int round = 0;
    CGFloat rounRadius;
    CGFloat roundAngleStep;
    int currentCount = 0;
    CGFloat currentAngle = 0;
    while (currentCount<count) {
        if (round==0) {
            round++;
            continue;
        }
        CGFloat rounRadius = (round+1) * avatarRadius;
        if (round%1==0) {
            rounRadius = rounRadius / sin(M_PI/3/round);
        }
        //roundAngleStep =  = M_PI/3/round
    }

}

@end
