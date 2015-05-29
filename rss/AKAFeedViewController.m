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
#import "MBProgressHUD.h"
#import "AKACoreData.h"
#import "AKASettingViewController.h"

@interface AKAFeedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *feedTableView;
- (IBAction)actionBtnTap:(id)sender;

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
    
    // スワイプジェスチャー
    UISwipeGestureRecognizer* swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeCell:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.feedTableView addGestureRecognizer:swipeGesture];
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeCell:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.feedTableView addGestureRecognizer:swipeGesture];
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
        cell.image.image = nil;
        if ([[_feed valueForKey:@"image"] valueForKey:@"image"][indexPath.row] == [NSNull null]) {
            // DBに存在しない
            
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//            dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_queue_t q_global = dispatch_queue_create("getImage", NULL);
            dispatch_queue_t q_main = dispatch_get_main_queue();
            dispatch_async(q_global, ^{
                // 画像読み込み
                NSString *imageURL = img[0];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: imageURL]]];
                
                // 画像を縮小
                UIImage *resizeImage = [self resizeImage:image];
                
                // 画像をDBへ保存
                id obj = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:[AKACoreData sharedCoreData].managedObjectContext];
                NSData *dataCropImage = UIImagePNGRepresentation(resizeImage);
                [obj setValue:dataCropImage forKey:@"image"];
                [[AKACoreData sharedCoreData] saveContext];
                [_feed[indexPath.row] setValue:obj forKey:@"image"];
                [[AKACoreData sharedCoreData] saveContext];
            
                
                // メインスレッドで表示
                dispatch_async(q_main, ^{
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    cell.image.layer.cornerRadius = 20.0f;
                    cell.image.layer.masksToBounds = YES;
                    cell.image.image = resizeImage;
                    [cell layoutSubviews];
                });
            });
        } else {
            // DBに存在する
            NSData *data = [[_feed valueForKey:@"image"] valueForKey:@"image"][indexPath.row];
            cell.image.layer.cornerRadius = 20.0f;
            cell.image.layer.masksToBounds = YES;
            cell.image.image = [UIImage imageWithData:data];

        }
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


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    /* 開いたときに既読にする */
    if ([[_feed valueForKey:@"unread"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        [self changeUnreadWithIndexPath:indexPath unread:[NSNumber numberWithBool:NO]];
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


#pragma mark - SwipeGesture
- (void)didSwipeCell:(UISwipeGestureRecognizer*)swipeRecognizer {
    CGPoint loc = [swipeRecognizer locationInView:self.feedTableView];
    NSIndexPath* indexPath = [self.feedTableView indexPathForRowAtPoint:loc];
//    AKAImgCustomCell *cell = (AKAImgCustomCell *)[self.feedTableView cellForRowAtIndexPath:indexPath];
    
    if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        // 右スワイプ
        [self rightSwipeWithIndexPath:indexPath];
    } else if (swipeRecognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        // 左スワイプ
        [self leftSwipeWithIndexPath:indexPath];
    }
}

//-- 右スワイプの処理
- (void)rightSwipeWithIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int rs = (int)[ud integerForKey:@"RightSwipe"];
    switch (rs) {
        case RNon:
            break;
            
        case RRead:
            if ([[_feed valueForKey:@"unread"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                // 既読にする
                [self changeUnreadWithIndexPath:indexPath unread:[NSNumber numberWithBool:NO]];
            } else {
                // 未読にする
                [self changeUnreadWithIndexPath:indexPath unread:[NSNumber numberWithBool:YES]];
            }
            break;
            
        case RSaved:
            if ([[_feed valueForKey:@"saved"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                // unsavedにする
                [self changeSavedWithIndexPath:indexPath saved:[NSNumber numberWithBool:NO]];
                
            } else {
                // savedにする
                [self changeSavedWithIndexPath:indexPath saved:[NSNumber numberWithBool:YES]];
            }
            break;
            
        default:
            break;
    }
}

//-- 左スワイプの処理
- (void)leftSwipeWithIndexPath:(NSIndexPath *)indexPath {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int ls = (int)[ud integerForKey:@"LeftSwipe"];
    switch (ls) {
        case LNon:
            break;
            
        case LRead:
            if ([[_feed valueForKey:@"unread"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                [self changeUnreadWithIndexPath:indexPath unread:[NSNumber numberWithBool:NO]];
            } else {
                [self changeUnreadWithIndexPath:indexPath unread:[NSNumber numberWithBool:YES]];
            }
            break;
            
        case LSaved:
            if ([[_feed valueForKey:@"saved"][indexPath.row] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                [self changeSavedWithIndexPath:indexPath saved:[NSNumber numberWithBool:NO]];
            } else {
                [self changeSavedWithIndexPath:indexPath saved:[NSNumber numberWithBool:YES]];
            }
            break;
            
        default:
            break;
    }
}

//-- 既読・未読の処理
- (void)changeUnreadWithIndexPath:(NSIndexPath *)indexPath unread:(NSNumber *)unread {
    /* feedlyへPOST */
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSArray *array = [NSArray arrayWithObjects:[_feed valueForKey:@"id"][indexPath.row], nil];
        AKAMarkersFeed *markersFeed = [[AKAMarkersFeed alloc] init];
        if ([unread isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            // 未読にする
            [markersFeed keepUnread:array];
        } else {
            // 既読にする
            [markersFeed markAsRead:array];
        }
    }];
    
    /* 配列内のデータも既読にする */
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.feed[_categoryRow][indexPath.row] setValue:unread forKey:@"unread"];
//    NSLog(@"%@", [_feed valueForKey:@"unread"][indexPath.row]);
    
    /* Cellを更新する */
    _feed = delegate.feed[_categoryRow];
    [_feedTableView reloadData];
}

//-- saved, unsavedの処理
- (void)changeSavedWithIndexPath:(NSIndexPath *)indexPath saved:(NSNumber *)saved {
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSArray *array = [NSArray arrayWithObjects:[_feed valueForKey:@"id"][indexPath.row], nil];
        AKAMarkersFeed *markersFeed = [[AKAMarkersFeed alloc] init];
        if ([saved isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            // savedにする
            [markersFeed markAsSaved:array];
        } else {
            // unsavedにする
            [markersFeed markAsUnsaved:array];
        }
    }];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.feed[_categoryRow][indexPath.row] setValue:saved forKey:@"saved"];
    
    _feed = delegate.feed[_categoryRow];
    [_feedTableView reloadData];
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


#pragma mark - Image
- (UIImage *)resizeImage:(UIImage *)image {
    UIImage *aImage = image;
    
    // 取得した画像の縦サイズ、横サイズを取得する
    int imageW = aImage.size.width;
    int imageH = aImage.size.height;
    
    // リサイズする倍率を作成する。
    float scale = (imageW > imageH ? 320.0f/imageH : 320.0f/imageW);
    
    // 比率に合わせてリサイズする。
    // ポイントはUIGraphicsXXとdrawInRectを用いて、リサイズ後のサイズで、
    // aImageを書き出し、書き出した画像を取得することで、
    // リサイズ後の画像を取得します。
    CGSize resizedSize = CGSizeMake(imageW * scale, imageH * scale);
    UIGraphicsBeginImageContext(resizedSize);
    [aImage drawInRect:CGRectMake(0, 0, resizedSize.width, resizedSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}


#pragma mark - Action
- (IBAction)actionBtnTap:(id)sender {
    // コントローラを生成
    UIAlertController * ac =
    [UIAlertController alertControllerWithTitle:nil
                                        message:@"Mark all items from this list as read?"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    // Cancel用のアクションを生成
    UIAlertAction * cancelAction =
    [UIAlertAction actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleCancel
                           handler:^(UIAlertAction * action) {
                               // ボタンタップ時の処理
                           }];
    
    // Destructive用のアクションを生成
    UIAlertAction * destructiveAction =
    [UIAlertAction actionWithTitle:@"Mark All as Read"
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * action) {
                               /* ボタンタップ時の処理
                                
                                  インジケータ表示     */
                               [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                               dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                                   /* 処理内容 */
                                   NSMutableArray *array = [NSMutableArray array];
                                   for (NSManagedObject *data in _feed) {
                                       [array addObject:[data valueForKey:@"id"]];
                                   }
                                   AKAMarkersFeed *markersFeed = [[AKAMarkersFeed alloc] init];
                                   [markersFeed markAsRead:array];
                                   NSLog(@"finish");
                                   
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [MBProgressHUD hideHUDForView:self.view animated:YES];
                                       [self.navigationController popViewControllerAnimated:YES];
                                   });
                               });
                               
                           }];
    
    // コントローラにアクションを追加
    [ac addAction:cancelAction];
    [ac addAction:destructiveAction];
    
    // アクションシート表示処理
    [self presentViewController:ac animated:YES completion:nil];
}

@end
