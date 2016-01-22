//
//  RadicalConvention.h
//  Pods
//
//  Created by Ferdly Sethio on 9/9/15.
//
//

#ifndef Pods_RadicalConvention_h
#define Pods_RadicalConvention_h

#ifdef DEBUG
#define FSLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#else
#define FSLog(...) ((void)0)
#endif

#define FSOSVersion [[UIDevice currentDevice].systemVersion floatValue]
#define FSKindOf(obj, cls) ((cls *)([obj isKindOfClass:[cls class]] ? obj : nil))
#define FSArrayKindOf(obj, cls) ((NSArray *)(FSKindOf(FSKindOf(obj, NSArray).firstObject, cls) ? obj : nil))

#import "UIViewController+FS.h"
#import "UIView+FS.h"
#import "UIImage+FS.h"

#import "FSAppDelegate.h"
#import "FSManager.h"
#import "FSAccountManager.h"
#import "FSRequestManager.h"
#import "FSJSONParserManager.h"
#import "FSResponderManager.h"
#import "FSKeychainManager.h"

#import "FSPageController.h"
#import "FSAlertController.h"

#import "FSSegmentedControl.h"
#import "FSPhotoImageView.h"
#import "FSButton.h"
#import "FSTableViewCell.h"
#import "FSCollectionViewCell.h"
#import "FSTableView.h"
#import "FSTextField.h"

#endif
