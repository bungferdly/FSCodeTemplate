//
//  FSSegmentedControl.m
//  Pods
//
//  Created by Ferdly Sethio on 9/23/15.
//
//

#import "FSSegmentedControl.h"
#import "UIView+FS.h"

@interface FSSegmentedControl ()

@property (strong, nonatomic) NSMutableArray<__kindof UIControl *> *segments;

@end

@implementation FSSegmentedControl

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.segments = [NSMutableArray array];
    [self fs_subviewsMapping:^(UIView *view, BOOL *stop) {
        if ([view isKindOfClass:[UIControl class]]) {
            [self.segments addObject:(UIControl *)view];
            [(UIControl *)view addTarget:self action:@selector(controlDidSelect:) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
    [self.segments sortUsingComparator:^NSComparisonResult(UIView *  _Nonnull obj1, UIView *  _Nonnull obj2) {
        return CGRectGetMinX(obj1.frame) < CGRectGetMinX(obj2.frame) ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    self.value = _value;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.value = self.value;
}

- (void)controlDidSelect:(UIButton *)sender
{
    if (self.value != [self.segments indexOfObject:sender]) {
        [UIView animateWithDuration:0.2 animations:^{
            self.value = [self.segments indexOfObject:sender];
            [self layoutIfNeeded];
        } completion:nil];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setValue:(CGFloat)value
{
    _value = value;
    
    NSInteger index = roundf(value);
    if (index >= 0 && index < self.segments.count) {
        for (int i = 0 ; i < self.segments.count ; i++) {
            [self.segments[i] setSelected:i == index];
        }
        self.stickerLeftLC.constant = (value / self.segments.count) * self.frame.size.width;
    }
}

@end
