//
//  FSLabel.m
//  Pods
//
//  Created by Ferdly on 3/7/16.
//
//

#import "FSLabel.h"
#import <DTCoreText/DTCoreText.h>

@interface FSLabel ()

@property (strong, nonatomic) DTAttributedTextContentView *htmlView;
@property (assign, nonatomic) CGSize htmlContentSize;
@property (assign, nonatomic) CGSize htmlLastSize;
@property (strong, nonatomic) NSArray *defaultConstraintValue;

@end

@implementation FSLabel

- (void)setHtmlText:(NSString *)htmlText
{
    _htmlText = htmlText;
    super.text = nil;
    
    if (!self.htmlView) {
        self.htmlView = [[DTAttributedTextContentView alloc] initWithFrame:self.bounds];
        self.htmlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.htmlView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.htmlView];
    }
    
    CTTextAlignment textAlignment = 0;
    switch (self.textAlignment) {
        case NSTextAlignmentLeft:
            textAlignment = kCTTextAlignmentLeft;
            break;
        case NSTextAlignmentCenter:
            textAlignment = kCTTextAlignmentCenter;
            break;
        case NSTextAlignmentRight:
            textAlignment = kCTTextAlignmentRight;
            break;
        case NSTextAlignmentJustified: textAlignment = kCTTextAlignmentJustified; break;
        case NSTextAlignmentNatural: textAlignment = kCTTextAlignmentNatural; break;
        default: break;
    }
    
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithHTMLData:[htmlText dataUsingEncoding:NSUTF8StringEncoding]
                                                                       options:@{DTDefaultFontFamily : self.font.familyName,
                                                                                 DTDefaultFontSize : @(self.font.pointSize),
                                                                                 DTDefaultTextColor : self.textColor,
                                                                                 DTDefaultTextAlignment : @(textAlignment)}
                                                        documentAttributes:nil];
    self.htmlView.frame = CGRectMake(0, 0, CGFLOAT_WIDTH_UNKNOWN, CGFLOAT_HEIGHT_UNKNOWN);
    [self.htmlView setAttributedString:attrStr];
    _htmlContentSize = [self.htmlView intrinsicContentSize];
    _htmlLastSize = CGSizeZero;
    self.htmlView.frame = self.bounds;
    
    [self invalidateIntrinsicContentSize];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self.htmlView removeFromSuperview];
    self.htmlView = nil;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self.htmlView removeFromSuperview];
    self.htmlView = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.zeroIfEmptyTextConstraints) {
        BOOL zero = self.text.length == 0 && self.htmlText.length == 0;
        for (NSLayoutConstraint *constraint in self.zeroIfEmptyTextConstraints) {
            if (zero) {
                constraint.constant = 0;
            } else {
                NSUInteger index = [self.zeroIfEmptyTextConstraints indexOfObject:constraint];
                constraint.constant = [self.defaultConstraintValue[index] floatValue];
            }
        }
    }
}

- (CGSize)intrinsicContentSize
{
    if (self.htmlView) {
        static Class contentSizeClass = nil;
        if (!contentSizeClass) {
            contentSizeClass = NSClassFromString(@"NSContentSizeLayoutConstraint");
        }
        CGFloat currentWidth = 0;
        for (NSLayoutConstraint *c in self.constraints) {
            if (c.firstAttribute == NSLayoutAttributeWidth && ![c isKindOfClass:contentSizeClass]) {
                currentWidth = self.frame.size.width;
                break;
            }
        }
        if (currentWidth == 0) {
            if (self.preferredMaxLayoutWidth) {
                currentWidth = self.preferredMaxLayoutWidth;
            } else {
                currentWidth = self.htmlContentSize.width;
            }
        }
        if (self.htmlLastSize.width != currentWidth) {
            if (self.htmlContentSize.width != currentWidth) {
                self.htmlLastSize = [self.htmlView suggestedFrameSizeToFitEntireStringConstraintedToWidth:currentWidth];
            } else {
                self.htmlLastSize = self.htmlContentSize;
            }
            _htmlLastSize.width = currentWidth;
        }
        return self.htmlLastSize;
    } else {
        return [super intrinsicContentSize];
    }
}

- (void)setZeroIfEmptyTextConstraints:(NSArray *)zeroIfEmptyTextConstraints
{
    _zeroIfEmptyTextConstraints = zeroIfEmptyTextConstraints;
    self.defaultConstraintValue = [zeroIfEmptyTextConstraints valueForKey:@"constant"];
}

@end

@interface DTCoreTextLayoutFrame(FS_m)

- (void)_buildLines;

@end

@implementation DTCoreTextLayoutFrame(FS)

- (CGRect)frame
{
    if (!_lines)
    {
        [self _buildLines];
    }
    
    if (![self.lines count])
    {
        return CGRectZero;
    }
    
    if (_frame.size.height == CGFLOAT_HEIGHT_UNKNOWN)
    {
        // actual frame is spanned between first and last lines
        DTCoreTextLayoutLine *lastLine = [_lines lastObject];
        
        _frame.size.height = ceil((CGRectGetMaxY(lastLine.frame) - _frame.origin.y + 1.5f));
    }
    
    if (_frame.size.width == CGFLOAT_WIDTH_UNKNOWN)
    {
        // actual frame width is maximum value of lines
        CGFloat maxWidth = 0;
        
        for (DTCoreTextLayoutLine *oneLine in _lines)
        {
            CGFloat lineWidthFromFrameOrigin = CGRectGetWidth(oneLine.frame);
            maxWidth = MAX(maxWidth, lineWidthFromFrameOrigin);
        }
        
        _frame.size.width = ceil(maxWidth);
    }
    
    return _frame;
}

@end
