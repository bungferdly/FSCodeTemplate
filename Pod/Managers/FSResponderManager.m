//
//  FSEditingManager.m
//  FS
//
//  Created by Ferdly Sethio on 10/12/15.
//  Copyright © 2015 2359 Media Pte Ltd. All rights reserved.
//

#import "FSResponderManager.h"
#import "FSCodeTemplate.h"

@interface UIView (FSResponderManager)

- (id)fs_getFirstResponder;
- (id)fs_getNextResponder;
- (id)fs_getPrevResponder;
- (UIScrollView *)fs_getParentScrollView;

@end

@interface FSResponderManager ()

@property (strong, nonatomic) UITapGestureRecognizer *tapGR;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *prevButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) id currentResponder;
@property (weak, nonatomic) id nextResponder;
@property (weak, nonatomic) id prevResponder;

@end

@implementation FSResponderManager

- (void)didLoad
{
    [[NSBundle mainBundle] loadNibNamed:@"FSResponderToolbar" owner:self options:nil];
    
    self.tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeFrameKeyboard:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)willShowKeyboard:(NSNotification *)notification
{
    [self.window addGestureRecognizer:self.tapGR];
    self.currentResponder = [self.window fs_getFirstResponder];
    [self recalculateResponders];
    [self calculateBottomInsetScrollView:notification.userInfo];
}

- (void)willChangeFrameKeyboard:(NSNotification *)notification
{
    [self calculateBottomInsetScrollView:notification.userInfo];
}

- (void)willHideKeyboard:(NSNotification *)notification
{
    [self.window removeGestureRecognizer:self.tapGR];
    self.currentResponder = nil;
    self.nextResponder = nil;
    self.prevResponder = nil;
}

- (void)didBeginEditing:(NSNotification *)notification
{
    self.currentResponder = notification.object;
    [self recalculateResponders];
}

- (void)recalculateResponders
{
    if (!self.currentResponder) {
        return;
    }
    
    self.nextResponder = [self.currentResponder fs_getNextResponder];
    self.prevResponder = [self.currentResponder fs_getPrevResponder];
    
    if (self.prevResponder || self.nextResponder) {
        self.prevButton.enabled = self.prevResponder != nil;
        self.nextButton.enabled = self.nextResponder != nil && ![self.nextResponder isKindOfClass:[UIButton class]];
        [self.currentResponder setInputAccessoryView:self.toolbar];
    }
    
    if (self.nextResponder) {
        [self.currentResponder addTarget:self action:@selector(gotoNextResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
    } else {
        [self.currentResponder addTarget:self action:@selector(endEditing) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
}

- (void)gotoResponder:(id)responder
{
    if (![self.currentResponder canResignFirstResponder]) {
        return;
    }
    
    self.currentResponder = responder;
    [self.currentResponder becomeFirstResponder];
    [[self.currentResponder fs_getParentScrollView] scrollRectToVisible:[self.currentResponder superview].frame animated:YES];
}

- (void)calculateBottomInsetScrollView:(NSDictionary *)userInfo
{
    UIScrollView *scrollView = [self.currentResponder fs_getParentScrollView];
    if (![scrollView isMemberOfClass:[UIScrollView class]]) {
        return;
    }
    
    UIEdgeInsets inset = scrollView.contentInset;
    CGRect keyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardRectInView = [scrollView.window convertRect:keyboardRect toView:scrollView.superview];
    inset.bottom = CGRectGetMaxY(scrollView.frame) - CGRectGetMinY(keyboardRectInView);
    
    if (scrollView.contentInset.bottom != inset.bottom) {
        scrollView.contentInset = inset;
        if ([self.currentResponder superview] != scrollView) {
            [scrollView scrollRectToVisible:[self.currentResponder superview].frame animated:NO];
        }
        
        UIEdgeInsets scrollerInset = scrollView.scrollIndicatorInsets;
        scrollerInset.bottom = inset.bottom;
        scrollView.scrollIndicatorInsets = scrollerInset;
    }
}

- (IBAction)gotoPrevResponder
{
    [self gotoResponder:self.prevResponder];
}

- (IBAction)gotoNextResponder
{
    [self gotoResponder:self.nextResponder];
}

- (IBAction)endEditing
{
    [self.window endEditing:YES];
}

@end

@implementation UIView (FSResponderManager)

- (id)fs_getFirstResponder
{
    if (self.isFirstResponder) {
        return self;
    } else {
        for (UIView *subview in self.subviews) {
            id theView = [subview fs_getFirstResponder];
            if (theView) {
                return theView;
            }
        }
    }
    return nil;
}

- (void)fs_mapResponders:(void(^)(id responder))map
{
    if (self.canBecomeFirstResponder) {
        map(self);
    }
    for (id subview in self.subviews) {
        [subview fs_mapResponders:map];
    }
}

- (UIScrollView *)fs_getParentScrollView
{
    id tableView = self.superview;
    while (tableView && ![tableView isKindOfClass:[UITableView class]]) {
        tableView = [tableView superview];
    }
    if (!tableView) {
        tableView = self.superview;
        while (tableView && ![tableView isKindOfClass:[UIScrollView class]]) {
            tableView = [tableView superview];
        }
    }
    return tableView;
}

- (id)fs_getNextResponder
{
    id tableView = [self fs_getParentScrollView];
    __block UIView *nextResponder = nil;
    __block CGPoint minPos = [self convertPoint:CGPointZero toView:self.window];
    __block CGPoint maxPos = CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX);
    [tableView fs_mapResponders:^(UIView *responder) {
        CGPoint pos = [responder convertPoint:CGPointZero toView:responder.window];
        if (pos.y > minPos.y || (pos.y == minPos.y && pos.x > minPos.x)) {
            if (pos.y < maxPos.y || (pos.y == maxPos.y && pos.x < maxPos.x)) {
                maxPos = pos;
                nextResponder = responder;
            }
        }
    }];
    return nextResponder;
}

- (id)fs_getPrevResponder
{
    id tableView = [self fs_getParentScrollView];
    __block UIView *prevResponder = nil;
    __block CGPoint minPos = CGPointMake(-CGFLOAT_MAX, -CGFLOAT_MAX);
    __block CGPoint maxPos = [self convertPoint:CGPointZero toView:self.window];
    [tableView fs_mapResponders:^(UIView *responder) {
        CGPoint pos = [responder convertPoint:CGPointZero toView:responder.window];
        if (pos.y < maxPos.y || (pos.y == maxPos.y && pos.x < maxPos.x)) {
            if (pos.y > minPos.y || (pos.y == minPos.y && pos.x > minPos.x)) {
                minPos = pos;
                prevResponder = responder;
            }
        }
    }];
    return prevResponder;
}

@end

@implementation FSResponderButton

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    return YES;
}

@end
