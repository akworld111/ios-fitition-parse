//
//  ISCAppDelegate.m
//  Interactive
//
//  Created by WuYong on 6/10/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCAppDelegate.h"
#import <Parse/Parse.h>

static NSString *const kLocationChangeNotification = @"kLocationChangeNotification";
static NSString *const kPostClassName = @"kPostClassName";
static NSString *const kLocationKey = @"kLocationKey";
static NSString *const kUpdatedName = @"kUpdatedName";
@implementation ISCAppDelegate

- (void)setCurrentLocation:(CLLocation*)aCurrentLocation{
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:aCurrentLocation forKey:@"location"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationChangeNotification object:nil userInfo:userInfo];
    PFUser *user = [PFUser currentUser];
    if(user){
        PFGeoPoint *currentPoint = [PFGeoPoint geoPointWithLatitude:aCurrentLocation.coordinate.latitude longitude:aCurrentLocation.coordinate.longitude];
        
        user[@"CurrentLocation"] = currentPoint;
        [user saveEventually];
    }
//    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        NSLog(@"Coordinate: %f, %f", aCurrentLocation.coordinate.latitude, aCurrentLocation.coordinate.longitude);
//        if(error){
//            NSLog(@"Updating location was failed!");
//        }else{
//            NSLog(@"Updating location was successed!");
//        }
//    }];
    
//
//    PFObject *postObject = [PFObject objectWithClassName:kPostClassName];
//    [postObject setObject:currentPoint forKey:kLocationKey];
//    
//    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        if(error){
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[error userInfo]objectForKey:@"error"] message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//            [alertView show];
//            return ;
//        }
//        if(succeeded){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter]postNotificationName:kUpdatedName object:nil];
//            });
//        }
//    }];
    
}

#pragma START_OF_LOCATION_MANAGER

- (CLLocationManager *)locationManager{
    if(_locationManager != nil){
        return _locationManager;
    }
    _locationManager = [[CLLocationManager alloc]init];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [_locationManager setDelegate:self];
    return _locationManager;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if([PFUser currentUser]){
        [self setCurrentLocation:[locations lastObject]];
        //[self setCurrentLocation:[self.locationManager location]];
    }
}
//-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
//    
//}
- (void)updatedLocation{
    [self setCurrentLocation:self.locationManager.location];
    PFInstallation *curInstallation = [PFInstallation currentInstallation];
    
    curInstallation[@"user"] = [PFUser currentUser];
    curInstallation.badge = 0;
    [curInstallation saveEventually];
    
//    if( curInstallation.badge != 0 ){
//        curInstallation.badge = 0;
//        [curInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if(error){
//                NSLog(@"Error occured in updating badge.");
//            }else{
//                NSLog(@"Updated badge!");
//            }
//        }];
//    }
}
#pragma END_OF_LOCATION_MANAGER

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    [application setStatusBarHidden:YES];
    
    
    
    self.levelOfScr = 0;
    [Parse setApplicationId:@"eEFqruaUBuXZ4wA9oLvGp6aLyl83CyW5a4UxkaKG" clientKey:@"nm8ZoYve2WOwxzJqxeWArBzfkpd5z75f6iAHLKiE"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    
    PFUser *currentUser = [PFUser currentUser];
    if(currentUser){
        [PFUser logOut];
    }
    
    
    [[self locationManager] startUpdatingLocation];
    
    //Regsiter for push notifications.
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}


- (void)switchToMainVC {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *mainVC = [storyboard instantiateViewControllerWithIdentifier:@"loginScreenStoryboardID"];
    self.window.rootViewController = mainVC;

}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    //Store the deviceToken in the current installation and save it.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveEventually];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    [PFPush handlePush:userInfo];
}

@end
