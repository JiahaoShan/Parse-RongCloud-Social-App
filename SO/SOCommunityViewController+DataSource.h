//
//  SOCommunityViewController+DataSource.h
//  SO
//
//  Created by Guanqing Yan on 7/27/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOCommunityViewController.h"
#import <Parse/Parse.h>
#import "User.h"
@interface SOCommunityViewController (DataSource)
-(PFUser*)currentUser;
//this will automatically cancel previous query
//batch not supported yet
-(void)startQueryFriendsOfUser:(PFUser*)user batch:(int)batch completion:(void(^)(int batchIndex, NSArray* users))completion;
@end
