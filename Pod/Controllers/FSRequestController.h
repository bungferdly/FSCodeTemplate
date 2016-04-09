//
//  FSRequestController.h
//  Pods
//
//  Created by Ferdly on 4/9/16.
//
//

#import <UIKit/UIKit.h>

@protocol FSRequestControllerDelegate;
@class FSRequest, FSResponse, FSRequestView;

@interface FSRequestController : UIViewController

@property (strong, nonatomic) IBOutlet FSRequestView *errorView;
@property (strong, nonatomic) IBOutlet FSRequestView *emptyView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *pagingAI;

@property (readonly, nonatomic) FSRequest *request;
@property (readonly, nonatomic) FSResponse *response;
@property (readonly, nonatomic) NSUInteger currentPage;
@property (assign, nonatomic) BOOL viewNoHidden;
@property (assign, nonatomic) int pagingObjectsCount;
@property (assign, nonatomic) BOOL autoReload;

+ (instancetype)controllerWithChildController:(UIViewController <FSRequestControllerDelegate> *)childController;
- (IBAction)requestData;

+ (void)setDefaultEmptyNIBName:(NSString *)defaultEmptyNIBName;
+ (void)setDefaultErrorNIBName:(NSString *)defaultErrorNIBName;

@end

@protocol FSRequestControllerDelegate <NSObject>

@optional
- (void)requestControllerWillStartRequest:(FSRequestController *)controller;
- (void)requestControllerDidReceiveResponse:(FSRequestController *)controller;

@end

@interface UIViewController (WSCRequestController)

- (FSRequestController *)requestController;

@end

@interface FSRequestView : UIView

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UIButton *reloadButton;

@end
