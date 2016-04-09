//
//  FSNavigationController.m
//  Pods
//
//  Created by Ferdly on 4/9/16.
//
//

#import "FSNavigationController.h"
#import "FSRequestController.h"

@interface FSNavigationController () <UINavigationControllerDelegate>

@property (strong, nonatomic) UIBarButtonItem *backButtonItem;
@end

@implementation FSNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
    self.backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
{
    [super setViewControllers:[self setupProtocolControllersFromControllers:viewControllers]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    UIViewController *vc = [self setupProtocolControllerFromController:viewController];
    vc.hidesBottomBarWhenPushed = self.viewControllers.count ? YES : NO;
    [super pushViewController:vc animated:animated];
}

- (UIViewController *)setupProtocolControllerFromController:(UIViewController *)controller
{
    return [[self setupProtocolControllersFromControllers:@[controller]] firstObject];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
{
    if (!viewController.navigationItem.backBarButtonItem) {
        viewController.navigationItem.backBarButtonItem = self.backButtonItem;
    }
    [self setNavigationBarHidden:[viewController conformsToProtocol:@protocol(FSNavigationBarHidden)] animated:animated];
}

- (NSArray *)setupProtocolControllersFromControllers:(NSArray *)controllers
{
    NSMutableArray *vcs = [NSMutableArray array];
    for (id vc in controllers) {
        UIViewController *newVC = vc;
        if ([vc conformsToProtocol:@protocol(FSRequestControllerDelegate)]) {
            FSRequestController *requestVC = [FSRequestController controllerWithChildController:vc];
            newVC = requestVC;
        }
        newVC.hidesBottomBarWhenPushed = self.viewControllers.count ? YES : NO;
        [vcs addObject:newVC];
    }
    return vcs;
}

@end

Class __fs_defaultNavigationControllerClass;

@implementation UINavigationController (FS)

+ (void)fs_setAsDefaultNavigationControllerClass
{
    __fs_defaultNavigationControllerClass = self;
}

+ (Class)fs_defaultNavigationControllerClass
{
    return __fs_defaultNavigationControllerClass ?: [FSNavigationController class];
}

@end
