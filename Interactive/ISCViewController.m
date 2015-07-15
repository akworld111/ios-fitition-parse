//
//  ISCViewController.m
//  Interactive
//
//  Created by WuYong on 6/10/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCViewController.h"
#import "ISCAppDelegate.h"

@interface ISCViewController ()

@end

@implementation ISCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self performSelector:@selector(gotoLoginScreen) withObject:nil afterDelay:5.0f];
    
    [self setNeedsStatusBarAppearanceUpdate];

}
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)gotoLoginScreen{
    ISCAppDelegate *app = (ISCAppDelegate*)[UIApplication sharedApplication].delegate;
    [app switchToMainVC];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
