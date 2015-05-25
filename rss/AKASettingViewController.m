//
//  AKASettingViewController.m
//  rss
//
//  Created by akaimo on 2015/05/10.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKASettingViewController.h"
#import "AKANavigationController.h"
#import "NXOauth2.h"
#import "AKASettingCustomCell.h"

@interface AKASettingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *settingTableView;
@property (strong, nonatomic) NSArray *section2CellName;

@end

@implementation AKASettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /* Menu追加 */
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(openVerticalMenu:)];
    
    /* カスタムセルの定義 */
    UINib *nib = [UINib nibWithNibName:@"AKASettingCustomCell" bundle:nil];
    [self.settingTableView registerNib:nib forCellReuseIdentifier:@"Radio"];
    
    self.title = @"Setting";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.section2CellName = @[@"保存日数", @"左スワイプ", @"右スワイプ"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section) {
        case 0:
            sectionName = @"Account";
            break;
            
        case 1:
            sectionName = @"General";
            break;
            
        default:
            break;
    }
    return sectionName;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    double footerHeight = 0.0;
    
    if (section != 1) {
        footerHeight = 30.0;
    }
    
    return footerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 120)];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger dataCount;
    
    switch (section) {
        case 0:
            dataCount = [[[NXOAuth2AccountStore sharedStore] accounts] count];
            break;
        case 1:
            dataCount = self.section2CellName.count;
            break;
        default:
            break;
    }
    return dataCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Radio";
    AKASettingCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    
    switch (indexPath.section) {
        case 0:{
            NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accounts] objectAtIndex:indexPath.row];
            NSDictionary *userData = (id)account.userData;
//            NSLog(@"%@", userData);
            NSString *name = [NSString stringWithFormat:@"%@ : %@", [userData valueForKey:@"client"], [[userData objectForKey:@"logins"][0] valueForKey:@"provider"]];
            
            cell.titleLabel.text = name;
            break;
        }
        case 1:{
            cell.titleLabel.text = self.section2CellName[indexPath.row];
            cell.detailLabel.text = @"hoge";
            break;
        }
        default:
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:{
            UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"Logout"
                                                                         message:@"Really Logout this account?"
                                                                  preferredStyle:UIAlertControllerStyleAlert];
            
            // Cancel用のアクションを生成
            UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction * action) {
                                                                      // ボタンタップ時の処理
//                                                                      NSLog(@"Cancel button tapped.");
                                                                  }];
            
            // OK用のアクションを生成
            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  // ボタンタップ時の処理
                                                                  NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accounts] objectAtIndex:indexPath.row];
                                                                  [[NXOAuth2AccountStore sharedStore] removeAccount:account];
                                                                  NSLog(@"account delete");
                                                                  [tableView reloadData];
                                                              }];
            
            // コントローラにアクションを追加
            [ac addAction:cancelAction];
            [ac addAction:okAction];
            
            // アラート表示処理
            [self presentViewController:ac animated:YES completion:nil];
            
            break;
        }
            
        case 1:
            NSLog(@"section1");
            break;
            
        default:
            break;
    }
}

@end
