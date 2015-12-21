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

- (void)setFs_borderColor:(UIColor *)fs_borderColor
{
    self.layer.borderColor = fs_borderColor.CGColor;
}

- (void)setFs_borderWidth:(CGFloat)fs_borderWidth
{
    self.layer.borderWidth = fs_borderWidth;
}

- (void)setFs_cornerRadius:(CGFloat)fs_cornerRadius
{
    self.layer.cornerRadius = fs_cornerRadius;
    self.clipsToBounds = YES;
}

- (void)setFs_content:(id)fs_content
{
    
}

@end
