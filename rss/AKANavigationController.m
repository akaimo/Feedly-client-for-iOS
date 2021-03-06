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
    FCVerticalMenuItem *item1 = [[FCVerticalMenuItem alloc] initWithTitle:@"Unread"
                                                             andIconImage:[UIImage imageNamed:@"unreadIcon"]];
    
    FCVerticalMenuItem *item2 = [[FCVerticalMenuItem alloc] initWithTitle:@"Saved"
                                                             andIconImage:[UIImage imageNamed:@"savedIcon"]];
    
    FCVerticalMenuItem *item3 = [[FCVerticalMenuItem alloc] initWithTitle:@"Read"
                                                             andIconImage:[UIImage imageNamed:@"readIcon"]];
    
    FCVerticalMenuItem *item4 = [[FCVerticalMenuItem alloc] initWithTitle:@"All Items"
                                                             andIconImage:[UIImage imageNamed:@"allIcon"]];
    
    FCVerticalMenuItem *item5 = [[FCVerticalMenuItem alloc] initWithTitle:@"Settings"
                                                             andIconImage:[UIImage imageNamed:@"settingIcon"]];
    
    FCVerticalMenuItem *item6 = [[FCVerticalMenuItem alloc] initWithTitle:@"Sync"
                                                             andIconImage:[UIImage imageNamed:@"syncIcon"]];
    
    item1.actionBlock = ^{
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.feedStatus = UnreadItems;
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UnreadViewController"];
//        [self setViewControllers:@[vc] animated:NO];
        [self pushViewController:vc animated:NO];
        
    };
    item2.actionBlock = ^{
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.feedStatus = SavedItems;
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UnreadViewController"];
//        [self setViewControllers:@[vc] animated:NO];
        [self pushViewController:vc animated:NO];
        
    };
    item3.actionBlock = ^{
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.feedStatus = ReadItems;
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UnreadViewController"];
//        [self setViewControllers:@[vc] animated:NO];
        [self pushViewController:vc animated:NO];
        
    };
    item4.actionBlock = ^{
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.feedStatus = AllItems;
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UnreadViewController"];
//        [self setViewControllers:@[vc] animated:NO];
        [self pushViewController:vc animated:NO];
        
    };
    item5.actionBlock = ^{
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"SettingViewController"];
//        [self setViewControllers:@[vc] animated:NO];
        [self pushViewController:vc animated:NO];
    };
    item6.actionBlock = ^{
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UnreadViewController"];
        AKASynchronized *synchronized = [[AKASynchronized alloc] init];
        [synchronized synchro:vc.unreadTableView];
        
    };
    
    
    _verticalMenu = [[FCVerticalMenu alloc] initWithItems:@[item1, item2, item3, item4, item5, item6]];
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
