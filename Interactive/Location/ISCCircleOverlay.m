//
//  ISCCircleOverlay.m
//  Interactive
//
//  Created by WuYong on 6/12/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCCircleOverlay.h"

@implementation ISCCircleOverlay
@synthesize radius = _radius;
@synthesize coordinate = _coordinate;


#pragma  mark - Initialization

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate radius:(CLLocationDistance)aRadius{
    if(self = [super init]){
        _coordinate = aCoordinate;
        _radius = aRadius*1000;
    }
    return self;
}

#pragma  mark - MKAnnotation
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    _coordinate = newCoordinate;
}

-(MKMapRect)boundingMapRect{
    MKMapPoint centerMapPoint = MKMapPointForCoordinate(_coordinate);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_coordinate, _radius * 2, _radius * 2);
    return MKMapRectMake(centerMapPoint.x, centerMapPoint.y, region.span.latitudeDelta, region.span.longitudeDelta);
}
@end
