//
//  ISCActiveEventTableViewCell.h
//  Interactive
//
//  Created by WuYong on 6/14/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol PostResultDelegate <NSObject>

@optional
- (void)PostResultWithObject:(PFObject *)obj;
- (void)showDescriptionView:(NSString *)txt;
- (void)showEventDetail:(PFObject *)obj;
- (void)showApplicants:(PFObject *)obj;
@end

@interface ISCActiveEventTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *m_lblOwner;
@property (weak, nonatomic) IBOutlet UILabel *m_lblType;
@property (weak, nonatomic) IBOutlet UILabel *m_lblPlace;
@property (weak, nonatomic) IBOutlet UILabel *m_lblStartTime;
@property (weak, nonatomic) IBOutlet UILabel *m_lblNumberOfPeople;
@property (weak, nonatomic) IBOutlet UITextView *m_txtDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnApply;
@property (weak, nonatomic) IBOutlet UIButton *btnPostResult;
@property (weak, nonatomic) IBOutlet UIButton *btnLike;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;
@property (weak, nonatomic) IBOutlet UIImageView *imgApplicantsBack;
@property (weak, nonatomic) IBOutlet UIButton *btnApplicants;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgType;
@property (weak, nonatomic) IBOutlet UIButton *m_btnNumberOfParticipants;
@property (weak, nonatomic) id<PostResultDelegate> delegate;

@property (weak, nonatomic) PFObject *object;

- (IBAction)btnApplyClicked:(id)sender;
- (IBAction)btnPostResultClicked:(id)sender;
- (IBAction)btnLikeClicked:(id)sender;
- (IBAction)btnShareClicked:(id)sender;


@end
