//
//  ISCMessageViewController.m
//  Fitition
//
//  Created by WuYong on 7/31/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCMessageViewController.h"
#import "ISCFirebaseManager.h"
#import <Parse/Parse.h>

@interface ISCMessageViewController ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>{
    
    __weak IBOutlet UITextView *m_txtMessage;
    __weak IBOutlet UIButton *m_btnSend;
    
    __weak IBOutlet UIView *m_viewContent;
    __weak IBOutlet UITableView *m_tblChatContent;
    
    
    UIImage *targetImage;
    UIImage *myImage;
    NSString *chatroomName;
    
    NSMutableArray *arrMessages;
    
}

@end

@implementation ISCMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)btnBackClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(!arrMessages){
        arrMessages = [[NSMutableArray alloc]init];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    if(!arrMessages){
        arrMessages = [[NSMutableArray alloc]init];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    ISCFirebaseManager *firebaseManager;
    Firebase *mine;
    firebaseManager = [ISCFirebaseManager sharedInstance];
    PFUser *curUser = [PFUser currentUser];

    if([curUser.objectId compare:self.targetUserId] == NSOrderedAscending){
        chatroomName = [NSString stringWithFormat:@"%@:%@", curUser.objectId, self.targetUserId];
    }else{
        chatroomName = [NSString stringWithFormat:@"%@:%@", self.targetUserId, curUser.objectId];
    }
    
    mine = [firebaseManager.myRef childByAppendingPath:[NSString stringWithFormat:@"Users/%@/%@", curUser.objectId, chatroomName]];
    
    [mine setValue:[NSNumber numberWithInteger:0]];
    
    
    PFQuery *userQuery = [PFUser query];
    [userQuery getObjectInBackgroundWithId:self.targetUserId block:^(PFObject *object, NSError *error) {
        PFFile *file = [object objectForKey:@"Photo"];
        [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            targetImage = [UIImage imageWithData:data];
        }];
    }];
    
    PFFile *imgFile = [[PFUser currentUser] objectForKey:@"Photo"];
    [imgFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        myImage = [UIImage imageWithData:data];
    }];
    
    Firebase *chatListener = [firebaseManager.myRef childByAppendingPath:[NSString stringWithFormat:@"Chatrooms/%@", chatroomName]];
    
    [chatListener observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSString *uid = [snapshot.value objectForKey:@"uid"];
        NSString *message = [snapshot.value objectForKey:@"message"];
        NSString *type = [snapshot.value objectForKey:@"type"];
        NSString *dateTime = [snapshot.value objectForKey:@"dateTime"];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZ";
        NSDate *msgDate = [dateFormatter dateFromString:dateTime];
        
        [arrMessages addObject:@{@"uid": uid, @"message": message, @"type": type, @"dateTime": msgDate}];
        
        [m_tblChatContent reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

- (void)keyboardWillShow: (NSNotification *)aNotification{
    [self moveViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide: (NSNotification *)aNotification{
    [self moveViewForKeyboard:aNotification up:NO];
}

- (void)moveViewForKeyboard: (NSNotification *)aNotification up:(BOOL)up{
    NSDictionary *userInfo = [aNotification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    CGRect newFrame = self.view.frame;//m_viewContent.frame;
    newFrame.size.height -= keyboardFrame.size.height * (up?1:-1);
    self.view.frame = newFrame;
//    m_viewContent.frame = newFrame;
    [UIView commitAnimations];
}


- (IBAction)btnSendClicked:(id)sender {
    
    if([m_txtMessage.text isEqualToString:@""]){
        [m_txtMessage resignFirstResponder];
        return;
    }
    
    [m_txtMessage resignFirstResponder];
    
    [self sendTextMessage:m_txtMessage.text];
    
    [self setUnreadCounts];
    
    m_txtMessage.text = @"";
}

- (void)sendTextMessage:(NSString *)strMessage{
    ISCFirebaseManager *firebaseManager;
    Firebase *chatroom;
    firebaseManager = [ISCFirebaseManager sharedInstance];
    PFUser *curUser = [PFUser currentUser];
    
    chatroom = [firebaseManager.myRef childByAppendingPath:[NSString stringWithFormat:@"Chatrooms/%@", chatroomName]];
    NSString *curDate = [NSDate date].description;
    [[chatroom childByAutoId] setValue:@{@"uid": curUser.objectId, @"message":strMessage, @"type":@"text", @"dateTime":curDate}];
}

- (void)setUnreadCounts{
    ISCFirebaseManager *firebaseManager;
    Firebase *mine, *yours;
    firebaseManager = [ISCFirebaseManager sharedInstance];
    PFUser *curUser = [PFUser currentUser];
    
    mine = [firebaseManager.myRef childByAppendingPath:[NSString stringWithFormat:@"Users/%@/%@", curUser.objectId, chatroomName]];

    yours = [firebaseManager.myRef childByAppendingPath:[NSString stringWithFormat:@"Users/%@/%@", self.targetUserId, chatroomName]];

    [yours observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSUInteger cntUnread;
        cntUnread = [snapshot.value integerValue];
        cntUnread ++;
        [yours setValue:[NSNumber numberWithInteger:cntUnread]];
    }];

    [mine setValue:[NSNumber numberWithInteger:0]];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [arrMessages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    NSString *cellIdentifier = @"MessageViewCellIdentifier";
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *dicMessage = [arrMessages objectAtIndex:indexPath.row];
    
    if([self.targetUserId isEqualToString:dicMessage[@"uid"]]){
        cell.imageView.image = targetImage;
    }else{
        cell.imageView.image = myImage;
    }
    cell.textLabel.text = dicMessage[@"message"];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *curDateString = [dateFormatter stringFromDate:dicMessage[@"dateTime"]];
    
    cell.detailTextLabel.text = curDateString;
    return cell;
}

- (void)textViewDidChange:(UITextView *)textView{
    if([textView.text isEqualToString:@""]){
        [m_btnSend setTitle:@"Done" forState:UIControlStateNormal];
    }else{
        [m_btnSend setTitle:@"Send" forState:UIControlStateNormal];
    }
}

- (IBAction)btnPlusClicked:(id)sender {
}

@end
