//
//  FSEAccountManager.m
//  RadicalConvention
//
//  Created by Ferdly Sethio on 9/9/15.
//  Copyright (c) 2015 Ferdly Sethio. All rights reserved.
//

#import "FSEAccountManager.h"

@implementation FSEAccountManager

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(accountManagerDidLoggedIn)]) {
            [delegate accountManagerDidLoggedIn];
        }
    }
    return YES;
}

@end
