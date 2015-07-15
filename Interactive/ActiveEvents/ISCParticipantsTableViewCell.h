//
//  ISCParticipantsTableViewCell.h
//  F.A.T
//
//  Created by WuYong on 7/15/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ISCParticipantsTableViewCell : UITableViewCell{
    
    __weak IBOutlet UIButton *m_btn1;
    __weak IBOutlet UIButton *m_btn2;
    __weak IBOutlet UIButton *m_btn3;
    __weak IBOutlet UIButton *m_btn4;
    __weak IBOutlet UIButton *m_btn5;
}


@property (weak, nonatomic) IBOutlet UIImageView *m_imgUser;
@property (weak, nonatomic) IBOutlet UILabel *m_lblUser;
@property (weak, nonatomic) IBOutlet UILabel *m_lblDescription;
@property (weak, nonatomic) IBOutlet UILabel *m_aveRating;

@property (nonatomic, retain) NSString *m_userId;
@end
