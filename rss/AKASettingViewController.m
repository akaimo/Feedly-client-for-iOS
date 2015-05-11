//
//  AKASettingViewController.m
//  rss
//
//  Created by akaimo on 2015/05/10.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKASettingViewController.h"
#import "AKANavigationController.h"

@interface AKASettingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *settingTableView;

@end

@implementation AKASettingViewController

- (id)init {
    // 図1
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        // ・・・・
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /* Menu追加 */
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStylePlain target:self.navigationController action:@selector(openVerticalMenu:)];
    
    self.title = @"Setting";
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger dataCount;
    
    // テーブルに表示するデータ件数を返す
    switch (section) {
        case 0:
//            dataCount = self.dataSourceiPhone.count;
            dataCount = 2;
            break;
        case 1:
//            dataCount = self.dataSourceAndroid.count;
            dataCount = 4;
            break;
        default:
            break;
    }
    return dataCount;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName = @"hoge";
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    // 再利用できるセルがあれば再利用する
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"section1";
            break;
        case 1:
            cell.textLabel.text = @"section2";
            break;
        default:
            break;
    }
    
    return cell;
}

@end
