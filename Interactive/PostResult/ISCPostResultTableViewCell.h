//
//  ISCPostResultTableViewCell.h
//  ActLife
//
//  Created by WuYong on 6/18/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostResultCellDelegate< NSObject>
@optional
- (void)setWinner:(BOOL)isWinner IndexPath: (NSIndexPath *)idxPath;
- (void)setRate:(NSUInteger)rate IndexPath: (NSIndexPath *)idxPath;
- (void)setDescription: (NSString *)dsc IndexPath: (NSIndexPath *)idxPath;
@end

@interface ISCPostResultTableViewCell : UITableViewCell<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *m_lblUsername;
@property (weak, nonatomic) IBOutlet UIButton *m_btnWinner;
@property (weak, nonatomic) IBOutlet UIButton *m_btnRate1;
@property (weak, nonatomic) IBOutlet UIButton *m_btnRate2;
@property (weak, nonatomic) IBOutlet UIButton *m_btnRate3;
@property (weak, nonatomic) IBOutlet UIButton *m_btnRate4;
@property (weak, nonatomic) IBOutlet UIButton *m_btnRate5;
@property (weak, nonatomic) IBOutlet UITextView *m_txtDescription;
@property (weak, nonatomic) IBOutlet UIImageView *m_imgUser;



@property (weak, nonatomic)NSIndexPath *indexPath;
@property (weak, nonatomic)NSMutableDictionary *initialInfo;
@property (weak, nonatomic) id<PostResultCellDelegate> delegate;
@end
