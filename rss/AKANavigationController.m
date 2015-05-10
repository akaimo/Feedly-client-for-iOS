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

@interface AKANavigationController ()

@end

@implementation AKANavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureVerticalMenu];
    self.verticalMenu.delegate = self;
    
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.barTintColor = [UIColor colorWithRed:61/255.0 green:153/255.0 blue:194/255.0 alpha:1.0];
//    self.verticalMenu.liveBlurBackgroundStyle = self.navigationBar.barStyle;
    self.navigationBar.tintColor = [UIColor colorWithRed:133/255.0 green:230/255.0 blue:255/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - FCVerticalMenu Configuration
- (void)configureVerticalMenu {
    FCVerticalMenuItem *item1 = [[FCVerticalMenuItem alloc] initWithTitle:@"Unread"
                                                             andIconImage:nil];
    
    FCVerticalMenuItem *item2 = [[FCVerticalMenuItem alloc] initWithTitle:@"Saved"
                                                             andIconImage:nil];
    
    FCVerticalMenuItem *item3 = [[FCVerticalMenuItem alloc] initWithTitle:@"Read"
                                                             andIconImage:nil];
    
    FCVerticalMenuItem *item4 = [[FCVerticalMenuItem alloc] initWithTitle:@"All Items"
                                                             andIconImage:nil];
    
    FCVerticalMenuItem *item5 = [[FCVerticalMenuItem alloc] initWithTitle:@"Settings"
                                                             andIconImage:[UIImage imageNamed:@"settingIcon"]];
    
    item1.actionBlock = ^{
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.feedStatus = UnreadItems;
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UnreadViewController"];
        [self setViewControllers:@[vc] animated:NO];
        
    };
    item2.actionBlock = ^{
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.feedStatus = SavedItems;
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UnreadViewController"];
        [self setViewControllers:@[vc] animated:NO];
        
    };
    item3.actionBlock = ^{
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.feedStatus = ReadItems;
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UnreadViewController"];
        [self setViewControllers:@[vc] animated:NO];
        
    };
    item4.actionBlock = ^{
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.feedStatus = AllItems;
        UnreadViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"UnreadViewController"];
        [self setViewControllers:@[vc] animated:NO];
        
    };
    item5.actionBlock = ^{
        NSLog(@"test element 5");
    };
    
    
    _verticalMenu = [[FCVerticalMenu alloc] initWithItems:@[item1, item2, item3, item4, item5]];
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
