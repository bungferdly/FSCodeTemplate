//
//  FSAlertController.h
//  Pods
//
//  Created by Ferdly Sethio on 11/3/15.
//
//

#import <Foundation/Foundation.h>

@class  FSAlertController;

typedef void (^FSAlertControllerCompletionBlock) (FSAlertController *__nonnull controller, NSInteger buttonIndex);

@interface FSAlertController : UIViewController

+ (_Nullable instancetype)showWithMessage:(nullable NSString *)message;
+ (_Nullable instancetype)showWithTitle:(nullable NSString *)title message:(nullable NSString *)message;
+ (_Nullable instancetype)showWithTitle:(nullable NSString *)title message:(nullable NSString *)message
                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle
                    otherButtonTitles:(nullable NSArray *)otherButtonTitles container:(nullable id)container tapBlock:(nullable FSAlertControllerCompletionBlock)tapBlock;
+ (_Nullable instancetype)showLoadingWithStatus:(NSString *)status;
+ (_Nullable instancetype)showSuccessWithStatus:(NSString *)status;
+ (_Nullable instancetype)showErrorWithStatus:(NSString *)status;

+ (void)dismiss;
+ (void)setAsDefaultAlertController;

@property(nonatomic, readonly) NSInteger cancelButtonIndex;
@property(nonatomic, readonly) NSInteger destructiveButtonIndex;
@property(nonatomic, readonly) NSInteger firstOtherButtonIndex;

@end
