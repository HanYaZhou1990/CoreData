//
//  HYZSqlite.m
//  HYZCoreData
//
//  Created by hanyazhou on 14-11-18.
//  Copyright (c) 2014年 韩亚周. All rights reserved.
//

#import "HYZSqlite.h"

@implementation HYZSqlite

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static HYZSqlite *sqlite = nil;

+ (HYZSqlite *)shareSqlite{
    @synchronized(self){
    if (!sqlite){
        sqlite = [[self alloc] init];
    }
    return sqlite;
	}
}

//插入数据
//创建数据上下文，调用insertNewObjectForName方法，创建两个数据记录NSManagedObject，然后就可以对之前数据模型编辑视图中定义的属性进行赋值。此时的数据只在内存中被修改，最后调用数据上下文的save方法，保存到持久层
- (void)insertCoreData:(NSDictionary *)informationDictionary tableName:(NSString *)tableName{
    NSManagedObjectContext *context = [self managedObjectContextWithableName:tableName];
    
    NSManagedObject *contactInfo = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:context];
    [contactInfo setValuesForKeysWithDictionary:informationDictionary];
    NSError *error;
    if(![context save:&error]){
        NSLog(@"不能保存：%@",[error localizedDescription]);
        }
}
//更新数据，如果已有数据就更新数据，如果没有，直接插入一行数据
- (void)updataCoreData:(NSDictionary *)informationDictionary tableName:(NSString *)tableName{
    NSFetchRequest *fetcheRequest = [[NSFetchRequest alloc] init];
    NSManagedObjectContext *context = [self managedObjectContextWithableName:tableName];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:tableName inManagedObjectContext:context];
    NSError *error;
    [fetcheRequest setEntity:entityDescription];
    NSArray *array =[context executeFetchRequest:fetcheRequest error:&error];
    NSManagedObject *contactInfo = nil;
    if ([array count] > 0) {
        contactInfo = [array objectAtIndex:0];
        [contactInfo setValuesForKeysWithDictionary:informationDictionary];
    }else {
        [self insertCoreData:informationDictionary tableName:tableName];
    }
    [context save:&error];
}
//查询数据
//在调用了insertCoreData之后，可以调用自定的查询方法dataFetchRequest来查询插入的数据
- (NSArray *)dataFetchRequestWithTableName:(NSString *)tableName{
    NSManagedObjectContext *context = [self managedObjectContextWithableName:tableName];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    return fetchedObjects;
    /*
    if ([fetchedObjects count] >0) {
        return fetchedObjects;
    }else{
//        当发现数据库里没数据的时候，插入一条空数据（想不起来当时为什么添加了，貌似有个地方出现了崩溃加的，但是想不起来，想起来以后再加注释）
        [self insertCoreData:nil tableName:tableName];
        return fetchedObjects;
    }*/
}
//删除数据
- (void)delCoreDataWithTableName:(NSString *)tableName{
    NSManagedObjectContext *context = [self managedObjectContextWithableName:tableName];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:tableName inManagedObjectContext:context];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:entityDescription];
    NSError *error;
    NSArray *array = [context executeFetchRequest:fetchRequest error:&error];
    if (!error) {
        if ([tableName isEqualToString:@"MyTest"]) {
            for (MyTest *object in array) {
                [context deleteObject:object];
            }
        }else{
            NSLog(@"another tableView");
        }
    }
    if ([context hasChanges]) {
        [context save:&error];
    }
}

- (void)saveContext{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
#pragma mark  - Core Data stack
#pragma mark  -
//被管理的数据上下文;初始化的后，必须设置持久化存储助理
- (NSManagedObjectContext *)managedObjectContextWithableName:(NSString *)tableName{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinatorWithableName:tableName];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}
//被管理的数据模型;初始化必须依赖.momd文件路径，而.momd文件由.xcdatamodeld文件编译而来
- (NSManagedObjectModel *)managedObjectModelWithableName:(NSString *)tableName{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HYZCoreData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
//持久化存储助理;初始化必须依赖NSManagedObjectModel，之后要指定持久化存储的数据类型，默认的是NSSQLiteStoreType，即SQLite数据库；并指定存储路径为Documents目录下，以及数据库名称
- (NSPersistentStoreCoordinator *)persistentStoreCoordinatorWithableName:(NSString *)tableName{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",tableName]];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModelWithableName:tableName]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}
/*根据某个谓词查询某张表里的数据*/
- (NSArray *)dataFetchRequestWithTableName:(NSString *)tableName predicateTitle:(NSString *)predicateTitleString predicate:(NSString *)predicateString{
     NSFetchRequest *request = [[NSFetchRequest alloc] init];
     NSEntityDescription *entityDescription = [NSEntityDescription entityForName:tableName inManagedObjectContext:[self managedObjectContextWithableName:tableName]];
     [request setEntity:entityDescription];
     NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==%@",predicateTitleString,predicateString]];
     [request setPredicate:predicate];
    return [[self managedObjectContextWithableName:tableName] executeFetchRequest:request error:nil];
}

/*根据谓词更新数据*/
- (void)updataCoreData:(NSString *)changeString tableName:(NSString *)tableName predicateTitle:(NSString *)predicateTitleString predicate:(NSString *)predicateString{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:tableName inManagedObjectContext:[self managedObjectContextWithableName:tableName]];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==%@",predicateTitleString,predicateString]];
    [request setPredicate:predicate];
    NSError *error = nil;
    for (MyTest *test in [[self managedObjectContextWithableName:tableName] executeFetchRequest:request error:&error]) {
        if ([predicateTitleString isEqualToString:@"test1"]) {
            test.test1 = changeString;
        }
    }
    if ([[self managedObjectContextWithableName:tableName] save:&error]) {
        printf("更新成功");
    }else {
        NSLog(@"更新失败的原因:%@",error);
    }
}

/*根据谓词删除数据*/
- (void)delCoreDataWithTableName:(NSString *)tableName predicateTitle:(NSString *)predicateTitleString predicate:(NSString *)predicateString{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:tableName inManagedObjectContext:[self managedObjectContextWithableName:tableName]];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@==%@",predicateTitleString,predicateString]];
    [request setPredicate:predicate];
    NSError *error = nil;
    for (MyTest *test in [[self managedObjectContextWithableName:tableName] executeFetchRequest:request error:&error]) {
        [[self managedObjectContextWithableName:tableName] deleteObject:test];
    }
    if ([[self managedObjectContextWithableName:tableName] save:&error]) {
        printf("删除成功");
    }else{
        NSLog(@"删除失败原因：%@",error);
    }
}

#pragma mark - Application's Documents directory
    //Documents目录路径
- (NSURL *)applicationDocumentsDirectory{
//    原来的数据路径在沙盒根目录下，不太合适，追加了一层路径
    NSString *pathString = [NSString stringWithFormat:@"%@/Documents/%@",NSHomeDirectory(),@"HYZSqlite"];
    NSFileManager *defaultManger = [NSFileManager defaultManager];
    BOOL isPath = NO;
    BOOL exisd = [defaultManger fileExistsAtPath:pathString isDirectory:&isPath];
    if (!(isPath == YES && exisd == YES)) {
        [defaultManger createDirectoryAtPath:pathString withIntermediateDirectories:YES attributes:nil error:nil];
        return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"HYZSqlite/"];
    }else{
        return [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"HYZSqlite/"];
    }
}
//获取当前时间的时间戳
+ (NSString *)getNowTimeStamp{
    NSDate *timeDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [timeDate timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%lf",time];
    return [[timeString componentsSeparatedByString:@"."] objectAtIndex:0];
}

    /*日期转换，时间戳转成时间*/
+ (NSString *)timeConversion:(NSString *)time{
    NSString *timeString = time;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss.ff "];
    NSString *timeDate = [dateFormat stringFromDate: date];
    return timeDate;
}
@end