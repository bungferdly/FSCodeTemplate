//
//  FSTextField.h
//  Pods
//
//  Created by Ferdly on 1/22/16.
//
//

#import <UIKit/UIKit.h>

@interface FSTextField : UITextField

@property (assign, nonatomic) IBInspectable NSUInteger maxTextLen;
@property (assign, nonatomic) IBInspectable CGPoint textPadding;

@end
