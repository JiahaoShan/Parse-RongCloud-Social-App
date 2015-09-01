//
//  SOPlaygroundFeedComposeController.m
//  SO
//
//  Created by Guanqing Yan on 8/19/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundFeedComposeController.h"
#import "SOPlaygroundFeedComposeImageView.h"
#import "SOImageProvider.h"
#import "SOUICommons.h"
#import "MTStatusBarOverlay.h"
@interface SOPlaygroundFeedComposeController()<SOPlaygroundFeedComposeImageViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *messageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addImageViewHeigheConstraint;
@property (weak, nonatomic) IBOutlet SOPlaygroundFeedComposeImageView *addImageView;
@property (strong,nonatomic) SOImageProvider* imageProvider;


@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@end

@implementation SOPlaygroundFeedComposeController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationBar setBarTintColor:[SOUICommons primaryTintColor]];
    [self.navigationBar setTintColor:[SOUICommons textColor]];
    UILabel* titleLabel = [[UILabel alloc] init];
    [SOUICommons configureNavigationBarLabel:titleLabel];
    [titleLabel setText:@"创作"];
    [titleLabel sizeToFit];
    UINavigationItem* item = [self.navigationBar.items firstObject];
    [item setTitleView:titleLabel];
}


-(SOImageProvider*)imageProvider{
    if (!_imageProvider) {
        _imageProvider = [[SOImageProvider alloc] initWithViewController:self];
        [_imageProvider setDelegate:self];
    }
    return _imageProvider;
}
- (IBAction)cancelled:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:true completion:^{
        [self.delegate userDidTapCancel];
    }];
}
- (IBAction)finish:(id)sender {
    PlaygroundFeed* newFeed = [[PlaygroundFeed alloc] initWithClassName:@"PlaygroundFeed"];
    newFeed.text = self.messageView.text;
    newFeed.poster = [PFUser currentUser];
    NSMutableArray* files = [NSMutableArray array];
    for (UIImage* img in [self.addImageView images]) {
        //compress image
        NSData* data = UIImageJPEGRepresentation(img, 0.1);//UIImagePNGRepresentation(img);
        if ([data length]>PFFILE_IMAGE_SUITABLE_SIZE) {
            data = UIImageJPEGRepresentation(img, 0.6);
            if ([data length]>PFFILE_IMAGE_SUITABLE_SIZE) {
                data = UIImageJPEGRepresentation(img, 0.4);
                if ([data length]>PFFILE_IMAGE_SUITABLE_SIZE) {
                    data = UIImageJPEGRepresentation(img, 0.2);
                    if ([data length]>PFFILE_IMAGE_SUITABLE_SIZE) {
                        [[MTStatusBarOverlay sharedInstance] postImmediateErrorMessage:@"image too big" duration:2 animated:true];
                        data=nil;
                    }
                }
            }
        }
        if (data) {
            PFFile* file = [PFFile fileWithName:@"UserPostedImage" data:data];
            [files addObject:file];
        }
    }
    newFeed.images = files;
    
    [self.delegate userDidFinishComposingFeed:newFeed];
    [self dismissViewControllerAnimated:true completion:NULL];
}
-(void)loadView{
    [super loadView];
    [self.addImageView setDelegate:self];
}
#pragma mark - SOPlaygroundFeedComposeImageViewDelegate
-(void)didRequestMoreImage{
    [self.imageProvider present];
}
-(void)didChangeHeightTo:(CGFloat)height{
    self.addImageViewHeigheConstraint.constant=height;
}

#pragma mark - SOImageProviderProtocol
-(void)providerDidGetPhotos:(NSArray*)photos{
    [[self addImageView] appendImages:photos];
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
