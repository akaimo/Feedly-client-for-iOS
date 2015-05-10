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

@interface UnreadViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *unreadTableView;
//@property (nonatomic, assign) NSInteger *categoryCount;
@property (nonatomic, retain) NXOAuth2Account *account;

@end

@implementation UnreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /* Menu追加 */
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(openVerticalMenu:)];
    
    /* カスタムセルの定義 */
    UINib *nib = [UINib nibWithNibName:@"AKATopCustomCell" bundle:nil];
    [self.unreadTableView registerNib:nib forCellReuseIdentifier:@"Top"];
    UINib *nib2 = [UINib nibWithNibName:@"AKASecondCustomCell" bundle:nil];
    [self.unreadTableView registerNib:nib2 forCellReuseIdentifier:@"Second"];
    
    /* sqlite3のURLを収得 */
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsPath = paths[0];
//    NSLog(@"sqlite3: %@", documentsPath);
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _account = delegate.account;
    [self setTitle];
    
    /* Menuから生成された場合は行わない */
    if (!delegate.feedStatus) {
        /* 同期処理 */
        //    [self synchro];
        
        /* fetch処理 */
        AKAFetchFeed *fechFeed = [[AKAFetchFeed alloc] init];
        delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedUnread:[NSNumber numberWithBool:YES]]];
        for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:YES]]]) {
            [delegate.feed addObject:dic];
        }
        
        /* マルチスレッド */
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            /* 同期処理 */
            [self synchro];
            
            AKAFetchFeed *fechFeed = [[AKAFetchFeed alloc] init];
            delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedUnread:[NSNumber numberWithBool:YES]]];
            for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:YES]]]) {
                [delegate.feed addObject:dic];
            }
            
            /* メインスレッドでの処理 */
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.unreadTableView reloadData];
            });
        }];
    }
    
    /* 次のViewの戻るボタンの設定 */
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
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
            
        case ReadItems:
            delegate.feed = [NSMutableArray arrayWithObject:[fechFeed fechAllFeedUnread:[NSNumber numberWithBool:NO]]];
            for (NSDictionary *dic in [NSMutableArray arrayWithArray:[fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:NO]]]) {
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
    if (indexPath.row == 0) {
        identifier = @"Top";
        switch (delegate.feedStatus) {
            case UnreadItems:
                title = @"Unread Items";
                break;
                
            case SavedItems:
                title = @"Saved Items";
                break;
                
            case ReadItems:
                title = @"Read Items";
                break;
                
            case AllItems:
                title = @"All Items";
                break;
                
            default:
                title = @"Unread Items";
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
    
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = [MSCellAccessory accessoryWithType:DISCLOSURE_INDICATOR color:[UIColor colorWithRed:133/255.0 green:230/255.0 blue:255/255.0 alpha:1.0]];
    
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




//-- タイトルを設定
- (void)setTitle {
    NSDictionary *dict = [_account userData];
    self.title = [[dict valueForKey:@"logins"][0] valueForKey:@"id"];
}

//-- 同期
- (void)synchro {
    AKASynchronized *synchronized = [[AKASynchronized alloc] init];
    /* アカウントの照合 */
    [synchronized checkAccount];
    
    /* カテゴリ一覧を収得 */
    NSURL *url = [NSURL URLWithString:CATEGORY];
    NSDictionary *category = [synchronized urlForJSONToDictionary:url];
    /* カテゴリを解析し保存 */
    [synchronized saveCategory:category];
    
    /* 未読数を収得して、その数だけ記事を収得 */
    NSDictionary *userData = [_account userData];
    NSString *str = [STREAMS stringByAppendingString:[userData valueForKey:@"id"]];
    str = [str stringByAppendingString:FEED];
    str = [str stringByAppendingString:[synchronized checkUnreadCount]];
    NSLog(@"%@", str);
    url = [NSURL URLWithString:str];
    NSDictionary *feed = [synchronized urlForJSONToDictionary:url];
    /* 記事を解析し保存 */
    [synchronized saveFeed:feed];
    
    /* お気に入りを収得 */
    str = [STREAMS stringByAppendingString:[userData valueForKey:@"id"]];
    str = [str stringByAppendingString:SAVED];
    url = [NSURL URLWithString:str];
    NSDictionary *save = [synchronized urlForJSONToDictionary:url];
    /* お気に入りを解析し保存 */
    [synchronized saveSaved:save];
    
    /* データベースの整合性のチェック */
    
    /* 過去のfeedを削除 */
    [synchronized deleteFeed];
}

//-- 最初の文字だけ大文字にする
-(NSString *)capitalizeFirstLetter:(NSString *)string{
    NSString *capitalisedSentence = [string stringByReplacingCharactersInRange:NSMakeRange(0,1)
                                                                    withString:[[string  substringToIndex:1] capitalizedString]];
    return capitalisedSentence;
}

//-- test
- (void)testRequest {

}


@end
