//
//  SOPlaygroundMainController.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundMainController.h"
#import <Parse/Parse.h>

@implementation SOPlaygroundMainController
- (IBAction)cloudTest:(UIButton *)sender {
    [PFCloud callFunctionInBackground:@"getToken"
                       withParameters:@{@"userId": @"xxxx", @"name" : @"Shawn", @"portraitUri" : @"http://abc.com/myportrait.jpg"}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSDictionary* json = [NSJSONSerialization
                                                              JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                                              options:kNilOptions 
                                                              error:&error];

                                    }
                                }];
    
}

@end
