//
//  ISCFirebaseManager.h
//  Fitition
//
//  Created by WuYong on 7/30/14.
//  Copyright (c) 2014 Wu Yong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Firebase/Firebase.h>
#import <FirebaseSimpleLogin/FirebaseSimpleLogin.h>

@interface ISCFirebaseManager : NSObject{
    FirebaseHandle handle;
}
@property (nonatomic, retain) Firebase *myRef;
@property (nonatomic, retain) FirebaseSimpleLogin *authClient;
@property (nonatomic, retain) Firebase *authRef;
@property (nonatomic, retain) Firebase *inboxCountRef;
@property (nonatomic, retain) Firebase *notificationCountRef;
@property (nonatomic, retain) Firebase *chatroomsRef;
@property (nonatomic, retain) NSString *userID;

@property (nonatomic, assign) BOOL isAuthenticated;

+(id)sharedInstance;

- (void)createNewAccount:(NSString *)email :(NSString *)password;
- (void)loginWithEmail:(NSString *)email password:(NSString *)password :(NSString *)parseUserId;
- (void)setListners:(NSString *)parseUserId;
- (void)logout;
@end
