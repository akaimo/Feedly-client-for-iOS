//
//  AKADetailSettingViewController.m
//  rss
//
//  Created by akaimo on 2015/05/25.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKADetailSettingViewController.h"
#import "AKASettingViewController.h"

@interface AKADetailSettingViewController ()
@property (weak, nonatomic) IBOutlet UITableView *detailSettingTableView;

@property (weak, nonatomic) NSArray *saveDay;
@property (weak, nonatomic) NSArray *rightSwipe;
@property (weak, nonatomic) NSArray *leftSwipe;
@property (weak, nonatomic) NSArray *orderItems;

@end

@implementation AKADetailSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.settingIndexPath.row == 0) self.title = @"Keep Read Items";
    else if (self.settingIndexPath.row == 1) self.title = @"Slide Right to";
    else if (self.settingIndexPath.row == 2) self.title = @"Slide Left to";
    else if (self.settingIndexPath.row == 3) self.title = @"Order Items";
    
    _saveDay = [NSArray arrayWithObjects:@"Never", @"1 day", @"2 days", @"3 days", @"1 week", @"2 weeks", @"1 month", nil];
    _rightSwipe = [NSArray arrayWithObjects:@"No Action", @"Toggle Read", @"Toggle Saved", nil];
    _leftSwipe = [NSArray arrayWithObjects:@"No Action", @"Toggle Read", @"Toggle Saved", nil];
    _orderItems = [NSArray arrayWithObjects:@"Older First", @"Newest First", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int sd = (int)[ud integerForKey:@"SaveDay"];
    int rs = (int)[ud integerForKey:@"RightSwipe"];
    int ls = (int)[ud integerForKey:@"LeftSwipe"];
    int oi = (int)[ud integerForKey:@"OrderItems"];
    
    if (self.settingIndexPath.row == 0) {
        cell.textLabel.text = _saveDay[indexPath.row];
        if (indexPath.row == sd) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (self.settingIndexPath.row == 1) {
        cell.textLabel.text = _rightSwipe[indexPath.row];
        if (indexPath.row == rs) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (self.settingIndexPath.row == 2) {
        cell.textLabel.text = _leftSwipe[indexPath.row];
        if (indexPath.row == ls) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    else if (self.settingIndexPath.row == 3) {
        cell.textLabel.text = _orderItems[indexPath.row];
        if (indexPath.row == oi) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.settingIndexPath.row == 0) return SDend;
    else if (self.settingIndexPath.row == 1) return Rend;
    else if (self.settingIndexPath.row == 2) return Lend;
    else if (self.settingIndexPath.row == 3) return OrderEND;
    else return 0;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.detailSettingTableView reloadData];
    
    // 選択したセル以外のすべてのチェックを取る
    for (NSInteger index=0; index<[self.detailSettingTableView numberOfRowsInSection:0]; index++) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
        // 選択したセルだけチェックする
        if (indexPath.row == index) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    // 選択したデータを保存
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (self.settingIndexPath.row == 0) [ud setInteger:indexPath.row forKey:@"SaveDay"];
    else if (self.settingIndexPath.row == 1) [ud setInteger:indexPath.row forKey:@"RightSwipe"];
    else if (self.settingIndexPath.row == 2) [ud setInteger:indexPath.row forKey:@"LeftSwipe"];
    else if (self.settingIndexPath.row == 3) [ud setInteger:indexPath.row forKey:@"OrderItems"];
    [ud synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
