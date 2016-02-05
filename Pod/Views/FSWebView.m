//
//  FSWebView.m
//  Pods
//
//  Created by Ferdly on 1/26/16.
//
//

#import "FSWebView.h"

@interface FSWebView () <UIScrollViewDelegate, UIWebViewDelegate>

@end

@implementation FSWebView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [self scrollViewDidScroll:self.scrollView];
}

- (void)dealloc
{
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.headerView layoutIfNeeded];
    
    CGFloat offset =  self.refreshControl.refreshing ? self.refreshControl.frame.size.height : 0;
    CGFloat bottom = self.footerView && !self.footerView.hidden ? self.footerView.frame.size.height : 0;
    self.scrollView.contentInset = UIEdgeInsetsMake(self.headerView.frame.size.height + offset, 0, bottom, 0);
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, self.footerView.frame.size.height, 0);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.headerTopConstraint.constant = MIN(-scrollView.contentOffset.y - scrollView.contentInset.top, 0);
    self.footerBottomConstraint.constant = MIN(scrollView.frame.size.height - scrollView.contentSize.height + scrollView.contentOffset.y - scrollView.contentInset.bottom, 0);
}

- (void)setFilename:(NSString *)filename
{
    _filename = filename;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    NSString *content = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    [self loadHTMLString:content baseURL:nil];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType != UIWebViewNavigationTypeOther) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    [self performSelector:@selector(repairOffset:) withObject:[NSValue valueWithCGPoint:webView.scrollView.contentOffset] afterDelay:0];
    return YES;
}

- (void)repairOffset:(NSValue *)value {
    [self.scrollView setContentOffset:[value CGPointValue]];
}

@end
