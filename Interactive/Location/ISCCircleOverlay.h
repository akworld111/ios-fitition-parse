//
//  ISCCircleOverlay.h
//  Interactive
//
//  Created by WuYong on 6/12/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ISCCircleOverlay : NSObject < MKOverlay >

@property (nonatomic, readonly) CLLocationDistance radius;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D) aCoordinate radius:(CLLocationDistance)aRadius;

@end
