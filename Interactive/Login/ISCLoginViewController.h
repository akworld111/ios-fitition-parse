//
//  ISCLoginViewController.h
//  Interactive
//
//  Created by WuYong on 6/10/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISCLoginViewController : UIViewController<UITextFieldDelegate>{
    
    __weak IBOutlet UITextField *m_txtEmail;
    __weak IBOutlet UITextField *m_txtPassword;
}

- (IBAction)btnLoginClicked:(id)sender;
- (IBAction)btnFacebookLoginClicked:(id)sender;
@end
