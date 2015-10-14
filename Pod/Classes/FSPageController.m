//
//  FSPageController.m
//  Pods
//
//  Created by Ferdly Sethio on 10/11/15.
//
//

#import "FSPageController.h"

@interface FSPageController () <UIScrollViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (assign, nonatomic) BOOL tellDelegate;

@end

@implementation FSPageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIScrollView *v in self.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            v.delegate = self;
        }
    }
    
    self.delegate = self;
    self.dataSource = self;
    self.selectedIndex = self.selectedIndex;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.tellDelegate = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.tellDelegate = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.tellDelegate) {
        return;
    }
    _offsetSelectedIndex = (scrollView.contentOffset.x / scrollView.frame.size.width) - 1;
    if ((_selectedIndex == 0 && _offsetSelectedIndex < 0) ||
        (_selectedIndex == self.controllers.count - 1 && _offsetSelectedIndex > 0)) {
        _offsetSelectedIndex *= (- ((NSInteger)self.controllers.count - 1));
    }
    if ([self.contentDelegate respondsToSelector:@selector(pageControllerDidScroll:)]) {
        [self.contentDelegate pageControllerDidScroll:self];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    if (!self.isViewLoaded) {
        return;
    }
    if (self.viewControllers.count && (selectedIndex == _selectedIndex || selectedIndex >= self.controllers.count)) {
        return;
    }
    UIViewController *selectedController = self.controllers[selectedIndex];
    if (selectedIndex <= _selectedIndex) {
        [self setViewControllers:@[selectedController] direction:UIPageViewControllerNavigationDirectionReverse animated:animated completion:nil];
    } else if (selectedIndex > _selectedIndex) {
        [self setViewControllers:@[selectedController] direction:UIPageViewControllerNavigationDirectionForward animated:animated completion:nil];
    }
    _selectedIndex = selectedIndex;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self.controllers indexOfObject:viewController] + 1;
    if (index >= self.controllers.count) {
        index = 0;
    }
    return self.controllers[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self.controllers indexOfObject:viewController] - 1;
    if (index < 0) {
        index = self.controllers.count - 1;
    }
    return self.controllers[index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished && completed) {
        _selectedIndex = [self.controllers indexOfObject:self.viewControllers.firstObject];
        _offsetSelectedIndex = 0;
        if ([self.contentDelegate respondsToSelector:@selector(pageControllerDidScroll:)]) {
            [self.contentDelegate pageControllerDidScroll:self];
        }
    }
}

@end
