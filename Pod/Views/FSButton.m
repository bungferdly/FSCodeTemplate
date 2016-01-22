//
//  FSButton.m
//  Wusic
//
//  Created by Ferdly on 12/16/15.
//  Copyright © 2015 2359 Media Pte Ltd. All rights reserved.
//

#import "FSButton.h"

@interface FSButton ()

@property (strong, nonatomic) UIView *highlightView;

@end

@implementation FSButton

@synthesize highlighted = _highlighted;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.highlightView = [[UIView alloc] initWithFrame:self.bounds];
    self.highlightView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.highlightView.backgroundColor = [UIColor blackColor];
    self.highlightView.alpha = 0;
    self.highlightView.userInteractionEnabled = NO;
    [self addSubview:self.highlightView];
}

- (void)setHighlighted:(BOOL)highlighted
{
    _highlighted = highlighted;
    if (highlighted) {
        self.highlightView.alpha = 0.2;
    } else if (self.alpha != 0){
        [UIView animateWithDuration:0.2 animations:^{
            self.highlightView.alpha = 0;
        }];
    }
}

@end
