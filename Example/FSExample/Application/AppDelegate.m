//
//  AppDelegate.m
//  FSExample
//
//  Created by Ferdly Sethio on 9/18/15.
//  Copyright © 2015 Ferdly Sethio. All rights reserved.
//

#import "AppDelegate.h"
#import "FSEAccountManager.h"
#import "FSEFirstController.h"

@interface AppDelegate () <FSEAccountManagerDelegate>

@end

@implementation AppDelegate

- (void)initializeManagers
{
    [[FSEAccountManager sharedManager] addDelegate:self];
}

- (void)accountManagerDidLoggedIn
{
    [[FSEFirstController fs_newController] fs_setAsRootViewController];
}

- (void)accountManagerDidLoggedOut
{
    
}

@end
