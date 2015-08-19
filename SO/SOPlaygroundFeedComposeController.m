//
//  SOPlaygroundFeedComposeController.m
//  SO
//
//  Created by Guanqing Yan on 8/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedComposeController.h"

@interface SOPlaygroundFeedComposeController()
@property (weak, nonatomic) IBOutlet UITextView *messageView;

@end

@implementation SOPlaygroundFeedComposeController
- (IBAction)cancelled:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:^{
        [self.delegate userDidTapCancel];
    }];
}
- (IBAction)finish:(id)sender {
    PlaygroundFeed* newFeed = [[PlaygroundFeed alloc] initWithClassName:@"PlaygroundFeed"];
    newFeed.text = self.messageView.text;
    newFeed.poster = [PFUser currentUser];
    [self.delegate userDidFinishComposingFeed:newFeed];
    [self dismissViewControllerAnimated:true completion:NULL];
}


//    UIImage* sampleImage = [UIImage imageNamed:@"sampleImage2.png"];
//    NSData* imageData = UIImagePNGRepresentation(sampleImage);
//    PFFile* image1 = [PFFile fileWithName:@"sampleImage2.png" data:imageData];
//
//    UIImage* sampleImage2 = [UIImage imageNamed:@"sampleImage3.png"];
//    NSData* imageData2 = UIImagePNGRepresentation(sampleImage2);
//    PFFile* image2 = [PFFile fileWithName:@"sampleImage3.png" data:imageData2];
//    //[image1 saveInBackground];
//
//    PFObject* sampleFeed = [PFObject objectWithClassName:@"PlaygroundFeed"];
//    sampleFeed[@"poster"] = [PFUser currentUser];
//    sampleFeed[@"text"] = @"这是一段超级长的文字。我就是想看看它能不能被正常显示出来。-- 并不能。";
//    sampleFeed[@"images"] = @[image1,image2];
//    [sampleFeed saveInBackground];



//    PFUser *user = [PFUser user];
//    user.username = @"Shawn";
//    user.password = @"12345678";
//    user.email = @"shawn.shan@wisc.edu";
//
//    UIImage* sampleImage2 = [UIImage imageNamed:@"sampleImage2.png"];
//    NSData* imageData2 = UIImagePNGRepresentation(sampleImage2);
//    PFFile* image2 = [PFFile fileWithName:@"sampleImage2.png" data:imageData2];
//
//    // other fields can be set just like with PFObject
//    user[@"portrait"] = image2;
//    user[@"male"] = @YES;
//
//    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if (!error) {   // Hooray! Let them use the app now.
//        } else {   NSString *errorString = [error userInfo][@"error"];   // Show the errorString somewhere and let the user try again.
//        }
//    }];
@end
