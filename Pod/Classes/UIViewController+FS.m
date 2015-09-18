//
//  UIViewController+FS.m
//  Pods
//
//  Created by Ferdly Sethio on 9/9/15.
//
//

#import "UIViewController+FS.h"

@implementation UIViewController (FS)

+ (instancetype)fs_newController
{
    NSString *className = NSStringFromClass([self class]);
    NSString *storyboardName = [className stringByReplacingOccurrencesOfString:@"Controller" withString:@""];
    UIViewController *instance = nil;
    @try {
        instance = [[UIStoryboard storyboardWithName:storyboardName bundle:nil] instantiateInitialViewController];
    }
    @catch (NSException *exception) {
        
    }
    if (![instance isKindOfClass:[self class]]) {
        instance = [[self alloc] init];
    }
    return instance;
}

- (void)fs_setAsRootViewController
{
    UIWindow *rootWindow = [[UIApplication sharedApplication].delegate window];
    UINavigationController *rootNC = (UINavigationController *)rootWindow.rootViewController;
    if ([self isKindOfClass:[UITabBarController class]] || [self isKindOfClass:[UINavigationController class]]) {
        rootWindow.rootViewController = self;
    } else if (![rootNC isKindOfClass:[UINavigationController class]]) {
        rootNC = [[UINavigationController alloc] initWithRootViewController:self];
        rootWindow.rootViewController = rootNC;
    } else {
        [rootNC setViewControllers:@[self]];
    }
}

+ (instancetype)fs_topViewController
{
    id rootNC = [UIApplication sharedApplication].delegate.window.rootViewController;
    if ([rootNC isKindOfClass:[UITabBarController class]]) {
        rootNC = [rootNC selectedViewController];
    }
    if ([rootNC isKindOfClass:[UINavigationController class]]) {
        rootNC = [rootNC topViewController];
    }
    return rootNC;
}

@end
