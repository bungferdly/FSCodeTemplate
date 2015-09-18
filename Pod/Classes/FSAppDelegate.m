//
//  FSAppDelegate.m
//  Pods
//
//  Created by Ferdly Sethio on 9/9/15.
//
//

#import "FSAppDelegate.h"
#import "FSManager.h"

@implementation FSAppDelegate

- (void)initializeManagers
{
    
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

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *))restorationHandler
{
    BOOL ret = NO;
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:continueUserActivity:restorationHandler:)]) {
            ret |= [manager application:application continueUserActivity:userActivity restorationHandler:restorationHandler];
        }
    }
    return ret;
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:didChangeStatusBarFrame:)]) {
            [manager application:application didChangeStatusBarFrame:oldStatusBarFrame];
        }
    }
}

- (void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:didChangeStatusBarOrientation:)]) {
            [manager application:application didChangeStatusBarOrientation:oldStatusBarOrientation];
        }
    }
}

- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:didDecodeRestorableStateWithCoder:)]) {
            [manager application:application didDecodeRestorableStateWithCoder:coder];
        }
    }
}

- (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:didFailToContinueUserActivityWithType:error:)]) {
            [manager application:application didFailToContinueUserActivityWithType:userActivityType error:error];
        }
    }
}

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

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    for (FSManager *manager in [FSManager allManagers]) {
        if ([manager respondsToSelector:@selector(application:didReceiveRemoteNotification:)]) {
            [manager application:application didReceiveRemoteNotification:userInfo];
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

@end
