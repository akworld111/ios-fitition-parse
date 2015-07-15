//
//  ISCAppDelegate.h
//  Interactive
//
//  Created by WuYong on 6/10/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface ISCAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, assign) NSUInteger levelOfScr;
@property (nonatomic, assign) BOOL isAuthenticated;

- (void)switchToMainVC;
- (void)updatedLocation;
@end
