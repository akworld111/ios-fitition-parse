//
//  ISCPostResultViewController.h
//  ActLife
//
//  Created by WuYong on 6/19/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ISCPostResultTableViewCell.h"

@interface ISCPostResultViewController : UIViewController<UITableViewDataSource, PostResultCellDelegate>
@property (weak, nonatomic) PFObject *eventInfo;
@end
