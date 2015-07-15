//
//  ISCShowResultDetailViewController.m
//  ActLife
//
//  Created by WuYong on 6/19/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCShowResultDetailViewController.h"
#import "ISCPostResultTableViewCell.h"
#import <Parse/Parse.h>

@interface ISCShowResultDetailViewController ()<UITableViewDataSource>{
    NSMutableArray *arrUsers;
    __weak IBOutlet UITableView *m_contentTable;
}

@end

@implementation ISCShowResultDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    PFQuery *query;
    PFObject *object;
    
    if(!arrUsers)
        arrUsers = [[NSMutableArray alloc]init];
    else
        [arrUsers removeAllObjects];
    
    for(NSString *rateId in self.rateIds){
        if([rateId isEqualToString:@""])
            continue;
        query = [PFQuery queryWithClassName:@"Rates"];
        [query whereKey:@"objectId" equalTo:rateId];
        object = [query getFirstObject];

        NSMutableDictionary *dicUser = [[NSMutableDictionary alloc]init];
        [dicUser setObject:object[@"Username"] forKey:@"Username"];
        [dicUser setObject:object[@"Winner"] forKey:@"Winner"];
        [dicUser setObject:object[@"Rate"] forKey:@"Rate"];
        [dicUser setObject:object[@"Description"] forKey:@"Description"];
        [arrUsers addObject:dicUser];
    }
    
    [m_contentTable reloadData];
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
        cell.delegate = nil;
        cell.initialInfo = [arrUsers objectAtIndex:indexPath.row];
//        cell.userInteractionEnabled = NO;
//        cell.m_txtDescription.userInteractionEnabled = YES;
        
    }
    return cell;
}
- (IBAction)btnBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
