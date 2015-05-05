//
//  AKADetailViewController.m
//  rss
//
//  Created by akaimo on 2015/04/30.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKADetailViewController.h"
#import "AKARegularExpression.h"
#import "AKADetailCustomCell.h"
#import "AKAFeedWebViewController.h"
#import "AKAMarkersFeed.h"
#import "UIViewController+MJPopupViewController.h"
#import "AKAPopupViewController.h"

@interface AKADetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)staoSaved:(id)sender;
- (IBAction)tapUnread:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *unreadBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *upBtn;
- (IBAction)tapUp:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *downBtn;
- (IBAction)tapDown:(id)sender;

@end

@implementation AKADetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINib *nib = [UINib nibWithNibName:@"AKADetailCustomCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Detail"];
    UINib *nib2 = [UINib nibWithNibName:@"AKADetailImgCustomCell" bundle:nil];
    [self.tableView registerNib:nib2 forCellReuseIdentifier:@"DetailImg"];
    
    /* 次のViewの戻るボタンの設定 */
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
}

- (void)viewWillAppear:(BOOL)animated {
    /* footer on */
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self reloadUnreadBtn];
    [self reloadSaveBtn];
    [self reloadUpDownBtn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AKARegularExpression *regularExpression = [[AKARegularExpression alloc] init];
    NSArray *img = [regularExpression imagesWithFeed:[_feed valueForKey:@"detail"][_feedRow]];
    NSString *identifier;
    
    if (img.count == 0) {
        identifier = @"Detail";
    } else {
        identifier = @"DetailImg";
    }
    
    AKADetailCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.title.text = [_feed valueForKey:@"title"][_feedRow];
    
    NSString *notag = [regularExpression noTagWithFeed:[_feed valueForKey:@"detail"][_feedRow]];
    if (notag.length != 0) {
        cell.detail.text = notag;
    } else {
        cell.detail.text = @"";
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[_feed valueForKey:@"timestamp"][_feedRow] longLongValue] /1000.0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MM/dd HH:mm";
    NSString *date24 = [dateFormatter stringFromDate:date];
    
    /*
    savedの確認のために一時的に表示
    本来ならば以下に1行
    cell.date.text = [NSString stringWithFormat:@"%@\n%@",date24, [[_feed valueForKey:@"site"] valueForKey:@"title"][_feedRow]];
     */
    if ([[_feed valueForKey:@"saved"][_feedRow] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        cell.date.text = [NSString stringWithFormat:@"%@\n%@",date24, [[_feed valueForKey:@"site"] valueForKey:@"title"][_feedRow]];
    } else {
        cell.date.text = [NSString stringWithFormat:@"★ %@\n%@",date24, [[_feed valueForKey:@"site"] valueForKey:@"title"][_feedRow]];
    }
    //-- ここまで
    
    if (img.count != 0) {
        dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t q_main = dispatch_get_main_queue();
        cell.detailImageView.image = nil;
        dispatch_async(q_global, ^{
            NSString *imageURL = img[0];
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: imageURL]]];
            
            dispatch_async(q_main, ^{
                cell.detailImageView.image = image;
                [cell layoutSubviews];
            });
        });
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height;
    CGFloat img;
    CGFloat pad = 30.0 + 5.0 + 20.0 + 10.0 + 30.0;
    
    /* Titleの高さを取得 */
    CGFloat viewMargin = 30.0f;
    CGFloat viewWidth = self.tableView.frame.size.width - (viewMargin * 2);
    CGSize bounds = CGSizeMake(viewWidth, CGFLOAT_MAX);
    CGRect boundingRectTitle = [[_feed valueForKey:@"title"][_feedRow] boundingRectWithSize:bounds options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:17.0] forKey:NSFontAttributeName] context:nil];
    
    /* Detailの高さを取得 */
    AKARegularExpression *regularExpression = [[AKARegularExpression alloc] init];
    NSString *notag = [regularExpression noTagWithFeed:[_feed valueForKey:@"detail"][_feedRow]];
    CGRect boundingRectDetail = [notag boundingRectWithSize:bounds options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:[NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:17.0] forKey:NSFontAttributeName] context:nil];
    
    /* Imageの高さ */
    NSArray *image = [regularExpression imagesWithFeed:[_feed valueForKey:@"detail"][_feedRow]];
    if (image.count == 0) {
        img = 0.0;
    } else {
        img = 200.0;
    }
    
    height = boundingRectTitle.size.height + 20.0 + img + boundingRectDetail.size.height + pad;
    
    return height;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Web" sender:_feed[_feedRow]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Web"]) {
        AKAFeedWebViewController *feedWebViewController = (AKAFeedWebViewController *)[segue destinationViewController];
        feedWebViewController.feed = sender;
    }
}


//-- barItemの更新
- (void)reloadUnreadBtn {
    if ([[_feed valueForKey:@"unread"][_feedRow] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        self.unreadBtn.title = @"Unread";
    } else {
        self.unreadBtn.title = @"Read";
    }
}

//-- saveBtnの更新
- (void)reloadSaveBtn {
    if ([[_feed valueForKey:@"saved"][_feedRow] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        self.saveBtn.title = @"Saved";
    } else {
        self.saveBtn.title = @"Unsaved";
    }
}

//-- up,downBtnの更新
- (void)reloadUpDownBtn {
    if (_feedRow == 0) {
        self.upBtn.enabled = NO;
    } else {
        self.upBtn.enabled = YES;
    }
    
    if (_feedRow == _feed.count -1) {
        self.downBtn.enabled = NO;
    } else {
        self.downBtn.enabled = YES;
    }
}



//-- savedを管理する
- (IBAction)staoSaved:(id)sender {
    NSString *nibName;
    NSArray *array = [NSArray arrayWithObjects:[_feed valueForKey:@"id"][_feedRow], nil];
    AKAMarkersFeed *markersFeed = [[AKAMarkersFeed alloc] init];
    
    if ([[_feed valueForKey:@"saved"][_feedRow] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        nibName = @"AKAPopupViewController";
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            [markersFeed markAsSaved:array];
            NSLog(@"markAsSaved");
        }];
        self.saveBtn.title = @"Unsaved";
    } else {
        nibName = @"AKAUnsavedPopupViewController";
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            [markersFeed markAsUnsaved:array];
            NSLog(@"markAsUnsaved");
        }];
        self.saveBtn.title = @"Saved";
    }
    
    AKAPopupViewController *popUpView = [[AKAPopupViewController alloc]initWithNibName:nibName bundle:nil];
    [self presentPopupViewController:popUpView animationType:MJPopupViewAnimationFade];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
        });
    }];
}

//-- unreadを管理する
- (IBAction)tapUnread:(id)sender {
    NSString *nibName;
    NSArray *array = [NSArray arrayWithObjects:[_feed valueForKey:@"id"][_feedRow], nil];
    AKAMarkersFeed *markersFeed = [[AKAMarkersFeed alloc] init];
    
    if ([[_feed valueForKey:@"unread"][_feedRow] isEqualToNumber:[NSNumber numberWithBool:NO]]) {
        nibName = @"AKAUnreadPopupViewController";
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            [markersFeed keepUnread:array];
            NSLog(@"keepUnread");
        }];
        self.unreadBtn.title = @"Read";
    } else {
        nibName = @"AKAReadPopupViewController";
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            [markersFeed markAsRead:array];
            NSLog(@"markAsRead");
        }];
        self.unreadBtn.title = @"Unread";
    }
    
    AKAPopupViewController *popUpView = [[AKAPopupViewController alloc]initWithNibName:nibName bundle:nil];
    [self presentPopupViewController:popUpView animationType:MJPopupViewAnimationFade];
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissPopupViewControllerWithanimationType:MJPopupViewAnimationFade];
        });
    }];
}

//-- 1つ前のfeedを表示する
- (IBAction)tapUp:(id)sender {
    if (_feedRow != 0) {
        _feedRow = _feedRow - 1;
    } else { return;}
    
    /* DB更新 */
    if ([[_feed valueForKey:@"unread"][_feedRow] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            NSArray *array = [NSArray arrayWithObjects:[_feed valueForKey:@"id"][_feedRow], nil];
            AKAMarkersFeed *markersFeed = [[AKAMarkersFeed alloc] init];
            [markersFeed markAsRead:array];
        }];
    }
    
    [self.tableView reloadData];
    self.unreadBtn.title = @"Unread";
    [self reloadSaveBtn];
    [self reloadUpDownBtn];
}

//-- 1つ後のfeedを表示する
- (IBAction)tapDown:(id)sender {
    if (_feedRow != _feed.count -1) {
        _feedRow = _feedRow + 1;
    } else { return; }
    
    /* DB更新 */
    if ([[_feed valueForKey:@"unread"][_feedRow] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
            NSArray *array = [NSArray arrayWithObjects:[_feed valueForKey:@"id"][_feedRow], nil];
            AKAMarkersFeed *markersFeed = [[AKAMarkersFeed alloc] init];
            [markersFeed markAsRead:array];
        }];
    }
    
    [self.tableView reloadData];
    self.unreadBtn.title = @"Unread";
    [self reloadSaveBtn];
    [self reloadUpDownBtn];
}

@end
