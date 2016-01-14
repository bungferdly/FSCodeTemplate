//
//  FSPageController.m
//  Pods
//
//  Created by Ferdly Sethio on 10/11/15.
//
//

#import "FSPageController.h"
#import "FSSegmentedControl.h"

@interface FSPageController () <UIScrollViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (assign, nonatomic) BOOL tellDelegate;

@end

@implementation FSPageController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self.pageViewController) {
        self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                  navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                options:nil];
        [self addChildViewController:self.pageViewController];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (UIScrollView *v in self.pageViewController.view.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            v.delegate = self;
        }
    }
    
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    [self.pageControl addTarget:self action:@selector(pageControlDidChangeValue:) forControlEvents:UIControlEventValueChanged];
    
    if (!self.pageContainerView) {
        self.pageContainerView = self.view;
    }
    [self.pageContainerView insertSubview:self.pageViewController.view atIndex:0];
    self.pageViewController.view.frame = self.pageContainerView.bounds;
    self.pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.selectedIndex = self.selectedIndex;
}

- (void)setControllers:(NSArray *)controllers
{
    _controllers = controllers;
    
    if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        ((UIPageControl *)self.pageControl).numberOfPages = controllers.count;
    }
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
    if ([self.pageControl isKindOfClass:[FSSegmentedControl class]]) {
        ((FSSegmentedControl *)self.pageControl).value = _selectedIndex + _offsetSelectedIndex;
    }
    if ([self.contentDelegate respondsToSelector:@selector(pageControllerDidScroll:)]) {
        [self.contentDelegate pageControllerDidScroll:self];
    }
}

- (void)pageControlDidChangeValue:(id)pageControl
{
    if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        [self setSelectedIndex:(NSUInteger)((UIPageControl *)self.pageControl).currentPage animated:YES];
    } else if ([self.pageControl isKindOfClass:[FSSegmentedControl class]]) {
        [self setSelectedIndex:(NSUInteger)((FSSegmentedControl *)self.pageControl).value animated:YES];
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
    if (self.pageViewController.viewControllers.count && (selectedIndex == _selectedIndex || selectedIndex >= self.controllers.count)) {
        return;
    }
    UIViewController *selectedController = self.controllers[selectedIndex];
    if (selectedIndex <= _selectedIndex) {
        [self.pageViewController setViewControllers:@[selectedController] direction:UIPageViewControllerNavigationDirectionReverse animated:animated completion:nil];
    } else if (selectedIndex > _selectedIndex) {
        [self.pageViewController setViewControllers:@[selectedController] direction:UIPageViewControllerNavigationDirectionForward animated:animated completion:nil];
    }
    [self _setSelectedIndex:selectedIndex];
}

- (void)_setSelectedIndex:(NSUInteger)selectedIndex
{
    _selectedIndex = selectedIndex;
    _offsetSelectedIndex = 0;
    if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        ((UIPageControl *)self.pageControl).currentPage = selectedIndex;
    } else if ([self.pageControl isKindOfClass:[FSSegmentedControl class]]) {
        ((FSSegmentedControl *)self.pageControl).value = selectedIndex;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [self.controllers indexOfObject:viewController] + 1;
    if (index >= self.controllers.count) {
        if (self.stopAtEdges) {
            return nil;
        }
        index = 0;
    }
    return self.controllers[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [self.controllers indexOfObject:viewController] - 1;
    if (index < 0) {
        if (self.stopAtEdges) {
            return nil;
        }
        index = self.controllers.count - 1;
    }
    return self.controllers[index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (finished && completed) {
        [self _setSelectedIndex:[self.controllers indexOfObject:self.pageViewController.viewControllers.firstObject]];
        if ([self.contentDelegate respondsToSelector:@selector(pageControllerDidScroll:)]) {
            [self.contentDelegate pageControllerDidScroll:self];
        }
    }
}

@end

@implementation UIViewController (FSPageController)

- (FSPageController *)fs_pageController
{
    FSPageController *vc = self.parentViewController;
    while (vc && ![vc isKindOfClass:[FSPageController class]]) {
        vc = vc.parentViewController;
    }
    return vc;
}

@end
