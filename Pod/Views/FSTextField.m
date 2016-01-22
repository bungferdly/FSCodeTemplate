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

- (void)setMaximumTextLength:(NSUInteger)maximumTextLength
{
    _maximumTextLength = maximumTextLength;
    [self addTarget:self action:@selector(myTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)myTextFieldDidChange:(id)sender {
    if (self.text.length > self.maximumTextLength) {
        self.text = self.oldText;
    } else {
        self.oldText = self.text;
    }
}

@end
