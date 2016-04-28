//
//  FSAppDelegate.m
//  Pods
//
//  Created by Ferdly Sethio on 9/9/15.
//
//

#import "FSAppDelegate.h"
#import "FSManager.h"
#import "FSResponderManager.h"
#import "FSAccountManager.h"

#ifdef FS_SUBSPEC_NOTIFICATION
    #import "FSNotificationManager.h"
#endif

@implementation FSAppDelegate

- (void)initializeManagers
{
    [FSResponderManager sharedManager];
    [[FSAccountManager sharedManager] addDelegate:self];
    
#ifdef FS_SUBSPEC_NOTIFICATION
    [FSNotificationManager sharedManager];
#endif
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initializeManagers];
    
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
            [manager application:application didFinishLaunchingWithOptions:launchOptions];
        }
    }
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(applicationDidBecomeActive:)]) {
            [manager applicationDidBecomeActive:application];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(applicationDidEnterBackground:)]) {
            [manager applicationDidEnterBackground:application];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(applicationWillEnterForeground:)]) {
            [manager applicationWillEnterForeground:application];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(applicationWillResignActive:)]) {
            [manager applicationWillResignActive:application];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(applicationWillTerminate:)]) {
            [manager applicationWillTerminate:application];
        }
    }
}

#ifdef FS_SUBSPEC_NOTIFICATION

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)]) {
            [manager application:application didFailToRegisterForRemoteNotificationsWithError:error];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:didReceiveLocalNotification:)]) {
            [manager application:application didReceiveLocalNotification:notification];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
            [manager application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
        }
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
            [manager application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        }
    }
}

#endif

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL ret = NO;
    
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:openURL:sourceApplication:annotation:)]) {
            ret |= [manager application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
        }
    }
    return ret;
}

@end
