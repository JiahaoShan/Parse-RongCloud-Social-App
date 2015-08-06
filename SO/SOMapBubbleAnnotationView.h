//
//  SOMapBubbleAnnotationView.h
//  SO
//
//  Created by Jiahao Shan on 8/5/15.
//  Copyright (c) 2015 Guanqing Shan. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface SOMapBubbleAnnotationView : MKAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end
