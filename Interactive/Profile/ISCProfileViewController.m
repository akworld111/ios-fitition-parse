//
//  ISCProfileViewController.m
//  Interactive
//
//  Created by WuYong on 6/11/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCProfileViewController.h"
#import "ECSlidingViewController.h"
#import "ISCMenuViewController.h"
#import "ISCTypeItemView.h"
#import "ISCCategoryPickerViewController.h"
#import <Parse/Parse.h>
#import <MapKit/MapKit.h>

#import "ISCLocationPickerViewController.h"

@interface ISCProfileViewController ()<TypeSelectionDelegate, UIActionSheetDelegate, UITableViewDataSource>{


    
    int queryIndex;
    
    
    //new structures
    NSMutableArray *titles;
    NSString *selectedType;    //Selected Category
    NSUInteger NoP; //Number of Players
    NSString *selectedPlayers;  //Coed, Male or Female
    UIActionSheet *postToSelector;
    MKPlacemark *selectedPlace; //Selected place
    
    UIDatePicker *timePicker;
    UIDatePicker *datePicker;
    UIView *coverView;
    NSDate *selectedDay;
    NSDate *selectedTime;
    
    NSMutableArray *arrInvPeople;
    
    id tmpTxtField;
    UIButton *doneButton;
    __weak IBOutlet UITableView *m_contentTable;
    
    NSArray *arrRecentMatches;
    NSUInteger showCountOfMathes;
    __weak IBOutlet UIScrollView *m_svRecentMatches;
    
    
    __weak IBOutlet UITextField *m_txtEventName;
}
@end

@implementation ISCProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)selectedCategory: (NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    selectedType = userInfo[@"SelectedCategory"];
    [self configureCell:nil IndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}
- (void)selectedPlace: (NSNotification *)notification{
    NSDictionary *userinfo = notification.userInfo;
    selectedPlace = userinfo[@"SelectedPlace"];

    [self configureCell:nil IndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(![self.slidingViewController.underLeftViewController isKindOfClass:[ISCMenuViewController class]]){
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuView"];
        //        [(ISCMenuViewController *)self.slidingViewController.underLeftViewController setDelegate:self];
    }
    
    if(![self.slidingViewController.underRightViewController isKindOfClass:[ISCCategoryPickerViewController class]]){
        self.slidingViewController.underRightViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CategoryPickerStoryboardID"];
    }
    
    //Add the pan gesture to allow sliding
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    selectedType = @"Tennis";
    NoP = 4;
    selectedPlayers = @"Coed";
    selectedPlace = nil;
    selectedDay = nil;
    selectedTime = nil;

    showCountOfMathes = 6;
    arrInvPeople = [[NSMutableArray alloc]init];
    doneButton = nil;
    
    titles = [[NSMutableArray alloc]initWithObjects:@"Activity", @"Number of Players", @"Players", @"Location", @"Time", @"Date", nil];


    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedPlace:) name:@"SelectedPlaceNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedCategory:) name:@"SelectedCategoryNotification" object:nil];

    timePicker = [[UIDatePicker alloc]init];
    [timePicker addTarget:self action:@selector(timeDidChange) forControlEvents:UIControlEventValueChanged];
//    timePicker.minimumDate = [NSDate date];
    timePicker.datePickerMode = UIDatePickerModeTime;
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"];
    timePicker.locale = locale;
    
    datePicker = [[UIDatePicker alloc]init];
    [datePicker addTarget:self action:@selector(dateDidChange) forControlEvents:UIControlEventValueChanged];
//    datePicker.minimumDate = [NSDate date];
    datePicker.datePickerMode = UIDatePickerModeDate;

    postToSelector = [[UIActionSheet alloc]initWithTitle:@"I am going to post event to" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Coed", @"Male",@"Female", nil];
//    784
    [m_contentScrollView setContentSize:CGSizeMake(320, 491)];
    [m_contentScrollView setContentInset:UIEdgeInsetsMake(0, 0, 491.0f, 0)];
    [m_contentScrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 491.0f, 0)];
    
    
    coverView = [[UIView alloc]initWithFrame:self.view.bounds];
    [coverView setHidden:YES];
    [coverView setBackgroundColor:[UIColor blackColor]];
    [coverView setAlpha:0.3];
    [self.view addSubview:coverView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backgroundClicked)];
    tapGesture.numberOfTapsRequired = 1;
    [coverView addGestureRecognizer:tapGesture];
    
    [self getRecentMatches];
}

- (void)getRecentMatches{
    
    NSMutableArray *tempMatches = [[NSMutableArray alloc]init];
    
    PFUser *user = [PFUser currentUser];
    PFQuery *query = [[PFQuery alloc]initWithClassName:@"ActiveEvents"];
    [query whereKey:@"Closed" equalTo:@"YES"];
    [query whereKey:@"People" containedIn:[NSArray arrayWithObject:user.objectId]];
    [query setLimit:5];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for(PFObject *object in objects){
            NSArray *obj;
            obj = object[@"People"];
            [tempMatches addObjectsFromArray:obj];
        }
        [tempMatches removeObject:user.objectId];
        arrRecentMatches = [NSOrderedSet orderedSetWithArray:tempMatches].array;
//        arrRecentMatches = [tempMatches valueForKeyPath:@"@distinctUnionOfObjects.self"];
//        NSLog(@"RecentMatches: %@", arrRecentMatches);
        [self refreshMatches];
    }];
    
}

- (void)refreshMatches{
    NSUInteger cnt;
    cnt = showCountOfMathes;
    if([arrRecentMatches count]<cnt)
        cnt = [arrRecentMatches count];
    
    for(NSUInteger i = 0; i < cnt; i++){
        NSString *userId;
        userId = arrRecentMatches[i];
        PFQuery *userQuery = [PFUser query];
        
        [userQuery getObjectInBackgroundWithId:userId block:^(PFObject *object, NSError *error) {
            CGFloat x, y, w, h;
            x = i * 85;
            y = 0;
            w = 65;
            h = 85;
            ISCTypeItemView *itemView = [[ISCTypeItemView alloc]initWithFrame:CGRectMake(x, y, w, h)];
            [itemView setLblType:object[@"username"]];
            [itemView setImgType:object[@"Photo"]];
            [itemView setImageChecked:NO];
            itemView.delegate = self;
            itemView.tag = i;
            [m_svRecentMatches addSubview:itemView];
        }];
    }
    [m_svRecentMatches setContentSize:CGSizeMake(cnt * 85, 0)];
}
- (void)backgroundClicked{
    doneButton = nil;
    [tmpTxtField resignFirstResponder];
    coverView.hidden = YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString *strTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if(![strTitle isEqualToString:@"Cancel"]){
        selectedPlayers = strTitle;
        [self configureCell:nil IndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    }
}
- (void)selectedTypeItem:(id)selectedItem{

    ISCTypeItemView *tiv = selectedItem;
    NSString *userId = arrRecentMatches[tiv.tag];
    if(tiv.bSelected){
        [arrInvPeople addObject:userId];
    }else{
        [arrInvPeople removeObject:userId];
    }
    NSLog(@"Selected People: %@", arrInvPeople);
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

#pragma mark - TableView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [titles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    NSString *cellIdentifier = [NSString stringWithFormat:@"CECellIdentifier%ld", (long)indexPath.row];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [self configureCell:cell IndexPath:indexPath];
    
    return cell;
}

- (void)gotoLocationPickerViewController{
    [self performSegueWithIdentifier:@"GoToLocationPickerSegueID" sender:self];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        [self.slidingViewController setAnchorLeftRevealAmount:220.0];
        [self.slidingViewController anchorTopViewTo:ECLeft];
    }
}
- (UITableViewCell *)configureCell :(UITableViewCell *)cell IndexPath: (NSIndexPath *)indexPath{
    UILabel *lblTitle;
    UIImageView *imgT;
    UILabel *lblDetail;
    UITextField *txtDetail;
    UIButton *btnDetail;

    if(cell == nil){
        cell = [m_contentTable cellForRowAtIndexPath:indexPath];
    }

    switch (indexPath.row) {
        case 0:{
            lblTitle = (UILabel *)[cell.contentView viewWithTag:1];
            if(lblTitle == nil){
                lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 11, 65, 21)];
                lblTitle.tag = 1;
                [lblTitle setText:@"Activity"];
                
                [cell.contentView addSubview:lblTitle];
            }
            
            lblDetail = (UILabel *)[cell.contentView viewWithTag:2];
            if(lblDetail == nil){
                lblDetail = [[UILabel alloc]initWithFrame:CGRectMake(124, 11, 163, 21)];
                [lblDetail setTextColor:[UIColor lightGrayColor]];
                lblDetail.font = [UIFont boldSystemFontOfSize:16.0];
                lblDetail.textAlignment = NSTextAlignmentRight;
                lblDetail.tag = 2;
                [cell.contentView addSubview:lblDetail];
            }
            [lblDetail setText:selectedType];
            CGFloat widthOfDetail = [self getWidthOfLabel:lblDetail];
            [lblDetail setFrame:CGRectMake(lblDetail.frame.origin.x + lblDetail.frame.size.width - widthOfDetail, lblDetail.frame.origin.y, widthOfDetail, lblDetail.frame.size.height)];
            
            
            imgT = (UIImageView *)[cell.contentView viewWithTag:3];
            if(imgT == nil){
                imgT = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
                imgT.tag = 3;
                [cell.contentView addSubview:imgT];
            }
            [imgT setCenter:CGPointMake(lblDetail.frame.origin.x - 30, lblDetail.center.y)];
            PFQuery *query;
            query = [PFQuery queryWithClassName:@"TypeOfEvents"];
            [query whereKey:@"TitleOfType" equalTo:selectedType];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if(!error){
                    PFFile *file = object[@"ImageOfType"];
                    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if(!error){
                            imgT.image = [UIImage imageWithData:data];
                            imgT.layer.cornerRadius = 15;
                            imgT.layer.masksToBounds = YES;
                        }
                    }];
                }
            }];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case 1:{
            lblTitle = (UILabel *)[cell.contentView viewWithTag:4];
            if(lblTitle == nil){
                lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 11, 151, 21)];
                lblTitle.tag = 4;
                [lblTitle setText:@"Number of Players"];
                
                [cell.contentView addSubview:lblTitle];
            }
            
            txtDetail = (UITextField *)[cell.contentView viewWithTag:5];
            if(txtDetail == nil){
                txtDetail = [[UITextField alloc]initWithFrame:CGRectMake(175, 0, 112, 44)];
                [txtDetail setTextColor:[UIColor lightGrayColor]];
                txtDetail.font = [UIFont boldSystemFontOfSize:16.0];
                txtDetail.textAlignment = NSTextAlignmentRight;
                txtDetail.tag = 5;
                txtDetail.keyboardType = UIKeyboardTypeNumberPad;
                txtDetail.delegate = self;
                txtDetail.clearsOnBeginEditing = YES;
                [cell.contentView addSubview:txtDetail];
            }
            [txtDetail setText:[NSString stringWithFormat:@"%lu",(unsigned long)NoP]];
            break;
        }
        case 2:{
            lblTitle = (UILabel *)[cell.contentView viewWithTag:6];
            if(lblTitle == nil){
                lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 11, 66, 21)];
                lblTitle.tag = 6;
                [lblTitle setText:@"Players"];
                
                [cell.contentView addSubview:lblTitle];
            }
            
            btnDetail = (UIButton *)[cell.contentView viewWithTag:7];
            if(btnDetail == nil){
                btnDetail = [[UIButton alloc]initWithFrame:CGRectMake(87, 0, 200, 44)];
                [btnDetail setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
                btnDetail.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
                btnDetail.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
                btnDetail.tag = 7;
                [btnDetail addTarget:self action:@selector(btnPlayersClicked:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:btnDetail];
            }
            [btnDetail setTitle:selectedPlayers forState:UIControlStateNormal];
            break;
        }
        case 3:{
            lblTitle = (UILabel *)[cell.contentView viewWithTag:8];
            if(lblTitle == nil){
                lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 11, 83, 21)];
                lblTitle.tag = 8;
                [lblTitle setText:@"Location"];
                
                [cell.contentView addSubview:lblTitle];
            }
            
            
            lblDetail = (UILabel *)[cell.contentView viewWithTag:9];
            if(lblDetail == nil){
                lblDetail = [[UILabel alloc]initWithFrame:CGRectMake(104, 11, 183, 21)];
                [lblDetail setTextColor:[UIColor lightGrayColor]];
                lblDetail.font = [UIFont boldSystemFontOfSize:16.0];
                lblDetail.textAlignment = NSTextAlignmentRight;
                lblDetail.tag = 9;
                [cell.contentView addSubview:lblDetail];
            }
            [lblDetail setText:selectedPlace.name];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(104, 0, 215, 44)];
            
            [btn setBackgroundColor:[UIColor clearColor]];

            [cell addSubview:btn];
//
            [btn addTarget:self action:	@selector(gotoLocationPickerViewController) forControlEvents:UIControlEventTouchUpInside];
            break;
        }
        case 4:{
            lblTitle = (UILabel *)[cell.contentView viewWithTag:10];
            if(lblTitle == nil){
                lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 11, 48, 21)];
                lblTitle.tag = 10;
                [lblTitle setText:@"Time"];
                
                [cell.contentView addSubview:lblTitle];
            }
            
            txtDetail = (UITextField *)[cell.contentView viewWithTag:11];
            if(txtDetail == nil){
                txtDetail = [[UITextField alloc]initWithFrame:CGRectMake(70, 0, 217, 44)];
                [txtDetail setTextColor:[UIColor lightGrayColor]];
                txtDetail.font = [UIFont boldSystemFontOfSize:16.0];
                txtDetail.textAlignment = NSTextAlignmentRight;
                txtDetail.tag = 11;
                txtDetail.inputView = timePicker;
                txtDetail.delegate = self;
                [cell.contentView addSubview:txtDetail];
            }
            if(selectedTime){
                NSDateFormatter *df = [[NSDateFormatter alloc]init];
                df.dateFormat = @"h:mm a";
                df.timeStyle = NSDateFormatterShortStyle;
                
                NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"];
                df.locale = locale;
                txtDetail.text = [df stringFromDate:selectedTime];
            }
            break;
        }
        case 5:{
            lblTitle = (UILabel *)[cell.contentView viewWithTag:12];
            if(lblTitle == nil){
                lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 11, 48, 21)];
                lblTitle.tag = 12;
                [lblTitle setText:@"Date"];
                
                [cell.contentView addSubview:lblTitle];
            }
            
            txtDetail = (UITextField *)[cell.contentView viewWithTag:13];
            if(txtDetail == nil){
                txtDetail = [[UITextField alloc]initWithFrame:CGRectMake(70, 0, 217, 44)];
                [txtDetail setTextColor:[UIColor lightGrayColor]];
                txtDetail.font = [UIFont boldSystemFontOfSize:16.0];
                txtDetail.textAlignment = NSTextAlignmentRight;
                txtDetail.tag = 13;
                txtDetail.inputView = datePicker;
                txtDetail.delegate = self;
                [cell.contentView addSubview:txtDetail];
            }
            if(selectedDay){
                NSDateFormatter *df = [[NSDateFormatter alloc]init];
                
                df.dateFormat = @"MM.dd.yy";
                txtDetail.text = [df stringFromDate:selectedDay];
            }
            break;
        }
        default:
            break;
    }
    return cell;
}
- (CGFloat)getWidthOfLabel:(UILabel *)label{
    CGSize size = [label.text sizeWithAttributes:@{NSFontAttributeName:label.font}];
    return size.width;
}
- (void)btnPlayersClicked:(id)sender{
    if(tmpTxtField){
        doneButton = nil;
        [tmpTxtField resignFirstResponder];
        tmpTxtField = nil;
    }
    [postToSelector showInView:self.view];
}


-(IBAction)unwindToProfileScreen: (UIStoryboardSegue *)unwindSegue{
    
}
- (IBAction)btnSignOutClicked:(id)sender {
    [PFUser logOut];
}

- (IBAction)btnPostClicked:(id)sender {
    
    UIAlertView *alertView;
    
    if([m_txtEventName.text isEqualToString:@""]){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter your event name." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertView show];
        return;
    }
    
    if(NoP == 0){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please enter number of players." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertView show];
        return;
    }
    
    if(selectedPlace == nil){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please select your event place." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertView show];
        return;
    }
    
    if(selectedDay == nil){
        alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please select your event date/time." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertView show];
        return;
    }
    
    
    PFObject *object;
    PFObject *currentUser = [PFUser currentUser];
    object = [PFObject objectWithClassName:@"ActiveEvents"];
    object[@"Owner"] = currentUser.objectId;
    object[@"Type"] = selectedType;
    object[@"Place"] = selectedPlace.name;
    object[@"StartTime"] = selectedDay;
    object[@"People"] = [NSArray arrayWithObject:currentUser.objectId];
    object[@"EventName"] = m_txtEventName.text;
//    object[@"Description"] = m_txtDescription.text;
    object[@"PostTo"] = selectedPlayers;
    object[@"NoP"] = [NSNumber numberWithInteger:NoP];
    
    PFGeoPoint *eventPlace = [PFGeoPoint geoPointWithLatitude:selectedPlace.location.coordinate.latitude longitude:selectedPlace.location.coordinate.longitude];
    
    object[@"PlaceCoords"] = eventPlace;
    
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Success" message:@"Successfully posted!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alertView show];
        
    }];
    
}

#pragma mark - Textview Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(tmpTxtField != textField){
        doneButton = nil;
        [tmpTxtField resignFirstResponder];
    }
    tmpTxtField = textField;
    
    if(textField.tag == 13 || textField.tag == 11){

        coverView.hidden = NO;
    }
    if(textField.tag == 5){
        coverView.hidden = NO;
//        [self performSelector:@selector(addDoneButton) withObject:nil afterDelay:0.1];
    }else{
        if(doneButton != nil){
            [doneButton removeFromSuperview];
            doneButton = nil;
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    doneButton = nil;
    [textField resignFirstResponder];
    
    return YES;
}
- (IBAction)doneButtonAction:(id)sender{
    doneButton = nil;
    [tmpTxtField resignFirstResponder];
}
- (void)addDoneButton{
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0, 163, 106, 53);
    doneButton.adjustsImageWhenHighlighted = NO;
    [doneButton setImage:[UIImage imageNamed:@"doneup.png"] forState:UIControlStateNormal];
    [doneButton setImage:[UIImage imageNamed:@"donedown.png"] forState:UIControlStateHighlighted];
    [doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    //locate keyboard view

    UIView *keyboardView = [[[[[UIApplication sharedApplication]windows]lastObject]subviews]firstObject];
    [doneButton setFrame:CGRectMake(0, keyboardView.frame.size.height - 53, 106, 53)];
    [keyboardView addSubview:doneButton];
    //        [keyboardView bringSubviewToFront:doneButton];
    
    //        For the iOS6,5,4
    //        UIWindow *tempWindow = [[[UIApplication sharedApplication]windows]objectAtIndex:0];
    //        UIView *keyboard;
    //        for(int i = 0;i < [tempWindow.subviews count]; i++){
    //            keyboard = [tempWindow.subviews objectAtIndex:i];
    //            if([[keyboard description]hasPrefix:@"UIKeyboard"] == YES){
    //                [keyboard addSubview:doneButton];
    //            }
    //        }
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if(textField.tag == 5){
        NoP = [textField.text integerValue];
    }
}

#pragma mark - AlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

//Invitation Part
    PFQuery *innerQuery = [PFUser query];
    [innerQuery whereKey:@"objectId" containedIn:arrInvPeople];
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" matchesQuery:innerQuery];

    PFPush *push = [[PFPush alloc]init];
    [push setQuery:pushQuery];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"You were invited from %@",[PFUser currentUser][@"username"]], @"alert", @"Increment", @"badge",@"", @"sound", nil];
    [push setData:data];
    [push sendPushInBackground];
    
//    [PFPush sendPushMessageToQueryInBackground:pushQuery withMessage:[NSString stringWithFormat:@"You were invited from %@",[PFUser currentUser][@"username"]]];
    
    if([self.slidingViewController.underLeftViewController isKindOfClass:[ISCMenuViewController class]]){
        ISCMenuViewController *mvc = (ISCMenuViewController *)self.slidingViewController.underLeftViewController;
        UIButton *button = [[UIButton alloc]init];
        button.tag = 0;
        [mvc btnClicked:button];
    }
}

#pragma mark - DatePicker Delegate
- (void)timeDidChange{
    
/*    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateFormat = @"h:mm a";
    df.timeStyle = NSDateFormatterShortStyle;
    
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"];
    df.locale = locale;
    
    m_txtStartTime.text = [df stringFromDate:timePicker.date];*/
    selectedTime = timePicker.date;
    [self configureCell:nil IndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
}
- (void)dateDidChange{
    /*    NSDateFormatter *df = [[NSDateFormatter alloc]init];
     df.dateFormat = @"dd";
     m_txtStartDay.text = [df stringFromDate:datePicker.date];
     df.dateFormat = @"MM";
     m_txtStartMonth.text = [df stringFromDate:datePicker.date];
     df.dateFormat = @"yy";
     m_txtStartYear.text = [df stringFromDate:datePicker.date];
     
     df.dateFormat = @"MMMM d, y";*/
    selectedDay = datePicker.date;
    [self configureCell:nil IndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
}
-(void)dealloc{
    NSLog(@"PostViewController deallocated!");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (IBAction)btnMenuClicked:(id)sender {
    [self.slidingViewController anchorTopViewTo:ECRight];
}

@end
