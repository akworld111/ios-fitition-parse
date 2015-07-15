//
//  ISCResultViewController.m
//  ActLife
//
//  Created by WuYong on 6/19/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCResultViewController.h"
#import "ECSlidingViewController.h"
#import "ISCMenuViewController.h"
#import "ISCShowResultDetailViewController.h"
#import <Parse/Parse.h>


@interface ISCResultViewController (){
    
    __weak IBOutlet UITableView *m_contentTable;
    NSArray *arrResults;
    NSUInteger skipIndex;
    NSIndexPath *tmpPara;
    
    UITextView *descriptionText;
    UIView *descriptionView;
}

@end

@implementation ISCResultViewController

- (void)viewWillAppear:(BOOL)animated{
    if(![self.slidingViewController.underLeftViewController isKindOfClass:[ISCMenuViewController class]]){
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuView"];
        //        [(ISCMenuViewController *)self.slidingViewController.underLeftViewController setDelegate:self];
    }
    
    //Add the pan gesture to allow sliding
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    if(arrResults == nil)
        arrResults = [[NSArray alloc]init];
    
    
    skipIndex = 0;
    
    [self getResultOfEvents];
    
}

- (void)getResultOfEvents{
    PFQuery *query = [PFQuery queryWithClassName:@"ResultsOfEvents"];
    [query orderByDescending:@"updatedAt"];
    query.skip = skipIndex;
    query.limit = 10;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        arrResults = objects;
        [m_contentTable reloadData];
    }];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (void) hideDescriptionView{
    descriptionView.hidden = YES;
}
- (void) showDescriptionView:(NSString *)txt{
    descriptionText.text = txt;
    descriptionView.hidden = NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ( [segue.identifier isEqualToString:@"ShowResultDetailSegueID"]) {
        ISCShowResultDetailViewController *destViewController = segue.destinationViewController;
        destViewController.rateIds = [arrResults[tmpPara.row]objectForKey:@"RateIds"];
    }
}

#pragma mark - TableviewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ISCResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ResultOfEventCellIdentifier"];
    if(!cell){
        cell = [[ISCResultTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ResultOfEventCellIdentifier"];
    }
    
    if(cell){
        PFObject *winnerObject = arrResults[indexPath.row];
        cell.indexPath = indexPath;
        cell.initialInfo = winnerObject;
        cell.delegate = self;
    }
    
    return cell;
}

- (void)showDetails:(NSIndexPath *)idxPath{
    tmpPara = idxPath;
    [self performSegueWithIdentifier:@"ShowResultDetailSegueID" sender:self];
}

- (IBAction)btnMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

@end
