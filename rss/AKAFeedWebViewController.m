//
//  AKAFeedWebViewController.m
//  rss
//
//  Created by akaimo on 2015/05/01.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAFeedWebViewController.h"

@interface AKAFeedWebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) UIBarButtonItem *actionBtn;
@property (strong, nonatomic) UIBarButtonItem *refreshBtn;
@property (strong, nonatomic) UIBarButtonItem *stopBtn;
@property (strong, nonatomic) UIBarButtonItem *forwardBtn;
@property (strong, nonatomic) UIBarButtonItem *backBtn;

@property (nonatomic) int webViewLoads;

@end

@implementation AKAFeedWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:[_feed valueForKey:@"url"]];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    _actionBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionBtnTap:)];
    _refreshBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshBtnTap:)];
    _stopBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopBtnTap:)];
    _forwardBtn = [[UIBarButtonItem alloc] initWithTitle:@"＞" style:UIBarButtonItemStylePlain target:self action:@selector(forwardBtnTap:)];
    _backBtn = [[UIBarButtonItem alloc] initWithTitle:@"＜" style:UIBarButtonItemStylePlain target:self action:@selector(backBtnTap:)];
    self.navigationItem.rightBarButtonItems = @[_actionBtn, _refreshBtn, _forwardBtn, _backBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    /* footer off */
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.webView.isLoading) {
        [self.webView stopLoading];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    /* 戻る・進むボタンのタップ可否を制御 */
    self.backBtn.enabled = self.webView.canGoBack;
    self.forwardBtn.enabled = self.webView.canGoForward;
    
    /* navigationbarのitemを入れ替える */
    NSMutableArray *changedBarButtonItemArray = [NSMutableArray arrayWithArray:[self.navigationItem rightBarButtonItems]];
    [changedBarButtonItemArray replaceObjectAtIndex:1 withObject:_stopBtn];
    self.navigationItem.rightBarButtonItems = changedBarButtonItemArray;
    
    _webViewLoads++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    _webViewLoads--;
    
    if (_webViewLoads <= 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSMutableArray *changedBarButtonItemArray = [NSMutableArray arrayWithArray:[self.navigationItem rightBarButtonItems]];
        [changedBarButtonItemArray replaceObjectAtIndex:1 withObject:_refreshBtn];
        self.navigationItem.rightBarButtonItems = changedBarButtonItemArray;
        
//        NSLog(@"finish");
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _webViewLoads--;
    NSLog(@"error webView");
}




- (void)actionBtnTap:(UIButton *)sender {
    // コントローラを生成
    UIAlertController * ac =
    [UIAlertController alertControllerWithTitle:nil
                                        message:@"share"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Cancel用のアクションを生成
    UIAlertAction * cancelAction =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction * action) {
                               // ボタンタップ時の処理
                           }];
    
    // Destructive用のアクションを生成
    UIAlertAction * safariAction =
    [UIAlertAction actionWithTitle:@"Open in Safari"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action) {
                               /* ボタンタップ時の処理*/
                               NSURL *url = [NSURL URLWithString:[_feed valueForKey:@"url"]];
                               // ブラウザを起動する
                               [[UIApplication sharedApplication] openURL:url];
                           }];
    
    // コントローラにアクションを追加
    [ac addAction:cancelAction];
    [ac addAction:safariAction];
    
    // アクションシート表示処理
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)refreshBtnTap:(UIButton *)sender {
    [self.webView reload];
}

- (void)stopBtnTap:(UIButton *)sender {
    [self.webView stopLoading];
}

- (void)forwardBtnTap:(UIButton *)sender {
    if (self.webView.canGoForward) [self.webView goForward];
}

- (void)backBtnTap:(UIButton *)sender {
    if (self.webView.canGoBack) [self.webView goBack];
}

@end
