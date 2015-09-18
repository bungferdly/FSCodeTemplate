//
//  FSEAccountManager.h
//  FSExample
//
//  Created by Ferdly Sethio on 9/9/15.
//  Copyright (c) 2015 Ferdly Sethio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSEAccountManager : FSManager

@end

@protocol FSEAccountManagerDelegate <NSObject>

- (void)accountManagerDidLoggedIn;
- (void)accountManagerDidLoggedOut;

@end