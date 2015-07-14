//
//  SOPlaygroundMainController.m
//  SO
//
//  Created by Guanqing Yan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import "SOPlaygroundMainController.h"
#import "SOPlaygroundFeedCell.h"

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

#import "SOLoginViewController.h"
#import "SOSignupViewController.h"

@interface SOPlaygroundMainController()<UITableViewDataSource,UITableViewDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
@property (nonatomic) NSArray* feedsData;
@end

@implementation SOPlaygroundMainController
-(void)viewDidLoad{
    [super viewDidLoad];
    // Check if login.
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        NSLog(@"Current user: %@", currentUser.username);
    } else {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    // 这些应该用不到 因为用到Parse
    self.feedsData = @[@{
                           @"images":@[
                                   @"http://hashtagzoned.com/wp-content/uploads/2015/01/jennifer_lawrence2-160x160.jpg",
                                   @"http://www.promipool.de/var/promipool/storage/images/media/images/jennifer-lawrence65/2266057-1-ger-DE/jennifer-lawrence_article_hoch_1_thumbnail.jpg",
                                   @"http://www.bakimlikadin.net/wp-content/plugins/contextual-related-posts/timthumb/timthumb.php?src=http%3A%2F%2Fwww.bakimlikadin.net%2Fwp-content%2Fuploads%2F2013%2F03%2Fjennifer-lawrence-11.jpg&w=150&h=150&zc=1&q=75",
                                   @"http://www.filmibeat.com/img/143x178/popcorn/profile_photos/jennifer-lawrence-25267.jpg",
                                   @"https://losjuegosdelhambrechile.files.wordpress.com/2011/06/jennifer-lawrence-14.png?w=130&h=130"]}];
    [self.tableView registerNib:[UINib nibWithNibName:@"SOPlaygroundFeedCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"feedCell"];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate
#pragma mark - UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 350;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SOPlaygroundFeedCell* cell = [tableView dequeueReusableCellWithIdentifier:@"feedCell"];
    [cell configureWithData:self.feedsData[0]];
    return cell;
}

#pragma mark - Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showLogin"])
    {
        // TODO: Customize it or create our own.
        
        SOLoginViewController *logInController = [segue destinationViewController];
        logInController.hidesBottomBarWhenPushed = YES;
        logInController.delegate = self;
        SOSignupViewController *signupController = [[SOSignupViewController alloc] init];
        signupController.delegate = self;
        signupController.hidesBottomBarWhenPushed = YES;
        signupController.fields = (PFSignUpFieldsUsernameAndPassword
                                   | PFSignUpFieldsSignUpButton
                                   | PFSignUpFieldsEmail
                                   | PFSignUpFieldsAdditional
                                   | PFSignUpFieldsDismissButton);
        logInController.signUpController = signupController;
        logInController.fields = (PFLogInFieldsUsernameAndPassword
                                  | PFLogInFieldsLogInButton
                                  | PFLogInFieldsSignUpButton
                                  | PFLogInFieldsPasswordForgotten
                                  );
    }
}

#pragma mark - Parse Login delegate

- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// NOT ALLOW TO CANCEL?!
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Parse Signup delegate

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController
           shouldBeginSignUp:(NSDictionary *)info {
    NSString *password = info[@"password"];
    return (password.length >= 8); // prevent sign up if password has to be at least 8 characters long
}
@end
