//
//  ISCPeopleProfileViewController.m
//  F.A.T
//
//  Created by WuYong on 7/8/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCPeopleProfileViewController.h"
#import "ISCFollowingTableViewCell.h"
#import "ISCAppDelegate.h"

#import "ISCMessageViewController.h"

@interface ISCPeopleProfileViewController ()<UITableViewDelegate, UITableViewDataSource>{
    NSArray *arrFollowings;
    NSArray *arrFollowers;
    PFUser *tUser;
    NSIndexPath *selectedIndex;
}
@property (weak, nonatomic) IBOutlet UIImageView *m_imgUser;
@property (weak, nonatomic) IBOutlet UILabel *m_lblUser;
@property (weak, nonatomic) IBOutlet UILabel *m_lblLocation;
@property (weak, nonatomic) IBOutlet UITableView *m_tblFollowers;
@property (weak, nonatomic) IBOutlet UITableView *m_tblFollowings;

@property (weak, nonatomic) IBOutlet UIButton *m_btnFollowers;
@property (weak, nonatomic) IBOutlet UIButton *m_btnFollowings;
@property (weak, nonatomic) IBOutlet UIButton *m_btnFollow;



@end

@implementation ISCPeopleProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated{
//    [self.m_lblUser setText:self.objUser[@"Owner"]];
    self.m_imgUser.layer.cornerRadius = self.m_imgUser.frame.size.width/2;
    self.m_imgUser.layer.masksToBounds = YES;
    
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:self.objUser[@"Owner"] block:^(PFObject *object, NSError *error) {
        tUser = (PFUser *)object;
        [self.m_lblUser setText:object[@"username"]];
        [self.m_lblLocation setText:object[@"address"]];
        PFFile *filePhoto = [object objectForKey:@"Photo"];
        [filePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.m_imgUser.image = [UIImage imageWithData:data];
            self.m_imgUser.layer.cornerRadius = self.m_imgUser.frame.size.width/2;
            self.m_imgUser.layer.masksToBounds = YES;
        }];
        
        [self getFollowingInfo: object.objectId];
    }];
}
- (void)getFollowingInfo:(NSString *)userId{
    PFQuery *query = [PFQuery queryWithClassName:@"FollowInfo"];
    [query whereKey:@"userId" equalTo:userId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            //Getting my Followers'count
            
            [self.m_btnFollowers setTitle:[NSString stringWithFormat:@"%lu Followers",(unsigned long)[object[@"Followers"]count] ] forState:UIControlStateNormal];
            [self.m_btnFollowings setTitle:[NSString stringWithFormat:@"%lu Followings",(unsigned long)[object[@"Followings"]count] ] forState:UIControlStateNormal];
            
            //Getting my Followings.
            
            if([object[@"Followings"] containsObject:[PFUser currentUser].objectId]){
                [self.m_btnFollow setEnabled:NO];
            }else{
                [self.m_btnFollow setEnabled:YES];
            }
            
            PFQuery *innerQuery = [PFUser query];
            [innerQuery whereKey:@"objectId" containedIn:object[@"Followings"]];
            [innerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                arrFollowings = objects;
                [self.m_tblFollowings reloadData];
            }];
            
            //Getting my Followers.
            PFQuery *innerQuery1 = [PFUser query];
            [innerQuery1 whereKey:@"objectId" containedIn:object[@"Followers"]];
            [innerQuery1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                arrFollowers = objects;
                [self.m_tblFollowers reloadData];
            }];
        }
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
    del.levelOfScr++;
    
    [self.m_tblFollowers setHidden:YES];
    [self.m_tblFollowings setHidden:NO];
    // Do any additional setup after loading the view.
}
-(void)dealloc{
    ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
    del.levelOfScr--;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"GoToMessageViewStoryboardID"]){
        ISCMessageViewController *mvc = segue.destinationViewController;
        mvc.targetUserId = tUser.objectId;
    }
}

- (IBAction)btnBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)btnFollowClicked:(id)sender {
    
    PFQuery *query = [PFQuery queryWithClassName:@"FollowInfo"];
    [query whereKey:@"userId" equalTo:tUser.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if(!error){
            if(!object){
                object = [PFObject objectWithClassName:@"FollowInfo"];
                [object setObject:tUser.objectId forKey:@"userId"];
            }
            NSMutableArray *arrFolUsers = object[@"Followings"];
            if(!arrFolUsers)
                arrFolUsers = [[NSMutableArray alloc]init];
        if([arrFolUsers containsObject:[PFUser currentUser].objectId])
            return;
            [arrFolUsers addObject:[PFUser currentUser].objectId];
            [object setObject:arrFolUsers forKey:@"Followings"];
            [object saveInBackground];
//        }else{
//            NSLog(@"Error occurred in Getting FollowInfo");
//        }
    }];
    PFQuery *sQuery = [PFQuery queryWithClassName:@"FollowInfo"];
    [sQuery whereKey:@"userId" equalTo:[PFUser currentUser].objectId];
    [sQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!object){
            object = [PFObject objectWithClassName:@"FollowInfo"];
            [object setObject:[PFUser currentUser].objectId forKey:@"userId"];
        }
        NSMutableArray *arrMyFollowings = object[@"Followers"];
        if(!arrMyFollowings){
            arrMyFollowings = [[NSMutableArray alloc]init];
        }
        if([arrMyFollowings containsObject:tUser.objectId])
            return ;
            [arrMyFollowings addObject:tUser.objectId];
            [object setObject:arrMyFollowings forKey:@"Followers"];
            [object saveInBackground];
    }];
//    [query whereKey:@"userId" equalTo:tUser.objectId];
//    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//        if(!error){
//            //Getting my Followers'count
//            [self.m_btnFollowers setTitle:[NSString stringWithFormat:@"%lu Followers",[object[@"Followers"]count] ] forState:UIControlStateNormal];
//            
//            //Getting my Followings.
//            PFQuery *innerQuery = [PFUser query];
//            [innerQuery whereKey:@"objectId" containedIn:object[@"Followings"]];
//            [innerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                arrFollowings = objects;
//                [self.m_tblFollowers reloadData];
//            }];
//        }
//    }];
}
- (IBAction)btnShowFollowersClicked:(id)sender {
    self.m_tblFollowings.hidden = YES;
    self.m_tblFollowers.hidden = NO;
}
- (IBAction)btnShowFollowingsClicked:(id)sender {
    self.m_tblFollowers.hidden = YES;
    self.m_tblFollowings.hidden = NO;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([self.m_tblFollowers isEqual:tableView])
        return [arrFollowers count];
    else
        return [arrFollowings count];
//    if(!arrFollowings)
//        return 0;
//    return [arrFollowings count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"FollowingsCell";
    ISCFollowingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[ISCFollowingTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    [self configureCell:cell :tableView :indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (void)configureCell:(ISCFollowingTableViewCell *)cell : (UITableView *)tableView :(NSIndexPath *)idxPath{
    PFUser *user;
    if([tableView isEqual:self.m_tblFollowings]){
        user = arrFollowings[idxPath.row];
        cell.m_lblUser.text = user[@"username"];
        cell.m_lblDescription.text = [NSString stringWithFormat:@"%@ is following %@.", user[@"username"], self.m_lblUser.text];
    }else{
        user = arrFollowers[idxPath.row];
        cell.m_lblUser.text = user[@"username"];
        cell.m_lblDescription.text = [NSString stringWithFormat:@"%@ is following %@.", self.m_lblUser.text, user[@"username"]];
    }
    PFFile *file = user[@"Photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if(!error){
            cell.m_imgUser.image = [UIImage imageWithData:data];
            cell.m_imgUser.layer.cornerRadius = cell.m_imgUser.frame.size.width/2;
            cell.m_imgUser.layer.masksToBounds = YES;
        }
    }];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
    if(del.levelOfScr>1)
        return;
    
    selectedIndex = indexPath;
    id temp;
    
    if([tableView isEqual:self.m_tblFollowings]){
        temp = arrFollowings[indexPath.row];
    }else{
        temp = arrFollowers[indexPath.row];
    }
    if([[PFUser currentUser].objectId isEqualToString:[temp objectId]])
        return;
    
    
    ISCPeopleProfileViewController *ppvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PeopleProfileStoryboardID"];
    PFObject *obj = [PFObject objectWithClassName:@"ActiveEvents"];
    [obj setObject:[temp objectId] forKey:@"Owner"];
    ppvc.objUser = obj;
    [self presentViewController:ppvc animated:YES completion:nil];
}

@end
