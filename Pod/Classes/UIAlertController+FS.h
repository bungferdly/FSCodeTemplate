//
//  UIAlertController+FS.h
//  Pods
//
//  Created by Ferdly Sethio on 10/14/15.
//
//

#import <UIKit/UIKit.h>
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>

@interface UIAlertController (FS)

+ (instancetype)showWithMessage:(NSString *)message;
+ (instancetype)showWithTitle:(NSString *)title message:(NSString *)message;

@end
