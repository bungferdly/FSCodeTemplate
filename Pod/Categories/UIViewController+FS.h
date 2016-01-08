//
//  UIViewController+FS.h
//  Pods
//
//  Created by Ferdly Sethio on 9/9/15.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (FS)

+ (instancetype)fs_topViewController;
+ (instancetype)fs_newController;
- (void)fs_setAsRootViewController;

- (IBAction)fs_popViewControllerAnimated:(id)sender;
- (IBAction)fs_dismissViewControllerAnimated:(id)sender;

@end
