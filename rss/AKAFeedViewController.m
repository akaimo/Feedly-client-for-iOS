//
//  AKAFeedViewController.m
//  rss
//
//  Created by akaimo on 2015/04/27.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAFeedViewController.h"
#import "AKAImgCustomCell.h"
#import "AKADetailViewController.h"
#import "AKARegularExpression.h"
#import "AKAMarkersFeed.h"
#import "AppDelegate.h"

@interface AKAFeedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *feedTableView;

@end

@implementation AKAFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _feed = delegate.feed[_categoryRow];
    
    /* カスタムセルの定義 */
    UINib *nib = [UINib nibWithNibName:@"AKAImgCustomCell" bundle:nil];
    [self.feedTableView registerNib:nib forCellReuseIdentifier:@"Img"];
    UINib *nib2 = [UINib nibWithNibName:@"AKANoImgCustomCell" bundle:nil];
    [self.feedTableView registerNib:nib2 forCellReuseIdentifier:@"NoImg"];
    
    /* 次のViewの戻るボタンの設定 */
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
}

- (void)viewWillAppear:(BOOL)animated {
    /* footer off */
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    [_feedTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AKARegularExpression *regularExpression = [[AKARegularExpression alloc] init];
    NSArray *img = [regularExpression imagesWithFeed:[_feed valueForKey:@"detail"][indexPath.row]];
    NSString *identifier;
    
    if (img.count == 0) {
        identifier = @"NoImg";
    } else {
        identifier = @"Img";
    }
    
    AKAImgCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.title.text = [NSString stringWithFormat:[_feed valueForKey:@"title"][indexPath.row]];
    
    NSString *notag = [regularExpression noTagWithFeed:[_feed valueForKey:@"detail"][indexPath.row]];
    if (notag.length != 0) {
        cell.detail.text = notag;
    } else {
        cell.detail.text = @"";
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[_feed valueForKey:@"timestamp"][indexPath.row] longLongValue] /1000.0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *date24 = [dateFormatter stringFromDate:date];
    
    /*
     savedの確認のために一時的に表示
     本来ならば以下に1行
     cell.siteTitle.text = [NSString stringWithFormat:@"%@ | %@",date24, [[_feed valueForKey:@"site"] valueForKey:@"title"][indexPath.row]];
     */
    if ([[_feed valueForKey:@"saved"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        cell.siteTitle.text = [NSString stringWithFormat:@"%@ | %@",date24, [[_feed valueForKey:@"site"] valueForKey:@"title"][indexPath.row]];
    } else {
        cell.siteTitle.text = [NSString stringWithFormat:@"★ %@ | %@",date24, [[_feed valueForKey:@"site"] valueForKey:@"title"][indexPath.row]];
    }
    //-- ここまで
    
    if (img.count != 0) {
        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t q_main = dispatch_get_main_queue();
        cell.image.image = nil;
        dispatch_async(q_global, ^{
            NSString *imageURL = img[0];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: imageURL]]];
            
            dispatch_async(q_main, ^{
                cell.image.image = image;
                [cell layoutSubviews];
            });
        });
    }
    
    if ([[_feed valueForKey:@"unread"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
//        NSLog(@"read");
        cell.title.textColor = [UIColor lightGrayColor];
        cell.detail.textColor = [UIColor lightGrayColor];
        cell.siteTitle.textColor = [UIColor lightGrayColor];
    } else {
//        NSLog(@"unread");
        cell.title.textColor = [UIColor blackColor];
        cell.detail.textColor = [UIColor darkGrayColor];
        cell.siteTitle.textColor = [UIColor darkGrayColor];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _feed.count;
}

- (void)updateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    AKAImgCustomCell *customeCell = (AKAImgCustomCell *)cell;
    if ([[_feed valueForKey:@"unread"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        customeCell.title.textColor = [UIColor lightGrayColor];
        customeCell.detail.textColor = [UIColor lightGrayColor];
        customeCell.siteTitle.textColor = [UIColor lightGrayColor];
    } else {
        customeCell.title.textColor = [UIColor blackColor];
        customeCell.detail.textColor = [UIColor darkGrayColor];
        customeCell.siteTitle.textColor = [UIColor darkGrayColor];
    }
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /* 開いたときに既読にする */
    if ([[_feed valueForKey:@"unread"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            NSArray *array = [NSArray arrayWithObjects:[_feed valueForKey:@"id"][indexPath.row], nil];
            AKAMarkersFeed *markersFeed = [[AKAMarkersFeed alloc] init];
            [markersFeed markAsRead:array];
        }];
        
        /* 配列内のデータも既読にする */
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//        NSLog(@"前: %@", [delegate.feed[_categoryRow] valueForKey:@"unread"][indexPath.row]);
        [delegate.feed[_categoryRow][indexPath.row] setValue:[NSNumber numberWithBool:NO] forKey:@"unread"];
//        NSLog(@"後: %@", [delegate.feed[_categoryRow] valueForKey:@"unread"][indexPath.row]);
        
        /* Cellを更新する */
        _feed = delegate.feed[_categoryRow];
        [_feedTableView reloadData];
    }
    
    [self performSegueWithIdentifier:@"Detail" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([[segue identifier] isEqualToString:@"Detail"]) {
        AKADetailViewController *detailViewController = (AKADetailViewController *)[segue destinationViewController];
        detailViewController.title = self.title;
        detailViewController.feed = delegate.feed[_categoryRow];
        detailViewController.feedRow = [sender row];
    }
}


@end
