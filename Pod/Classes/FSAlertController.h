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

@interface FSAlertController : NSObject

+ (nonnull instancetype)showWithMessage:(nullable NSString *)message;
+ (nonnull instancetype)showWithTitle:(nullable NSString *)title message:(nullable NSString *)message;
+ (nonnull instancetype)showWithTitle:(nullable NSString *)title message:(nullable NSString *)message
                    cancelButtonTitle:(nullable NSString *)cancelButtonTitle destructiveButtonTitle:(nullable NSString *)destructiveButtonTitle
                    otherButtonTitles:(nullable NSArray *)otherButtonTitles container:(nullable id)container tapBlock:(nullable FSAlertControllerCompletionBlock)tapBlock;

@property(nonatomic, readonly) NSInteger cancelButtonIndex;
@property(nonatomic, readonly) NSInteger destructiveButtonIndex;
@property(nonatomic, readonly) NSInteger firstOtherButtonIndex;

@end
