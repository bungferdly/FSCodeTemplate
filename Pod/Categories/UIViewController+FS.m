//
//  UIViewController+FS.m
//  Pods
//
//  Created by Ferdly Sethio on 9/9/15.
//
//

#import "UIViewController+FS.h"
#import "FSPageController.h"
#import "FSRequestController.h"
#import "FSNavigationController.h"

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
    if ([self isKindOfClass:[UITabBarController class]] || [self isKindOfClass:[UINavigationController class]]) {
        rootWindow.rootViewController = self;
    } else {
        UINavigationController *rootNC = [[UINavigationController fs_defaultNavigationControllerClass] fs_newController];
        rootNC.viewControllers = @[self];
        rootWindow.rootViewController = rootNC;
    }
}

+ (instancetype)fs_topViewController
{
    id rootNC = [UIApplication sharedApplication].delegate.window.rootViewController;
    while (true) {
        if ([rootNC presentedViewController]) {
            rootNC = [rootNC presentedViewController];
        } else if ([rootNC isKindOfClass:[UITabBarController class]]) {
            rootNC = [rootNC selectedViewController];
        } else if ([rootNC isKindOfClass:[UINavigationController class]]) {
            rootNC = [rootNC topViewController];
        } else if ([rootNC isKindOfClass:[FSPageController class]] && [rootNC controllers].count > [rootNC selectedIndex]) {
            rootNC = [rootNC controllers][[rootNC selectedIndex]];
        } else if ([rootNC isKindOfClass:[FSRequestController class]]){
            rootNC = [[rootNC childViewControllers] firstObject];
        } else {
            break;
        }
    }
    return rootNC;
}

- (instancetype)fs_childControllerWithClass:(Class)cls
{
    if ([self isKindOfClass:cls]) {
        return self;
    }
    if (self.presentedViewController && self.presentedViewController != self.parentViewController.presentedViewController) {
        id vc = [self.presentedViewController fs_childControllerWithClass:cls];
        if (vc) {
            return vc;
        }
    }
    for (UIViewController *childVC in self.childViewControllers) {
        id vc = [childVC fs_childControllerWithClass:cls];
        if (vc) {
            return vc;
        }
    }
    return nil;
}

+ (instancetype)fs_sharedController
{
    id rootNC = [UIApplication sharedApplication].delegate.window.rootViewController;
    return [rootNC fs_childControllerWithClass:[self class]];
}

- (IBAction)fs_popViewControllerAnimated:(id)sender
{
    [self.navigationController popViewControllerAnimated:[sender tag]];
}

- (void)fs_dismissViewControllerAnimated:(id)sender
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:[sender tag] completion:nil];
    } else {
        [self fs_popViewControllerAnimated:sender];
    }
}

@end
