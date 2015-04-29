//
//  AKAFeedViewController.m
//  rss
//
//  Created by akaimo on 2015/04/27.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAFeedViewController.h"

@interface AKAFeedViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation AKAFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* footer off */
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    self.title = [[_feed valueForKey:@"category"] valueForKey:@"name"][0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];

    
    /* feedタイトルを表示 */
    UILabel *label1 = (UILabel*)[cell viewWithTag:1];
    label1.text = [NSString stringWithFormat:[_feed valueForKey:@"title"][indexPath.row]];
    
    /* feedの更新時間とサイトタイトルを表示 */
    UILabel *label2 = (UILabel*)[cell viewWithTag:2];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[_feed valueForKey:@"timestamp"][indexPath.row] longLongValue] /1000.0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *date24 = [dateFormatter stringFromDate:date];
    label2.text = [NSString stringWithFormat:@"%@ | %@",date24, [[_feed valueForKey:@"site"] valueForKey:@"title"][indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _feed.count;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accounts] objectAtIndex:indexPath.row];
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    delegate.account = account;
//    [self performSegueWithIdentifier:@"Unread" sender:nil];
}

@end
