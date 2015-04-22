//
//  UnreadViewController.m
//  rss
//
//  Created by akaimo on 2015/04/03.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "UnreadViewController.h"
#import "AppDelegate.h"
#import "AKASynchronized.h"

@interface UnreadViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *unreadTableView;
@property (nonatomic, assign) NSInteger * categoryCount;

@property (nonatomic, assign) NXOAuth2Account *account;

@end

@implementation UnreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.account = delegate.account;
    [self setTitle];
    [self synchro];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _categoryCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"accountViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = @"hoge";
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}




//-- タイトルを設定
- (void)setTitle {
    NSDictionary *dict = [_account userData];
    self.title = [[dict valueForKey:@"logins"][0] valueForKey:@"id"];
}

//-- 同期
- (void)synchro {
    AKASynchronized *synchronized = [[AKASynchronized alloc] init];
    [synchronized synchro];
}


//-- カテゴリーを習得
- (void)feedCategory {
    NSURL *url = [NSURL URLWithString:SYNCHRO];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:_account.accessToken.accessToken forHTTPHeaderField:@"Authorization"];
    
    // 非同期通信
    [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            if (error.code == -1003) {
                NSLog(@"not found hostname. targetURL=%@", url);
            } else if (-1019) {
                NSLog(@"auth error. reason=%@", error);
            } else {
                NSLog(@"unknown error occurred. reason = %@", error);
            }
        } else {
            int httpStatusCode = ((NSHTTPURLResponse *)response).statusCode;
            if (httpStatusCode == 404) {
                NSLog(@"404 NOT FOUND ERROR. targetURL=%@", url);
            } else {
                NSLog(@"success request!!");
                NSLog(@"statusCode = %ld", (long)((NSHTTPURLResponse *)response).statusCode);
                
                NSError *e = nil;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
                NSLog(@"%@", dict);
                NSLog(@"responseText = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                
                self.categoryCount = [[dict valueForKey:@"unreadcounts"] count];
                
                // メインスレッドでの処理
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_unreadTableView reloadData];
                });
            }
        }
    }];
}

@end
