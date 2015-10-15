//
//  UIView+FS.h
//  Pods
//
//  Created by Ferdly Sethio on 10/11/15.
//
//

#import <UIKit/UIKit.h>

@interface UIView (FS)

- (void)fs_subviewsMapping:(void (^)(UIView *view, BOOL *stop))map;

@end
