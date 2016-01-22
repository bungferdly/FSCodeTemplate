//
//  FSPageController.h
//  Pods
//
//  Created by Ferdly Sethio on 10/11/15.
//
//

#import <UIKit/UIKit.h>

@protocol FSPageControllerDelegate;
@class FSSegmentedControl;

@interface FSPageController : UIViewController

@property (weak, nonatomic)     id<FSPageControllerDelegate> contentDelegate;
@property (strong, nonatomic)   NSArray *controllers;
@property (readonly, nonatomic) CGFloat offsetSelectedIndex;
@property (assign, nonatomic)   NSUInteger selectedIndex;
@property (assign, nonatomic)   BOOL stopAtEdges;
@property (strong, nonatomic)   IBOutlet id pageControl;
@property (strong, nonatomic)   IBOutlet UIView *pageContainerView;
@property (strong, nonatomic)   IBOutlet UIPageViewController *pageViewController;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@end

@protocol FSPageControllerDelegate <NSObject>

- (void)pageControllerDidScroll:(FSPageController *)pageController;

@end

@interface UIViewController (FSPageController)

@property (readonly, nonatomic) FSPageController *fs_pageController;

@end
