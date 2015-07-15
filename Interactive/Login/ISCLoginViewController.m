//
//  ISCLoginViewController.m
//  Interactive
//
//  Created by WuYong on 6/10/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCLoginViewController.h"
#import "ISCProfileViewController.h"
#import <Parse/Parse.h>
#import "ISCAppDelegate.h"
#import "ISCFirebaseManager.h"

@interface ISCLoginViewController ()

@end

@implementation ISCLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
    [m_txtEmail setText:@""];
    [m_txtPassword setText:@""];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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

- (IBAction)btnLoginClicked:(id)sender {
    [PFUser logInWithUsernameInBackground:m_txtEmail.text password:m_txtPassword.text block:^(PFUser *user, NSError *error) {
        if(user){
            NSLog(@"Login Successed!");
            NSLog(@"password: %@",user.password);
            [[ISCFirebaseManager sharedInstance] createNewAccount:user.email :user.password];
            [[ISCFirebaseManager sharedInstance] setListners:user.objectId];

            [self performSegueWithIdentifier:@"gotoNavigationScreenSegueID" sender:self];
            
            ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
            [del updatedLocation];
            
        }else{
            NSString *strError = [error userInfo][@"error"];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:strError delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alertView show];
        }
    }];
}

- (IBAction)btnFacebookLoginClicked:(id)sender {
//    NSArray *permissions = @[@"email", @"user_likes", @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
//    NSArray *permissions = @[@"public_profile"];
//    NSArray *permissions = @[@"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    NSArray *permissions = @[@"publish_actions", @"public_profile", @"email", @"user_likes", @"user_birthday", @"user_location" ];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if(!user){
            if(!error)
                NSLog(@"User cancelled the facebook login!");
            else
                NSLog(@"An error occurred: %@", error);
            NSString *strError = [error userInfo][@"error"];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:strError delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alertView show];
            
        }else if(user.isNew){
            NSLog(@"User signed up and logged in through Facebook!");
            FBRequest *request = [FBRequest requestForMe];
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if(!error){
                    NSDictionary *userdata = result;
                    NSLog(@"%@",userdata);
                    
                    user.username = [userdata objectForKey:@"name"];
                    user.email = [userdata objectForKey:@"email"];
                    if([userdata[@"location"][@"name"] isEqual:[NSNull null]]){
                        user[@"address"] = @"";
                    }else{
                        user[@"address"] = userdata[@"location"][@"name"];
                    }
                    if([userdata[@"gender"]isEqual:[NSNull null]]){
                        user[@"gender"] = @"Male";
                    }else{
                        if([userdata[@"gender"]isEqualToString:@"male"])
                            user[@"gender"] = @"Male";
                        else
                            user[@"gender"] = @"Female";
                    }
                    [user saveEventually:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
                            [self performSegueWithIdentifier:@"gotoNavigationScreenSegueID" sender:self];
                            ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
                            [self uploadPhoto];
                            [del updatedLocation];
                            
                            
                        }else{
                            
                        }
                    }];
                }else{
                    NSString *strError = [error userInfo][@"error"];
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:strError delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    [alertView show];
                }
            }];
        }else{
            NSLog(@"User logged in through Facebook!");
            [self performSegueWithIdentifier:@"gotoNavigationScreenSegueID" sender:self];
            ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
            [del updatedLocation];
        }
    }];
}

- (void)uploadPhoto{
    FBSession *fbSession = [PFFacebookUtils session];
    NSString *accessToken = [fbSession accessTokenData].accessToken;
    
    NSURL *url =  [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?type=large&return_ssl_resources=1&access_token=%@", accessToken]];
    
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    
    PFFile *imageFile = [PFFile fileWithName:@"Photo.jpg" data:imageData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            PFUser *user = [PFUser currentUser];
            [user setObject:imageFile forKey:@"Photo"];
            [user saveEventually:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"ProfileChanged" object:self];
                }else{
                    NSLog(@"Error occured while uploading photo.");
                }
            }];
        }
    }];
}
- (void) gotoProfilePage{

    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(IBAction)unwindToLoginScreen: (UIStoryboardSegue *)unwindSegue{
    
}

@end
