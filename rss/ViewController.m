//
//  ViewController.m
//  rss
//
//  Created by akaimo on 2015/04/01.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "ViewController.h"
#import "NXOauth2.h"
#import "objc/message.h"
#import "AppDelegate.h"
#import "UnreadViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *authTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
- (IBAction)editAction:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"Account";
    
    // tableview inset
    _authTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    // 次のViewの戻るボタンの設定
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationItem.backBarButtonItem = barButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    // footer on
    [self.navigationController setToolbarHidden:NO animated:YES];

    // reload account data
    [_authTableView reloadData];
    [super viewWillAppear:animated];
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"accountViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accounts] objectAtIndex:indexPath.row];
    NSDictionary *userData = (id)account.userData;
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *name = [NSString stringWithFormat:@"%@:%ld", [appDelegate jsonToString:[[userData valueForKey:@"logins"] valueForKey:@"provider"]], (long)indexPath.row ];
    cell.textLabel.text = name;
    
    cell.detailTextLabel.text = account.identifier;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //number of account
    return [[[NXOAuth2AccountStore sharedStore] accounts] count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSArray *accounts = [[NXOAuth2AccountStore sharedStore] accounts];
    for (NXOAuth2Account *account in accounts) {
        if ([account.identifier isEqualToString:cell.detailTextLabel.text]) {
            //delete account
            [[NXOAuth2AccountStore sharedStore] removeAccount:account];
            break;
        }
    }
    
    //delete tableview cell
    NSArray *deleteIndexs = [NSArray arrayWithObject:indexPath];
    [tableView deleteRowsAtIndexPaths:deleteIndexs withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accounts] objectAtIndex:indexPath.row];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.account = account;
    [self performSegueWithIdentifier:@"Unread" sender:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"Unread"]) {
//        UnreadViewController *unreadViewController = (UnreadViewController *)[segue destinationViewController];
//        unreadViewController.account = sender;
//    }
}

- (IBAction)editAction:(id)sender {
    if (_authTableView.editing) {
        [_authTableView setEditing:NO animated:YES];
        _editButton.title = @"Edit";
        
    } else {
        [_authTableView setEditing:YES animated:YES];
        _editButton.title = @"Done";
    }
}

@end
