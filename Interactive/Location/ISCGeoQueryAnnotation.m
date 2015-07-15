//
//  ISCGeoQueryAnnotation.m
//  Interactive
//
//  Created by WuYong on 6/12/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCGeoQueryAnnotation.h"

@implementation ISCGeoQueryAnnotation
@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;
@synthesize radius = _radius;

#pragma mark - Initialization

- (id)initWithCoordinate:(CLLocationCoordinate2D)aCoordinate radius:(CLLocationDistance)aRadius{
    if(self = [super init]){
        _coordinate = aCoordinate;
        _radius = aRadius;
        
        [self configureLabels];
    }
    return self;
}

#pragma mark - MKAnnotation

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate{
    _coordinate = newCoordinate;
    [self configureLabels];
}

#pragma mark - ConfigureLabels

- (void)configureLabels{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    _title = @"Current Position";
    _subtitle = [NSString stringWithFormat:@"Center: (%@, %@) Radius %@ km", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:_coordinate.latitude]], [numberFormatter stringFromNumber:[NSNumber numberWithFloat:_coordinate.longitude]], [numberFormatter stringFromNumber:[NSNumber numberWithInt:_radius]]];
}
@end
