//
//  FSTableViewCell.h
//  Pods
//
//  Created by Ferdly on 12/21/15.
//
//

#import <UIKit/UIKit.h>

@interface FSTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *subtitleLabel;

+ (CGFloat)heightForTableView:(UITableView *)tableView andContent:(id)content;

@end
