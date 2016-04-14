//
//  FSNavigationController.h
//  Pods
//
//  Created by Ferdly on 4/9/16.
//
//

#import <UIKit/UIKit.h>

@interface FSNavigationController : UINavigationController

@end

@protocol FSNavigationBarHidden <NSObject>

@end

@protocol FSToolbarShow <NSObject>

@end

@interface UINavigationController (FS)

+ (void)fs_setAsDefaultNavigationControllerClass;
+ (Class)fs_defaultNavigationControllerClass;

@end
