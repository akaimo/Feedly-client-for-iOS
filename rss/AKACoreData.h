//
//  AKACoreData.h
//  rss
//
//  Created by akaimo on 2015/04/17.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKACoreData : NSObject

//  アプリケーション内で共有するMBCoreDataを戻す。
+ (AKACoreData*)sharedCoreData;

//  利用するファイルのフルパスをNSURLで戻す。
+ (NSURL*)url;

//  利用しているNSManagedObjectContextを戻す。
- (NSManagedObjectContext *)managedObjectContext;

//  保存する。
- (void)saveContext;

@end
