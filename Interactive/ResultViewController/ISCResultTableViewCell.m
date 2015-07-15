//
//  ISCResultTableViewCell.m
//  ActLife
//
//  Created by WuYong on 6/19/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCResultTableViewCell.h"

@implementation ISCResultTableViewCell

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
    UITapGestureRecognizer *dblTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDescription)];
    [dblTapGesture setNumberOfTapsRequired:2];
    [self.m_txtDescription addGestureRecognizer:dblTapGesture];
    
}

- (void)showDescription{
    if([self.delegate respondsToSelector:@selector(showDescriptionView:)]){
        [self.delegate showDescriptionView:self.m_txtDescription.text];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnDetailsClicked:(id)sender {
    if([self.delegate respondsToSelector:@selector(showDetails:)]){
        [self.delegate showDetails:self.indexPath];
    }
}

- (void)setInitialInfo:(PFObject *)initialInfo{
    _initialInfo = initialInfo;
//    self.m_imgType.image = nil;
//    self.m_lblWinners.text = @"";
//    self.m_lblType.text = @"";
//    self.m_lblStartTime.text = @"";
//    self.m_lblPlace.text = @"";
//    self.m_lblNumber.text = @"";
//    self.m_txtDescription.text = @"";
    
    PFQuery *query = [PFQuery queryWithClassName:@"ActiveEvents"];

    [query getObjectInBackgroundWithId:self.initialInfo[@"EventId"] block:^(PFObject *object, NSError *error) {
        self.m_lblWinners.text = @"";
        NSArray *tmpWinnerIds = self.initialInfo[@"Winners"];
        PFQuery *innerQuery = [PFUser query];
        [innerQuery whereKey:@"objectId" containedIn:tmpWinnerIds];
        [innerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSString *winners = @"";
            for(id tmpStr in objects){
                if([winners isEqualToString:@""])
                    winners = tmpStr[@"username"];
                else
                    winners = [NSString stringWithFormat:@"%@,%@",winners, tmpStr[@"username"]];
            }
            self.m_lblWinners.text = winners;
        }];

//        if([self.initialInfo[@"Winners"]length]>0){
//            self.m_lblWinners.text = [self.initialInfo[@"Winners"] substringFromIndex:1];
//            
//        }
        self.m_lblType.text = object[@"Type"];
        
        innerQuery = [PFQuery queryWithClassName:@"TypeOfEvents"];
        [innerQuery whereKey:@"TitleOfType" equalTo:object[@"Type"]];
        [innerQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            PFFile *file = [object objectForKey:@"ImageOfType"];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.m_imgType.image = [UIImage imageWithData:data];
            }];
        }];
        
        self.m_lblPlace.text = object[@"Place"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MMMM d, yyyy"];
        self.m_lblStartTime.text = [formatter stringFromDate:object[@"StartTime"]];
//        self.m_lblNumber.text = [NSString stringWithFormat:@"%lu participants", [[object[@"People"]componentsSeparatedByString:@","]count]];
        [self.m_btnParticipants setTitle:[NSString stringWithFormat:@"%lu participants", (unsigned long)[object[@"People"]count]] forState:UIControlStateNormal];
        self.m_txtDescription.text = object[@"Description"];
    }];
}
-(void)dealloc{
//    NSLog(@"Cell Deallocated! %lu", self.indexPath.row);
}
@end
