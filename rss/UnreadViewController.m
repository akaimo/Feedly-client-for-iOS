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
#import "AKACoreData.h"
#import "AKAFetchFeed.h"
#import "AKAFeedViewController.h"
#import "AKATopCustomCell.h"
#import "AKANavigationController.h"
#import "MSCellAccessory.h"
#import "JDStatusBarNotification.h"

@interface UnreadViewController () <UITableViewDataSource, UITableViewDelegate>
//@property (nonatomic, assign) NSInteger *categoryCount;
@property (nonatomic, retain) NXOAuth2Account *account;

@end

@implementation UnreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Menu追加 */
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(openVerticalMenu:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menuBtn"] style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(openVerticalMenu:)];
    
    /* 次のViewの戻るボタンの設定 */
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
    
    /* アカウント情報が無い場合はログインを要求 */
    if([[[NXOAuth2AccountStore sharedStore] accounts] count] == 0){
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"ViewController"];
        [self.navigationController setViewControllers:@[vc] animated:NO];
        self.title = @"Account";
        return;
    }
    
    /* カスタムセルの定義 */
    UINib *nib = [UINib nibWithNibName:@"AKATopCustomCell" bundle:nil];
    [self.unreadTableView registerNib:nib forCellReuseIdentifier:@"Top"];
    UINib *nib2 = [UINib nibWithNibName:@"AKASecondCustomCell" bundle:nil];
    [self.unreadTableView registerNib:nib2 forCellReuseIdentifier:@"Second"];
    
    /* RefreshControl */
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.unreadTableView addSubview:refreshControl];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _account = delegate.account;
    NSDictionary *dict = [_account userData];
    self.title = [[dict valueForKey:@"logins"][0] valueForKey:@"id"];
    
    /* Menuから生成された場合は行わない */
    if (!delegate.feedStatus) {
        /* fetch処理 */
        AKAFetchFeed *fechFeed = [[AKAFetchFeed alloc] init];
        delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedUnread:[NSNumber numberWithBool:YES]]];
        for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:YES]]]) {
            [delegate.feed addObject:dic];
        }
        
        /* 同期処理 */
        AKASynchronized *synchronized = [[AKASynchronized alloc] init];
        [synchronized synchro:_unreadTableView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    // footer off
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    /* fetch処理 */
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    AKAFetchFeed *fechFeed = [[AKAFetchFeed alloc] init];
    switch (delegate.feedStatus) {
        case UnreadItems:
            delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedUnread:[NSNumber numberWithBool:YES]]];
            for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:YES]]]) {
                [delegate.feed addObject:dic];
            }
            break;
            
        case SavedItems:
            delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedSaved:[NSNumber numberWithBool:YES]]];
            for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedSaved:[NSNumber numberWithBool:YES]]]) {
                [delegate.feed addObject:dic];
            }
            break;
            
        case AllItems:
            delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedUnread:nil]];
            for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedUnread:nil]]) {
                [delegate.feed addObject:dic];
            }
            break;
            
        default:
            delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedUnread:[NSNumber numberWithBool:YES]]];
            for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:YES]]]) {
                [delegate.feed addObject:dic];
            }
            break;
    }
    
    [self.unreadTableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return delegate.feed.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString *identifier;
    NSString *title;
    NSString *unreadCount;
    UIImage *image;
    if (indexPath.row == 0) {
        identifier = @"Top";
        switch (delegate.feedStatus) {
            case UnreadItems:
                title = @"Unread Items";
                image = [UIImage imageNamed:@"unreadIcon"];
                break;
                
            case SavedItems:
                title = @"Saved Items";
                image = [UIImage imageNamed:@"savedIcon"];
                break;
                
            case AllItems:
                title = @"All Items";
                image = [UIImage imageNamed:@"allIcon"];
                break;
                
            default:
                title = @"Unread Items";
                image = [UIImage imageNamed:@"unreadIcon"];
                break;
        }
        
        /* 未読数をカウント */
        int count = 0;
        for (NSDictionary *dic in delegate.feed[indexPath.row]) {
            if ([[dic valueForKey:@"unread"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                count++;
            }
        }
        /* 未読数が0なら表示しない */
        if (count == 0) unreadCount = @"";
        else            unreadCount = [NSString stringWithFormat:@"%d", count];
        
    } else {
        identifier = @"Second";
        title = [self capitalizeFirstLetter:[[delegate.feed[indexPath.row] valueForKey:@"category"] valueForKey:@"name"][0]];
        image = [UIImage imageNamed:@"feedIcon"];
        int count = 0;
        for (NSDictionary *dic in delegate.feed[indexPath.row]) {
            if ([[dic valueForKey:@"unread"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                count++;
            }
        }
        if (count == 0) unreadCount = @"";
        else            unreadCount = [NSString stringWithFormat:@"%d", count];
        
    }
    
    AKATopCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.title.text = title;
    cell.unreadCount.text = unreadCount;
    
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.iconImageView.image = image;
    
    UIColor *themeColor = [UIColor colorWithRed:133/255.0 green:230/255.0 blue:255/255.0 alpha:1.0];
    cell.iconImageView.tintColor = themeColor;
    cell.accessoryView = [MSCellAccessory accessoryWithType:DISCLOSURE_INDICATOR color:themeColor];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (indexPath.row == 0) {
        NSArray *array = [NSArray arrayWithObjects:@"All Items", indexPath, nil];
        [self performSegueWithIdentifier:@"Feed" sender:array];
    } else {
        NSArray *array = [NSArray arrayWithObjects:[[delegate.feed[indexPath.row] valueForKey:@"category"] valueForKey:@"name"][0], indexPath, nil];
        [self performSegueWithIdentifier:@"Feed" sender:array];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Feed"]) {
        AKAFeedViewController *feedViewController = (AKAFeedViewController *)[segue destinationViewController];
        feedViewController.title = sender[0];
        feedViewController.categoryRow = [sender[1] row];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            return [AKATopCustomCell topRowHeight];
            break;
            
        default:
            return [AKATopCustomCell secondRowHeight];
            break;
    }
}


#pragma mark - RefreshControl
- (void)onRefresh:(UIRefreshControl *) refreshControl {
    [refreshControl beginRefreshing];
    
    AKASynchronized *synchronized = [[AKASynchronized alloc] init];
    [synchronized synchro:_unreadTableView];
    
    [refreshControl endRefreshing];
    
}


#pragma mark - PrivateMethods
//-- 最初の文字だけ大文字にする
-(NSString *)capitalizeFirstLetter:(NSString *)string{
    NSString *capitalisedSentence = [string stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                    withString:[[string  substringToIndex:1] capitalizedString]];
    return capitalisedSentence;
}


@end
