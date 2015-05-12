//
//  OAuthWebViewController.m
//  rss
//
//  Created by akaimo on 2015/04/07.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "OAuthWebViewController.h"
#import "NXOAuth2.h"
#import "AppDelegate.h"
#import "UnreadViewController.h"

@interface OAuthWebViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) id successObserver;
@property (strong, nonatomic) id failObserver;

//private method
- (void) p_addOauth2Notification;
- (void) p_getUserProfile:(NXOAuth2Account*)account;
- (void) p_startRequest;
- (void) p_removeOauth2Notification;

@end

@implementation OAuthWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _webView.delegate = self;
    
    // init notifications
    [self p_addOauth2Notification];
    [self p_startRequest];
}

- (void)viewDidDisappear:(BOOL)animated {
    // hide network activity indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    // remove notifications
    [self p_removeOauth2Notification];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)p_addOauth2Notification {
    // setup notifications for success or fail
    //-- for success
    self.successObserver = [[NSNotificationCenter defaultCenter]
                            addObserverForName:NXOAuth2AccountStoreAccountsDidChangeNotification
                            object:[NXOAuth2AccountStore sharedStore]
                            queue:nil usingBlock:^(NSNotification *notification) {
                                //TODO
                                NSLog(@"Success.");
                                
                                // get authinticate userinfo
                                NSDictionary *dict = notification.userInfo;
                                NXOAuth2Account *account = [dict valueForKey:NXOAuth2AccountStoreNewAccountUserInfoKey];
                                //get user profile
                                [self p_getUserProfile:account];
                                
                                // pop navigation controller
                                //                                 [self.navigationController popViewControllerAnimated:YES];
                            }];
    
    //-- for fail
    self.failObserver = [[NSNotificationCenter defaultCenter]
                         addObserverForName:NXOAuth2AccountStoreDidFailToRequestAccessNotification
                         object:[NXOAuth2AccountStore sharedStore]
                         queue:nil
                         usingBlock:^(NSNotification *note) {
                             //TODO
                             NSLog(@"Fail.");
                             
                             //TODO error message.
                             
                             //pop navigation controller
                             [self.navigationController popViewControllerAnimated:YES];
                             
                         }];
    
}

- (void)p_startRequest {
    [[NXOAuth2AccountStore sharedStore] requestAccessToAccountWithType:kOauth2ClientAccountType
                                   withPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
                                       //start authentication request.
                                       [_webView loadRequest:[NSURLRequest requestWithURL:preparedURL]];
                                       
                                   }];
}

- (void)p_getUserProfile:(NXOAuth2Account *)account {
    //get user profile on feedly user
    NSLog(@"account info : %@", account);
    
    NSURL *targetUrl = [NSURL URLWithString:PROFILE];
    [NXOAuth2Request performMethod:@"GET"
                        onResource:targetUrl
                   usingParameters:nil
                       withAccount:account
               sendProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
                   //TODO
               }
                   responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
                       NSLog(@"error : %@", error);
                       NSLog(@"response : %@", response);
                       NSString *jsonString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                       NSLog(@"response data : %@", jsonString);
                       
                       //
                       if (!error) {
                           //success
                           NSLog(@"get profile success.");
                           // json変換してDictionary型をuserDataとして格納する
                           NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                           if (dict) {
                               // set user data
                               [account setUserData:dict];
                           }
                           
                           //pop viewcontroller
//                           [self.navigationController popViewControllerAnimated:YES];
                           // アカウント情報をデリゲートに保存しViewをUnreadViewCOntrollerへ
                           NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accounts] objectAtIndex:0];
                           AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                           delegate.account = account;
                           delegate.feedStatus = nil;
                           UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UnreadViewController"];
                           [self.navigationController setViewControllers:@[vc] animated:NO];
                           
                       } else {
                           //error
                           NSLog(@"get profile failer.");
                       }
                       
                   }];
    
}

- (void) p_removeOauth2Notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self.successObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.failObserver];
}


#pragma mark - UIWebViewDelegate

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([[NXOAuth2AccountStore sharedStore] handleRedirectURL:[request URL]]) {
        return NO;
    }
    return YES;
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
