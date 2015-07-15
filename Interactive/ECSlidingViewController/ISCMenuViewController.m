//
//  ISCMenuViewController.m
//  Interactive
//
//  Created by WuYong on 6/13/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCMenuViewController.h"
#import "ECSlidingViewController.h"
#import "ISCPeopleProfileViewController.h"
#import "ISCAppDelegate.h"
#import <Parse/Parse.h>
#import "ISCFirebaseManager.h"

@interface ISCMenuViewController ()<UISearchBarDelegate, UISearchDisplayDelegate>{
    NSUInteger selectedIndex;
    NSArray *searchResults;
}
//@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UISearchBar *m_searchBar;
@property (weak, nonatomic) IBOutlet UIImageView *m_photo;
@property (weak, nonatomic) IBOutlet UILabel *m_name;
@property (weak, nonatomic) IBOutlet UILabel *m_location;

@end

@implementation ISCMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void) ProfileChanged : (NSNotification*) notification{
    if([[notification name] isEqualToString:@"ProfileChanged"]){
        PFUser *curUser = [PFUser currentUser];
        
        self.m_name.text = curUser.username;
        self.m_location.text = curUser[@"address"];
        PFFile *filePhoto = [curUser objectForKey:@"Photo"];
        [filePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.m_photo.image = [UIImage imageWithData:data];
            self.m_photo.layer.cornerRadius = self.m_photo.frame.size.width/2;
            self.m_photo.layer.masksToBounds = YES;
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
    
    selectedIndex = 1;
    searchResults = [[NSArray alloc]init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ProfileChanged:) name:@"ProfileChanged" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willResetTopView:) name:ECSlidingViewTopWillReset object:nil];
    
    
    // Do any additional setup after loading the view.
    PFUser *curUser = [PFUser currentUser];
    
    [self.slidingViewController setAnchorRightRevealAmount:225.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
    self.m_name.text = curUser.username;
    self.m_location.text = [curUser objectForKey:@"address"];

    self.m_photo.image = [UIImage imageNamed:@"images-1.jpg"];
    self.m_photo.layer.cornerRadius = self.m_photo.frame.size.width/2;
    self.m_photo.layer.masksToBounds = YES;
    
    PFFile *filePhoto = [curUser objectForKey:@"Photo"];
    [filePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.m_photo.image = [UIImage imageWithData:data];
        self.m_photo.layer.cornerRadius = self.m_photo.frame.size.width/2;
        self.m_photo.layer.masksToBounds = YES;
    }];
    

    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imgPhotoClicked)];
    [self.m_photo addGestureRecognizer:ges];
    [self.m_photo setUserInteractionEnabled:YES];
    
//    self.m_location.text = [PFUser currentUser][@"home"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor lightGrayColor]];
}

- (void)keyboardWillAppear: (NSNotification *)notification{
    [self.m_searchBar setShowsCancelButton:NO animated:NO];
}

- (void)willResetTopView: (NSNotification *)notification{
    [self.m_searchBar setText:@""];
    [self.searchDisplayController setActive:NO animated:YES];
}
- (void)imgPhotoClicked{
    
    ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
    del.levelOfScr = 0;
    
    NSLog(@"Profile Clicked!");
    selectedIndex = 6;
    //go to profile.
    self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyProfileViewControllerStoryboardID"];
    [self.slidingViewController resetTopView];
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


- (IBAction)btnClicked:(id)sender {
    UIButton *temp = sender;
    ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
    del.levelOfScr = 0;
    
    if(selectedIndex == temp.tag){
        [self.slidingViewController resetTopView];
        return;
    }
    
    if(temp.tag == 0){
        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyEventViewStoryboardID"];
    }
    if(temp.tag == 1){
        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActiveEventViewStoryboardID"];
    }
    if(temp.tag == 2){
        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PostActionSelectTypeStoryboardID"];
    }
    if(temp.tag == 3){
        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ResultsOfEventsStoryboardID"];
    }
    if(temp.tag == 4){
        self.slidingViewController.topViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewControllerStoryboardID"];
    }
    if(temp.tag == 5){
        [PFUser logOut];
        [[ISCFirebaseManager sharedInstance]logout];
    }else{
        [self.slidingViewController resetTopView];
    }
    selectedIndex = temp.tag;
}

#pragma mark - Search Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *searchString = searchBar.text;
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" containsString:searchString];
    [query whereKey:@"username" notEqualTo:[PFUser currentUser].username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        searchResults = objects;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
}

#pragma mark - SearhResult Tableview Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"UserSearchResultCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    [self configureCell:cell :indexPath :tableView];
    
    return cell;
}
- (void)configureCell : (UITableViewCell *)cell :(NSIndexPath *)indexPath : (UITableView *)tableView{
    PFObject *user = [searchResults objectAtIndex:indexPath.row];
    [cell.textLabel setText:user[@"username"]];
    cell.imageView.image = [UIImage imageNamed:@"imgres.jpg"];
    cell.imageView.layer.cornerRadius = 22;
    cell.imageView.layer.masksToBounds = YES;
    
    PFFile *file = user[@"Photo"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        if(!error){
            cell.imageView.image = [UIImage imageWithData:data];
            cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height/2;
            cell.imageView.layer.masksToBounds = YES;
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ISCPeopleProfileViewController *ppvc = [self.storyboard instantiateViewControllerWithIdentifier:@"PeopleProfileStoryboardID"];
    PFObject *obj = [PFObject objectWithClassName:@"ActiveEvents"];
    [obj setObject:[searchResults[indexPath.row] objectId] forKey:@"Owner"];
    ppvc.objUser = obj;
    [self presentViewController:ppvc animated:YES completion:nil];
    
    
    ISCAppDelegate *del = (ISCAppDelegate *)[UIApplication sharedApplication].delegate;
    del.levelOfScr = 0;
    
//    NSLog(@"Profile Clicked!");
//    selectedIndex = 6;
//    //go to profile.
//    self.slidingViewController.topViewController = ppvc;
//    [self.slidingViewController resetTopView];
}
@end
