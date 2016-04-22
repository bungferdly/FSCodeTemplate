//
//  FSDynamicTableController.h
//  Pods
//
//  Created by Ferdly on 4/9/16.
//
//

#import <UIKit/UIKit.h>

@interface FSDynamicTableController : UITableViewController

@end

@interface UITableView (FS)

- (void)layoutHeaderFooterIfNeeded;
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier nilIdentifier:(NSString *)nilIdentifier;

@end
