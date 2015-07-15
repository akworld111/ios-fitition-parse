//
//  ISCEventDetailViewController.m
//  F.A.T
//
//  Created by WuYong on 7/13/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCEventDetailViewController.h"
#import "ISCPeopleProfileViewController.h"
#import "ISCAppDelegate.h"
#import "ISCParticipantsTableViewCell.h"

@interface ISCEventDetailViewController ()<UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UITableView *m_tblContent;
    __weak IBOutlet UIButton *m_btnParticipate;
    
    
    NSMutableArray *arrParticipants;
    NSString *owner;
}

@end

@implementation ISCEventDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    //    NSString *people = self.eventInfo[@"People"];
    PFUser *curUser = [PFUser currentUser];
    owner = self.eventObj[@"Owner"];
    arrParticipants = self.eventObj[@"People"];
    
    if([arrParticipants containsObject:curUser.objectId]){
        [m_btnParticipate setEnabled:NO];
    }
    
    if([self.eventObj[@"Applicants"] containsObject:curUser.objectId]){
        [m_btnParticipate setEnabled:NO];
    }
    
    [m_tblContent reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnParticipateClicked:(id)sender {

    [m_btnParticipate setEnabled:NO];
    
    NSString *curUsername = [PFUser currentUser].objectId;
    
//    [arrParticipants addObject:curUsername];
//    [self.eventObj setObject:arrParticipants forKey:@"People"];
    NSMutableArray *arrAppliedPeople = self.eventObj[@"Applicants"];
    if(!arrAppliedPeople){
        arrAppliedPeople = [[NSMutableArray alloc]init];
    }
    [arrAppliedPeople addObject:curUsername];
    [self.eventObj setObject:arrAppliedPeople forKey:@"Applicants"];

    //This should be saveInBackground... after adding waiting screen.
    [self.eventObj save];

}

#pragma mark - Tableview Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(!arrParticipants)
        return 0;
    return [arrParticipants count];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 60.;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *strIdentifier = @"EventDetailsCellIdentifier";
    ISCParticipantsTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:strIdentifier];
    if(!cell){
        cell = [[ISCParticipantsTableViewCell alloc]init];
    }
    cell.m_userId = [arrParticipants objectAtIndex:indexPath.row];
    
    if([cell.m_userId isEqualToString:owner])
        cell.m_lblDescription.text = @"Creator";
    else
        cell.m_lblDescription.text = @"Participant";
    
//    [self configureCell:cell indexPath:indexPath];
    return cell;
}

//- (void) configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)idxPath{
//    NSString *userId = [arrParticipants objectAtIndex:idxPath.row];
//    
//    cell.backgroundColor = [UIColor clearColor];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    
//    cell.imageView.image = [UIImage imageNamed:@"images.jpg"];
//    cell.textLabel.text = @"                      ";
//    
//    if([userId isEqualToString:owner])
//        cell.detailTextLabel.text = @"Creator";
//    else
//        cell.detailTextLabel.text = @"Participant";
//    
//    PFQuery *query = [PFUser query];
//    [query getObjectInBackgroundWithId:userId block:^(PFObject *object, NSError *error) {
//        cell.textLabel.text = object[@"username"];
//        
//        PFFile *file = object[@"Photo"];
//        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
//            cell.imageView.image = [UIImage imageWithData:data];
//        }];
//    }];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
    del.levelOfScr = 1;
//    if(del.levelOfScr>1)
//        return;
    NSString *selectedUserId = [arrParticipants objectAtIndex:indexPath.row];
    
    
    if([[PFUser currentUser].objectId isEqualToString:selectedUserId])
        return;
    
    
    ISCPeopleProfileViewController *ppvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PeopleProfileStoryboardID"];
    PFObject *obj = [PFObject objectWithClassName:@"ActiveEvents"];
    [obj setObject:selectedUserId forKey:@"Owner"];
    ppvc.objUser = obj;
    [self presentViewController:ppvc animated:YES completion:nil];
}
@end
