//
//  FSTableViewCell.m
//  Pods
//
//  Created by Ferdly on 12/21/15.
//
//

#import "FSTableViewCell.h"
#import "UIView+FS.h"

@interface FSTableViewCell ()

@property (strong, nonatomic) UIView *highlightView;

@end

@implementation FSTableViewCell

@synthesize highlighted = _highlighted, detailTextLabel = _fsDetailTextLabel, textLabel = _fsTextLabel, imageView = _fsImageView, accessoryView = _fsAccessoryView;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (self.selectionStyle != UITableViewCellSelectionStyleNone) {
        
        self.highlightView = [[UIView alloc] initWithFrame:self.bounds];
        self.highlightView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.highlightView.backgroundColor = [UIColor blackColor];
        self.highlightView.alpha = 0;
        self.highlightView.userInteractionEnabled = NO;
        [self addSubview:self.highlightView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
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

- (void)callDelegate:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(tableViewCell:didSelectView:)]) {
        [self.delegate tableViewCell:self didSelectView:sender];
    }
}

@end
