//
//  ISCActiveEventTableViewCell.m
//  Interactive
//
//  Created by WuYong on 6/14/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCActiveEventTableViewCell.h"

@implementation ISCActiveEventTableViewCell

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
    
//    self.m_txtDescription.gestureRecognizers = nil;
    
    UITapGestureRecognizer *dblTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDescription)];
    [dblTapGesture setNumberOfTapsRequired:2];
    
//    NSMutableArray *arr = [NSMutableArray alloc]initWithArray:<#(NSArray *)#>
    
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

- (IBAction)btnApplyClicked:(id)sender {
    if([self.delegate respondsToSelector:@selector(showEventDetail:)]){
        [self.delegate showEventDetail:self.object];
    }
//    [self.btnApply setTitle:@"Applied" forState:UIControlStateNormal];
//    [self.btnApply setEnabled:NO];
//
//    NSString *curUsername = [PFUser currentUser].objectId;
//    NSMutableArray *strPeoples = self.object[@"People"];
//    if([self.m_lblOwner.text  isEqualToString:curUsername]){
//        return;
//    }else{
////        strPeoples = [NSString stringWithFormat:@"%@,%@", strPeoples, curUsername];
//        [strPeoples addObject:curUsername];
//        [self.object setObject:strPeoples forKey:@"People"];
//        [self.object save];
//    }
}
- (IBAction)btnApplicantsClicked:(id)sender {
    if([self.delegate respondsToSelector:@selector(showApplicants:)]){
        [self.delegate showApplicants:self.object];
    }
}
- (IBAction)btnPostResultClicked:(id)sender {
    if([self.delegate respondsToSelector:@selector(PostResultWithObject:)]){
        [self.delegate PostResultWithObject:self.object];
    }
}

- (IBAction)btnLikeClicked:(id)sender {
}

- (IBAction)btnShareClicked:(id)sender {
}
-(void)dealloc{
    NSLog(@"Cell dealloced");
}

- (void)setObject:(PFObject *)object{
    _object = object;
//    self.m_lblOwner.text = object[@"Owner"];
    self.m_lblType.text = object[@"Type"];
    self.m_lblPlace.text = object[@"Place"];
    NSDate *da = object[@"StartTime"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MMMM d, y"];
    self.m_lblStartTime.text = [formatter stringFromDate:da];//object[@"StartTime"];
    self.m_txtDescription.text = object[@"Description"];
    NSArray *tmp = object[@"People"];
//    self.m_lblNumberOfPeople.text = [NSString stringWithFormat:@"%lu People",(unsigned long)[tmp count]];//object[@"People"];
    [self.m_btnNumberOfParticipants setTitle:[NSString stringWithFormat:@"%lu participants",(unsigned long)[tmp count]] forState:UIControlStateNormal];

    tmp = object[@"Applicants"];
    [self.btnApplicants setTitle:[NSString stringWithFormat:@"%lu applicants",(unsigned long)[tmp count]] forState:UIControlStateNormal];
    
    PFUser *curUser = [PFUser currentUser];
//    NSString *curUsername = [PFUser currentUser].objectId;
//    NSString *strPeoples = self.object[@"People"];
//    NSArray *tmpArray = self.object[@"People"];//[strPeoples componentsSeparatedByString:@","];

    
//For the discover screen.
    if(self.m_imgPhoto){
        self.m_imgPhoto.image = [UIImage imageNamed:@"images-1.jpg"];
        
//        if([curUsername isEqualToString:self.m_lblOwner.text]){
        if([curUser.objectId isEqualToString:object[@"Owner"]]){
            self.m_lblOwner.text = curUser.username;
            [self.btnPostResult setHidden:NO];
            [self.imgApplicantsBack setHidden:NO];
            [self.btnApplicants setHidden:NO];
            //get User's photo
            PFFile *filePhoto = [[PFUser currentUser] objectForKey:@"Photo"];
            [filePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.m_imgPhoto.image = [UIImage imageWithData:data];
            }];
        }else{
            [self.imgApplicantsBack setHidden:YES];
            [self.btnApplicants setHidden:YES];
            [self.btnPostResult setHidden:YES];
            PFQuery *query = [PFUser query];
            [query getObjectInBackgroundWithId:object[@"Owner"] block:^(PFObject *object, NSError *error) {
                self.m_lblOwner.text = object[@"username"];
                PFFile *filePhoto = [object objectForKey:@"Photo"];
                [filePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    self.m_imgPhoto.image = [UIImage imageWithData:data];
                }];
            }];
//            [query whereKey:@"username" equalTo:self.m_lblOwner.text];
//            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//                
//                PFFile *filePhoto = [object objectForKey:@"Photo"];
//                [filePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//                    self.m_imgPhoto.image = [UIImage imageWithData:data];
//                }];
//            }];
        }
    }
    
    
//For the My Events screen.
    if(self.m_imgType){
        PFQuery *query = [PFQuery queryWithClassName:@"TypeOfEvents"];
        [query whereKey:@"TitleOfType" equalTo:object[@"Type"]];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            PFFile *file = [object objectForKey:@"ImageOfType"];
            [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                self.m_imgType.image = [UIImage imageWithData:data];
            }];
        }];
        
        if([object[@"Owner"]isEqualToString:curUser.objectId]){
            [self.btnPostResult setHidden:NO];
            [self.imgApplicantsBack setHidden:NO];
            [self.btnPostResult setHidden:NO];
        }else{
            [self.imgApplicantsBack setHidden:YES];
            [self.btnApplicants setHidden:YES];
            [self.btnPostResult setHidden:YES];
        }
    }

//    for(NSString *tmpStr in tmpArray){
//        if([tmpStr isEqualToString:curUsername]){
//            [self.btnApply setEnabled:NO];
//            [self.btnApply setTitle:@"Applied" forState:UIControlStateNormal];
//            return;
//        }
//    }
    
    [self.btnApply setEnabled:YES];
//    [self.btnApply setTitle:@"Apply" forState:UIControlStateNormal];
    
    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if(!error){
//            for (PFObject *object in objects){
//                [nearPeoples addObject:object];
//                ISCGeoPointAnnotation *geoPointAnnotation = [[ISCGeoPointAnnotation alloc]initWithObject:object];
//                [self.m_mapView addAnnotation:geoPointAnnotation];
//            }
//            [self.m_tableview reloadData];
//        }
//    }];
}
@end
