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

@interface SOMapBubbleViewController () <MKMapViewDelegate, CSGrowingTextViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *messageList;
@property (nonatomic) BOOL ifLocatedUser;
@property (nonatomic) BOOL waitForLocation;
@property (nonatomic, strong) CSGrowingTextView* textView;
@property (nonatomic, strong) UIView* inputMessageView;
@end


@implementation SOMapBubbleViewController

@synthesize messageList = _messageList;

const CGFloat messageFrameWidth = 100.0f;
const CGFloat messageTextPaddingWidth = 5.0f;
const CGFloat messageTextWidth = messageFrameWidth - 2 * messageTextPaddingWidth;
const CGFloat imageWidth = 40.0f;
const NSInteger displayDistanceMeters = 5000;

- (NSMutableArray*) messageList
{
    if (!_messageList){
        _messageList = [[NSMutableArray alloc] init];
    }
    return _messageList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;
    _mapView.mapType =MKMapTypeStandard;
    //cancelLocationRequest
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyHouse
                                       timeout:10.0
                          delayUntilAuthorized:YES
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             NSLog(@"");
                                             if (status == INTULocationStatusSuccess) {
                                                 //TODO: 这里是不是会被访问很多次 根据不同的成功定位level
                                                 _ifLocatedUser = YES;
                                                 MKUserLocation *userLocation = _mapView.userLocation;
                                                 MKCoordinateRegion region =
                                                 MKCoordinateRegionMakeWithDistance (userLocation.location.coordinate, 5000, 5000);
                                                 [_mapView setRegion:region animated:NO];                                                 if (_waitForLocation) {
                                                     _waitForLocation = NO;
                                                     [self hideMessage];
                                                     [self addButtonTapped:_addButton];
                                                 }
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 // Wasn't able to locate the user with the requested accuracy within the timeout interval.
                                                 // However, currentLocation contains the best location available (if any) as of right now,
                                                 // and achievedAccuracy has info on the accuracy/recency of the location in currentLocation.
                                             }
                                             else {
                                                 // An error occurred, more info is available by looking at the specific status returned.
                                             }
                                         }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self joinChatRoom];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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
    RCTextMessage* content = [RCTextMessage messageWithContent:_textView.internalTextView.text];
    content.senderUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
    [[RCIMClient sharedRCIMClient] sendMessage:ConversationType_CHATROOM targetId:@"go" content:content pushContent:@"extraInfo"success:^(long messageId){
        NSLog(@"send successfully");
    } error:^(RCErrorCode nErrorCode, long messageId) {
        NSLog(@"send error");
    }];
    //    - (RCMessage *)sendMessage:(RCConversationType)conversationType
    //targetId:(NSString *)targetId
    //content:(RCMessageContent *)content
    //pushContent:(NSString *)pushContent
    //pushData:(NSString *)pushData
    //success:(void (^)(long messageId))successBlock
    //error:(void (^)(RCErrorCode nErrorCode, long messageId))errorBlock;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    _mapView.centerCoordinate =
    userLocation.location.coordinate;
}

//- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
//{
//    [mapView selectAnnotation:[[mapView annotations] lastObject] animated:YES];
//}

MKCoordinateRegion coordinateRegionForCoordinates(CLLocationCoordinate2D *coords, NSUInteger coordCount) {
    MKMapRect r = MKMapRectNull;
    for (NSUInteger i=0; i < coordCount; ++i) {
        MKMapPoint p = MKMapPointForCoordinate(coords[i]);
        r = MKMapRectUnion(r, MKMapRectMake(p.x, p.y, 0, 0));
    }
    return MKCoordinateRegionForMapRect(r);
}

- (void)zoomToFitMapAnnotations:(MKMapView *)mapView {
    if ([mapView.annotations count] == 0) return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(id<MKAnnotation> annotation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    
    // Add a little extra space on the sides
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1;
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1;
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[SOMapBubbleAnnotation class]])
    {
        // Try to dequeue an existing annotation view first
        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"REUSABLE_ANNOTATION_VIEW_IDENTIFIER"];
        
        if (!annotationView)
        {
            // If an existing pin view was not available, create one.
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"REUSABLE_ANNOTATION_VIEW_IDENTIFIER"];
            annotationView.canShowCallout = YES;
            
            // set pin image
            UIImage *pinImage = [self customizePinForAnnotation:annotation];
            annotationView.image = pinImage;
        }
        else
        {
            annotationView.annotation = annotation;
        }
        
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
    NSLog(notification.description);
}

- (void) addNewMessage:(RCTextMessage*)textMessage {
    if ([self.messageList count] > 10) {
        [self.messageList removeLastObject];
        [self.messageList insertObject:textMessage atIndex:0];
    }
    NSString* content = textMessage.content;

    // 暂时的测试
    
    SOMapBubbleAnnotation *myAnnotation = [[SOMapBubbleAnnotation alloc] init];
    MKUserLocation *userLocation = _mapView.userLocation;
    myAnnotation.coordinate = userLocation.coordinate;
    myAnnotation.title = content;
    //myAnnotation.subtitle = content;
    dispatch_async (dispatch_get_main_queue(), ^
    {
        [_mapView addAnnotation:myAnnotation];
    });

    
//    SOMapBubbleAnnotation *ann = [[SOMapBubbleAnnotation alloc] init];
//    ann.title = @"Me";
//    ann.subtitle = content;
//    MKUserLocation *userLocation = _mapView.userLocation;
//    ann.coordinate = userLocation.coordinate;
//    [_mapView addAnnotation:ann];
}

- (UIImage*) customizePinForAnnotation:(id<MKAnnotation>)annotation {
    UIView* messageView = [[UIView alloc] init];
    messageView.opaque = NO;
    messageView.backgroundColor = [UIColor clearColor];
    NSString* message = ((SOMapBubbleAnnotation*)annotation).title;
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
//    messageLabel.backgroundColor = [UIColor colorWithRed:102.0f/255.0f green:187.0f/255.0f blue:106.0f/255.0f alpha:0.8f]; // Green
    messageLabel.layer.cornerRadius = 6.0f;
    messageLabel.clipsToBounds = YES;
    messageLabel.textAlignment = NSTextAlignmentCenter;

//    NSDictionary *userAttributes = @{NSFontAttributeName: font,
//                                     NSForegroundColorAttributeName: [UIColor blackColor]};
//    const CGSize textSize = [message sizeWithAttributes: userAttributes];
//    if (textSize.width < messageTextWidth) {
//        messageLabel.center = CGPointMake(messageFrameWidth/2, (heightForText + messageTextPaddingWidth)/2);
//    }
    
    [messageView addSubview:messageLabel];
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thumb.jpg"]];
    imageView.frame = CGRectMake((messageFrameWidth - imageWidth)/2, heightForText + messageTextPaddingWidth * 2, imageWidth, imageWidth);
    UIImage *_maskingImage = [UIImage imageNamed:@"pinMask.png"];
    CALayer *_maskingLayer = [CALayer layer];
    _maskingLayer.frame = imageView.bounds;
    [_maskingLayer setContents:(id)[_maskingImage CGImage]];
    [imageView.layer setMask:_maskingLayer];
    [messageView addSubview:imageView];

    return [self imageWithView:messageView];
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
            [self runSpinAnimationOnView:sender duration:1.0f rotations:0.5f repeat:999.0f];
            [self showMesssage:@"定位中..."];
            _waitForLocation = YES;
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
//    [UIView animateWithDuration:1.0
//                     animations:^{
//                         theView.frame = newFrame;    // move
//                     }
//                     completion:^(BOOL finished){
//                         // code to run when animation completes
//                         // (in this case, another animation:)
//                         [UIView animateWithDuration:1.0
//                                          animations:^{
//                                              theView.alpha = 0.0;   // fade out
//                                          }
//                                          completion:^(BOOL finished){  
//                                              [theView removeFromSuperview];           
//                                          }];
//                     }];
}

- (void) startInputMode {
    if (_ifLocatedUser) {
        MKCoordinateRegion region = _mapView.region;
        region.center = _mapView.userLocation.location.coordinate;
        [_mapView setRegion:region animated:YES];
        _mapView.scrollEnabled = NO;
        _mapView.zoomEnabled = NO;
        _mapView.showsUserLocation = NO;
        [self addTextField];
    }
}

- (void) endInputMode {
    _mapView.scrollEnabled = YES;
    _mapView.zoomEnabled = YES;
    _mapView.showsUserLocation = YES;
    [_textView removeFromSuperview];
    [_inputMessageView removeFromSuperview];
    _textView = nil;
    _inputMessageView = nil;
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
    
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"thumb.jpg"]];
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
    return YES;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
