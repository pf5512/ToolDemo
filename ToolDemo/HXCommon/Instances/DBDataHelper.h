//
//  DBDataHelper.h
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-20.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

/*
 注：使用FMDatabase框架需要导入libsqlite3.0
 */

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface DBDataHelper : NSObject

@property (nonatomic, retain) NSString *dbFilePath;

+ (DBDataHelper *)sharedService;
- (BOOL)openDataBase;
- (void)closeDataBase;

//以下为数据库操作方法，根据需求添加

@end
