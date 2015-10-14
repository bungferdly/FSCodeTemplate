//
//  FSPageController.h
//  Pods
//
//  Created by Ferdly Sethio on 10/11/15.
//
//

#import <UIKit/UIKit.h>

@protocol FSPageControllerDelegate;

@interface FSPageController : UIPageViewController

@property (weak, nonatomic)     id<FSPageControllerDelegate> contentDelegate;
@property (strong, nonatomic)   NSArray *controllers;
@property (readonly, nonatomic) CGFloat offsetSelectedIndex;
@property (assign, nonatomic)   NSUInteger selectedIndex;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@end

@protocol FSPageControllerDelegate <NSObject>

- (void)pageControllerDidScroll:(FSPageController *)pageController;

@end
