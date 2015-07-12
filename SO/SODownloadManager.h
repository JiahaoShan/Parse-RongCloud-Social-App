//
//  SODownloadManager.h
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^SODownloadCompletion)(id object, NSError* error);
typedef NSString* SOTaskID;


//wrap around ATNetworking
@interface SODownloadManager : NSObject
//returns an identifier of the download
+(SOTaskID)startDownloading:(NSURL*)url completion:(SODownloadCompletion)completion;
+(void)cancelDownloadingTask:(SOTaskID)task;
@end
