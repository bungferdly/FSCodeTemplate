//
//  FSTableViewCell.h
//  Pods
//
//  Created by Ferdly on 12/21/15.
//
//

#import <UIKit/UIKit.h>

@interface FSTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailTextLabel;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak  , nonatomic) IBOutlet id delegate;

@end
