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

@end
