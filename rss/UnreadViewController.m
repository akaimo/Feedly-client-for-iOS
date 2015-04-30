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

@interface UnreadViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *unreadTableView;
//@property (nonatomic, assign) NSInteger *categoryCount;
@property (nonatomic, retain) NSArray *feed;
@property (nonatomic, retain) NSDictionary *allFeed;
@property (nonatomic, retain) NXOAuth2Account *account;

@end

@implementation UnreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* カスタムセルの定義 */
    UINib *nib = [UINib nibWithNibName:@"AKATopCustomCell" bundle:nil];
    [self.unreadTableView registerNib:nib forCellReuseIdentifier:@"Top"];
    UINib *nib2 = [UINib nibWithNibName:@"AKASecondCustomCell" bundle:nil];
    [self.unreadTableView registerNib:nib2 forCellReuseIdentifier:@"Second"];
    
    /* sqlite3のURLを収得 */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = paths[0];
    NSLog(@"sqlite3: %@", documentsPath);
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _account = delegate.account;
    [self setTitle];
    
    /* 同期処理 */
//    [self synchro];
    
    /* fetch処理 */
    AKAFetchFeed *fechFeed = [[AKAFetchFeed alloc] init];
    _feed = [fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:YES]];
    _allFeed = [fechFeed fechAllFeedUnread:[NSNumber numberWithBool:YES]];
    
    /* マルチスレッド */
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        /* 同期処理 */
        [self synchro];
        
        /* fetch処理 */
        AKAFetchFeed *fechFeed = [[AKAFetchFeed alloc] init];
        _feed = [fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:YES]];
        _allFeed = [fechFeed fechAllFeedUnread:[NSNumber numberWithBool:YES]];
        
        /* メインスレッドでの処理 */
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.unreadTableView reloadData];
        });
    }];
    
    /* 次のViewの戻るボタンの設定 */
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    for (int i=0; i<_feed.count; i++) {
        if ([_feed[i] count] != 0) {
            count = count + 1;
        }
    }
//    NSLog(@"categoryCount: %ld", (long)count);
    return count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    NSString *title;
    NSString *unreadCount;
    switch (indexPath.row) {
        case 0:
            identifier = @"Top";
            title = @"Unread";
            unreadCount = [NSString stringWithFormat:@"%lu", (unsigned long)[_allFeed count]];
            break;
            
        default:
            identifier = @"Second";
            title = [self capitalizeFirstLetter:[[_feed[indexPath.row -1] valueForKey:@"category"] valueForKey:@"name"][0]];
            unreadCount = [NSString stringWithFormat:@"%lu", (unsigned long)[_feed[indexPath.row -1] count]];
            break;
    }
    
    AKATopCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.title.text = title;
    cell.unreadCount.text = unreadCount;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSArray *array = [NSArray arrayWithObjects:@"All Items", _allFeed, nil];
        [self performSegueWithIdentifier:@"Feed" sender:array];
    } else {
        NSArray *array = [NSArray arrayWithObjects:[[_feed[indexPath.row-1] valueForKey:@"category"] valueForKey:@"name"][0], _feed[indexPath.row-1], nil];
        [self performSegueWithIdentifier:@"Feed" sender:array];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Feed"]) {
        AKAFeedViewController *feedViewController = (AKAFeedViewController *)[segue destinationViewController];
        feedViewController.title = sender[0];
        feedViewController.feed = sender[1];
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
    NSString *str = [FEED stringByAppendingString:[synchronized checkUnreadCount]];
    NSLog(@"%@", str);
    url = [NSURL URLWithString:str];
    NSDictionary *feed = [synchronized urlForJSONToDictionary:url];
    /* 記事を解析し保存 */
    [synchronized saveFeed:feed];
    
    /* お気に入りを収得 */
    url = [NSURL URLWithString:SAVED];
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
