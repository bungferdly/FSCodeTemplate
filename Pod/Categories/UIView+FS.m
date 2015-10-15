//
//  UIView+FS.m
//  Pods
//
//  Created by Ferdly Sethio on 10/11/15.
//
//

#import "UIView+FS.h"

@implementation UIView (FS)

- (void)subviewsMapping:(void (^)(UIView *view, BOOL *stop))map
{
    BOOL stop = NO;
    for (UIControl *con in self.subviews) {
        [con subviewsMapping:map];
        map(con, &stop);
        if (stop) {
            return;
        }
    }
}

- (void)controlsWithTagMapping:(void (^)(UIControl *, BOOL *))map
{
    [self subviewsMapping:^(UIView *view, BOOL *stop) {
        if ([view isKindOfClass:[UIControl class]] && view.tag > 0) {
            map((UIControl *)view, stop);
        }
    }];
}

@end
