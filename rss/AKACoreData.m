//
//  AKACoreData.m
//  rss
//
//  Created by akaimo on 2015/04/17.
//  Copyright (c) 2015年 akaimo. All rights reserved.
//

#import "AKACoreData.h"

@implementation AKACoreData {
    NSManagedObjectContext*         _managedObjectContext;          //  Core Dataコンテキスト。
}

static AKACoreData* _CoreData;

+ (AKACoreData*)sharedCoreData;
{
    //  共有するMBCoreDataをアプリケーション中に1つだけ作成。
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _CoreData = [[AKACoreData alloc] init];
    });
    return _CoreData;
}

//-- 永続性を保つために利用するファイルを指定
+ (NSURL*)url
{
    static NSURL* storeURL = nil;       //  Core Dataが利用するファイルのパス文字列。
    if (storeURL) {
        return storeURL;
    }
    storeURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    storeURL = [storeURL URLByAppendingPathComponent:@"AKACoreData.sqlite"];
    return storeURL;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
/*
     Core Dataモデルファイルディレクトリの指定
     Model.momdはディレクトリで、編集用のModel.xcdatamodeldから生成される実行時用ファイル群を収めている。
     NSManagedObjectModelの初期化にはこのディレクトリを指定する。
*/
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    NSManagedObjectModel* managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    

    //  Core Dataのオブジェクト群の永続性を保証するNSPersistentStoreCoordinatorを、扱うモデル情報NSManagedObjectModelを指定して作成。
    NSError *error = nil;
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
    //  自分のクラスオブジェクトからURLをもらうように変更。 [self class].url
    if (![coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self class].url options:nil error:&error]) {
        NSLog(@"永続ストアの設定に失敗 %@", [error localizedDescription]);
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"永続ストアへの保存に失敗 %@", [error localizedDescription]);
        }
    }
}


@end
