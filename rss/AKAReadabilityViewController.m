//
//  AKAReadabilityViewController.m
//  rss
//
//  Created by akaimo on 2015/05/17.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAReadabilityViewController.h"
#import "MBProgressHUD.h"

@interface AKAReadabilityViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation AKAReadabilityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _webView.scalesPageToFit = YES;
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        /* 処理内容 */
        [self getReadabilityForURL:[NSURL URLWithString:_url]
                 completionHandler:^(NSDictionary *dict, NSError *error) {
                     NSLog(@"%@", dict);
                     
                     NSData *bodyData = [[dict valueForKey:@"content"] dataUsingEncoding:NSUTF8StringEncoding];
                     [_webView loadData:bodyData MIMEType:@"text/html"textEncodingName:@"utf-8"baseURL:nil];
                 }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *string = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='300%%'"];
    [webView stringByEvaluatingJavaScriptFromString:string];
}



- (void)getReadabilityForURL:(NSURL *)url completionHandler:(void (^)(NSDictionary *, NSError *))handler {
    NSString *getUrl = [NSString stringWithFormat:@"url=%@", [url.absoluteString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *token = [NSString stringWithFormat:@"&token=%@", @"01a12b1b435c61b59e2dd8c75b4f86fcefa1bc2d"];
    NSString *shortenUrl = [@"https://readability.com/api/content/v1/parser?" stringByAppendingString:getUrl];
    shortenUrl = [shortenUrl stringByAppendingString:token];
    NSLog(@"%@", shortenUrl);
    
    NSURL *readabilityUrl = [NSURL URLWithString:shortenUrl];
    NSMutableURLRequest *shortenRequest = [NSMutableURLRequest requestWithURL:readabilityUrl];
    shortenRequest.HTTPMethod = @"GET";
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:shortenRequest returningResponse:&response error:&error];
    if (error != nil) {
        NSLog(@"Error!");
        return;
    }
    NSError *e = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    handler(dict, nil);
    
//    [NSURLConnection sendAsynchronousRequest:shortenRequest
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *shortenResponse, NSData *shortenData, NSError *shortenError) {
//                               if (shortenError) {
//                                   handler(nil, shortenError);
//                               }
//                               else {
//                                   NSDictionary *shortenJson = [NSJSONSerialization JSONObjectWithData:shortenData
//                                                                                               options:0
//                                                                                                 error:NULL];
//                                   handler(shortenJson, nil);
//                               }
//                           }];
}

@end
