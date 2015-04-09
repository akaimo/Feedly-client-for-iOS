//
//  UnreadViewController.m
//  rss
//
//  Created by akaimo on 2015/04/03.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "UnreadViewController.h"

@interface UnreadViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *unreadTableView;
@property (nonatomic, assign) NSInteger * categoryCount;

@end

@implementation UnreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setTitle];
    [self feedCategory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categoryCount;
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
    NSDictionary *dict = [self.account userData];
    NSString *str = [self jsonToString:[[dict valueForKey:@"logins"] valueForKey:@"id"]];
    self.title = str;
}

//-- JsonからStringに変更し、余分な文字を除去
- (NSString *)jsonToString:(id)json {
    // jsonをdataに変更
    NSData *json_check = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:nil];
    // dataをstringに変更
    NSString *s1= [[NSString alloc] initWithData:json_check encoding:NSUTF8StringEncoding];
    // 余分な文字を除去
    s1 = [s1 stringByReplacingOccurrencesOfString:@"[" withString:@""];
    s1 = [s1 stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    s1 = [s1 stringByReplacingOccurrencesOfString:@"]" withString:@""];
    return s1;
}

//-- カテゴリーを習得
- (void)feedCategory {
    NSURL *url = [NSURL URLWithString:@"https://sandbox.feedly.com/v3/markers/counts"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request setValue:self.account.accessToken.accessToken forHTTPHeaderField:@"Authorization"];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error != nil) {
        NSLog(@"Error!");
        return;
    }
    
    NSError *e = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&e];
    
    NSLog(@"%@", dict);
    
    // cell数を設定
    self.categoryCount = [[dict valueForKey:@"unreadcounts"] count];
}

@end
