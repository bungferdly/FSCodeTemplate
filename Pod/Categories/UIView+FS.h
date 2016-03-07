//
//  UIView+FS.h
//  Pods
//
//  Created by Ferdly Sethio on 10/11/15.
//
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
//IB_DESIGNABLE
#endif

@interface UIView (FS)

@property (assign, nonatomic) IBInspectable CGFloat borderWidth;
@property (strong, nonatomic) IBInspectable UIColor *borderColor;
@property (assign, nonatomic) IBInspectable CGFloat cornerRadius;

- (void)fs_subviewsMapping:(void (^)(UIView *view, BOOL *stop))map;

@end
