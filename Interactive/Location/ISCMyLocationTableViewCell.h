//
//  ISCMyLocationTableViewCell.h
//  ActLife
//
//  Created by WuYong on 6/16/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InvitationDelegate <NSObject>

@optional
- (void)btnInviteClicked: (NSString *)userName;

@end


@interface ISCMyLocationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *m_lblUser;
@property (weak, nonatomic) IBOutlet UILabel *m_lblCoords;
- (IBAction)btnInviteClicked:(id)sender;

@property (weak, nonatomic) id<InvitationDelegate>delegate;
@end
