//
//  ISCMenuViewController.h
//  Interactive
//
//  Created by WuYong on 6/13/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewControllerDelegate;

@interface ISCMenuViewController : UIViewController
- (IBAction)btnClicked:(id)sender;
@property (nonatomic, weak) id<MenuViewControllerDelegate> delegate;
@end

@protocol MenuViewControllerDelegate
-(void)menuViewControllerDidFinishWithMenuId:(NSInteger)menuId;
@end