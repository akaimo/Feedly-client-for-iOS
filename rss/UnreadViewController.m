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

@interface UnreadViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *unreadTableView;
//@property (nonatomic, assign) NSInteger *categoryCount;
@property (nonatomic, retain) NSArray *feed;
@property (nonatomic, retain) NSArray *allFeed;
@property (nonatomic, retain) NXOAuth2Account *account;

@end

@implementation UnreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* sqlite3のURLを収得 */
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = paths[0];
    NSLog(@"sqlite3: %@", documentsPath);
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _account = delegate.account;
    [self setTitle];
    [self synchro];
    
    AKAFetchFeed *fechFeed = [[AKAFetchFeed alloc] init];
    _feed = [fechFeed fechCategoryFeedUnread:[NSNumber numberWithBool:YES]];
    _allFeed = [fechFeed fechAllFeedUnread:[NSNumber numberWithBool:YES]];
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
    static NSString *cellId = @"accountViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        switch(indexPath.row) {
            case 0:
                cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellId];
                cell.textLabel.text = @"hogehoge";
                tableView.rowHeight = 66.0;
                break;
            default:
                cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellId];
                cell.textLabel.text = @"hoge";
                tableView.rowHeight = 44.0;
                break;
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
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


@end
