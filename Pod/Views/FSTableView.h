//
//  FSTableView.h
//  Pods
//
//  Created by Ferdly on 1/20/16.
//
//

#import <UIKit/UIKit.h>

@interface FSTableView : UITableView

@property (strong, nonatomic) IBOutlet UIView *staticTableHeaderView;
@property (assign, nonatomic) IBInspectable BOOL dynamicHeight;

@end
