//
//  ISCDiscoverSettingViewController.h
//  Fitition
//
//  Created by WuYong on 7/17/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ISCDiscoverSettingViewController : UIViewController

@property (nonatomic, retain) PFGeoPoint *centerCoords;
@property (nonatomic, assign) NSUInteger radius;
@end
