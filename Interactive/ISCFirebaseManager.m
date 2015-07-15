//
//  ISCFirebaseManager.m
//  Fitition
//
//  Created by WuYong on 7/30/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import "ISCFirebaseManager.h"
ISCFirebaseManager *firebaseManager;
@implementation ISCFirebaseManager

+ (id)sharedInstance{
    if(!firebaseManager){
        firebaseManager = [[ISCFirebaseManager alloc]init];
    }
    return firebaseManager;
}

- (id)init{
    if(self = [super init]){
        self.myRef = [[Firebase alloc]initWithUrl:@"https://fitition.firebaseio.com"];
        self.authClient = [[FirebaseSimpleLogin alloc]initWithRef:self.myRef];
        
        [self.authClient checkAuthStatusWithBlock:^(NSError *error, FAUser *user) {
            if(error != nil){
                NSLog(@"%@", error);
            }else if(user == nil){
                NSLog(@"No user is logged in.");
            }else{
                NSLog(@"%@", user);
            }
        }];
        
        self.authRef = [self.myRef.root childByAppendingPath:@".info/authenticated"];
        [self.authRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            self.isAuthenticated = [snapshot.value boolValue];
            NSLog(@"isAuthenticated: %hhd", self.isAuthenticated);
        }];
        
    }
    return self;
}

- (void)createNewAccount:(NSString *)email :(NSString *)password{
    password = @"asdkljf8l2kKD4!@8M";
    [self.authClient createUserWithEmail:email password:password andCompletionBlock:^(NSError *error, FAUser *user) {
        if(error != nil){
            NSLog(@"Eror Code: %ld",(long)error.code);
            NSLog(@"Error domain: %@", error.domain);
            NSLog(@"Error Userinfo: %@", error.userInfo);
        }else{
            NSLog(@"Created a new account");
        }
    }];
}

- (void)loginWithEmail:(NSString *)email password:(NSString *)password :(NSString *)parseUserId{
    password = @"asdkljf8l2kKD4!@8M";
    [self.authClient loginWithEmail:email andPassword:password withCompletionBlock:^(NSError *error, FAUser *user) {
        if(error){
            NSLog(@"Error in logging firebase user in! %@", error);
        }else{
            NSLog(@"Logged in firebase!");
        }
    }];
    
    
}
- (void)setListners:(NSString *)parseUserId{
    self.userID = parseUserId;
    
    self.inboxCountRef = [self.myRef childByAppendingPath:[NSString stringWithFormat:@"Users/%@", self.userID]];
    [self.inboxCountRef observeEventType:FEventTypeChildChanged withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"Listner: (%@, %@)",snapshot.name, snapshot.value);
        //notification should be sent
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:@"NewMessage" object:self]];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"Inbox Count Error: %@", error);
    }];
    
    [self.inboxCountRef observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"Listner: (%@, %@)",snapshot.name, snapshot.value);
        //notification should be sent
        [[NSNotificationCenter defaultCenter]postNotification:[NSNotification notificationWithName:@"NewMessage" object:self]];
    } withCancelBlock:^(NSError *error) {
        NSLog(@"Inbox Count Error: %@", error);
    }];
}
- (void)logout{
    [self.authClient logout];
}
@end
