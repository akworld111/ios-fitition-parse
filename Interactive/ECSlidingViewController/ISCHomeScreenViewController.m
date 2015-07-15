//
//  ISCHomeScreenViewController.m
//  Interactive
//
//  Created by WuYong on 6/13/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCHomeScreenViewController.h"

@interface ISCHomeScreenViewController ()

@end

@implementation ISCHomeScreenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
    [self selectTopViewControllerWithId:1];

}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)selectTopViewControllerWithId:(NSUInteger)topViewId{
    if(topViewId == 0){
        self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyEventViewStoryboardID"];
    }else if(topViewId == 1){
        self.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActiveEventViewStoryboardID"];
    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
