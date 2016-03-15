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
            self.htmlView.frame = CGRectMake(0, 0, CGFLOAT_WIDTH_UNKNOWN, CGFLOAT_HEIGHT_UNKNOWN);
            break;
        case NSTextAlignmentCenter:
            textAlignment = kCTTextAlignmentCenter;
            self.htmlView.frame = CGRectMake((-CGFLOAT_WIDTH_UNKNOWN+self.bounds.size.width)/2, 0, CGFLOAT_WIDTH_UNKNOWN, CGFLOAT_HEIGHT_UNKNOWN);
            break;
        case NSTextAlignmentRight:
            textAlignment = kCTTextAlignmentRight;
            self.htmlView.frame = CGRectMake(-CGFLOAT_WIDTH_UNKNOWN+self.bounds.size.width, 0, CGFLOAT_WIDTH_UNKNOWN, CGFLOAT_HEIGHT_UNKNOWN);
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
    [self.htmlView setAttributedString:attrStr];
    
    _htmlContentSize = [self.htmlView intrinsicContentSize];
    _htmlContentSize.width += self.htmlView.frame.origin.x;
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

- (CGSize)intrinsicContentSize
{
    if (self.htmlView) {
        for (NSLayoutConstraint *c in self.constraints) {
            if (c.firstAttribute == NSLayoutAttributeWidth) {
                return [self.htmlView suggestedFrameSizeToFitEntireStringConstraintedToWidth:self.frame.size.width];
            }
        }
        if (self.preferredMaxLayoutWidth) {
            return [self.htmlView suggestedFrameSizeToFitEntireStringConstraintedToWidth:self.preferredMaxLayoutWidth];
        }
        return self.htmlContentSize;
    } else {
        return [super intrinsicContentSize];
    }
}

@end
