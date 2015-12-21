//
//  UIView+FS.h
//  Pods
//
//  Created by Ferdly Sethio on 10/11/15.
//
//

#import <UIKit/UIKit.h>

@interface UIView (FS)

@property (assign, nonatomic) CGFloat fs_borderWidth;
@property (strong, nonatomic) UIColor *fs_borderColor;
@property (assign, nonatomic) CGFloat fs_cornerRadius;
@property (strong, nonatomic) id fs_content;

- (void)fs_subviewsMapping:(void (^)(UIView *view, BOOL *stop))map;

@end
