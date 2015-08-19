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


@end
