//
//  FSLabel.h
//  Pods
//
//  Created by Ferdly on 3/7/16.
//
//

#import <UIKit/UIKit.h>

@interface FSLabel : UILabel

@property (strong, nonatomic) NSString *htmlText;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *zeroIfEmptyTextConstraints;

@end
