//
//  FSWebView.h
//  Pods
//
//  Created by Ferdly on 1/26/16.
//
//

#import <UIKit/UIKit.h>

@interface FSWebView : UIWebView

@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headerTopConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *footerBottomConstraint;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSString *filename;

@end
