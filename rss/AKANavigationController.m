//
//  AKANavigationController.m
//  rss
//
//  Created by akaimo on 2015/05/08.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKANavigationController.h"
#import "AppDelegate.h"
#import "UnreadViewController.h"
#import "AKASynchronized.h"

@interface AKANavigationController ()

@end

@implementation AKANavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureVerticalMenu];
    self.verticalMenu.delegate = self;
    
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.barTintColor = [UIColor colorWithRed:61/255.0 green:173/255.0 blue:204/255.0 alpha:1.0];
//    self.verticalMenu.liveBlurBackgroundStyle = self.navigationBar.barStyle;
    self.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - FCVerticalMenu Configuration
- (void)configureVerticalMenu {
    FCVerticalMenuItem *item1 = [[FCVerticalMenuItem alloc] initWithTitle:@"Feedly" andIconImage:[UIImage imageNamed:@"feedlyIcon"]];
    
    FCVerticalMenuItem *item2 = [[FCVerticalMenuItem alloc] initWithTitle:@"Pocket" andIconImage:[UIImage imageNamed:@"pocketIcon"]];
    
    FCVerticalMenuItem *item3 = [[FCVerticalMenuItem alloc] initWithTitle:@"Settings" andIconImage:[UIImage imageNamed:@"settingIcon"]];
    
    item1.actionBlock = ^{
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (delegate.feedStatus == 0) {
            NSLog(@"hoge");
            delegate.feedStatus = UnreadItems;
        }
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UnreadViewController"];
        [self pushViewController:vc animated:NO];
        
    };
    item2.actionBlock = ^{
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"PocketViewController"];
        [self pushViewController:vc animated:NO];
        
    };
    item3.actionBlock = ^{
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SettingViewController"];
        [self pushViewController:vc animated:NO];
        
    };
    
    
    _verticalMenu = [[FCVerticalMenu alloc] initWithItems:@[item1, item2, item3]];
    _verticalMenu.appearsBehindNavigationBar = YES;
    
}

-(IBAction)openVerticalMenu:(id)sender {
    if (_verticalMenu.isOpen)
        return [_verticalMenu dismissWithCompletionBlock:nil];
    
    [_verticalMenu showFromNavigationBar:self.navigationBar inView:self.view];
}



#pragma mark - FCVerticalMenu Delegate Methods

-(void)menuWillOpen:(FCVerticalMenu *)menu {
//    NSLog(@"menuWillOpen hook");
}

-(void)menuDidOpen:(FCVerticalMenu *)menu {
//    NSLog(@"menuDidOpen hook");
}

-(void)menuWillClose:(FCVerticalMenu *)menu {
//    NSLog(@"menuWillClose hook");
}

-(void)menuDidClose:(FCVerticalMenu *)menu {
//    NSLog(@"menuDidClose hook");
}

@end
