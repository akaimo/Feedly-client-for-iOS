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

@interface AKADetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)unRead:(id)sender;

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
    cell.date.text = [NSString stringWithFormat:@"%@\n%@",date24, [[_feed valueForKey:@"site"] valueForKey:@"title"][_feedRow]];
    
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
    CGFloat pad = 30.0 + 5.0 + 20.0 + 10.0 + 30.0 + 20.0;
    
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
    
    height = boundingRectTitle.size.height + img + boundingRectDetail.size.height + pad;
    
    return height;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 600;
//}


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

- (IBAction)unRead:(id)sender {
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        NSArray *array = [NSArray arrayWithObjects:[_feed valueForKey:@"id"][_feedRow], nil];
        AKAMarkersFeed *markersFeed = [[AKAMarkersFeed alloc] init];
        [markersFeed keepUnread:array];
    }];
}
@end
