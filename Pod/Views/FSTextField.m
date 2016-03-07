//
//  FSTextField.m
//  Pods
//
//  Created by Ferdly on 1/22/16.
//
//

#import "FSTextField.h"

@interface FSTextField ()

@property (strong, nonatomic) NSString *oldText;

@end

@implementation FSTextField

- (void)setMaxTextLen:(NSUInteger)maxTextLen
{
    _maxTextLen = maxTextLen;
    [self addTarget:self action:@selector(myTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)myTextFieldDidChange:(id)sender {
    if (self.text.length > self.maxTextLen) {
        self.text = self.oldText;
    } else {
        self.oldText = self.text;
    }
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, self.textPadding.x, self.textPadding.y);
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, self.textPadding.x, self.textPadding.y);
}

@end
