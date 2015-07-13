////
////  SODownloadManager.m
////  SO
////
////  Created by Guanqing Yan on 7/12/15.
////  Copyright (c) 2015 Guanqing Shan. All rights reserved.
////
//
//#import "SODownloadManager.h"
//#import "AFNetworking.h"
//
//@implementation SODownloadManager
////to be made singleton
//+(NSURL*)downloadDirectoryURL{
//    NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//    documentsDirectoryURL = [documentsDirectoryURL URLByAppendingPathComponent:@"Downloads"];
//    return documentsDirectoryURL;
//}
//+(NSURLSessionDownloadTask*)startDownloadingImage:(NSURL*)url completion:(SODownloadCompletion)completion{
//    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:url];
//    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
//    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"Response: %@", responseObject);
//        _imageView.image = responseObject;
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Image error: %@", error);
//    }];
//    [requestOperation start];
//}
//+(void)cancelDownloadingTask:(NSURLSessionDownloadTask*)task{
//    [task cancel];
//}
//@end
