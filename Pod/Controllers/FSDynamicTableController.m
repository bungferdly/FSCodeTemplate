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
        
        UIView *footerView = self.tableView.tableFooterView;
        self.tableView.tableFooterView = nil;
        self.tableView.tableFooterView = footerView;
    }
}

@end
