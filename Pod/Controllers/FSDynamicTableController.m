//
//  FSDynamicTableController.m
//  Pods
//
//  Created by Ferdly on 4/9/16.
//
//

#import "FSDynamicTableController.h"
#import "FSConstants.h"

@interface FSDynamicTableController ()

@property (assign, nonatomic) CGSize contentSize;
@property (assign, nonatomic) CGFloat width;
@end

@implementation FSDynamicTableController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = self.tableView.rowHeight;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (FSOSVersion >= 8) {
        return UITableViewAutomaticDimension;
    } else {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tableView.estimatedRowHeight;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    if (FSOSVersion < 8 && self.tableView.tableFooterView &&
        (self.contentSize.width != self.tableView.contentSize.width || self.contentSize.height != self.tableView.contentSize.height)) {
        self.contentSize = self.tableView.contentSize;
        
        [self.tableView layoutHeaderFooterIfNeeded];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (self.width != self.view.frame.size.width) {
        self.width = self.view.frame.size.width;
        [self.tableView layoutHeaderFooterIfNeeded];
    }
}


@end

@implementation UITableView (FS)

- (void)layoutHeaderFooterIfNeeded
{
    UIView *headerView = self.tableHeaderView;
    if (headerView) {
        [self sizeViewToFit:headerView];
        self.tableHeaderView = headerView;
    }
    
    UIView *footerView = self.tableFooterView;
    if (footerView) {
        [self sizeViewToFit:footerView];
        self.tableFooterView = footerView;
    }
}

- (void)sizeViewToFit:(UIView *)view
{
    NSLayoutConstraint *c = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:nil multiplier:1 constant:self.frame.size.width];
    [view addConstraint:c];
    
    CGSize size = [view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    if (size.height != 0) {
        CGRect frame = [view frame];
        frame.size.height = size.height;
        view.frame = frame;
    }
    
    [view removeConstraint:c];
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier nilIdentifier:(NSString *)nilIdentifier
{
    id cell = [self dequeueReusableCellWithIdentifier:identifier];
    if (!cell && nilIdentifier) {
        cell = [self dequeueReusableCellWithIdentifier:nilIdentifier];
    }
    return cell;
}

@end
