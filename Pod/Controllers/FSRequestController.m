//
//  FSRequestController.m
//  Pods
//
//  Created by Ferdly on 4/9/16.
//
//

#import "FSRequestController.h"
#import "FSCodeTemplate.h"

NSString *__fsDefaultEmptyNIBName = nil;
NSString *__fsDefaultErrorNIBName = nil;

typedef enum : int {
    FSRequestContentModeNormal,
    FSRequestContentModeEmpty,
    FSRequestContentModeError,
} FSRequestContentMode;

@interface FSRequestController ()

@property (assign, nonatomic) BOOL requesting;
@property (strong, nonatomic) NSTimer *requestTimer;
@property (assign, nonatomic) BOOL hitMaxPage;
@property (assign, nonatomic) NSUInteger currentPage;
@property (strong, nonatomic) FSResponse *response;
@property (assign, nonatomic) FSRequestContentMode contentMode;

@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) UIViewController<FSRequestControllerDelegate> *childController;
@property (weak, nonatomic) UIScrollView *childView;

@end

@implementation FSRequestController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    self.request = [[FSRequest alloc] init];
    return self;
}

- (instancetype)init
{
    self = [super init];
    self.request = [[FSRequest alloc] init];
    return self;
}

+ (instancetype)controllerWithChildController:(UIViewController<FSRequestControllerDelegate> *)childController
{
    FSRequestController *vc = [self fs_newController];
    [vc addChildViewController:childController];
    return vc;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.autoReload) {
        [self requestData];
    }
}

- (UIViewController<FSRequestControllerDelegate> *)childController
{
    return [self.childViewControllers firstObject];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (!self.childController) {
        [self setContentMode:FSRequestContentModeEmpty withInfo:nil];
        return;
    }
    
    [self.view addSubview:self.childController.view];
    self.childController.view.frame = self.view.bounds;
    self.childController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    if (![self.childController respondsToSelector:@selector(requestControllerWillStartRequest:)] && !self.request.path) {
        return;
    }
    
    id vc = self.childController;
    if (FSKindOf([vc view], UIScrollView)) {
        self.childView = [vc view];
    } else {
        [[vc view] fs_subviewsMapping:^(UIView *view, BOOL *stop) {
            if (FSKindOf(view, UIScrollView)) {
                self.childView = (UIScrollView *)view;
                *stop = YES;
            }
        }];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(requestData) forControlEvents:UIControlEventValueChanged];
    if ([self.childController respondsToSelector:@selector(setRefreshControl:)]) {
        [(id)self.childController setRefreshControl:self.refreshControl];
    } else {
        [self.childView insertSubview:self.refreshControl atIndex:0];
    }
    
    self.view.backgroundColor = self.childController.view.backgroundColor;
    
    UIView *parentView = self.childView;
    while (parentView && parentView != self.view) {
        parentView.backgroundColor = [UIColor clearColor];
        parentView = parentView.superview;
    }
    
    [self.childView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    [self requestData];
}

- (UINavigationItem *)navigationItem
{
    return [self childController].navigationItem ?: [super navigationItem];
}

- (NSArray<UIBarButtonItem *> *)toolbarItems
{
    return [self childController].toolbarItems ?: [super toolbarItems];
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    return [self.childController conformsToProtocol:aProtocol];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (self.pagingObjectsCount && object == self.childView && self.response.arrayObject.count > 0 && !self.requesting
        && !self.hitMaxPage && self.childView.contentOffset.y > self.childView.contentSize.height - self.childView.frame.size.height - 200) {
        [self requestDataAtPage:self.currentPage +1];
    }
}

- (void)dealloc
{
    [self.childView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)requestData
{
    [self requestDataAtPage:0];
}

- (void)requestDataAtPage:(NSUInteger)page
{
    if (self.requesting) {
        return;
    }
    
    NSUInteger currentPage = self.currentPage;
    self.currentPage = page;
    self.request.errorHidden = page == 0;
    
    if ([self.childController respondsToSelector:@selector(requestControllerWillStartRequest:)]) {
        [self.childController requestControllerWillStartRequest:self];
    }
    if (!self.request.path.length) {
        self.requesting = NO;
        return;
    }
    
    self.contentMode = FSRequestContentModeNormal;
    self.requesting = YES;
    
    [self.request startWithCompletion:^(FSResponse *response) {
        
        BOOL hideChildView = !self.viewNoHidden && response.error != nil && !self.response.object && page == 0;
        FSRequestContentMode mode = hideChildView ? FSRequestContentModeError : FSRequestContentModeNormal;
        [self setContentMode:mode withInfo:response.error.localizedDescription];
        self.requesting = NO;
        
        if (response && !response.error) {
            if (self.pagingObjectsCount) {
                self.hitMaxPage = response.arrayObject.count < self.pagingObjectsCount;
                UIEdgeInsets insets = self.childView.contentInset;
                insets.bottom = self.hitMaxPage ? 0 : 50;
                self.childView.contentInset = insets;
            }
            if (page == 0) {
                self.response = response;
            } else {
                [self.response.arrayObject addObjectsFromArray:response.arrayObject];
            }
            if ([self.childController respondsToSelector:@selector(requestControllerDidReceiveResponse:)]) {
                [self.childController requestControllerDidReceiveResponse:self];
            }
            if ([self.childView respondsToSelector:@selector(reloadData)]) {
                [(id)self.childView reloadData];
            }
        } else {
            self.currentPage = currentPage;
        }
    }];
}

- (void)setRequesting:(BOOL)requesting
{
    _requesting = requesting;
    [self.requestTimer invalidate];
    self.requestTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(reloadRefreshControl) userInfo:nil repeats:NO];
}

- (void)reloadRefreshControl
{
    if (self.currentPage == 0) {
        if (self.requesting && !self.refreshControl.isRefreshing) {
            [self.refreshControl beginRefreshing];
            self.childView.contentOffset = CGPointMake(0, -self.childView.contentInset.top);
        } else if (!self.requesting && self.refreshControl.isRefreshing) {
            [self.refreshControl endRefreshing];
        }
    } else {
        if (self.requesting && !self.pagingAI.isAnimating) {
            [self.pagingAI startAnimating];
        } else if (!self.requesting && self.pagingAI.isAnimating) {
            [self.pagingAI stopAnimating];
        }
    }
    self.requestTimer = nil;
}

- (void)setContentMode:(FSRequestContentMode)mode
{
    [self setContentMode:mode withInfo:nil];
}

- (void)setContentMode:(FSRequestContentMode)mode withInfo:(NSString *)info
{
    _contentMode = mode;
    if (_errorView || mode == FSRequestContentModeError) {
        self.errorView.hidden = mode != FSRequestContentModeError;
        self.errorView.messageLabel.text = info;
    }
    if (_emptyView || mode == FSRequestContentModeEmpty) {
        self.emptyView.hidden = mode != FSRequestContentModeEmpty;
    }
    self.childController.view.hidden = (mode == FSRequestContentModeError && self.errorView.reloadButton) ||
                                        (mode == FSRequestContentModeEmpty && self.emptyView.reloadButton);
}

- (FSRequestView *)errorView
{
    if (!_errorView && __fsDefaultErrorNIBName) {
        _errorView = [[[NSBundle mainBundle] loadNibNamed:__fsDefaultErrorNIBName owner:self options:nil] firstObject];
        _errorView.frame = self.view.bounds;
        _errorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:_errorView atIndex:0];
    }
    return _errorView;
}

- (FSRequestView *)emptyView
{
    if (!_emptyView && __fsDefaultEmptyNIBName) {
        _emptyView = [[[NSBundle mainBundle] loadNibNamed:__fsDefaultEmptyNIBName owner:self options:nil] firstObject];
        _emptyView.frame = self.view.bounds;
        _emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _emptyView;
}

+ (void)setDefaultEmptyNIBName:(NSString *)defaultEmptyNIBName
{
    __fsDefaultEmptyNIBName = defaultEmptyNIBName;
}

+ (void)setDefaultErrorNIBName:(NSString *)defaultErrorNIBName
{
    __fsDefaultErrorNIBName = __fsDefaultErrorNIBName;
}

@end

@implementation UIViewController (FSRequestController)

- (FSRequestController *)requestController
{
    id parentVC = self.parentViewController;
    while (parentVC && !FSKindOf(parentVC, FSRequestController)) {
        parentVC = [parentVC parentViewController];
    }
    return parentVC;
}

@end
