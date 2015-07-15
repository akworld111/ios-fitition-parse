//
//  ISCMyProfileViewController.m
//  F.A.T
//
//  Created by WuYong on 7/3/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCMyProfileViewController.h"
#import "ISCMenuViewController.h"
#import "ISCEditProfileViewController.h"
#import "ECSlidingViewController.h"
#import "ISCAppDelegate.h"
#import "ISCFollowingTableViewCell.h"
#import "ISCPeopleProfileViewController.h"
#import <Parse/Parse.h>
@interface ISCMyProfileViewController ()<UITableViewDataSource, UITableViewDelegate>{
    
    __weak IBOutlet UIImageView *m_imgPhoto;
    __weak IBOutlet UILabel *m_lblName;
    __weak IBOutlet UILabel *m_lblLocation;
    __weak IBOutlet UITableView *m_tblFollowers;
    __weak IBOutlet UITableView *m_tblFollowings;
    __weak IBOutlet UIButton *m_btnMenu;
    __weak IBOutlet UIButton *m_btnFollowings;
    __weak IBOutlet UIButton *m_btnFollowers;
    
    NSArray *arrFollowings;
    NSArray *arrFollowers;
    NSIndexPath *selectedIndex;
}

@end

@implementation ISCMyProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
    
    PFUser *curUser = [PFUser currentUser];
    
    
    [self.slidingViewController setAnchorRightRevealAmount:225.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    m_lblName.text = curUser.username;
    m_lblLocation.text = [curUser objectForKey:@"address"];
    
    m_imgPhoto.image = [UIImage imageNamed:@"images-1.jpg"];
    m_imgPhoto.layer.cornerRadius = m_imgPhoto.frame.size.width/2;
    m_imgPhoto.layer.masksToBounds = YES;
    
    PFFile *filePhoto = [curUser objectForKey:@"Photo"];
    [filePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        m_imgPhoto.image = [UIImage imageWithData:data];
        m_imgPhoto.layer.cornerRadius = m_imgPhoto.frame.size.width/2;
        m_imgPhoto.layer.masksToBounds = YES;
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"FollowInfo"];
    [query whereKey:@"userId" equalTo:curUser.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if(!error){
            //Getting my Followers'count
            [m_btnFollowers setTitle:[NSString stringWithFormat:@"%lu Followers",(unsigned long)[object[@"Followers"]count] ] forState:UIControlStateNormal];
            [m_btnFollowings setTitle:[NSString stringWithFormat:@"%lu Followings",(unsigned long)[object[@"Followings"]count] ] forState:UIControlStateNormal];
            
            //Getting my Followings.
            PFQuery *innerQuery = [PFUser query];
            [innerQuery whereKey:@"objectId" containedIn:object[@"Followings"]];
            [innerQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                arrFollowings = objects;
                [m_tblFollowings reloadData];
            }];
            
            //Getting my Followers.
            PFQuery *innerQuery1 = [PFUser query];
            [innerQuery1 whereKey:@"objectId" containedIn:object[@"Followers"]];
            [innerQuery1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                arrFollowers = objects;
                [m_tblFollowers reloadData];
            }];
        }
    }];
}
- (void)dealloc{
    
    ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
    del.levelOfScr--;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)ProfileChanged: (NSNotification *) notification{
    if([[notification name]isEqualToString:@"ProfileChanged"]){
        
        PFUser *curUser = [PFUser currentUser];
        
        m_lblName.text = curUser.username;
        m_lblLocation.text = curUser[@"address"];
        PFFile *filePhoto = [curUser objectForKey:@"Photo"];
        [filePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            m_imgPhoto.image = [UIImage imageWithData:data];
            m_imgPhoto.layer.cornerRadius = m_imgPhoto.frame.size.width/2;
            m_imgPhoto.layer.masksToBounds = YES;
        }];
    }
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
    
    [m_tblFollowers setHidden:YES];
    [m_tblFollowings setHidden:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ProfileChanged:) name:@"ProfileChanged" object:nil];
    
    // Do any additional setup after loading the view.
    if(![self.slidingViewController.underLeftViewController isKindOfClass:[ISCMenuViewController class]]){
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuView"];
        //        [(ISCMenuViewController *)self.slidingViewController.underLeftViewController setDelegate:self];
    }
    
    //Add the pan gesture to allow sliding
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
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
- (IBAction)btnMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (IBAction)btnEditClicked:(id)sender {
    [self performSegueWithIdentifier:@"EditProfileSegueID" sender:self];
}
- (IBAction)btnFollowingsClicked:(id)sender {
    m_tblFollowers.hidden = YES;
    m_tblFollowings.hidden = NO;
}
- (IBAction)btnFollowersClicked:(id)sender {
    m_tblFollowings.hidden = YES;
    m_tblFollowers.hidden = NO;
}



#pragma mark - Table Datasoure and Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([m_tblFollowers isEqual:tableView])
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
    if([tableView isEqual:m_tblFollowings]){
        user = arrFollowings[idxPath.row];
        cell.m_lblUser.text = user[@"username"];
        cell.m_lblDescription.text = [NSString stringWithFormat:@"%@ is following you.", user[@"username"]];
    }else{
        user = arrFollowers[idxPath.row];
        cell.m_lblUser.text = user[@"username"];
        cell.m_lblDescription.text = [NSString stringWithFormat:@"You are following %@.", user[@"username"]];
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
    
    if([tableView isEqual:m_tblFollowings]){
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
