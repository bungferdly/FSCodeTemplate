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
    }
    self.htmlView.frame = self.bounds;
    [self addSubview:self.htmlView];
    
    CTTextAlignment textAlignment = 0;
    switch (self.textAlignment) {
        case NSTextAlignmentLeft: textAlignment = kCTTextAlignmentLeft; break;
        case NSTextAlignmentCenter: textAlignment = kCTTextAlignmentCenter; break;
        case NSTextAlignmentRight: textAlignment = kCTTextAlignmentRight; break;
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
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self.htmlView removeFromSuperview];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    [super setAttributedText:attributedText];
    [self.htmlView removeFromSuperview];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.htmlView) {
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize
{
    return self.htmlView ? [self.htmlView intrinsicContentSize] : [super intrinsicContentSize];
}

@end
