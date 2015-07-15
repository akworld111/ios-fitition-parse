//
//  ISCCategoryPickerViewController.m
//  Fitition
//
//  Created by WuYong on 7/24/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCCategoryPickerViewController.h"
#import "ECSlidingViewController.h"
#import <Parse/Parse.h>
#import <QuartzCore/QuartzCore.h>

@interface ISCCategoryPickerViewController ()<UITableViewDataSource, UITableViewDelegate>{
    NSArray *arrCategories;
    __weak IBOutlet UITableView *tblCategories;
}

@end

@implementation ISCCategoryPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    PFQuery *query = [PFQuery queryWithClassName:@"TypeOfEvents"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        arrCategories = objects;
        [tblCategories reloadData];
    }];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    
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

#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(arrCategories == nil) return 0;
    return [arrCategories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryPickerCellIdentifier"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CategoryPickerCellIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.imageView.image = [UIImage imageNamed:@"icon.png"];//NumberOfParticipantsBack.png
    cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width/2;
    cell.imageView.layer.masksToBounds = YES;
    [cell.textLabel setText:[arrCategories[indexPath.row] objectForKey:@"TitleOfType"]];
    
    PFFile *file;
    file = arrCategories[indexPath.row][@"ImageOfType"];
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        cell.imageView.image = [UIImage imageWithData:data];
        cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width/2;
        cell.imageView.layer.masksToBounds = YES;
    }];

    return cell;
}

#pragma mark - Tableview Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:arrCategories[indexPath.row][@"TitleOfType"] forKey:@"SelectedCategory"];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"SelectedCategoryNotification" object:nil userInfo:userInfo];
    [self.slidingViewController resetTopView];
}
@end
