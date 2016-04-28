//
//  FSTextField.h
//  Pods
//
//  Created by Ferdly on 1/22/16.
//
//

#import <UIKit/UIKit.h>

@interface FSTextField : UITextField <UITextFieldDelegate>

@property (assign, nonatomic) IBInspectable NSUInteger maxTextLen;
@property (assign, nonatomic) IBInspectable CGPoint textPadding;
@property (strong, nonatomic) IBInspectable NSString *defaultText;
@property (strong, nonatomic) IBInspectable NSString *regex;

@end

@interface FSDateTextField : FSTextField

@property (strong, nonatomic) IBInspectable NSString *dateFormat;
@property (assign, nonatomic) IBInspectable BOOL autoFill;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (strong, nonatomic) NSDate *date;

@end
