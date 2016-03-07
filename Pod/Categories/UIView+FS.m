//
//  UIView+FS.m
//  Pods
//
//  Created by Ferdly Sethio on 10/11/15.
//
//

#import "UIView+FS.h"

@implementation UIView (FS)

- (void)fs_subviewsMapping:(void (^)(UIView *view, BOOL *stop))map
{
    BOOL stop = NO;
    for (UIControl *con in self.subviews) {
        [con fs_subviewsMapping:map];
        map(con, &stop);
        if (stop) {
            return;
        }
    }
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.clipsToBounds = YES;
}

- (UIColor *)borderColor
{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}

- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}

@end
