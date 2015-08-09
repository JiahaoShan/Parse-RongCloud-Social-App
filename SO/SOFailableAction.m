//
//  SOFailableAction.m
//  SO
//
//  Created by Guanqing Yan on 8/9/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOFailableAction.h"
@interface SOFailableAction()
@property (nonatomic,strong) NSMutableArray* failHandlers;
@property (nonatomic,copy) SOFailableActionHandler successHanler;
@end
@implementation SOFailableAction
-(instancetype)initWithSucceed:(SOFailableActionHandler)succeed failed:(SOFailableActionHandler)failed{
    if (self=[super init]) {
        self.successHanler = succeed;
        self.failHandlers = [NSMutableArray array];
        [self.failHandlers addObject:[failed copy]];
    }
    return self;
}
-(void)addFailHandler:(SOFailableActionHandler)failed{

}
-(void)succeed{
if (self.successHanler) {
        self.successHanler();
}
else{
    NSLog(@"action succeeded");
}
}
-(void)failed{
    if (self.failHandlers.count>0) {
        for (SOFailableActionHandler handler in self.failHandlers) {
            handler();
    }
}
else{
    NSLog(@"action failed");
}
}
@end
