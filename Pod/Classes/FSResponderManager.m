//
//  FSEditingManager.m
//  FS
//
//  Created by Ferdly Sethio on 10/12/15.
//  Copyright © 2015 2359 Media Pte Ltd. All rights reserved.
//

#import "FSResponderManager.h"

@interface UIView (FSResponderManager)

- (id)fs_getFirstResponder;
- (id)fs_getNextResponder;

@end

@interface FSResponderManager ()

@property (strong, nonatomic) UITapGestureRecognizer *tapGR;
@property (weak, nonatomic) id currentResponder;
@property (weak, nonatomic) id nextResponder;

@end

@implementation FSResponderManager

- (void)didLoad
{
    self.tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowKeyboard) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideKeyboard) name:UIKeyboardDidHideNotification object:nil];
}

- (void)willShowKeyboard
{
    [self.window addGestureRecognizer:self.tapGR];
    self.currentResponder = [self.window fs_getFirstResponder];
    [self calculateNextReponder];
}

- (void)didHideKeyboard
{
    [self.window removeGestureRecognizer:self.tapGR];
}

- (void)calculateNextReponder
{
    if ([self.currentResponder isKindOfClass:[UITextField class]]) {
        self.nextResponder = [self.currentResponder fs_getNextResponder];
        if (self.nextResponder) {
            [self.currentResponder addTarget:self action:@selector(gotoNextResponder) forControlEvents:UIControlEventEditingDidEndOnExit];
        } else {
            [self.currentResponder addTarget:self action:@selector(endEditing) forControlEvents:UIControlEventEditingDidEndOnExit];
        }
    }
}

- (void)gotoNextResponder
{
    self.currentResponder = self.nextResponder;
    self.nextResponder = nil;
    [self.currentResponder becomeFirstResponder];
    [self calculateNextReponder];
}

- (void)endEditing
{
    [self.window endEditing:YES];
}

@end

@implementation UIView (FSControlManager)

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

- (id)fs_getNextResponder
{
    id tableView = self.superview;
    while (tableView && ![tableView isKindOfClass:[UITableView class]]) {
        tableView = [tableView superview];
    }
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
