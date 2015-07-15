//
//  ISCGeoQueryAnnotation.h
//  Interactive
//
//  Created by WuYong on 6/12/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface ISCGeoQueryAnnotation : NSObject<MKAnnotation>

- (id)initWithCoordinate: (CLLocationCoordinate2D)aCoordinate radius:(CLLocationDistance)aRadius;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationDistance radius;

@end
