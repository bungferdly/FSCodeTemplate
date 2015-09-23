//
//  FSSegmentedControl.m
//  Pods
//
//  Created by Ferdly Sethio on 9/23/15.
//
//

#import "FSSegmentedControl.h"

@implementation FSSegmentedControl

- (void)awakeFromNib
{
    [super awakeFromNib];
    for (UIButton *segment in self.segments) {
        [segment addTarget:self action:@selector(buttonDidSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    self.value = _value;
}

- (void)buttonDidSelect:(UIButton *)sender
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
            id segment = self.segments[i];
            if ([segment isKindOfClass:[UIButton class]]) {
                [self.segments[i] setSelected:i == index];
            }
        }
        self.stickerLeftLC.constant = value * [self.segments[index] frame].size.width;
    }
}

@end
