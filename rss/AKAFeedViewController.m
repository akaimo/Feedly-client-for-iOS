//
//  AKAFeedViewController.m
//  rss
//
//  Created by akaimo on 2015/04/27.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKAFeedViewController.h"
#import "AKAImgCustomCell.h"

@interface AKAFeedViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *feedTableView;

@end

@implementation AKAFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /* カスタムセルの定義 */
    UINib *nib = [UINib nibWithNibName:@"AKAImgCustomCell" bundle:nil];
    [self.feedTableView registerNib:nib forCellReuseIdentifier:@"Img"];
    UINib *nib2 = [UINib nibWithNibName:@"AKANoImgCustomCell" bundle:nil];
    [self.feedTableView registerNib:nib2 forCellReuseIdentifier:@"NoImg"];
    
    /* footer off */
    [self.navigationController setToolbarHidden:YES animated:YES];
    
//    self.title = [[_feed valueForKey:@"category"] valueForKey:@"name"][0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *img = [self imagesWithFeed:[_feed valueForKey:@"detail"][indexPath.row]];
    NSString *identifier;
    
    if (img.count == 0) {
        identifier = @"NoImg";
    } else {
        identifier = @"Img";
    }
    
    AKAImgCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    cell.title.text = [NSString stringWithFormat:[_feed valueForKey:@"title"][indexPath.row]];
    
    NSString *notag = [self noTagWithFeed:[_feed valueForKey:@"detail"][indexPath.row]];
    if (notag.length != 0) {
        cell.detail.text = notag;
    } else {
        cell.detail.text = @"";
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[[_feed valueForKey:@"timestamp"][indexPath.row] longLongValue] /1000.0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *date24 = [dateFormatter stringFromDate:date];
    cell.siteTitle.text = [NSString stringWithFormat:@"%@ | %@",date24, [[_feed valueForKey:@"site"] valueForKey:@"title"][indexPath.row]];
    
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
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _feed.count;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"Detail" sender:_feed[indexPath.row]];
}


//-- feedからimgのsrcを取り出す
- (NSArray *)imagesWithFeed:(NSString *)feed {
        if (!feed){
            return nil;
        }
    
    NSMutableArray *results = [NSMutableArray new];
        NSString* pattern = @"(<img.*?src=\\\")(?!.*rss.rssad.jp)(.*?)(\\\".*?>)";
    
        NSError* error = nil;
        NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
        if (error == nil){
            NSArray *matches = [regex matchesInString:feed options:0 range:NSMakeRange(0, feed.length)];
            for (NSTextCheckingResult *match in matches){
//                NSLog(@"hoge: %@", [feed substringWithRange:[match rangeAtIndex:2]]);
                [results addObject:[feed substringWithRange:[match rangeAtIndex:2]]];
            }
        }
    
    return results;
}

//-- feedからHTMLタグを取り除く
- (NSString *)noTagWithFeed:(NSString *)feed {
    if (!feed){
        return nil;
    }
    
    NSString* noteTitle = feed;
    NSLog(@"除去前：%@", noteTitle);
    /* 改行を除去 */
    NSString* regPattern = @"(\r|(\r?\n))";
    NSRegularExpression* regExp = [NSRegularExpression regularExpressionWithPattern:regPattern options:0 error:nil];
    noteTitle = [regExp stringByReplacingMatchesInString:noteTitle options:0 range:NSMakeRange(0, noteTitle.length) withTemplate:@""];
    NSLog(@"除去後：%@", noteTitle);
    /* HTMLタグを除去 */
    regPattern = @"<(\\\"[^\\\"]*\\\"|'[^']*'|[^'\\\">])*>";
    regExp = [NSRegularExpression regularExpressionWithPattern:regPattern options:1 error:nil];
    noteTitle = [regExp stringByReplacingMatchesInString:noteTitle options:0 range:NSMakeRange(0, noteTitle.length) withTemplate:@""];
    NSLog(@"除去後2：%@", noteTitle);
    
    return noteTitle;
}

@end
