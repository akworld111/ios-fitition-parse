//
//  ISCMyEventsViewController.m
//  ActLife
//
//  Created by WuYong on 6/18/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ECSlidingViewController.h"
#import "ISCMenuViewController.h"
#import "ISCMyEventsViewController.h"
#import "ISCActiveEventTableViewCell.h"
#import "ISCPostResultViewController.h"
#import "ISCEventDetailViewController.h"
#import "ISCApplicantsViewController.h"
#import <Parse/Parse.h>

@interface ISCMyEventsViewController ()<PostResultDelegate>{
    NSArray *arrMyEvents;
    NSUInteger skipIndex;
    PFObject *tempParameter;
    
    UITextView *descriptionText;
    UIView *descriptionView;
}

@end

@implementation ISCMyEventsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
    if(![self.slidingViewController.underLeftViewController isKindOfClass:[ISCMenuViewController class]]){
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuView"];
        //        [(ISCMenuViewController *)self.slidingViewController.underLeftViewController setDelegate:self];
    }
    
    //Add the pan gesture to allow sliding
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    if(arrMyEvents == nil)
        arrMyEvents = [[NSArray alloc]init];
    
    
    skipIndex = 0;

    [self getMyEvents];
}

- (void)getMyEvents{
    PFQuery *query = [PFQuery queryWithClassName:@"ActiveEvents"];
    PFUser *curUser = [PFUser currentUser];
    [query whereKey:@"Closed" notEqualTo:@"YES"];
    [query orderByDescending:@"updatedAt"];
//    [query whereKey:@"Owner" equalTo:curUser.objectId];
    [query whereKey:@"People" containedIn:@[curUser.objectId]];
    query.skip = skipIndex;
    query.limit = 10;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        arrMyEvents = objects;
        [m_contentTable reloadData];
    }];
//    arrMyEvents = [query findObjects];
//    [m_contentTable reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
    
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
}

- (void) hideDescriptionView{
    descriptionView.hidden = YES;
}
- (void) showDescriptionView:(NSString *)txt{
    descriptionText.text = txt;
    descriptionView.hidden = NO;
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
    if( [segue.identifier isEqualToString:@"GoToEventDetailStoryboardSegueID"]){
        ISCEventDetailViewController *destViewController = segue
        .destinationViewController;
        destViewController.eventObj = tempParameter;
    }
    
    if( [segue.identifier isEqualToString:@"GoToApplicantsViewSegueID"]){
        ISCApplicantsViewController *avc = segue.destinationViewController;
        avc.eventObj = tempParameter;
    }
}



#pragma mark - Tableview Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrMyEvents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *activeCellIdentifier = @"ActiveCellIdentifier";
    ISCActiveEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:activeCellIdentifier];
    
    if(!cell)
        cell = [[ISCActiveEventTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ActiveCellIdentifier"];
    
    if(cell){
        
        PFObject *object = [arrMyEvents objectAtIndex:indexPath.row];
        cell.object = object;
        cell.delegate = self;
    }
    
    return cell;
}


- (IBAction)btnMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)showEventDetail:(PFObject *)obj{
    tempParameter = obj;
    [self performSegueWithIdentifier:@"GoToEventDetailStoryboardSegueID" sender:self];
}

- (void)showApplicants:(PFObject *)obj{
    tempParameter = obj;
    [self performSegueWithIdentifier:@"GoToApplicantsViewSegueID" sender:self];
}
#pragma mark - PostResultDelegate
- (void)PostResultWithObject:(PFObject *)obj{
    tempParameter = obj;
    [self performSegueWithIdentifier:@"PostResultStoryboardSegueID" sender:self];
}


@end
