//
//  ISCResultTableViewCell.h
//  ActLife
//
//  Created by WuYong on 6/19/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol ResultOfEventCellProtocol <NSObject>

@optional
- (void)showDetails:(NSIndexPath *)idxPath;
- (void)showDescriptionView:(NSString *)txt;

@end

@interface ISCResultTableViewCell : UITableViewCell{
    BOOL isRated;
}

@property (weak, nonatomic) IBOutlet UILabel *m_lblWinners;
@property (weak, nonatomic) IBOutlet UILabel *m_lblType;
@property (weak, nonatomic) IBOutlet UILabel *m_lblPlace;
@property (weak, nonatomic) IBOutlet UILabel *m_lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *m_lblNumber;
@property (weak, nonatomic) IBOutlet UITextView *m_txtDescription;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgType;
@property (weak, nonatomic) IBOutlet UIButton *m_btnParticipants;

@property (weak, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<ResultOfEventCellProtocol> delegate;
@property (weak, nonatomic) PFObject *initialInfo;
@end
