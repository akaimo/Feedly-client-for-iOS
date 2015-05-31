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
#import "AKADetailSettingViewController.h"
#import "PocketAPI.h"

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
    
    /* 次のViewの戻るボタンの設定 */
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
    
    self.title = @"Settings";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.section2CellName = @[@"Keep Read Items", @"Slide Right to", @"Slide Left to", @"Order Items"];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.settingTableView reloadData];
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
            dataCount += 2;
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
        // Accountについての設定
            if (indexPath.row == 0) {
                NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accounts] objectAtIndex:indexPath.row];
                NSDictionary *userData = (id)account.userData;
                NSString *name = [NSString stringWithFormat:@"%@ : %@", [userData valueForKey:@"client"], [[userData objectForKey:@"logins"][0] valueForKey:@"provider"]];
                
                cell.titleLabel.text = name;
            } else if (indexPath.row == 1) {
                cell.titleLabel.text = @"Pocket Login";
            } else if (indexPath.row == 2) {
                cell.titleLabel.text = @"Pocket Logout";
            }
            break;
        }
        case 1:{
        // クライアントの設定
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            int i;
            if (indexPath.row == 0) i = (int)[ud integerForKey:@"SaveDay"];
            else if (indexPath.row == 1) i = (int)[ud integerForKey:@"RightSwipe"];
            else if (indexPath.row == 2) i = (int)[ud integerForKey:@"LeftSwipe"];
            else if (indexPath.row == 3) i = (int)[ud integerForKey:@"OrderItems"];
            
            cell.titleLabel.text = self.section2CellName[indexPath.row];
            cell.detailLabel.text = [self selectDetailText:indexPath userDefaults:i];
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
        case 0:{    // Accountについての設定
            if (indexPath.row == 0) {
                // feedlyアカウント
                [self confirmLogout:indexPath];
                
            } else if (indexPath.row == 1) {
                // Pocketアカウント
                [[PocketAPI sharedAPI] loginWithHandler:^(PocketAPI *API, NSError *error){
                    if (error != nil) {
                        // error
                        NSLog(@"error");
                        return;
                    } else {
                        // login
                        NSLog(@"success");
                    }
                }];
            } else if (indexPath.row == 2) {
                NSLog(@"logout");
//                [[PocketAPI sharedAPI] logout];
                NSURL *url = [NSURL URLWithString:@"http://google.com"];
                              [[PocketAPI sharedAPI] saveURL:url handler: ^(PocketAPI *API, NSURL *URL, NSError *error){
                    if(error){
                        // there was an issue connecting to Pocket
                        // present some UI to notify if necessary
                        NSLog(@"erroe");
                    }else{
                        // the URL was saved successfully
                        NSLog(@"success");
                    }
                }];
            }
            
            break;
        }
            
        case 1:     // クライアントの設定
            [self performSegueWithIdentifier:@"Detail" sender:indexPath];
            break;
            
        default:
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Detail"]) {
        AKADetailSettingViewController *detailSettingViewController = (AKADetailSettingViewController *)[segue destinationViewController];
        detailSettingViewController.settingIndexPath = sender;
    }
}


#pragma mark - private
//-- ログアウトの確認
- (void)confirmLogout:(NSIndexPath *)indexPath {
    UIAlertController * ac = [UIAlertController alertControllerWithTitle:@"Logout"
                                                                 message:@"Really Logout this account?"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    // Cancel用のアクションを生成
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * action) {
                                                              // ボタンタップ時の処理
                                                          }];
    
    // OK用のアクションを生成
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * action) {
                                                          // ボタンタップ時の処理
                                                          NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accounts] objectAtIndex:indexPath.row];
                                                          [[NXOAuth2AccountStore sharedStore] removeAccount:account];
                                                          NSLog(@"account delete");
                                                          [_settingTableView reloadData];
                                                      }];
    
    // コントローラにアクションを追加
    [ac addAction:cancelAction];
    [ac addAction:okAction];
    
    // アラート表示処理
    [self presentViewController:ac animated:YES completion:nil];
}

//-- 一般設定のテキストを取得
- (NSString *)selectDetailText:(NSIndexPath *)indexPath userDefaults:(int)defaults {
    switch (indexPath.row) {
        case 0:
            if (defaults == Never)          return @"Never";
            else if (defaults == Day1)      return @"1 day";
            else if (defaults == Day2)      return @"2 days";
            else if (defaults == Day3)      return @"3 days";
            else if (defaults == Week1)     return @"1 week";
            else if (defaults == Week2)     return @"2 weeks";
            else if (defaults == Month1)    return @"1 month";
            else                            return @"";
            break;
            
        case 1:
            if (defaults == RNon)            return @"No Action";
            else if (defaults == RRead)      return @"Toggle Read";
            else if (defaults == RSaved)     return @"Toggle Saved";
            else                             return @"";
            break;
            
        case 2:
            if (defaults == LNon)            return @"No Action";
            else if (defaults == LRead)      return @"Toggle Read";
            else if (defaults == LSaved)     return @"Toggle Saved";
            else                             return @"";
            break;
            
        case 3:
            if (defaults == OlderFirst)         return @"Older First";
            else if (defaults == NewestFirst)   return @"Newest First";
            else                                return @"";
            
        default:
            return @"";
            break;
    }
}

@end
