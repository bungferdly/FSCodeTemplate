//
//  FSViewController.m
//  Pods
//
//  Created by Ferdly on 4/7/16.
//
//

#import "FSViewController.h"
#import "FSRequestManager.h"

UIBarButtonItem *__fsBackButtonItem = nil;

@interface FSViewController ()

@property (strong, nonatomic) FSRequest *request;
@property (strong, nonatomic) FSResponse *response;
@property (assign, nonatomic) BOOL requesting;
@property (strong, nonatomic) NSTimer *requestTimer;

@end

@implementation FSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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

#pragma mark - HANDLE TABLE VIEW

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - MAKE REQUEST

- (FSRequest *)request
{
    if (!_request) {
        _request = [[FSRequest alloc] init];
        _request.errorHidden = YES;
    }
    return _request;
}

- (void)reloadData
{
    if (self.request.path) {
        [self setInfo:nil error:NO];
        self.requesting = YES;
        
        [[FSRequestManager sharedManager] startRequest:self.request withCompletion:^(FSResponse *response) {
            
            BOOL hideChildView = !self.viewNoHidden && response.error != nil && !self.response.object;
            [self setInfo:hideChildView ? response.error.localizedDescription : nil error:hideChildView];
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
        
        BOOL hasRows = NO;
        int sections = [tableView numberOfSections];
        for (int i = 0; i < sections; i++) {
            hasRows = [tableView numberOfRowsInSection:i] > 0;
        }
        if (!hasRows) {
            [self setInfo:self.emptyContentView.emptyText error:NO];
        }
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

- (void)setInfo:(NSString *)string error:(BOOL)error
{
    self.emptyContentView.hidden = !string.length;
    self.emptyContentView.messageLabel.text = string;
    if (self.emptyContentView.reloadButton) {
        self.emptyContentView.reloadButton.hidden = !error;
        self.contentView.hidden = error;
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

@end
