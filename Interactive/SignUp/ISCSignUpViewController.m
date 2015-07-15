//
//  ISCSignUpViewController.m
//  Interactive
//
//  Created by WuYong on 6/10/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCSignUpViewController.h"
#import "GKImagePicker.h"
#import <Parse/Parse.h>
#import "AFNetworking.h"

@interface ISCSignUpViewController ()<GKImagePickerDelegate>{
    
    __weak IBOutlet UIButton *btnTitle;
    GKImagePicker *picker;
    __weak IBOutlet UIButton *m_btnPhoto;
    __weak IBOutlet UITextField *m_txtZipCode;
    BOOL photoAdded;
    NSString *m_strLocation;
    
    __weak IBOutlet UIScrollView *m_contentSV;
    NSString *strGender;
    UITextField *tempTextField;
    UIButton *doneButton;
}

@end

@implementation ISCSignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    doneButton = nil;
    photoAdded = NO;
    strGender = @"Male";
    // Do any additional setup after loading the view.
}
- (IBAction)doneButtonAction:(id)sender{
    doneButton = nil;
    [m_txtZipCode resignFirstResponder];
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
    if([m_txtUsername.text isEqualToString:@""]){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please input username." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    if([m_txtEmail.text isEqualToString:@""]){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please input email address." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    if([m_txtPassword.text length]<6){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Password should be at least 6 letters." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    if(![m_txtConfirm.text isEqualToString:m_txtPassword.text]){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please confirm password is correct." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }
    if([m_txtZipCode.text isEqualToString:@""]){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please input Zipcode." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
        return NO;
    }else{
        m_strLocation = @"";
        NSString *str = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true",m_txtZipCode.text];
        NSURL *url = [NSURL URLWithString:str];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc]initWithRequest:req];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *arr = [responseObject objectForKey:@"results"];
            if([arr count]==0)
            {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please input correct Zipcode." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
                return ;
            }
            NSDictionary *dic = [arr objectAtIndex:0];
            NSArray *addComp = [dic objectForKey:@"address_components"];
            for(NSDictionary *t in addComp){
                NSArray *t1 = [t objectForKey:@"types"];
                if([[t1 objectAtIndex:0]isEqualToString:@"locality"]){
                    m_strLocation = [NSString stringWithFormat:@"%@,", [t objectForKey:@"long_name"]];
                }
                if([[t1 objectAtIndex:0]isEqualToString:@"administrative_area_level_1"]){
                    m_strLocation = [NSString stringWithFormat:@"%@%@,",m_strLocation, [t objectForKey:@"long_name"]];
                }
                if([[t1 objectAtIndex:0]isEqualToString:@"country"]){
                    if([m_strLocation length]>20)
                        m_strLocation = [NSString stringWithFormat:@"%@%@",m_strLocation, [t objectForKey:@"short_name"]];
                    else
                        m_strLocation = [NSString stringWithFormat:@"%@%@",m_strLocation, [t objectForKey:@"long_name"]];
                }
            }
            
            NSString *address = [dic objectForKey:@"formatted_address"];
            NSLog(@"%@",address);
            NSLog(@"%@",m_strLocation);
            [self createAccount];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error!" message:@"Please input correct Zipcode." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
        }];
        [op start];
    }
    return YES;
}
- (void)createAccount{
    PFUser *user = [PFUser user];
    user.username = m_txtUsername.text;
    user.password = m_txtPassword.text;
    user.email = m_txtEmail.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            NSLog(@"Account Created!");
            //[self loginWithUsername:m_txtUsername.text Password:m_txtPassword.text];
            [PFUser logInWithUsernameInBackground:m_txtUsername.text password:m_txtPassword.text block:^(PFUser *user, NSError *error) {
                if(user){
                    NSLog(@"Login Successed!");
                    [self uploadPhoto];
                }
            }];
        }else{
            NSString *strError = [error userInfo][@"error"];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:strError delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alertView show];
            //            NSLog(@"SignUp Error: %@",strError);
        }
    }];
}
- (IBAction)btnCreateAccountClicked:(id)sender {
    
    if(![self checkCorrect]){
        return;
    }
//    [self createAccount];
    
}

- (void)loginWithUsername:(NSString *)username Password:(NSString *)password{
    
    [PFUser logInWithUsernameInBackground:m_txtUsername.text password:m_txtPassword.text block:^(PFUser *user, NSError *error) {
        if(user){
            NSLog(@"Login Successed!");
            user[@"gender"] = [btnTitle titleForState:UIControlStateNormal];
            user[@"zipcode"] = m_txtZipCode.text;
            
            [user saveEventually:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    [self uploadPhoto];
                }else{
                    
                }
            }];
            
        }else{
//            NSString *strError = [error userInfo][@"error"];
//            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:strError delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//            [alertView show];
            NSLog(@"Error!");
        }
    }];
}

- (void)uploadPhoto{
    NSData *imageData = UIImageJPEGRepresentation([m_btnPhoto imageForState:UIControlStateNormal], 0.05f);
    PFFile *imageFile = [PFFile fileWithName:@"Photo.jpg" data:imageData];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            PFUser *user = [PFUser currentUser];
            user[@"gender"] = strGender;//[btnTitle titleForState:UIControlStateNormal];
//            user[@"zipcode"] = m_txtZipCode.text;
            user[@"address"] = m_strLocation;
            [user setObject:imageFile forKey:@"Photo"];
            [user saveEventually:^(BOOL succeeded, NSError *error) {
                if(succeeded){
                    [PFUser logOut];
                    [self btnBackClicked:nil];
                }else{
                    NSLog(@"Error occured while uploading photo.");
                }
            }];
        }
    }];
}

- (IBAction)btnBackClicked:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//    }];
    [self performSegueWithIdentifier:@"UnwindToLoginScreenSegueID" sender:self];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    doneButton = nil;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [m_contentSV setContentOffset:CGPointMake(0, 0)];
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}
- (void)addDoneButton{
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    doneButton.adjustsImageWhenHighlighted = NO;
    [doneButton setImage:[UIImage imageNamed:@"doneup.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"donedown.png"] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //locate keyboard view
    
    UIView *keyboardView = [[[[[UIApplication sharedApplication]windows]lastObject]subviews]firstObject];
    [doneButton setFrame:CGRectMake(0, keyboardView.frame.size.height - 53, 106, 53)];
    [keyboardView addSubview:doneButton];
    //        [keyboardView bringSubviewToFront:doneButton];
    
    //        For the iOS6,5,4
    //        UIWindow *tempWindow = [[[UIApplication sharedApplication]windows]objectAtIndex:0];
    //        UIView *keyboard;
    //        for(int i = 0;i < [tempWindow.subviews count]; i++){
    //            keyboard = [tempWindow.subviews objectAtIndex:i];
    //            if([[keyboard description]hasPrefix:@"UIKeyboard"] == YES){
    //                [keyboard addSubview:doneButton];
    //            }
    //        }
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    tempTextField = textField;
    if([textField isEqual:m_txtZipCode]){
        [self performSelector:@selector(addDoneButton) withObject:nil afterDelay:0.1];
    }else{
        if(doneButton!=nil){
            [doneButton removeFromSuperview];
            doneButton = nil;
        }
    }
    
    if([textField isEqual:m_txtConfirm] || [textField isEqual:m_txtPassword] || [textField isEqual:m_txtEmail]){
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [m_contentSV setContentOffset:CGPointMake(0, 150)];
        [UIView commitAnimations];
    }else{
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.5];
        [m_contentSV setContentOffset:CGPointMake(0, 0)];
        [UIView commitAnimations];
    }
}
//- (void)textFieldDidEndEditing:(UITextField *)textField{
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.5];
//    [m_contentSV setContentOffset:CGPointMake(0, 0)];
//    [UIView commitAnimations];
//}
- (IBAction)btnGenderClicked:(id)sender {
    UIButton *btnTemp = sender;
    if([strGender isEqualToString:@"Male"]){
        [btnTemp setImage:[UIImage imageNamed:@"Female-icon.png"] forState:UIControlStateNormal];
        strGender = @"Female";
    }else{
        [btnTemp setImage:[UIImage imageNamed:@"Male-icon.png"] forState:UIControlStateNormal];
        strGender = @"Male";
    }
//    [btnTemp setTitle:title forState:UIControlStateNormal];
}

- (IBAction)btnPhotoClicked:(id)sender {
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera Roll", @"Take a photo", nil];
//    [actionSheet showInView:self.view];
    picker = [[GKImagePicker alloc]init];
    picker.delegate = self;
    picker.cropper.cropSize = CGSizeMake(320., 320.);
    picker.cropper.rescaleImage = YES;
    picker.cropper.rescaleFactor = 2.0;
    picker.cropper.dismissAnimated = YES;
    picker.cropper.overlayColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:0.7];
    picker.cropper.innerBorderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7];
    [picker presentPicker];
}

#pragma mark - GKImagePicker Delegate
- (void)imagePickerDidFinish:(GKImagePicker *)imagePicker withImage:(UIImage *)image{
    NSLog(@"Success");
    [m_btnPhoto setImage:image forState:UIControlStateNormal];
    photoAdded = YES;
}

@end
