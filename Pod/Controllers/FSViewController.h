//
//  FSViewController.h
//  Pods
//
//  Created by Ferdly on 4/7/16.
//
//

#import <UIKit/UIKit.h>

@class FSRequest, FSResponse, FSErrorView;

@interface FSViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) IBInspectable BOOL navigationBarHidden;
@property (assign, nonatomic) BOOL viewNoHidden;
@property (strong, nonatomic) IBOutlet FSErrorView *errorView;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (readonly, nonatomic) FSRequest *request;
@property (readonly, nonatomic) FSResponse *response;

- (IBAction)reloadView;

+ (void)setDefaultEmptyNIBName:(NSString *)defaultEmptyNIBName;
+ (void)setDefaultErrorNIBName:(NSString *)defaultErrorNIBName;

@end

@interface FSErrorView : UIView

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIButton *reloadButton;

@end
