//
//  AppDelegate.m
//  rss
//
//  Created by akaimo on 2015/04/01.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AppDelegate.h"
#import "NXOAuth2.h"

@interface AppDelegate ()

@end

//-- for Feedly Oauth2(sandbox)
NSString * const kOauth2ClientAccountType = @"Feedly";                                      // account type
static NSString * const kOauth2ClientClientId = @"sandbox";                                 // clientId
static NSString * const kOauth2ClientClientSecret = @"A4143F56J75FGQY7TAJM";                // Client Secret
static NSString * const kOauth2ClientRedirectUrl = @"http://localhost";                     // Redirect Url
static NSString * const kOauth2ClientBaseUrl = @"https://sandbox.feedly.com";               // base url
static NSString * const kOauth2ClientAuthUrl = @"/v3/auth/auth";                            // auth url
static NSString * const kOauth2ClientTokenUrl = @"/v3/auth/token";                          // token url
static NSString * const kOauth2ClientScopeUrl = @"https://cloud.feedly.com/subscriptions";  // scope url
static NSString *const kOauth2ClientKeyChainGroup = @"Feedly";                              // keyChainGroup

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *viewController;
    
    if([[[NXOAuth2AccountStore sharedStore] accounts] count] == 0){
        viewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavigationController"];
    } else {
        NXOAuth2Account *account = [[[NXOAuth2AccountStore sharedStore] accounts] objectAtIndex:0];
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        delegate.account = account;

        viewController = [storyboard instantiateViewControllerWithIdentifier:@"FeedNavigationController"];
    }
    
    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

+ (void)initialize {
    
    NSString *authUrl = [kOauth2ClientBaseUrl stringByAppendingString:kOauth2ClientAuthUrl];
    NSString *tokenUrl = [kOauth2ClientBaseUrl stringByAppendingString:kOauth2ClientTokenUrl];
    
    // setup oauth2client
    [[NXOAuth2AccountStore sharedStore] setClientID:kOauth2ClientClientId
                                             secret:kOauth2ClientClientSecret
                                              scope:[NSSet setWithObjects:kOauth2ClientScopeUrl, nil]
                                   authorizationURL:[NSURL URLWithString:authUrl]
                                           tokenURL:[NSURL URLWithString:tokenUrl]
                                        redirectURL:[NSURL URLWithString:kOauth2ClientRedirectUrl]
                                      keyChainGroup:kOauth2ClientKeyChainGroup
                                     forAccountType:kOauth2ClientAccountType];
    
}

@end
