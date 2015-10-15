//
//  FSAccountManager.h
//  Pods
//
//  Created by Ferdly Sethio on 10/15/15.
//
//

#import "FSManager.h"

@interface FSAccountManager : FSManager

@property (assign, nonatomic) BOOL loggedIn;

- (void)setLoggedIn:(BOOL)loggedIn withUserInfo:(id)userInfo;

@end

@protocol FSAccountManagerDelegate <NSObject>

@optional
- (void)accountManagerDidLoggedIn:(id)userInfo;
- (void)accountManagerDidLoggedOut:(id)userInfo;

@end
