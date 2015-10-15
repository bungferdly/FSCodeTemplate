//
//  FSAppDelegate.h
//  Pods
//
//  Created by Ferdly Sethio on 9/9/15.
//
//

#import <UIKit/UIKit.h>

@interface FSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

@interface FSAppDelegate(override)

- (void)initializeManagers;

@end
