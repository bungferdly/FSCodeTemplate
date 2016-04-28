//
//  FSAppDelegate.h
//  Pods
//
//  Created by Ferdly Sethio on 9/9/15.
//
//

#import <UIKit/UIKit.h>

@protocol FSAccountManagerDelegate;

@interface FSAppDelegate : UIResponder <UIApplicationDelegate, FSAccountManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

@interface FSAppDelegate(override)

- (void)initializeManagers;

@end
