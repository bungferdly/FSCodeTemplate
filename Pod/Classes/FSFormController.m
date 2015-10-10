//
//  FSFormController.m
//  NHG
//
//  Created by Ferdly Sethio on 10/10/15.
//  Copyright © 2015 2359 Media Pte Ltd. All rights reserved.
//

#import "FSFormController.h"

@interface FSFormController () <UITextFieldDelegate>

@property (strong, nonatomic) UIButton *commitButton;
@property (strong, nonatomic) UIControl *currentResponder;

@end

@implementation FSFormController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
    [self.view addGestureRecognizer:tapGR];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reconfigControls];
}

- (void)reconfigControls
{
    UIButton *commitButton = self.commitButton;
    
    [self  controlMapping:^(UIControl *control, BOOL *stop) {
        if ([control isKindOfClass:[UITextField class]]) {
            [(UITextField *)control setDelegate:self];
        } else if ([control isKindOfClass:[UIButton class]]) {
            self.commitButton = (UIButton *)control;
        }
        if (control.tag > self.commitButton.tag) {
            self.commitButton = nil;
        }
    }];
    if (!commitButton || commitButton != self.commitButton) {
        [self.commitButton addTarget:self action:@selector(commit) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)controlMapping:(void (^)(UIControl *control, BOOL *stop))map
{
    [self controlMapping:map withParent:self.view];
}

- (void)controlMapping:(void (^)(UIControl *control, BOOL *stop))map withParent:(UIView *)parent
{
    BOOL stop = NO;
    for (UIControl *con in parent.subviews) {
        if ([con isKindOfClass:[UIControl class]] && con.tag > 0) {
            map(con, &stop);
        } else {
            [self controlMapping:map withParent:con];
        }
        if (stop) {
            return;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self nextResponder:textField];
    return YES;
}

- (void)nextResponder:(UIControl *)currentResponder
{
    [self controlMapping:^(UIControl *control, BOOL *stop) {
        if (control.tag == currentResponder.tag + 1) {
            if ([control isKindOfClass:[UITextField class]]) {
                [control becomeFirstResponder];
            } else if (control == self.commitButton){
                [control sendActionsForControlEvents:UIControlEventTouchUpInside];
            } else {
                [currentResponder resignFirstResponder];
            }
            *stop = YES;
        }
    }];
}

- (BOOL)resignFirstResponder
{
    [self controlMapping:^(UIControl *control, BOOL *stop) {
        [control resignFirstResponder];
    }];
    return [super resignFirstResponder];
}

- (void)commit
{
    [self resignFirstResponder];
}

@end
