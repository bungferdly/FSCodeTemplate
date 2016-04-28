//
//  FSTextField.m
//  Pods
//
//  Created by Ferdly on 1/22/16.
//
//

#import "FSTextField.h"



@interface FSTextField ()

@property (strong, nonatomic) UIView *defaultBackgroundView;

@end

@implementation FSTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
}

- (void)setDefaultText:(NSString *)defaultText
{
    _defaultText = defaultText;
    self.text = defaultText;
    [self reloadDefaultBackgroundView];
}

- (void)reloadDefaultBackgroundView
{
    if (_defaultText.length && !self.defaultBackgroundView) {
        self.defaultBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.defaultBackgroundView.userInteractionEnabled = NO;
        self.defaultBackgroundView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:0.8 alpha:1];
        self.defaultBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:self.defaultBackgroundView atIndex:0];
    } else if (!_defaultText.length && self.defaultBackgroundView) {
        [self.defaultBackgroundView removeFromSuperview];
        self.defaultBackgroundView = nil;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *replacement = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.regex) {
        NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.regex];
        if (![p evaluateWithObject:replacement]) {
            return NO;
        }
    }
    if (self.maxTextLen > 0 && replacement.length > self.maxTextLen) {
        return NO;
    }
    if (_defaultText) {
        _defaultText = nil;
        [self reloadDefaultBackgroundView];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
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


@interface FSDateTextField ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation FSDateTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.inputView = self.datePicker;
    [self.datePicker addTarget:self action:@selector(inputViewDidChangeValue) forControlEvents:UIControlEventValueChanged];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = self.dateFormat;
    self.dateFormatter.locale = self.datePicker.locale;
    
    if (self.autoFill) {
        self.date = self.datePicker.date;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([super textField:textField shouldChangeCharactersInRange:range replacementString:string]) {
        NSString *replacement = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if ([self.dateFormatter dateFromString:replacement]) {
            return YES;
        }
    }
    return NO;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    self.text = [self.dateFormatter stringFromDate:date];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.datePicker.date = [self.dateFormatter dateFromString:self.text] ?: [NSDate date];
    });
}

- (void)inputViewDidChangeValue
{
    if (self.isFirstResponder) {
        self.date = self.datePicker.date;
        [self sendActionsForControlEvents:UIControlEventEditingChanged];
    }
}

@end
