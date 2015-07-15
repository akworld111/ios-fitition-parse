//
//  ISCActiveEventsViewController.m
//  Interactive
//
//  Created by WuYong on 6/14/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCActiveEventsViewController.h"
#import "ECSlidingViewController.h"
#import "ISCMenuViewController.h"
#import "ISCPostResultViewController.h"
#import "ISCPeopleProfileViewController.h"
#import "ISCEventDetailViewController.h"
#import "ISCDiscoverSettingViewController.h"
#import <Parse/Parse.h>

@interface ISCActiveEventsViewController (){
    NSArray *activeEvents;
    NSUInteger skipIndex;
    NSString *filter;
    __weak IBOutlet UITableView *m_eventsTable;
    NSString *curUsername;
    PFObject *tempParameter;
    
    UIView *descriptionView;
    UITextView *descriptionText;
    
    double kMeters;
    PFGeoPoint *centerPoint;
}
@end

@implementation ISCActiveEventsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(![self.slidingViewController.underLeftViewController isKindOfClass:[ISCMenuViewController class]]){
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuView"];
//        [(ISCMenuViewController *)self.slidingViewController.underLeftViewController setDelegate:self];
    }
    
    //Add the pan gesture to allow sliding
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    if(activeEvents == nil)
        activeEvents = [[NSArray alloc]init];
    
    skipIndex = 0;
    
    [self getActiveEvents];
//    [self.view setUserInteractionEnabled:YES];
}

- (void)discoverSettingChanged:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    centerPoint = [userInfo objectForKey:@"CenterCoords"];
    kMeters = [[userInfo objectForKey:@"Radius"]integerValue];
    
    NSLog(@"CenterCoords: %@", centerPoint);
    NSLog(@"Radius: %le", kMeters);
    if(activeEvents == nil)
        activeEvents = [[NSArray alloc]init];
    
    skipIndex = 0;
    
    [self getActiveEvents];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(discoverSettingChanged:) name:@"DiscoverSettingChanged" object:nil];
    
    kMeters = 10;
    centerPoint = [PFUser currentUser][@"CurrentLocation"];
    
    
    filter = @"All";
    curUsername = [PFUser currentUser].username;
    CGRect rt;
    rt = self.view.bounds;
    
    descriptionView = [[UIView alloc]initWithFrame:rt];
    rt.size.height = rt.size.height/2;
    descriptionText = [[UITextView alloc]initWithFrame:rt];
    [descriptionView addSubview:descriptionText];
    [self.view addSubview:descriptionView];
    descriptionText.center = descriptionView.center;
    descriptionText.textAlignment = NSTextAlignmentCenter;
    descriptionText.textColor = [UIColor whiteColor];
    descriptionText.font = [UIFont systemFontOfSize:20];
    
    descriptionText.editable = NO;
    descriptionText.selectable = NO;
    
    descriptionView.hidden = YES;
    descriptionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    descriptionText.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideDescriptionView)];
    descriptionView.gestureRecognizers = [NSArray arrayWithObject:ges];
    descriptionView.userInteractionEnabled = YES;
    // Do any additional setup after loading the view.
}
- (void) hideDescriptionView{
    descriptionView.hidden = YES;
}
- (void) showDescriptionView:(NSString *)txt{
    descriptionText.text = txt;
    descriptionView.hidden = NO;
}
- (void)showEventDetail:(PFObject *)obj{
    tempParameter = obj;
    [self performSegueWithIdentifier:@"GoToEventDetailStoryboardSegueID" sender:self];
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
    if ( [segue.identifier isEqualToString:@"PostResultStoryboardSegueID"]) {
        ISCPostResultViewController *destViewController = segue.destinationViewController;
        destViewController.eventInfo = tempParameter;
    }
    if ([segue.identifier isEqualToString:@"PeopleProfileSegueID"]) {
        ISCPeopleProfileViewController *ppvc = segue.destinationViewController;
        ppvc.objUser = tempParameter;
    }
    
    if ([segue.identifier isEqualToString:@"GoToEventDetailStoryboardSegueID"]){
        ISCEventDetailViewController *edvc = segue.destinationViewController;
        edvc.eventObj = tempParameter;
    }
    
    if ([segue.identifier isEqualToString:@"DiscoverSettingStoryboardSegueID"]){
        ISCDiscoverSettingViewController *dsvc = segue.destinationViewController;
        dsvc.centerCoords = centerPoint;
        dsvc.radius = kMeters;
        NSLog(@"%f,%f", centerPoint.latitude, centerPoint.longitude);
        NSLog(@"%f",kMeters);
    }
}


#pragma mark - TableView Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [activeEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *activeCellIdentifier = @"ActiveCellIdentifier";
    ISCActiveEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:activeCellIdentifier];
    
    if(!cell)
        cell = [[ISCActiveEventTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActiveCellIdentifier"];
    
    if(cell){
        
        PFObject *object = [activeEvents objectAtIndex:indexPath.row];
        cell.object = object;
        cell.delegate = self;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"%lu",indexPath.row);
    tempParameter = [activeEvents objectAtIndex:indexPath.row];
    if([tempParameter[@"Owner"]isEqualToString:[PFUser currentUser].objectId])
        return;
    [self performSegueWithIdentifier:@"PeopleProfileSegueID" sender:self];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"ActiveEventsViewcontroller dellocated");
}

- (void)getActiveEvents{
    PFQuery *query = [[PFQuery alloc]initWithClassName:@"ActiveEvents"];
//    if(![filter isEqualToString:@"All"]){
//        [query whereKey:@"Type" equalTo:filter];
//    }
    NSString *gend = [[PFUser currentUser]objectForKey:@"gender"];
    if([gend isEqualToString:@"Male"]){
        gend = @"Female";
    }
    if([gend isEqualToString:@"Female"]){
        gend = @"Male";
    }
    [query whereKey:@"PostTo" notEqualTo:gend];
    [query whereKey:@"Closed" notEqualTo:@"YES"];
    [query whereKey:@"People" notContainedIn:@[[PFUser currentUser].objectId]];
    
    [query whereKey:@"PlaceCoords" nearGeoPoint:centerPoint withinKilometers:kMeters];
    
    [query orderByDescending:@"updatedAt"];
    query.limit = 10;
    query.skip = skipIndex;
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        activeEvents = objects;
        
        [m_eventsTable reloadData];
    }];
}


- (IBAction)btnMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - PostResultDelegate
- (void)PostResultWithObject:(PFObject *)obj{
    tempParameter = obj;
    [self performSegueWithIdentifier:@"PostResultStoryboardSegueID" sender:self];
}
@end
