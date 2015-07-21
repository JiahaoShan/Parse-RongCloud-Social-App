//
//  UserRelation.h
//  SO
//
//  Created by Jiahao Shan on 7/20/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Parse/Parse.h>

@interface UserRelation : PFObject <PFSubclassing>
+ (NSString *)parseClassName;

@property NSNumber* relation;
@property NSString* userAId;
@property NSString* userBId;

// A lot of counts
//@property NSNumber* likeCount;
//@property NSNumber* likeCount;
//@property NSNumber* likeCount;
//@property NSNumber* likeCount;
//@property NSNumber* likeCount;


@end
