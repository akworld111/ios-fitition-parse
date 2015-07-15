//
//  ISCGeoPointAnnotation.m
//  Interactive
//
//  Created by WuYong on 6/12/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCGeoPointAnnotation.h"

@interface ISCGeoPointAnnotation(){
    BOOL flag;
}
@property (nonatomic, strong) PFObject *object;
@end

@implementation ISCGeoPointAnnotation

#pragma mark - Initialization
- (id)initWithObject:(PFObject *)aObject{
    if(self = [super init]){
        _object = aObject;
        PFGeoPoint *geoPoint = self.object[@"CurrentLocation"];
        flag = NO;
        [self setGeoPoint: geoPoint];
    }
    return self;
}
- (id)initWithObject:(PFObject *)aObject :(BOOL)kk{
    if(self = [super init]){
        _object = aObject;
        PFGeoPoint *geoPoint = self.object[@"PlaceCoords"];
        flag = YES;
        [self setGeoPoint: geoPoint];
    }
    return self;
}
#pragma mark - MKAnnotation


#pragma mark - setGeoPoint
- (void)setGeoPoint: (PFGeoPoint *)geoPoint{
    _coordinate = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
    
//    static NSDateFormatter *dateFormatter = nil;
//    if(dateFormatter == nil){
//        dateFormatter = [[NSDateFormatter alloc]init];
//        dateFormatter.timeStyle = NSDateFormatterMediumStyle;
//        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
//        
//    }
    
    
    static NSNumberFormatter *numberFormatter = nil;
    
    if(numberFormatter == nil){
        numberFormatter = [[NSNumberFormatter alloc]init];
        numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        numberFormatter.maximumFractionDigits = 3;
    }
    if(flag)
        _title = self.object[@"Type"];
    else
        _title = self.object[@"username"];
    _subtitle = [NSString stringWithFormat:@"%@, %@", [numberFormatter stringFromNumber:[NSNumber numberWithFloat:geoPoint.latitude]], [numberFormatter stringFromNumber:[NSNumber numberWithFloat:geoPoint.longitude]]];
    
    
}
@end
