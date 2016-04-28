//
//  FSNotificationManager.m
//  Pods
//
//  Created by Ferdly on 4/27/16.
//
//

#import "FSNotificationManager.h"
#import "FSAccountManager.h"

@interface FSNotificationManager () <FSAccountManagerDelegate>

@end

@implementation FSNotificationManager

- (void)didLoad
{
    [[FSAccountManager sharedManager] addDelegate:self];
}

- (void)accountManagerDidLoggedIn:(id)userInfo
{
    if (FSOSVersion >= 8) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
}

- (void)accountManagerDidLoggedOut:(id)userInfo
{
    [self setBadgeNumber:0];
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

- (void)setBadgeNumber:(int)badgeNumber
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber + 1];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
}

@end
