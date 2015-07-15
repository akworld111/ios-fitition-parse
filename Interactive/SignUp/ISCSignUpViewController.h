//
//  ISCSignUpViewController.h
//  Interactive
//
//  Created by WuYong on 6/10/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISCSignUpViewController : UIViewController<UITextFieldDelegate>{
    
    __weak IBOutlet UITextField *m_txtUsername;
    __weak IBOutlet UITextField *m_txtEmail;
    __weak IBOutlet UITextField *m_txtPassword;
    __weak IBOutlet UITextField *m_txtConfirm;
}
- (IBAction)btnCreateAccountClicked:(id)sender;
- (IBAction)btnBackClicked:(id)sender;

@end
