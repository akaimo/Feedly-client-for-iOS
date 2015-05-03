//
//  AKAFeedWebViewController.m
//  rss
//
//  Created by akaimo on 2015/05/01.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAFeedWebViewController.h"

@interface AKAFeedWebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AKAFeedWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *url = [NSURL URLWithString:[_feed valueForKey:@"url"]];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    self.title = [_feed valueForKey:@"title"];

}

- (void)viewWillAppear:(BOOL)animated {
    /* footer off */
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
