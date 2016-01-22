//
//  FSCollectionViewCell.m
//  Pods
//
//  Created by Ferdly on 1/22/16.
//
//

#import "FSCollectionViewCell.h"

@interface FSCollectionViewCell ()

@property (strong, nonatomic) UIView *highlightView;

@end

@implementation FSCollectionViewCell

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

- (void)setFs_content:(id)fs_content
{
    
}

@end
