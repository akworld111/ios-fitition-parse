//
//  ISCPostResultViewController.m
//  ActLife
//
//  Created by WuYong on 6/19/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCPostResultViewController.h"

@interface ISCPostResultViewController (){
    NSMutableArray *arrUsers;
    __weak IBOutlet UITableView *m_contentTable;
}
@end

@implementation ISCPostResultViewController

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
    NSArray *peoples = self.eventInfo[@"People"];//[people componentsSeparatedByString:@","];
    PFUser *curUser = [PFUser currentUser];
    NSString *curUsername = [curUser username];
    
    if(!arrUsers)
        arrUsers = [[NSMutableArray alloc]init];
    else
        [arrUsers removeAllObjects];
    
    for(NSString *username in peoples){
        if([username isEqualToString:curUsername])
            continue;
        NSMutableDictionary *dicUser = [[NSMutableDictionary alloc]init];
        [dicUser setObject:username forKey:@"Username"];
        [dicUser setObject:@"NO" forKey:@"Winner"];
        [dicUser setObject:[NSNumber numberWithInteger:0] forKey:@"Rate"];
        [dicUser setObject:@"" forKey:@"Description"];
        [arrUsers addObject:dicUser];
    }
    
    [m_contentTable reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    NSLog(@"%@", self.eventInfo[@"Owner"]);
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

#pragma mark - TableView Datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ISCPostResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostResultCellIdentifier"];
    if(!cell){
        cell = [[ISCPostResultTableViewCell alloc]init];
    }
    
    if(cell){
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.initialInfo = [arrUsers objectAtIndex:indexPath.row];
        
    }
    return cell;
}

#pragma mark - PostResultCellDelegate
- (void)setRate:(NSUInteger)rate IndexPath:(NSIndexPath *)idxPath{
    [[arrUsers objectAtIndex:idxPath.row]setObject:[NSNumber numberWithInteger:rate] forKey:@"Rate"];
    NSLog(@"%@",arrUsers);
}

- (void)setDescription:(NSString *)dsc IndexPath:(NSIndexPath *)idxPath{
    [[arrUsers objectAtIndex:idxPath.row]setObject:dsc forKey:@"Description"];
        NSLog(@"%@",arrUsers);
}

- (void)setWinner:(BOOL)isWinner IndexPath:(NSIndexPath *)idxPath{
    if(isWinner)
        [[arrUsers objectAtIndex:idxPath.row]setObject:@"YES" forKey:@"Winner"];
    else
        [[arrUsers objectAtIndex:idxPath.row]setObject:@"NO" forKey:@"Winner"];
        NSLog(@"%@",arrUsers);
}

- (IBAction)btnCloseEventClicked:(id)sender {
//    PFObject *object = [PFObject objectWithClassName:@"ResultOfEvents"];
//    [object setObject:[self.eventInfo objectId] forKey:@"EventId"];
    PFUser *curUser = [PFUser currentUser];
//    NSString *ratesPeopleInEvent = @"";
//    NSString *winners = @"";
    NSMutableArray *winners = [[NSMutableArray alloc]init];
    NSMutableArray *ratesPeopleInEvent = [[NSMutableArray alloc]init];
    
    PFObject *object;
    for(NSMutableDictionary *tmpDic in arrUsers){
        if([tmpDic[@"Winner"]isEqualToString:@"YES"]){
            //winners = [NSString stringWithFormat:@"%@,%@",winners, tmpDic[@"Username"]];
            [winners addObject:tmpDic[@"Username"]];
        }
        if([tmpDic[@"Rate"]integerValue]!=0){
            object = [PFObject objectWithClassName:@"Rates"];
            [object setObject:tmpDic[@"Username"] forKey:@"Username"];
            [object setObject:tmpDic[@"Rate"] forKey:@"Rate"];
            [object setObject:tmpDic[@"Description"] forKey:@"Description"];
            [object setObject:curUser.objectId forKey:@"Owner"];
        [object setObject:self.eventInfo.objectId forKey:@"EventId"];
            [object setObject:tmpDic[@"Winner"] forKey:@"Winner"];
            [object save];
        }else{
            continue;
        }
        
//        ratesPeopleInEvent = [NSString stringWithFormat:@"%@,%@",ratesPeopleInEvent ,object.objectId];
        [ratesPeopleInEvent addObject:object.objectId];
        
    }
    
    object = [PFObject objectWithClassName:@"ResultsOfEvents"];
    [object setObject:self.eventInfo.objectId forKey:@"EventId"];
    [object setObject:ratesPeopleInEvent forKey:@"RateIds"];
    [object setObject:winners forKey:@"Winners"];
    [object save];
    
    [self.eventInfo setObject:@"YES" forKey:@"Closed"];
    [self.eventInfo save];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
