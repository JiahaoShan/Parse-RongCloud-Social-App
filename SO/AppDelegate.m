//
//  AppDelegate.m
//  SO
//
//  Created by Jiahao Shan on 7/12/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

// If you want to use any of the UI components, uncomment this line
// #import <ParseUI/ParseUI.h>

// If you are using Facebook, uncomment this line
// #import <ParseFacebookUtils/PFFacebookUtils.h>

// If you want to use Crash Reporting - uncomment this line
// #import <ParseCrashReporting/ParseCrashReporting.h>

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <Bolts/Bolts.h>
#import <RongIMKit/RongIMKit.h>

#import <ParseUI/ParseUI.h>

#import "SOLoginViewController.h"
#import "SOSignupViewController.h"

#import "SODataManager.h"
#import "SOCommonStrings.h"
#import "SOTabBarController.h"
#import "SONavigationController.h"

#import "PlaygroundFeed.h"
#import "PlaygroundImage.h"
#import "PlaygroundComment.h"
#import "PlaygroundLike.h"
#import "UserRelation.h"
#import "User.h"

#define iPhone6                                                                \
([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
? CGSizeEqualToSize(CGSizeMake(750, 1334),                              \
[[UIScreen mainScreen] currentMode].size)           \
: NO)
#define iPhone6Plus                                                            \
([UIScreen instancesRespondToSelector:@selector(currentMode)]                \
? CGSizeEqualToSize(CGSizeMake(1242, 2208),                             \
[[UIScreen mainScreen] currentMode].size)           \
: NO)


@interface AppDelegate () <RCIMConnectionStatusDelegate, RCIMUserInfoDataSource, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, RCIMClientReceiveMessageDelegate>

@end

@implementation AppDelegate

// Possible open a push from homescreen will use this method.
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Enable storing and querying data from Local Datastore. Remove this line if you don't want to
    // use Local Datastore features or want to use cachePolicy.

    [Parse enableLocalDatastore];
    //[ParseCrashReporting enable];
    [self initCustomizedDataModel];

    [Parse setApplicationId:@"uBuTDLkmhCRldizIowfn0RKXztA95UnsFJBtDaXG"
                  clientKey:@"eWLFMmcLaMSgUgYoOyz8UoNdpq24iTTFFmPrlEhB"];

    // ****************************************************************************
    // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
    // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
    // [PFFacebookUtils initializeFacebook];
    // ****************************************************************************
    
    //[User enableAutomaticUser];  // No anonymous user allowed
    PFACL *defaultACL = [PFACL ACL];
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    [self.window makeKeyAndVisible];
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced in iOS 7).
        // In that case, we skip tracking here to avoid double counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else
#endif
    {
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    // Notification: the push while app is off
    //NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    
    
    //[User logOut];
    [self registerNotificationCenter];
    [self initRongCloudService];
    //登录
    NSString *token =[[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_RONG_DEVICE_TOKEN_KEY];
    if (token.length && [User currentUser]) {
        [self connectToRongCloud];
    } else {
        SOLoginViewController *logInController = [[SOLoginViewController alloc] init];
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
        UINavigationController *_navi =
        [[UINavigationController alloc] initWithRootViewController:logInController];
        self.window.rootViewController = _navi;
    }
    return YES;
}



- (void) registerNotificationCenter {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidSignUp:)
                                                 name:SONotificationUserSignUp
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogIn:)
                                                 name:SONotificationUserLogIn
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogOut:)
                                                 name:SONotificationUserLogOut
                                               object:nil];
}



// Call when register finish and success
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    // currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
    
    [PFPush subscribeToChannelInBackground:@"" block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
        } else {
            NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

// Get Push when app is open
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

//TODO: Difference between these two???

// Get Push when app is open
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[
                                                                         @(ConversationType_PRIVATE),
                                                                         @(ConversationType_DISCUSSION),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_PUBLICSERVICE),
                                                                         @(ConversationType_GROUP)
                                                                         ]];
    application.applicationIconBadgeNumber = unreadMsgCount;

}

#pragma mark Facebook SDK Integration

///////////////////////////////////////////////////////////
// Uncomment this method if you are using Facebook
///////////////////////////////////////////////////////////
//- (BOOL)application:(UIApplication *)application
//            openURL:(NSURL *)url
//  sourceApplication:(NSString *)sourceApplication
//         annotation:(id)annotation {
//    return [PFFacebookUtils handleOpenURL:url];
//}

#pragma mark System Related

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark NotificationCenter Handlers
- (void) userDidLogIn: (id) sender {
    if ([User currentUser]) {
        [self registerRongCloudService];
    }
    else {
        NSLog(@"Error. User logs in but no current User.");
    }
}

- (void) userDidLogOut: (id) sender {
    
}

- (void) userDidSignUp: (id) sender {
    if ([User currentUser]) {
        [self registerRongCloudService];
    }
    else {
        NSLog(@"Error. User sign up but no current User.");
    }
}


#pragma mark RongCloud Methods && Delegate

//- (void)onReceived:(RCMessage *)message left:(int)nLeft object:(id)object {
//    NSLog(message.description);
//}

- (void) initRongCloudService {
    [[RCIM sharedRCIM] initWithAppKey:RONGCLOUD_IM_APPKEY];
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    //[[RCIMClient sharedRCIMClient] setReceiveMessageDelegate:self object:nil];
    if (iPhone6Plus) {
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(56, 56);
    } else {
        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
    }
    [[RCIM sharedRCIM] setUserInfoDataSource:SODataSource];
    [RCIM sharedRCIM].groupInfoDataSource = SODataSource;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];
}

- (void) registerRongCloudService {
    [self getRongCloudTokenForUser];
}

- (void) getRongCloudTokenForUser {
    User *currentUser = [User currentUser];
    [PFCloud callFunctionInBackground:@"getToken"
                       withParameters:@{@"userId": currentUser.objectId , @"name" : [currentUser objectForKey:UserNameKey], @"portraitUri" :
                                        @"http://img.135q.com/2015-06/20/14348061890006.jpg"}
                                block:^(NSString *result, NSError *error) {
                                    if (!error) {
                                        NSDictionary* json = [NSJSONSerialization
                                                              JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding]
                                                              options:kNilOptions
                                                              error:&error];
                                        NSString* token = [json objectForKey:@"token"];
                                        [[NSUserDefaults standardUserDefaults] setObject:token forKey:DEFAULTS_RONG_DEVICE_TOKEN_KEY];
                                        [self connectToRongCloud];
                                    }
                                    else {
                                        NSLog(@"Error to get token");
                                    }
                                }];
}

- (void) connectToRongCloud {
    User* user = [User currentUser];
    RCUserInfo *_currentUserInfo =
    [[RCUserInfo alloc] initWithUserId:user.objectId
                                  name:[user objectForKey:UserNameKey]
                              portrait:nil];
    NSString* token = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_RONG_DEVICE_TOKEN_KEY];
    [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
    [[RCIM sharedRCIM] connectWithToken:token
                                success:^(NSString *userId) {
                                    //[[RCIM sharedRCIM] refreshUserInfoCache:user withUserId:userId];
                                    //设置当前的用户信息
                                    NSLog(@"Login successfully with userId: %@.", userId);
                                }
                                  error:^(RCConnectErrorCode status) {
                                      RCUserInfo *_currentUserInfo =[[RCUserInfo alloc] initWithUserId:user.objectId name:[user objectForKey:UserNameKey] portrait:nil];
                                      [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
                                      NSLog(@"登录失败connect error %ld", (long)status);
//                                      dispatch_async(dispatch_get_main_queue(), ^{
//                                          UIStoryboard *storyboard =
//                                          [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                                          SOTabBarController *rootNavi = [storyboard   instantiateViewControllerWithIdentifier:@"SOtabBarController"];                                              self.window.rootViewController = rootNavi;
//                                      });
                                  }
                         tokenIncorrect:^{
                             NSLog(@"Error. Token expires.");
                             // TODO:  避免死循环
                             [self getRongCloudTokenForUser];
                         }];
}


- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
    NSLog([NSString stringWithFormat:@"RongCloud connection status changed. %ld", (long)status]);
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    //NSLog(notification.description);
}
#pragma mark - Parse Login delegate

- (void)logInViewController:(PFLogInViewController *)controller
               didLogInUser:(User *)user {
    [[NSNotificationCenter defaultCenter] postNotificationName:SONotificationUserLogIn object:nil];
    [self showTabViewController];
}

// NOT ALLOW TO CANCEL?!
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
}

#pragma mark - Parse Signup delegate

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(User *)user {
    [[NSNotificationCenter defaultCenter] postNotificationName:SONotificationUserSignUp object:nil];
    [self showTabViewController];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
}

- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController
           shouldBeginSignUp:(NSDictionary *)info {
    NSString *password = info[@"password"];
    return (password.length >= 8); // prevent sign up if password has to be at least 8 characters long
}

- (void) showTabViewController {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard =
        [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SONavigationController* rootNavi = [storyboard instantiateViewControllerWithIdentifier:@"rootNavigationController"];
        self.window.rootViewController = rootNavi;
    });
}

- (void) initCustomizedDataModel{
    [User registerSubclass];
    [PlaygroundFeed registerSubclass];
    [PlaygroundComment registerSubclass];
    [PlaygroundImage registerSubclass];
    [PlaygroundLike registerSubclass];
    [UserRelation registerSubclass];
}
//PFFile *imageFile = [photo objectForKey:@"file"];
//NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];

//
//- (void) rongInit {
//    //设置会话列表头像和会话界面头像
//
//    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
//    if (iPhone6Plus) {
//        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(56, 56);
//    } else {
//        NSLog(@"iPhone6 %d", iPhone6);
//        [RCIM sharedRCIM].globalConversationPortraitSize = CGSizeMake(46, 46);
//    }
//    
//    //设置用户信息源和群组信息源
//    [RCIM sharedRCIM].userInfoDataSource = RCDDataSource;
//    [RCIM sharedRCIM].groupInfoDataSource = RCDDataSource;
//    
//    //    [RCIM sharedRCIM].globalMessagePortraitSize = CGSizeMake(46, 46);
//    
//    //登录
//    NSString *token =[[NSUserDefaults standardUserDefaults] objectForKey:@"userToken"];
//    NSString *userId=[DEFAULTS objectForKey:@"userId"];
//    NSString *userName = [DEFAULTS objectForKey:@"userName"];
//    NSString *password = [DEFAULTS objectForKey:@"userPwd"];
//    
//    if (token.length && userId.length && password.length && !debugMode) {
//        [[RCIM sharedRCIM] connectWithToken:token
//                                    success:^(NSString *userId) {
//                                        RCUserInfo *_currentUserInfo =
//                                        [[RCUserInfo alloc] initWithUserId:userId
//                                                                      name:userName
//                                                                  portrait:nil];
//                                        [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
//                                        [AFHttpTool loginWithEmail:userName
//                                                          password:password
//                                                               env:1
//                                                           success:^(id response) {
//                                                               if ([response[@"code"] intValue] == 200) {
//                                                                   [RCDHTTPTOOL getUserInfoByUserID:userId
//                                                                                         completion:^(RCUserInfo *user) {
//                                                                                             [[RCIM sharedRCIM]
//                                                                                              refreshUserInfoCache:user
//                                                                                              withUserId:userId];
//                                                                                         }];
//                                                               }
//                                                           }
//                                                           failure:^(NSError *err){
//                                                           }];
//                                        //设置当前的用户信息
//                                        
//                                        //同步群组
//                                        [RCDDataSource syncGroups];
//                                        dispatch_async(dispatch_get_main_queue(), ^{
//                                            UIStoryboard *storyboard =
//                                            [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                                            UINavigationController *rootNavi = [storyboard
//                                                                                instantiateViewControllerWithIdentifier:@"rootNavi"];
//                                            self.window.rootViewController = rootNavi;
//                                        });
//                                    }
//                                      error:^(RCConnectErrorCode status) {
//                                          RCUserInfo *_currentUserInfo =[[RCUserInfo alloc] initWithUserId:userId
//                                                                                                      name:userName
//                                                                                                  portrait:nil];
//                                          [RCIMClient sharedRCIMClient].currentUserInfo = _currentUserInfo;
//                                          [RCDDataSource syncGroups];
//                                          NSLog(@"connect error %ld", (long)status);
//                                          dispatch_async(dispatch_get_main_queue(), ^{
//                                              UIStoryboard *storyboard =
//                                              [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//                                              UINavigationController *rootNavi = [storyboard
//                                                                                  instantiateViewControllerWithIdentifier:@"rootNavi"];
//                                              self.window.rootViewController = rootNavi;
//                                          });
//                                      }
//                             tokenIncorrect:^{
//                                 RCDLoginViewController *loginVC =
//                                 [[RCDLoginViewController alloc] init];
//                                 UINavigationController *_navi = [[UINavigationController alloc]
//                                                                  initWithRootViewController:loginVC];
//                                 self.window.rootViewController = _navi;
//                                 UIAlertView *alertView =
//                                 [[UIAlertView alloc] initWithTitle:nil
//                                                            message:@"Token已过期，请重新登录"
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"确定"
//                                                  otherButtonTitles:nil, nil];
//                                 ;
//                                 [alertView show];
//                             }];
//        
//    } else {
//        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
//        // [loginVC defaultLogin];
//        // RCDLoginViewController* loginVC = [storyboard
//        // instantiateViewControllerWithIdentifier:@"loginVC"];
//        UINavigationController *_navi =
//        [[UINavigationController alloc] initWithRootViewController:loginVC];
//        self.window.rootViewController = _navi;
//    }
//    
//    if ([application
//         respondsToSelector:@selector(registerUserNotificationSettings:)]) {
//        //注册推送, iOS 8
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings
//                                                settingsForTypes:(UIUserNotificationTypeBadge |
//                                                                  UIUserNotificationTypeSound |
//                                                                  UIUserNotificationTypeAlert)
//                                                categories:nil];
//        [application registerUserNotificationSettings:settings];
//    } else {
//        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge |
//        UIRemoteNotificationTypeAlert |
//        UIRemoteNotificationTypeSound;
//        [application registerForRemoteNotificationTypes:myTypes];
//    }
//    
//    //统一导航条样式
//    UIFont *font = [UIFont systemFontOfSize:19.f];
//    NSDictionary *textAttributes = @{
//                                     NSFontAttributeName : font,
//                                     NSForegroundColorAttributeName : [UIColor whiteColor]
//                                     };
//    [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
//    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
//    [[UINavigationBar appearance]
//     setBarTintColor:[UIColor colorWithHexString:@"0195ff" alpha:1.0f]];
//    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(didReceiveMessageNotification:)
//     name:RCKitDispatchMessageNotification
//     object:nil];
//    
//    //    NSArray *groups = [self getAllGroupInfo];
//    //    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:groups];
//    //    NSArray *loadedContents = [NSKeyedUnarchiver
//    //                               unarchiveObjectWithData:data];
//    //    NSLog(@"loadedContents size is %d", loadedContents.count);
//}
//
//// Codes from Sample
//- (void)application:(UIApplication *)application
//didReceiveLocalNotification:(UILocalNotification *)notification {
//    //震动
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//    AudioServicesPlaySystemSound(1007);
//}
//
//- (void)didReceiveMessageNotification:(NSNotification *)notification {
//    [UIApplication sharedApplication].applicationIconBadgeNumber =
//    [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
//}
//
//#pragma mark - RCWKAppInfoProvider
//- (NSString *)getAppName {
//    return @"融云";
//}
//
//- (NSString *)getAppGroups {
//    return @"group.com.RCloud.UIComponent.WKShare";
//}
//
//- (NSArray *)getAllUserInfo {
//    return [RCDDataSource getAllUserInfo:^{
//        [[RCWKNotifier sharedWKNotifier] notifyWatchKitUserInfoChanged];
//    }];
//}
//- (NSArray *)getAllGroupInfo {
//    return [RCDDataSource getAllGroupInfo:^{
//        [[RCWKNotifier sharedWKNotifier] notifyWatchKitGroupChanged];
//    }];
//}
//- (NSArray *)getAllFriends {
//    return [RCDDataSource getAllFriends:^{
//        [[RCWKNotifier sharedWKNotifier] notifyWatchKitFriendChanged];
//    }];
//}
//- (void)openParentApp {
//    [[UIApplication sharedApplication]
//     openURL:[NSURL URLWithString:@"rongcloud://connect"]];
//}
//- (BOOL)getNewMessageNotificationSound {
//    return ![RCIM sharedRCIM].disableMessageAlertSound;
//}
//- (void)setNewMessageNotificationSound:(BOOL)on {
//    [RCIM sharedRCIM].disableMessageAlertSound = !on;
//}
//- (void)logout {
//    [DEFAULTS removeObjectForKey:@"userName"];
//    [DEFAULTS removeObjectForKey:@"userPwd"];
//    [DEFAULTS removeObjectForKey:@"userToken"];
//    [DEFAULTS removeObjectForKey:@"userCookie"];
//    if (self.window.rootViewController != nil) {
//        UIStoryboard *storyboard =
//        [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        RCDLoginViewController *loginVC =
//        [storyboard instantiateViewControllerWithIdentifier:@"loginVC"];
//        UINavigationController *navi =
//        [[UINavigationController alloc] initWithRootViewController:loginVC];
//        self.window.rootViewController = navi;
//    }
//    [[RCIMClient sharedRCIMClient] disconnect:NO];
//}
//- (BOOL)getLoginStatus {
//    NSString *token = [DEFAULTS stringForKey:@"userToken"];
//    if (token.length) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//#pragma mark - RCIMConnectionStatusDelegate
//
///**
// *  网络状态变化。
// *
// *  @param status 网络状态。
// */
//- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status {
//    if (status == ConnectionStatus_KICKED_OFFLINE_BY_OTHER_CLIENT) {
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"提示"
//                              message:@"您"
//                              @"的帐号在别的设备上登录，您被迫下线！"
//                              delegate:nil
//                              cancelButtonTitle:@"知道了"
//                              otherButtonTitles:nil, nil];
//        [alert show];
//        RCDLoginViewController *loginVC = [[RCDLoginViewController alloc] init];
//        // [loginVC defaultLogin];
//        // RCDLoginViewController* loginVC = [storyboard
//        // instantiateViewControllerWithIdentifier:@"loginVC"];
//        UINavigationController *_navi =
//        [[UINavigationController alloc] initWithRootViewController:loginVC];
//        self.window.rootViewController = _navi;
//    }
//}
//

//- (void)handlePush:(NSDictionary *)launchOptions {
//    
//    // If the app was launched in response to a push notification, we'll handle the payload here
//    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//    if (remoteNotificationPayload) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:PAPAppDelegateApplicationDidReceiveRemoteNotification object:nil userInfo:remoteNotificationPayload];
//        
//        if (![User currentUser]) {
//            return;
//        }
//        
//        // If the push notification payload references a photo, we will attempt to push this view controller into view
//        NSString *photoObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadPhotoObjectIdKey];
//        if (photoObjectId && photoObjectId.length > 0) {
//            [self shouldNavigateToPhoto:[PFObject objectWithoutDataWithClassName:kPAPPhotoClassKey objectId:photoObjectId]];
//            return;
//        }
//        
//        // If the push notification payload references a user, we will attempt to push their profile into view
//        NSString *fromObjectId = [remoteNotificationPayload objectForKey:kPAPPushPayloadFromUserObjectIdKey];
//        if (fromObjectId && fromObjectId.length > 0) {
//            PFQuery *query = [User query];
//            query.cachePolicy = kPFCachePolicyCacheElseNetwork;
//            [query getObjectInBackgroundWithId:fromObjectId block:^(PFObject *user, NSError *error) {
//                if (!error) {
//                    UINavigationController *homeNavigationController = self.tabBarController.viewControllers[PAPHomeTabBarItemIndex];
//                    self.tabBarController.selectedViewController = homeNavigationController;
//                    
//                    PAPAccountViewController *accountViewController = [[PAPAccountViewController alloc] initWithStyle:UITableViewStylePlain];
//                    NSLog(@"Presenting account view controller with user: %@", user);
//                    accountViewController.user = (User *)user;
//                    [homeNavigationController pushViewController:accountViewController animated:YES];
//                }
//            }];
//        }
//    }
//}

@end
