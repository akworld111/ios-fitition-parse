//
//  ISCApplicantsViewController.h
//  Fitition
//
//  Created by WuYong on 7/19/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ISCSwipingControl.h"

@interface ISCApplicantsViewController : UIViewController<SwipingControlDataSource, SwipingControlDelegate>

@property (nonatomic, retain) PFObject *eventObj;
@end
