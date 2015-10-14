//
//  FSSegmentedControl.h
//  Pods
//
//  Created by Ferdly Sethio on 9/23/15.
//
//

#import <UIKit/UIKit.h>

@interface FSSegmentedControl : UIControl

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *stickerLeftLC;
@property (strong, nonatomic) IBOutlet UIView *stickerView;
@property (assign, nonatomic) CGFloat value;

@end
