//
//  ISCParticipantsTableViewCell.m
//  F.A.T
//
//  Created by WuYong on 7/15/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCParticipantsTableViewCell.h"

@implementation ISCParticipantsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setM_userId:(NSString *)m_userId{
    
    _m_userId = m_userId;
    
//    PFUser *curUser = [PFUser currentUser];
//    if([object[@"username"] isEqualToString:curUser.username])
//        self.m_lblDescription.text = @"Creator";
//    else
//        self.m_lblDescription.text = @"Participant";
    
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:m_userId block:^(PFObject *object, NSError *error) {
        self.m_lblUser.text = object[@"username"];
        
        PFFile *file = object[@"Photo"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.m_imgUser.image = [UIImage imageWithData:data];
        }];
    }];
    
    PFQuery *queryForRates = [[PFQuery alloc]initWithClassName:@"Rates"];
    [queryForRates whereKey:@"Username" equalTo:m_userId];
    [queryForRates findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSUInteger totalScore = 0;
        for(PFObject *tmpObj in objects){
            totalScore += [tmpObj[@"Rate"]integerValue];
        }
        [self setScore:totalScore :[objects count]];
    }];
}

- (void)setScore: (NSUInteger)tScore :(NSUInteger)count{
    NSUInteger starScore = 0;
    if(count>0)
        starScore = tScore / count;
    m_btn1.selected = NO;
    m_btn2.selected = NO;
    m_btn3.selected = NO;
    m_btn4.selected = NO;
    m_btn5.selected = NO;
    
    if(starScore>=1)
        m_btn1.selected = YES;
    if(starScore>=2)
        m_btn2.selected = YES;
    if(starScore>=3)
        m_btn3.selected = YES;
    if(starScore>=4)
        m_btn4.selected = YES;
    if(starScore>=5)
        m_btn5.selected = YES;
    if(count == 0)
    {
        self.m_aveRating.text = @"No Ratings";
        return;
    }
    float fRate = tScore;
    fRate = fRate / count;
    self.m_aveRating.text = [NSString stringWithFormat:@"%.1f", fRate];
}

@end
