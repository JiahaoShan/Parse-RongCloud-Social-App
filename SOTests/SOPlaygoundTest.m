//
//  SOPlaygoundTest.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "SOPlaygroundFeedImageView.h"

@interface SOPlaygoundTest : XCTestCase

@end

@implementation SOPlaygoundTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPlaygroundFeedImageViewHeightCalculation {
    // This is an example of a functional test case.
    SOPlaygroundFeedImageView* view = [[SOPlaygroundFeedImageView alloc] init];
//    [view setImages:@[]];
//    XCTAssert(view.frame.size.height == 0.0f, @"height = 0 when image array is empty");
//    [view setImages:@[ [NSNull null] ]];
//    XCTAssert(view.frame.size.height == kPlaygroundSingleImageHeight, @"single image height");
//    view.frame = [[[UIApplication sharedApplication] keyWindow] bounds];
//    [view setImages:@[ [NSNull null],[NSNull null],[NSNull null],[NSNull null] ]];
//    XCTAssert(view.frame.size.height == kPlaygroundMultipleImageSize, @"4 images should still fit in one row");
//    [view setImages:@[ [NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null],[NSNull null] ]];
//    XCTAssert(view.frame.size.height == kPlaygroundMultipleImageSize * 2, @"7 images should use 2 rows");
}

@end
