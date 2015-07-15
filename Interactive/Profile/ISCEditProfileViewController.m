//
//  ISCEditProfileViewController.m
//  F.A.T
//
//  Created by WuYong on 7/11/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCEditProfileViewController.h"
#import <Parse/Parse.h>
#import "GKImagePicker.h"

@interface ISCEditProfileViewController ()<UITextFieldDelegate, GKImagePickerDelegate>{
    NSString *strGender;
    
    GKImagePicker *picker;
}
@property (weak, nonatomic) IBOutlet UITextField *m_txtUsername;
@property (weak, nonatomic) IBOutlet UITextField *m_txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *m_txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *m_txtLocation;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgUser;
@property (weak, nonatomic) IBOutlet UIScrollView *m_contentScrollView;
@property (weak, nonatomic) IBOutlet UIButton *m_btnGender;

@end

@implementation ISCEditProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)btnBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnSaveClicked:(id)sender {
    if([self checkCorrect]){

        

            NSData *imageData = UIImageJPEGRepresentation(self.m_imgUser.image, 0.05f);
            PFFile *imageFile = [PFFile fileWithName:@"Photo.jpg" data:imageData];
            
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if(!error){
                    PFUser *curUser = [PFUser currentUser];
                    curUser.username = self.m_txtUsername.text;
                    curUser.password = self.m_txtPassword.text;
                    curUser[@"address"] = self.m_txtLocation.text;
                    curUser[@"gender"] = strGender;
                    
                    [curUser setObject:imageFile forKey:@"Photo"];
                    [curUser saveEventually:^(BOOL succeeded, NSError *error) {
                        if(succeeded){
//                            [PFUser logOut];
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"ProfileChanged" object:self];
                            [self btnBackClicked:nil];
                        }else{
                            NSLog(@"Error occured while uploading photo.");
                        }
                    }];
                }
            }];
        
    }
}
- (IBAction)btnGenderClicked:(id)sender {
    if([strGender isEqualToString:@"Male"]){
        strGender = @"Female";
        [sender setImage:[UIImage imageNamed:@"Female-icon.png"] forState:UIControlStateNormal];
    }else{
        strGender = @"Male";
        [sender setImage:[UIImage imageNamed:@"Male-icon.png"] forState:UIControlStateNormal];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self.m_contentScrollView setContentOffset:CGPointMake(0, 100)];
    [UIView commitAnimations];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self.m_contentScrollView setContentOffset:CGPointMake(0, 0)];
    [UIView commitAnimations];
    [textField resignFirstResponder];
    
    return [textField resignFirstResponder];
    
}

- (void)addPhoto{
    picker = [[GKImagePicker alloc]init];
    picker.delegate = self;
    picker.cropper.cropSize = CGSizeMake(320., 320.);
    picker.cropper.rescaleImage = YES;
    picker.cropper.rescaleFactor = 2.;
    picker.cropper.dismissAnimated = YES;
    picker.cropper.overlayColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.7];
    picker.cropper.innerBorderColor = [UIColor colorWithRed:1. green:1. blue:1. alpha:0.7];
    [picker presentPicker];
}

#pragma mark - GKImagePicker Delegate
- (void)imagePickerDidFinish:(GKImagePicker *)imagePicker withImage:(UIImage *)image{
    [self.m_imgUser setImage:image];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addPhoto)];
    tapGesture.numberOfTapsRequired = 1;
    [self.m_imgUser addGestureRecognizer:tapGesture];
    [self.m_imgUser setUserInteractionEnabled:YES];
    
    self.m_imgUser.layer.cornerRadius = self.m_imgUser.frame.size.width/2;
    self.m_imgUser.layer.masksToBounds = YES;
    
    PFUser *curUser = [PFUser currentUser];
    strGender = curUser[@"gender"];
    if([strGender isEqualToString:@"Female"]){
        [self.m_btnGender setImage:[UIImage imageNamed:@"Female-icon.png"] forState:UIControlStateNormal];
    }else{
        [self.m_btnGender setImage:[UIImage imageNamed:@"Male-icon.png"] forState:UIControlStateNormal];
    }
    self.m_txtUsername.text = curUser.username;
    self.m_txtEmail.text = curUser.email;
    self.m_txtLocation.text = curUser[@"address"];
    
    PFFile *file = curUser[@"Photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.m_imgUser.image = [UIImage imageWithData:data];
        self.m_imgUser.layer.cornerRadius = self.m_imgUser.frame.size.width/2;
        self.m_imgUser.layer.masksToBounds = YES;
    }];
    // Do any additional setup after loading the view.
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
- (BOOL)checkCorrect{
    UIAlertView *alertView;
    if([self.m_txtUsername.text isEqualToString:@""]){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please input username." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    if([self.m_txtEmail.text isEqualToString:@""]){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please input email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    if([self.m_txtPassword.text length]<6){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Password should be at least 6 letters." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    if([self.m_txtLocation.text isEqualToString:@""]){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please input Zipcode." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    return YES;
}
@end
