//
//  FSViewController.m
//  Pods
//
//  Created by Ferdly on 4/7/16.
//
//

#import "FSViewController.h"
#import "FSRequestManager.h"
#import "FSTableView.h"
#import "FSCodeTemplate.h"

UIBarButtonItem *__fsBackButtonItem = nil;
NSString *__fsDefaultEmptyNIBName = nil;
NSString *__fsDefaultErrorNIBName = nil;

typedef enum : NSUInteger {
    FSViewContentModeNormal,
    FSViewContentModeEmpty,
    FSViewContentModeError,
} FSViewContentMode;

@interface FSViewController ()

@property (strong, nonatomic) FSRequest *request;
@property (strong, nonatomic) FSResponse *response;
@property (assign, nonatomic) BOOL requesting;
@property (strong, nonatomic) NSTimer *requestTimer;
@property (assign, nonatomic) FSViewContentMode *contentMode;

@end

@implementation FSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.contentView isKindOfClass:[FSTableView class]]) {
        FSTableView *tableView = (FSTableView *)self.contentView;
        if (tableView.dynamicHeight) {
            tableView.estimatedRowHeight = tableView.rowHeight;
            tableView.rowHeight = UITableViewAutomaticDimension;
        }
    }
    
    [self performSelector:@selector(reloadData) withObject:nil afterDelay:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (!__fsBackButtonItem) {
        __fsBackButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    if (self.navigationItem.backBarButtonItem != __fsBackButtonItem) {
        self.navigationItem.backBarButtonItem = __fsBackButtonItem;
    }
    
    [super viewWillAppear:animated];
    if (self.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:YES animated:animated];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:animated];
    }
}

#pragma mark - HANDLE TABLEVIEW

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (FSKindOf(tableView, FSTableView).dynamicHeight) {
        if (FSOSVersion >= 8) {
            return UITableViewAutomaticDimension;
        } else {
            UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
            return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        }
    } else {
        return tableView.rowHeight;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - MAKE REQUEST

- (void)reloadData
{
    if (self.request) {
        self.request.errorHidden = YES;
        self.contentMode = FSViewContentModeNormal;
        self.requesting = YES;
        
        [[FSRequestManager sharedManager] startRequest:self.request withCompletion:^(FSResponse *response) {
            
            BOOL hideChildView = !self.viewNoHidden && response.error != nil && !self.response.object;
            [self setContentMode:hideChildView ? FSViewContentModeError : FSViewContentModeNormal withInfo:response.error.localizedDescription];
            self.requesting = NO;
            
            if (response && !response.error) {
                self.response = response;
                [self reloadView];
            }
        }];
    }
}

- (UIRefreshControl *)refreshControl
{
    id contentView = self.contentView;
    if ([contentView respondsToSelector:@selector(refreshControl)]) {
        if (![contentView refreshControl]) {
            [contentView setRefreshControl:[[UIRefreshControl alloc] init]];
        }
        return [contentView refreshControl];
    } else {
        return nil;
    }
}

- (void)reloadView
{
    if ([self.contentView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView *)self.contentView;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView reloadData];
        
        FSViewContentMode contentMode = FSViewContentModeEmpty;
        int sections = [tableView numberOfSections];
        for (int i = 0; i < sections; i++) {
            contentMode |= [tableView numberOfRowsInSection:i] > 0;
        }
        self.contentMode = contentMode;
    }
}

- (void)setRequesting:(BOOL)requesting
{
    _requesting = requesting;
    [self.requestTimer invalidate];
    self.requestTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(reloadRefreshControl) userInfo:nil repeats:NO];
}

- (void)reloadRefreshControl
{
    if (self.requesting && ![self refreshControl].isRefreshing) {
        [[self refreshControl] beginRefreshing];
        if ([self.contentView isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)self.contentView;
            scrollView.contentOffset = CGPointMake(0, -scrollView.contentInset.top);
        }
    } else if (!self.requesting && [self refreshControl].isRefreshing) {
        [[self refreshControl] endRefreshing];
    }
    self.requestTimer = nil;
}

- (void)setContentMode:(FSViewContentMode *)mode
{
    [self setContentMode:mode withInfo:nil];
}

- (void)setContentMode:(FSViewContentMode *)mode withInfo:(NSString *)info
{
    _contentMode = mode;
    if (_errorView || mode == FSViewContentModeError) {
        self.errorView.hidden = mode != FSViewContentModeError;
        self.errorView.messageLabel.text = info;
        if (self.errorView.reloadButton) {
            self.contentView.hidden = mode != FSViewContentModeNormal;
        } else {
            self.contentView.backgroundColor = [UIColor clearColor];
        }
    }
    if (_emptyView || mode == FSViewContentModeEmpty) {
        self.emptyView.hidden = mode != FSViewContentModeEmpty;
    }
}

- (FSErrorView *)errorView
{
    if (!_errorView &&  __fsDefaultErrorNIBName) {
        _errorView = [[[NSBundle mainBundle] loadNibNamed:__fsDefaultErrorNIBName owner:self options:nil] firstObject];
    }
    return _errorView;
}

- (UIView *)emptyView
{
    if (!_emptyView && __fsDefaultEmptyNIBName) {
        _emptyView = [[[NSBundle mainBundle] loadNibNamed:__fsDefaultErrorNIBName owner:self options:nil] firstObject];
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
