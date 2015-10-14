//
//  UIView+FS.h
//  Pods
//
//  Created by Ferdly Sethio on 10/11/15.
//
//

#import <UIKit/UIKit.h>

@interface UIView (FS)

- (void)subviewsMapping:(void (^)(UIView *view, BOOL *stop))map;
- (void)controlsWithTagMapping:(void (^)(UIControl *control, BOOL *stop))map;

@end
