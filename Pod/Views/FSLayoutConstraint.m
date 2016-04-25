//
//  FSLayoutConstraint.m
//  Virsagi
//
//  Created by Ferdly on 4/25/16.
//  Copyright © 2016 2359 Media Pte Ltd. All rights reserved.
//

#import "FSLayoutConstraint.h"
#import "FSCodeTemplate.h"

@interface FSLayoutConstraint ()

@property (assign, nonatomic) CGFloat tempConstant;

@end

@implementation FSLayoutConstraint

- (void)awakeFromNib
{
    [super awakeFromNib];
    _tempConstant = super.constant;
    FSObserve(self.firstItem, @"hidden", [self recalculate]);
    FSObserve(FSKindOf(self.firstItem, UILabel), @"text", [self recalculate]);
    [self recalculate];
}

- (void)setConstant:(CGFloat)constant
{
    [super setConstant:constant];
    _tempConstant = constant;
}

- (void)recalculate
{
    BOOL hidden = ([self.firstItem isHidden] ||
                   (FSKindOf(self.firstItem, UILabel) && ![self.firstItem text].length));
    
    super.constant = hidden ? 0 : _tempConstant;
}

@end
