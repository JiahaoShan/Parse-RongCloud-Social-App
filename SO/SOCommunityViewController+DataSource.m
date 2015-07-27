//
//  SOCommunityViewController+DataSource.m
//  SO
//
//  Created by Guanqing Yan on 7/27/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOCommunityViewController+DataSource.h"
#import <objc/objc-runtime.h>

@interface SOCommunityViewController (DataSourcePrivate)
@property (nonatomic) PFQuery* currentQuery;
@end

NSString * const currentQueryKey = @"currentQueryKey";
@implementation SOCommunityViewController (DataSource)
- (void)setCurrentQuery:(NSString *)query
{
    objc_setAssociatedObject(self, (__bridge const void *)(currentQueryKey), query, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)currentQuery
{
    return objc_getAssociatedObject(self, (__bridge const void *)(currentQueryKey));
}
-(PFUser*)currentUser{
    return [PFUser currentUser];
}
-(void)startQueryFriendsOfUser:(PFUser*)user batch:(int)batch completion:(void(^)(int batchIndex, NSArray* users))completion{
    NSLog(@"%@",self.currentQuery);
    if (self.currentQuery) {
        [self.currentQuery cancel];
    }else{
        self.currentQuery = [PFQuery queryWithClassName:@"User"];
        [self.currentQuery findObjectsInBackgroundWithBlock:^(NSArray *PF_NULLABLE_S objects, NSError *PF_NULLABLE_S error){
            if(error){
                NSLog(@"error: %@", [error localizedDescription]);
                NSAssert(!error, @"eror");
            }
            if (completion) {
                completion(0,objects);
            }
        }];
    }
}
@end
