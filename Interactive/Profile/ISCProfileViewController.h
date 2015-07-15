//
//  ISCProfileViewController.h
//  Interactive
//
//  Created by WuYong on 6/11/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ISCProfileViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIAlertViewDelegate>{

    __weak IBOutlet UILabel *m_lblWelcomeUser;
    __weak IBOutlet UIScrollView *m_contentScrollView;

    __weak IBOutlet UITextField *m_txtStartMonth;
    __weak IBOutlet UITextField *m_txtStartDay;
    __weak IBOutlet UITextField *m_txtStartYear;
    __weak IBOutlet UITextField *m_txtStartTime;
    
    __weak IBOutlet UITextField *m_txtPlace;
    __weak IBOutlet UITextView *m_txtDescription;
    __weak IBOutlet UITextField *m_txtPostTo;
    
    
    __weak IBOutlet UIScrollView *m_scrollTypeList;
    __weak IBOutlet UIButton *m_btnMenu;
}
- (IBAction)btnSignOutClicked:(id)sender;
- (IBAction)btnPostClicked:(id)sender;

@end
