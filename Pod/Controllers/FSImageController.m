//
//  FSImageController.m
//  Test
//
//  Created by Ferdly on 2/16/16.
//  Copyright © 2016 Ferdly. All rights reserved.
//

#import "FSImageController.h"
#import "UIViewController+FS.h"

//@interface FSImageChildController ()
//
//@property (strong, nonatomic) id image;
//
//@end
//
//@interface FSImageController () <UIViewControllerTransitioningDelegate>
//
//@end

@implementation FSImageController

//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
//{
//    CustomAnimatedTransitioning *transitioning = [CustomAnimatedTransitioning new];
//    transitioning.presenting = YES;
//    return transitioning;
//}
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
//{
//    CustomAnimatedTransitioning * transitioning = [CustomAnimatedTransitioning new];
//    transitioning.presenting = NO;
//    return transitioning;
//}
//
//- (void)presentFromViewController:(UIViewController *)controller andImageView:(UIImageView *)imageView
//{
//    NSMutableArray *childVCs = [NSMutableArray array];
//    for (id image in self.images) {
//        FSImageChildController *childVC = [FSImageChildController fs_newController];
//        childVC.image = image;
//        [childVCs addObject:childVC];
//    }
//    self.controllers = childVCs;
//    
//    UIImageView *animatedIV = [[UIImageView alloc] initWithImage:imageView.image];
//    animatedIV.clipsToBounds = imageView.clipsToBounds;
//    animatedIV.contentMode = imageView.contentMode;
//    animatedIV.frame = [imageView.superview convertRect:imageView.frame toView:imageView.window];
//    [imageView.window addSubview:animatedIV];
//    
//    self.view.alpha = 0;
//    imageView.alpha = 0;
//    
//    [controller addChildViewController:self];
//    
//    [UIView animateWithDuration:0.15 animations:^{
//        
//    }];
//}
//
//- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
//{
//    
//}

@end

@implementation FSImageChildController

//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    if (!self.scrollView) {
//        self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        [self.view addSubview:self.scrollView];
//    }
//}
//
//@end
//
//@interface FSModalTransitionAnimator : NSObject<UIViewControllerAnimatedTransitioning>
//@end
//
//@implementation FSModalTransitionAnimator
//
//- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
//    return 0.5; // 1
//}
//
//- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext // 2
//{
//    UIViewController* destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    
//    if([destination isBeingPresented]) { // 3
//        [self animatePresentation:transitionContext]; // 4
//    } else {
//        [self animateDismissal:transitionContext]; // 5
//    }
//}
//
//- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext
//{
//    UIViewController* source = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIViewController* destination = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIView* container = transitionContext.containerView;
//    
//    // Take destination view snapshot
//    UIView* destinationSS = [destination.view snapshotViewAfterScreenUpdates:YES]; // YES because the view hasn't been rendered yet.
//    
//    // Add snapshot view
//    [container addSubview:destinationSS];
//    
//    // Move destination snapshot back in Z plane
//    CATransform3D perspectiveTransform = CATransform3DIdentity;
//    perspectiveTransform.m34 = 1.0 / -1000.0;
//    perspectiveTransform = CATransform3DTranslate(perspectiveTransform, 0, 0, -100);
//    destinationSS.layer.transform = perspectiveTransform;
//    
//    // Start appearance transition for source controller
//    // Because UIKit does not remove views from hierarchy when transition finished
//    [source beginAppearanceTransition:NO animated:YES];
//    
//    [UIView animateKeyframesWithDuration:0.5 delay:0.0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
//        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
//            CGRect sourceRect = source.view.frame;
//            sourceRect.origin.y = CGRectGetHeight([[UIScreen mainScreen] bounds]);
//            source.view.frame = sourceRect;
//        }];
//        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.8 animations:^{
//            destinationSS.layer.transform = CATransform3DIdentity;
//        }];
//    } completion:^(BOOL finished) {
//        // Remove destination snapshot
//        [destinationSS removeFromSuperview];
//        
//        // Add destination controller to view
//        [container addSubview:destination.view];
//        
//        // Finish transition
//        [transitionContext completeTransition:finished];
//        
//        // End appearance transition for source controller
//        [source endAppearanceTransition];
//    }];
//}

@end
