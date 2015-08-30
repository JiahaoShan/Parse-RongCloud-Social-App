//
//  SOMapBubbleViewController.m
//  SO
//
//  Created by Jiahao Shan on 7/30/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "SOMapBubbleViewController.h"
#import <MapKit/MapKit.h>
#import "INTULocationManager.h"
#import <RongIMKit/RongIMKit.h>
#import <ParseUI/ParseUI.h>
#import "SOMapBubbleAnnotation.h"
#import "SOMapBubbleAnnotationView.h"
#import "SOLabelView.h"
#import "CSGrowingTextView.h"
#import "SODataManager.h"
#import "UIImageView+AFNetworking.h"
#import "SOUserDefaultManager.h"


@interface SOMapBubbleViewController () <MKMapViewDelegate, CSGrowingTextViewDelegate, TTTAttributedLabelDelegate> {
    int locationTryCounter;
}
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *annotationList;
@property (nonatomic) BOOL ifLocatedUser;
@property (nonatomic) BOOL preventSendingMessage;
@property (nonatomic) BOOL waitForLocation;
@property (nonatomic) BOOL waitForAppealingSendingMessage;
@property (nonatomic, strong) CSGrowingTextView* textView;
@property (nonatomic, strong) UIView* inputMessageView;
@property (strong, nonatomic) NSMutableDictionary *userMessageDict;
@property (nonatomic, strong) UIImageView* userPotraitImageView;
@property (nonatomic, strong) UIImage* userPotraitImage;
@property (nonatomic, strong) NSTimer* preventSendingMessageTimer;
@end


@implementation SOMapBubbleViewController

@synthesize annotationList = _annotationList;

const CGFloat messageFrameWidth = 100.0f;
const CGFloat messageTextPaddingWidth = 5.0f;
const CGFloat messageTextWidth = messageFrameWidth - 2 * messageTextPaddingWidth;
const CGFloat imageWidth = 40.0f;
const NSInteger displayDistanceMeters = 5000;

- (NSMutableArray*) annotationList
{
    if (!_annotationList){
        _annotationList = [[NSMutableArray alloc] init];
    }
    return _annotationList;
}

- (NSMutableDictionary*) userMessageDict
{
    if (!_userMessageDict){
        _userMessageDict = [[NSMutableDictionary alloc] init];
    }
    return _userMessageDict;
}

- (UIImageView*) userPotraitImageView
{
    if (!_userPotraitImageView){
        _userPotraitImageView = [[UIImageView alloc] init];
    }
    return _userPotraitImageView;
}

-(NSString*)title{
    return @"地图群聊";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"地图群聊";
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.mapType = MKMapTypeStandard;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance (CLLocationCoordinate2DMake(43.076592, -89.4124875), 5000, 5000);
    [_mapView setRegion:region animated:NO];
    locationTryCounter = 0;
    [self requestForUserPotraitImage];
    [self requestForMoreAccurateLocation: INTULocationAccuracyCity];
    //cancelLocationRequest
}

- (void) requestForUserPotraitImage {
    RCUserInfo* userInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
    _userPotraitImage = nil;
    [[SODataManager sharedInstance] getUserInfoWithUserId:userInfo.userId completion:^(RCUserInfo *userInfo) {
        NSString* userPotraitUrl = userInfo.portraitUri;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:userPotraitUrl] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        [self.userPotraitImageView setImageWithURLRequest:imageRequest placeholderImage:nil success:^void(NSURLRequest * request, NSHTTPURLResponse * response, UIImage * image) {
            _userPotraitImage = image;
        } failure:^void(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error) {
            //TODO: LOAD FAILED;
            NSLog(@"error");
        }];
    }];
}

- (void) requestForMoreAccurateLocation:(INTULocationAccuracy) accuracy {
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:accuracy
                                       timeout:accuracy + 3
                          delayUntilAuthorized:YES
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 //NSLog([NSString stringWithFormat:@"Success, %ld",(long)achievedAccuracy]);
                                                 locationTryCounter = 0;
                                                 if (achievedAccuracy >= INTULocationAccuracyNeighborhood) {
                                                     _ifLocatedUser = YES;
                                                     if (_waitForLocation) {
                                                         _waitForLocation = NO;
                                                         [self hideMessage];
                                                         [self.addButton.layer removeAllAnimations];
                                                         [self addButtonTapped:_addButton];
                                                     }
                                                 }
                                                 if (achievedAccuracy < INTULocationAccuracyHouse) {
                                                     //NSLog([NSString stringWithFormat:@"Success < House! Move on!, %ld",(long)achievedAccuracy]);
                                                     [self requestForMoreAccurateLocation:achievedAccuracy + 1];
                                                 }
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 //NSLog([NSString stringWithFormat:@"Fail < House! Counter: %ld, Achieved Accuracy:%ld",locationTryCounter, (long)achievedAccuracy]);
                                                 if (locationTryCounter < 3) {
                                                     locationTryCounter++;
                                                     [self requestForMoreAccurateLocation:achievedAccuracy + 1];
                                                 }
                                                 else {
                                                     if (_ifLocatedUser) {
                                                         [self hideMessage];
                                                         [self.addButton.layer removeAllAnimations];
                                                     } else {
                                                         _waitForLocation = NO;
                                                         [self presentAlertViewWithTitle:@"出错啦" andMessage:@"好难过，定位失败。连您所在的城市都定位不到，稍后再试一下好吗？" showSettingOption:NO];
                                                         [self hideMessage];
                                                         [self.addButton.layer removeAllAnimations];
                                                     }
                                                 }
                                             }
                                             else if (status == INTULocationStatusServicesNotDetermined){
                                                 _waitForLocation = NO;
                                                 [self hideMessage];
                                                 [self.addButton.layer removeAllAnimations];
                                                 [self presentAlertViewWithTitle:@"出错啦" andMessage:@"请允许定位服务来使用地图群聊" showSettingOption:YES];
                                             }
                                             else if (status == INTULocationStatusServicesDenied){
                                                 _waitForLocation = NO;
                                                 [self hideMessage];
                                                 [self.addButton.layer removeAllAnimations];
                                                 [self presentAlertViewWithTitle:@"出错啦" andMessage:@"为什么把我拒绝。。请允许定位服务来使用地图群聊"  showSettingOption:YES];
                                             }
                                             else if (status == INTULocationStatusServicesRestricted){
                                                 _waitForLocation = NO;
                                                 [self hideMessage];
                                                 [self.addButton.layer removeAllAnimations];
                                                 [self presentAlertViewWithTitle:@"出错啦" andMessage:@"抱歉，您没有系统权限开启定位服务，直到您开启定位服务前暂时无法发送地图群聊" showSettingOption:NO];
                                             }
                                             else if (status == INTULocationStatusServicesDisabled){
                                                 _waitForLocation = NO;
                                                 [self hideMessage];
                                                 [self.addButton.layer removeAllAnimations];
                                                 [self presentAlertViewWithTitle:@"出错啦" andMessage:@"您需要开启系统定位来发送地图群聊" showSettingOption:YES];
                                             }
                                             else {
                                                 _waitForLocation = NO;
                                                 [self hideMessage];
                                                 [self.addButton.layer removeAllAnimations];
                                                 [self presentAlertViewWithTitle:@"出错啦" andMessage:@"定位出现错误，请连接WiFi或者稍后再试" showSettingOption:NO];
                                             }
                                         }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    _preventSendingMessage = NO;
    _waitForAppealingSendingMessage = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _preventSendingMessage = NO;
    _waitForAppealingSendingMessage = NO;
    [self joinChatRoom];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _waitForLocation = NO;
    [self quitChatRoom];
    //[self applyMapViewMemoryFix];
}

- (void)applyMapViewMemoryFix{
    _mapView.showsUserLocation = NO;
    _mapView.delegate = nil;
    [_mapView removeFromSuperview];
    self.mapView = nil;
}

- (void) joinChatRoom {
    void (^errorBlock)(RCErrorCode) = ^void(RCErrorCode status) {
        NSLog(@"BAD Join");
        
    };
    void (^successBlock)(void) = ^void() {
        NSLog(@"Good to go");
    };
    
    [[RCIMClient sharedRCIMClient] joinChatRoom:@"id" messageCount:0 success:successBlock error:errorBlock];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didReceiveMessageNotification:)
     name:RCKitDispatchMessageNotification
     object:nil];
}

- (void) quitChatRoom {
    [[RCIMClient sharedRCIMClient] quitChatRoom:@"id" success:^{
        
    } error:^(RCErrorCode status) {
        
    }];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}

- (void) sendMessage {
    NSString* message = _textView.internalTextView.text;
    NSString* trimmedMessage = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedMessage.length == 0) return;
    RCTextMessage* content = [RCTextMessage messageWithContent:_textView.internalTextView.text];
    content.senderUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
    
    NSDictionary *extraInfo = @{@"Latitude" : [NSString stringWithFormat:@"%f",_mapView.userLocation.coordinate.latitude],
                                @"Longitude" : [NSString stringWithFormat:@"%f",_mapView.userLocation.coordinate.longitude],
                                };
    NSError *error = nil;
    NSData *json;
    // Dictionary convertable to JSON ?
    if ([NSJSONSerialization isValidJSONObject:extraInfo])
    {
        // Serialize the dictionary
        json = [NSJSONSerialization dataWithJSONObject:extraInfo options:NSJSONWritingPrettyPrinted error:&error];
        
        // If no errors, let's view the JSON
        if (json != nil && error == nil)
        {
            NSString *jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
            content.extra = jsonString;
        }
    }
    
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_CHATROOM targetId:@"id" content:content pushContent:@"extraInfo"success:^(long messageId){
        if (!self.chatRecordTableView.attributeLabelDelegate) self.chatRecordTableView.attributeLabelDelegate = self;
        [self.chatRecordTableView insertMessage:content withUserInfo:content.senderUserInfo];
        NSLog(@"send successfully");
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"send error");
    }];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
        return;
    }
    
    if ([view.annotation isKindOfClass:[SOMapBubbleAnnotation class]]) {
        SOMapBubbleAnnotation* annotation = (SOMapBubbleAnnotation*) view.annotation;
        NSString* userID = annotation.subtitle;
        UIViewController* c = [self.storyboard instantiateViewControllerWithIdentifier:@"userDetail"];
        [self.navigationController pushViewController:c animated:YES];
        [mapView deselectAnnotation:view.annotation animated:YES];
    }
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        
        return nil;
    }
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[SOMapBubbleAnnotation class]])
    {
        // Try to dequeue an existing annotation view first
        MKAnnotationView *annotationView  = [[MKAnnotationView alloc] init];
        annotationView.annotation = annotation;
        annotationView.canShowCallout = NO;
        
        // set pin image
        SOMapBubbleAnnotation *mapAnnotation = (SOMapBubbleAnnotation*) annotation;
        NSMutableDictionary* annotaionInfo = [self.userMessageDict objectForKey:mapAnnotation.subtitle];
        
        UIView* messageView = [[UIView alloc] init];
        messageView.opaque = NO;
        messageView.backgroundColor = [UIColor clearColor];
        NSString* message = mapAnnotation.title;
        CGFloat heightForText = [self calculateTextHeightForMessageView:message];
        CGRect frame = messageView.frame;
        frame.size = CGSizeMake(messageFrameWidth, (heightForText + imageWidth + 2 * messageTextPaddingWidth) * 2);
        messageView.frame = frame;
        
        UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:13.0];
        UIEdgeInsets insets = {messageTextPaddingWidth,messageTextPaddingWidth,messageTextPaddingWidth,messageTextPaddingWidth};
        SOLabelView* messageLabel = [[SOLabelView alloc] initWithFrame:CGRectMake(0, 0, messageFrameWidth, heightForText + messageTextPaddingWidth + messageTextPaddingWidth) AndUIEdgeInsets:insets];
        messageLabel.text = message;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.font = font;
        messageLabel.numberOfLines = 0;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:124.0f/255.0f blue:0.0f/255.0f alpha:0.8f]; // Orange
        messageLabel.layer.cornerRadius = 6.0f;
        messageLabel.clipsToBounds = YES;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageView addSubview:messageLabel];
        
        UIImageView* imageView = [[UIImageView alloc] initWithImage:[annotaionInfo objectForKey:@"image"]];
        
        imageView.frame = CGRectMake((messageFrameWidth - imageWidth)/2, heightForText + messageTextPaddingWidth * 2, imageWidth, imageWidth);
        UIImage *_maskingImage = [UIImage imageNamed:@"pinMask.png"];
        CALayer *_maskingLayer = [CALayer layer];
        _maskingLayer.frame = imageView.bounds;
        [_maskingLayer setContents:(id)[_maskingImage CGImage]];
        [imageView.layer setMask:_maskingLayer];
        [messageView addSubview:imageView];
        
        UIImage* messageImage = [self imageWithView:messageView];
        
        UIImage *pinImage = messageImage;
        annotationView.image = pinImage;
        
        [annotaionInfo setObject:annotation forKey:@"annotation"];
        [annotaionInfo setObject:annotationView forKey:@"annotationView"];
        [self.userMessageDict setObject:annotaionInfo forKey:mapAnnotation.subtitle];
        
        return annotationView;
    }
    
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[RCMessage class]]) {
        RCMessage* message = (RCMessage*)notification.object;
        if (message.conversationType == ConversationType_CHATROOM) {
            RCTextMessage* textMessage = (RCTextMessage*)message.content;
            [self addNewMessage:textMessage];
        }
    }
}

- (void) addNewMessage:(RCTextMessage*)textMessage {
    NSString* content = textMessage.content;
    
    NSError *jsonError;
    NSData *objectData = [textMessage.extra dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *extraInfo = [NSJSONSerialization JSONObjectWithData:objectData
                                                              options:NSJSONReadingMutableContainers
                                                                error:&jsonError];
    double latitude = [[extraInfo objectForKey:@"Latitude"] doubleValue];
    double longitude = [[extraInfo objectForKey:@"Longitude"] doubleValue];
    // TODO: Calculate Difference to make sure it is within school.
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
    
    SOMapBubbleAnnotation *myAnnotation = [[SOMapBubbleAnnotation alloc] init];
    myAnnotation.coordinate = location;
    myAnnotation.title = content;
    myAnnotation.subtitle = textMessage.senderUserInfo.userId;
    
    [self updateannotationList:myAnnotation];
    
    [[SODataManager sharedInstance] getUserInfoWithUserId:textMessage.senderUserInfo.userId completion:^(RCUserInfo *userInfo) {
        [self setMessageView:userInfo withAnnotation:myAnnotation];
        if (!self.chatRecordTableView.attributeLabelDelegate) self.chatRecordTableView.attributeLabelDelegate = self;
        [self.chatRecordTableView insertMessage:textMessage withUserInfo:userInfo];
    }];
}

//- (void) danmu:(RCTextMessage*)message withUserInfo:(RCUserInfo*)userInfo {
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
////        TTTAttributedLabel* label = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
////        label.delegate = self; // Delegate methods are called when the user taps on a link
////        label.font = [UIFont systemFontOfSize:14];
////        label.textColor = [UIColor darkGrayColor];
////        label.lineBreakMode = NSLineBreakByWordWrapping;
////        label.numberOfLines = 0;
////        //label.text = [NSString stringWithFormat:@"%@: %@", userInfo.name, message.content];
////        
////        
////        NSString *text = [NSString stringWithFormat:@"%@: %@", userInfo.name, message.content] ;
////        [label setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
////            NSRange boldRange = [[mutableAttributedString string] rangeOfString:userInfo.name options:NSCaseInsensitiveSearch];
////            
////            // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
////            UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:14];
////            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
////            if (font) {
////                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
////                CFRelease(font);
////            }
////            
////            return mutableAttributedString;
////        }];
////        
////        
////        CGRect frame = label.frame;
////        frame.origin = CGPointMake(0, 200);
////        label.frame = frame;
////        
////        label.backgroundColor = [UIColor clearColor];
////        [self.view addSubview:label];
//
////        CSGrowingTextView* textView = [[CSGrowingTextView alloc] initWithFrame:CGRectMake(0, 300, messageFrameWidth, 15 + messageTextPaddingWidth + messageTextPaddingWidth)];
////        textView.maximumNumberOfLines = 3;
////        textView.minimumNumberOfLines = 1;
////        textView.growDirection = CSGrowDirectionUp;
////        textView.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:124.0f/255.0f blue:0.0f/255.0f alpha:0.8f]; // Orange
////        textView.layer.cornerRadius = 6.0f;
////        textView.clipsToBounds = YES;
////        textView.delegate = self;
////        textView.internalTextView.text = [NSString stringWithFormat:@"%@: %@", userInfo.name, message.content];
//        
//        UILabel* textView = [[UILabel alloc] initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, 50)];
//        textView.text= [NSString stringWithFormat:@"%@: %@", userInfo.name, message.content];
//        textView.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:124.0f/255.0f blue:0.0f/255.0f alpha:0.8f];
//        textView.layer.cornerRadius = 6.0f;
//        textView.clipsToBounds = YES;
//        [textView sizeToFit];
//        [self.view addSubview:textView];
//        
//        [UIView animateWithDuration:5
//                              delay:0.0
//                            options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
//                         animations:^{
//                             textView.center = CGPointMake(self.view.frame.size.width / 2 * 3, 300);
//                         }
//                         completion:^(BOOL finished){
//                             [textView removeFromSuperview];
//                             NSLog(@"Done!");
//                         }];
//
//    });
//}

-(void)updateannotationList:(SOMapBubbleAnnotation*)annotation{
    //TODO: TEST THE FOLLOWING CODES
    
    //exist, update the location
    if ([self.userMessageDict objectForKey:annotation.subtitle]) {
        for (int i = 0; i < [self.annotationList count]; i++) {
            SOMapBubbleAnnotation* anno = [self.annotationList objectAtIndex:i];
            if ([anno.subtitle isEqualToString:annotation.subtitle]) {
                [self.annotationList removeObjectAtIndex:i];
                [self.annotationList insertObject:annotation atIndex:0];
                break;
            }
        }
    }
    //not existed
    else {
        NSUInteger numberOfannotationList = [self.annotationList count];
        if (numberOfannotationList > 10) {
            SOMapBubbleAnnotation* removedAnnotation = [self.annotationList objectAtIndex:numberOfannotationList - 1];
            [self.annotationList removeLastObject];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.mapView removeAnnotation:removedAnnotation];
                [self.userMessageDict removeObjectForKey:removedAnnotation.subtitle];
            });
        }
        [self.annotationList insertObject:annotation atIndex:0];
    }
}

- (void) setMessageView: (RCUserInfo*)userInfo withAnnotation:(SOMapBubbleAnnotation*)annotation{
    if ([_userMessageDict objectForKey:userInfo.userId]) {
        NSMutableDictionary* existedAnnotaionInfo = [_userMessageDict objectForKey:userInfo.userId];
        id existedAnnotation = [existedAnnotaionInfo objectForKey:@"annotation"];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [_mapView removeAnnotation:existedAnnotation];
            [_mapView addAnnotation:annotation];
        });
    }
    else {
        NSMutableDictionary* annotaionInfo = [[NSMutableDictionary alloc] init];
        UIImageView* loadingView = [[UIImageView alloc] init];
        [annotaionInfo setObject:loadingView forKey:@"loadingImageView"];
        
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:userInfo.portraitUri] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
        [loadingView setImageWithURLRequest:imageRequest placeholderImage:nil success:^void(NSURLRequest * request, NSHTTPURLResponse * response, UIImage * image) {
            // TODO: Temporary self defense codes
            NSMutableDictionary* annotaionInfo = [self.userMessageDict objectForKey:userInfo.userId];
            [annotaionInfo setObject:image forKey:@"image"];
            [self.userMessageDict setObject:annotaionInfo forKey:userInfo.userId];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [_mapView addAnnotation:annotation];
            });
        } failure:^void(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error) {
            NSLog(@"error");
        }];
        [self.userMessageDict setObject:annotaionInfo forKey:userInfo.userId];
    }
}

- (CGFloat) calculateTextHeightForMessageView:(NSString*) messageText {
    CGSize constrainedSize = CGSizeMake(messageTextWidth,9999);
    
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [UIFont fontWithName:@"Helvetica-Bold" size:13.0], NSFontAttributeName,
                                          nil];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:messageText attributes:attributesDictionary];
    
    CGRect requiredRect = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    
    if (requiredRect.size.width > messageFrameWidth) {
        requiredRect = CGRectMake(0,0, messageTextWidth, requiredRect.size.height);
    }
    //    CGRect newFrame = self.resizableLable.frame;
    //    newFrame.size.height = requiredHeight.size.height;
    //    self.resizableLable.frame = newFrame;
    
    return requiredRect.size.height;
}

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

- (IBAction)addButtonTapped:(SOMapBubbleButtonView *)sender {
    if (_waitForLocation) return;
    if ([sender isKindOfClass:[SOMapBubbleButtonView class]]) {
        if (sender.isAddButton && !_ifLocatedUser) {
            [self requestForMoreAccurateLocation:INTULocationAccuracyCity];
            [self runSpinAnimationOnView:sender duration:1.0f rotations:0.5f repeat:999.0f];
            [self showMesssage:@"定位中..."];
            _waitForLocation = YES;
            return;
        }
        else if (_preventSendingMessage) {
            [self runSpinAnimationOnView:sender duration:1.0f rotations:0.5f repeat:999.0f];
            _waitForAppealingSendingMessage = YES;
            return;
        }
        
        _waitForLocation = NO;
        [self runSpinAnimationOnView:sender duration:1.0f rotations:0.5f repeat:1.0f];
        if (sender.isAddButton) {
            sender.isAddButton = NO;
            sender.fillColor = [UIColor colorWithRed:238.0f/255.0f green:77.0f/255.0f blue:77.0f/255.0f alpha:1];
            [self startInputMode];
        }
        else {
            sender.isAddButton = YES;
            sender.fillColor = [UIColor colorWithRed:87.0f/255.0f green:218.0f/255.0f blue:213.0f/255.0f alpha:1];
            [self endInputMode];
        }
        [sender setNeedsDisplay];
    }
}

- (void) startInputMode {
    if (_ifLocatedUser) {
        MKCoordinateRegion region = _mapView.region;
        region.center = _mapView.userLocation.location.coordinate;
        [_mapView setRegion:region animated:YES];
        _mapView.scrollEnabled = NO;
        _mapView.zoomEnabled = NO;
        _mapView.showsUserLocation = NO;
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
        [cancelButton setTintColor:[UIColor whiteColor]];
        self.tabBarController.navigationItem.leftBarButtonItem = cancelButton;
        [self addTextField];
    }
}

- (void) cancelButtonTapped:(UIBarButtonItem*)button {
    self.addButton.isAddButton = YES;
    self.addButton.fillColor = [UIColor colorWithRed:87.0f/255.0f green:218.0f/255.0f blue:213.0f/255.0f alpha:1];
    [self runSpinAnimationOnView:self.addButton duration:1.0f rotations:0.5f repeat:1.0f];
    [self endInputMode];
    [self.addButton setNeedsDisplay];
}

- (void) endInputMode {
    self.tabBarController.navigationItem.leftBarButtonItem = nil;
    _mapView.scrollEnabled = YES;
    _mapView.zoomEnabled = YES;
    _mapView.showsUserLocation = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:(UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             _textView.center = CGPointMake(_textView.center.x, 0 - _inputMessageView.frame.size.height);
                             _inputMessageView.alpha = 0.0;
                         }
                         completion:^(BOOL finished){
                             [_textView removeFromSuperview];
                             [_inputMessageView removeFromSuperview];
                             _textView = nil;
                             _inputMessageView = nil;
                         }];
        
    });
}

- (void) addTextField{
    _inputMessageView = [[UIView alloc] init];
    _inputMessageView.opaque = NO;
    _inputMessageView.backgroundColor = [UIColor clearColor];
    
    CGRect frame = _inputMessageView.frame;
    frame.size = CGSizeMake(messageFrameWidth, (15 + imageWidth + 2 * messageTextPaddingWidth) * 2);
    _inputMessageView.frame = frame;
    _inputMessageView.center = _mapView.center;
    
    _textView = [[CSGrowingTextView alloc] initWithFrame:CGRectMake(0, 0, messageFrameWidth, 15 + messageTextPaddingWidth + messageTextPaddingWidth)];
    _textView.maximumNumberOfLines = 3;
    _textView.minimumNumberOfLines = 1;
    _textView.growDirection = CSGrowDirectionUp;
    _textView.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:124.0f/255.0f blue:0.0f/255.0f alpha:0.8f]; // Orange
    _textView.layer.cornerRadius = 6.0f;
    _textView.clipsToBounds = YES;
    _textView.delegate = self;
    [_textView becomeFirstResponder];
    
    [_inputMessageView addSubview:_textView];
    
    UIImageView* imageView;
    if (!_userPotraitImage) {
        imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pinMask"]];
        [self requestForUserPotraitImage];
    }
    else {
        imageView = [[UIImageView alloc] initWithImage:_userPotraitImage];
    }
    imageView.frame = CGRectMake((messageFrameWidth - imageWidth)/2, 15 + messageTextPaddingWidth * 2, imageWidth, imageWidth);
    UIImage *_maskingImage = [UIImage imageNamed:@"pinMask.png"];
    CALayer *_maskingLayer = [CALayer layer];
    _maskingLayer.frame = imageView.bounds;
    [_maskingLayer setContents:(id)[_maskingImage CGImage]];
    [imageView.layer setMask:_maskingLayer];
    [_inputMessageView addSubview:imageView];
    
    [self.view addSubview:_inputMessageView];
}

- (BOOL)growingTextViewShouldReturn:(CSGrowingTextView *)textView {
    [textView resignFirstResponder];
    [self sendMessage];
    [self addButtonTapped:_addButton];
    [self setPreventSendingMessage];
    return YES;
}

- (BOOL)growingTextView:(CSGrowingTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if(range.length + range.location > textView.internalTextView.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textView.internalTextView.text length] + [text length] - range.length;
    return newLength <= 25;
}

- (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration];
    //rotationAnimation.duration = duration;
    rotationAnimation.duration = 0.5;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void) presentAlertViewWithTitle:(NSString*)title andMessage:(NSString*)message showSettingOption:(BOOL)show{
    // Greater or Equal
    if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] != NSOrderedAscending) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* actionOne = [UIAlertAction actionWithTitle:@"知道啦！" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];

        [alert addAction:actionOne];
        if (show) {
            UIAlertAction* actionTwo = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  if (&UIApplicationOpenSettingsURLString != NULL) {
                                                                      NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                                      [[UIApplication sharedApplication] openURL:appSettings];
                                                                  }
                                                              }];
            [alert addAction:actionTwo];
        }
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                          message:message
                                                         delegate:nil
                                                cancelButtonTitle:@"知道啦！"
                                                otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)setPreventSendingMessage{
    _preventSendingMessage = YES;
    if (self.preventSendingMessageTimer) {
        [self.preventSendingMessageTimer invalidate];
        self.preventSendingMessageTimer = nil;
    }
    self.preventSendingMessageTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                       target:self
                                                                     selector:@selector(sendMessageTimer:)
                                                                     userInfo:nil repeats:NO];
}

-(void)sendMessageTimer:(NSTimer *)timer {
    _preventSendingMessage = NO;
    if (_waitForAppealingSendingMessage) {
        [self.addButton.layer removeAllAnimations];
        _waitForAppealingSendingMessage = NO;
        [self addButtonTapped:self.addButton];
    }
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    UIViewController* c = [self.storyboard instantiateViewControllerWithIdentifier:@"userDetail"];
    [self.navigationController pushViewController:c animated:YES];
}
@end
