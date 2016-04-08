//
//  FSViewController.h
//  Pods
//
//  Created by Ferdly on 4/7/16.
//
//

#import <UIKit/UIKit.h>

@class FSRequest, FSResponse, FSEmptyView;

@interface FSViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) IBInspectable BOOL navigationBarHidden;
@property (assign, nonatomic) BOOL viewNoHidden;
@property (strong, nonatomic) IBOutlet FSEmptyView *emptyContentView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (readonly, nonatomic) FSRequest *request;
@property (readonly, nonatomic) FSResponse *response;

- (void)reloadView;

@end

@interface FSEmptyView : UIView

@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIButton *reloadButton;
@property (strong, nonatomic) NSString *emptyText;

@end
