//
//  FSTableView.m
//  Pods
//
//  Created by Ferdly on 1/20/16.
//
//

#import "FSTableView.h"

@implementation FSTableView

- (void)setStaticTableHeaderView:(UIView *)staticTableHeaderView
{
    _staticTableHeaderView = staticTableHeaderView;
    self.contentInset = UIEdgeInsetsMake(staticTableHeaderView.frame.size.height, 0, 0, 0);
    [self addSubview:staticTableHeaderView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.staticTableHeaderView) {
        self.staticTableHeaderView.frame = CGRectMake(0, self.contentOffset.y, self.frame.size.width, self.staticTableHeaderView.frame.size.height);
    }
}

@end
