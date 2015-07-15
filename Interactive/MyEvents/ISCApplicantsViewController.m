//
//  ISCApplicantsViewController.m
//  Fitition
//
//  Created by WuYong on 7/19/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCApplicantsViewController.h"
#import "UIImage+ImageEffects.h"

@interface ISCApplicantsViewController (){
    NSMutableArray *applicants;
    __weak IBOutlet UIImageView *m_imgBack;
    __weak IBOutlet UILabel *m_lblUsername;
    __weak IBOutlet UILabel *m_lblDscription;
    __weak IBOutlet UIButton *m_btnAccept;
    __weak IBOutlet UIButton *m_btnDecline;
    
}
@property (nonatomic, retain) ISCSwipingControl *swipingView;
@end

@implementation ISCApplicantsViewController

#pragma mark - Getters


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
    m_imgBack.image = [m_imgBack.image applyLightEffect];
    
    applicants = self.eventObj[@"Applicants"];
    if (!applicants)
        applicants = [[NSMutableArray alloc]init];
    
    [self.swipingView reloadData];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.swipingView = [[ISCSwipingControl alloc]initWithFrame:CGRectMake(0, 0, 200, 300)];
    self.swipingView.center = self.view.center;
    self.swipingView.delegate = self;
    self.swipingView.dataSource = self;
    [self.view addSubview:self.swipingView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString *)GetUserId:(ISCSwipingControl *)swipingControl{
    if((!applicants) || [applicants count]==0){
        m_lblUsername.hidden = YES;
        m_lblDscription.hidden = YES;
        m_btnAccept.hidden = YES;
        m_btnDecline.hidden = YES;
    }
    if(applicants)
        return [applicants firstObject];
    else
        return nil;
}
- (void)didAcceptUser:(ISCSwipingControl *)swipingControl{

    
    NSString *curUsername = [applicants firstObject];

    NSMutableArray *arrParticipants = self.eventObj[@"People"];
    if(!arrParticipants){
        arrParticipants = [[NSMutableArray alloc]init];
    }
    [arrParticipants addObject:curUsername];
    
    [applicants removeObjectAtIndex:0];
    [self.eventObj setObject:applicants forKey:@"Applicants"];
    
    [self.eventObj setObject:arrParticipants forKey:@"People"];

    //This should be saveInBackground... after adding waiting screen.
    [self.eventObj save];
    
    [self.swipingView reloadData];
}
- (void)didDeclineUser:(ISCSwipingControl *)swipingControl{
    [applicants removeObjectAtIndex:0];
    [self.eventObj setObject:applicants forKey:@"Applicants"];
    [self.eventObj save];
    
    [self.swipingView reloadData];
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

- (IBAction)btnAcceptClicked:(id)sender {
    [self.swipingView flickAway:self.swipingView withVelocity:CGPointMake(250, 0)];
    
}
- (IBAction)btnDeclineClicked:(id)sender {
    [self.swipingView flickAway:self.swipingView withVelocity:CGPointMake(-250, 0)];
}

- (void)imageLoaded:(UIImage *)img{
    m_imgBack.image = [img applyLightEffect];
    m_btnAccept.hidden = NO;
    m_btnDecline.hidden = NO;
}

- (void)didGetUsername:(NSString *)uName{
    m_lblUsername.text = uName;
    m_lblUsername.hidden = NO;
}
@end
