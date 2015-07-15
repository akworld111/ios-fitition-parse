//
//  ISCGeoPointAnnotation.h
//  Interactive
//
//  Created by WuYong on 6/12/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface ISCGeoPointAnnotation : NSObject<MKAnnotation>

- (id)initWithObject:(PFObject *)aObject;
- (id)initWithObject:(PFObject *)aObject :(BOOL)kk;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;

@end
