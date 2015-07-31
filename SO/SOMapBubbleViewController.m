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

@interface SOMapBubbleViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *messageList;
@end


@implementation SOMapBubbleViewController

@synthesize messageList = _messageList;

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
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:INTULocationAccuracyCity
                                       timeout:4.0
                          delayUntilAuthorized:YES  // This parameter is optional, defaults to NO if omitted
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             if (status == INTULocationStatusSuccess) {
                                                 MKUserLocation *userLocation = _mapView.userLocation;
                                                 
                                                 MKCoordinateRegion region =
                                                 MKCoordinateRegionMakeWithDistance (
                                                                                     userLocation.location.coordinate, 5000, 5000);
                                                 [_mapView setRegion:region animated:NO];
                                                 // Request succeeded, meaning achievedAccuracy is at least the requested accuracy, and
                                                 // currentLocation contains the device's current location.
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
    [self joinChatRoom];
}

- (void) viewDidDisappear:(BOOL)animated {
    [self quitChatRoom];
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

- (void)mapView:(MKMapView *)mapView
didUpdateUserLocation:
(MKUserLocation *)userLocation
{
    _mapView.centerCoordinate =
    userLocation.location.coordinate;
}

//-(MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//    MKPinAnnotationView *MyPin=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"current"];
//    //MyPin.pinColor = MKPinAnnotationColorPurple;
//    
//    UIButton *advertButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//    [advertButton addTarget:self action:@selector(button:) forControlEvents:UIControlEventTouchUpInside];
//    
//    /*MyPin.rightCalloutAccessoryView = advertButton;
//     MyPin.draggable = YES;
//     
//     MyPin.animatesDrop=TRUE;
//     MyPin.canShowCallout = YES;*/
//    MyPin.highlighted = NO;
//    MyPin.image = [UIImage imageNamed:@"pin"];
//    
//    return MyPin;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveMessageNotification:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[RCMessage class]]) {
        RCMessage* message = (RCMessage*)notification.object;
       // if (message.conversationType == ConversationType_CHATROOM) {
            RCTextMessage* textMessage = (RCTextMessage*)message.content;
            [self addNewMessage:textMessage];
        //}
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
    
    MKPointAnnotation *myAnnotation = [[MKPointAnnotation alloc] init];
    MKUserLocation *userLocation = _mapView.userLocation;
    myAnnotation.coordinate = userLocation.coordinate;
    myAnnotation.title = @"Me";
    myAnnotation.subtitle = content;
    [_mapView addAnnotation:myAnnotation];

    
//    SOMapBubbleAnnotation *ann = [[SOMapBubbleAnnotation alloc] init];
//    ann.title = @"Me";
//    ann.subtitle = content;
//    MKUserLocation *userLocation = _mapView.userLocation;
//    ann.coordinate = userLocation.coordinate;
//    [_mapView addAnnotation:ann];
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
