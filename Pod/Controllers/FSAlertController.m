//
//  FSAlertController.m
//  Pods
//
//  Created by Ferdly Sethio on 11/3/15.
//
//

#import "FSAlertController.h"
#import "FSCodeTemplate.h"
#import <UIAlertController+Blocks/UIAlertController+Blocks.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>

@interface FSAlertController ()

@property(assign, nonatomic) NSInteger cancelButtonIndex;
@property(assign, nonatomic) NSInteger destructiveButtonIndex;
@property(assign, nonatomic) NSInteger firstOtherButtonIndex;

@end

@implementation FSAlertController

+ (instancetype)showWithMessage:(NSString *)message
{
    return [self showWithTitle:nil message:message];
}

+ (instancetype)showWithTitle:(NSString *)title message:(NSString *)message
{
    return [self showWithTitle:title message:message cancelButtonTitle:@"Dismiss" destructiveButtonTitle:nil
             otherButtonTitles:nil container:nil tapBlock:nil];
}

+ (instancetype)showWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle
       destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles
                    container:(id)container tapBlock:(FSAlertControllerCompletionBlock)tapBlock
{
    FSAlertController *alertController = [[FSAlertController alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (FSOSVersion >= 8) {
            
            //iOS 9 bug, the action sheet is hidden behind keyboard
            if (FSOSVersion >= 9 && container) {
                [[UIViewController fs_topViewController].view endEditing:YES];
            }
            
            [UIAlertController showInViewController:[UIViewController fs_topViewController] withTitle:title message:message
                                     preferredStyle:container ? UIAlertControllerStyleActionSheet : UIAlertControllerStyleAlert
                                  cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles
                 popoverPresentationControllerBlock:^(UIPopoverPresentationController * _Nonnull popover) {
                     if ([container isKindOfClass:[UIBarButtonItem class]]) {
                         popover.barButtonItem = container;
                     } else if ([container isKindOfClass:[UIView class]]){
                         popover.sourceRect = [container bounds];
                         popover.sourceView = container;
                     }
                 } tapBlock:^(UIAlertController * _Nonnull controller, UIAlertAction * _Nonnull action, NSInteger buttonIndex) {
                     if (tapBlock) {
                         alertController.cancelButtonIndex = controller.cancelButtonIndex;
                         alertController.destructiveButtonIndex = controller.destructiveButtonIndex;
                         alertController.firstOtherButtonIndex = controller.firstOtherButtonIndex;
                         tapBlock(alertController, buttonIndex);
                     }
                 }];
        } else if (!container){
            [UIAlertView showWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles
                              tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                                  if (tapBlock) {
                                      alertController.cancelButtonIndex = alertView.cancelButtonIndex;
                                      alertController.destructiveButtonIndex = -1;
                                      alertController.firstOtherButtonIndex = alertView.firstOtherButtonIndex;
                                      tapBlock(alertController, buttonIndex);
                                  }
                              }];
        } else if ([container isKindOfClass:[UIBarButtonItem class]]){
            static UIActionSheet *lastActionSheet = nil;
            if (lastActionSheet) {
                [lastActionSheet dismissWithClickedButtonIndex:lastActionSheet.cancelButtonIndex animated:NO];
            }
            lastActionSheet = [UIActionSheet showFromBarButtonItem:container animated:YES withTitle:title cancelButtonTitle:cancelButtonTitle
                                            destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles
                                                          tapBlock:^(UIActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                                                              lastActionSheet = nil;
                                                              if (tapBlock) {
                                                                  alertController.cancelButtonIndex = actionSheet.cancelButtonIndex;
                                                                  alertController.destructiveButtonIndex = actionSheet.destructiveButtonIndex;
                                                                  alertController.firstOtherButtonIndex = actionSheet.firstOtherButtonIndex;
                                                                  tapBlock(alertController, buttonIndex);
                                                              }
                                                          }];
        } else if ([container isKindOfClass:[UIView class]]) {
            [UIActionSheet showFromRect:[container bounds] inView:container animated:YES withTitle:title cancelButtonTitle:cancelButtonTitle
                 destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:otherButtonTitles
                               tapBlock:^(UIActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
                                   if (tapBlock) {
                                       alertController.cancelButtonIndex = actionSheet.cancelButtonIndex;
                                       alertController.destructiveButtonIndex = actionSheet.destructiveButtonIndex;
                                       alertController.firstOtherButtonIndex = actionSheet.firstOtherButtonIndex;
                                       tapBlock(alertController, buttonIndex);
                                   }
                               }];
        }
    });
    
    return alertController;
}

@end
