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

@interface AKADetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AKADetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINib *nib = [UINib nibWithNibName:@"AKADetailCustomCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"Detail"];
//    UINib *nib2 = [UINib nibWithNibName:@"AKANoImgCustomCell" bundle:nil];
//    [self.feedTableView registerNib:nib2 forCellReuseIdentifier:@"NoImg"];
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
    
    if (img.count == 0) {
        AKADetailCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Detail" forIndexPath:indexPath];
        
        cell.title.text = [_feed valueForKey:@"title"][_feedRow];
        
        NSString *notag = [regularExpression noTagWithFeed:[_feed valueForKey:@"detail"][_feedRow]];
        if (notag.length != 0) {
            cell.detail.text = notag;
        } else {
            cell.detail.text = @"";
        }
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Feed"];
        
        UILabel *label1 = (UILabel*)[cell viewWithTag:1];
        UILabel *label2 = (UILabel*)[cell viewWithTag:2];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:3];
        
        label1.text = [_feed valueForKey:@"title"][_feedRow];
        label2.text = [regularExpression noTagWithFeed:[_feed valueForKey:@"detail"][_feedRow]];
        if (img.count != 0) {
            dispatch_queue_t q_global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_queue_t q_main = dispatch_get_main_queue();
            imageView.image = nil;
            dispatch_async(q_global, ^{
                NSString *imageURL = img[0];
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString: imageURL]]];
                
                dispatch_async(q_main, ^{
                    imageView.image = image;
                    [cell layoutSubviews];
                });
            });
        }
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSArray *array = [NSArray arrayWithObjects:_feed, indexPath, nil];
//    [self performSegueWithIdentifier:@"Detail" sender:array];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"Detail"]) {
//        AKADetailViewController *detailViewController = (AKADetailViewController *)[segue destinationViewController];
//        detailViewController.title = self.title;
//        detailViewController.feed = sender[0];
//        detailViewController.feedRow = [sender[1] row];
//    }
}

@end
