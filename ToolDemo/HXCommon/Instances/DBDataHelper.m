//
//  DBDataHelper.m
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-20.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

#import "DBDataHelper.h"

@implementation DBDataHelper
{
    FMDatabase *localDB;
}
@synthesize dbFilePath;

static DBDataHelper *_sharedInst = nil;

+ (DBDataHelper *)sharedService
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInst=[[DBDataHelper alloc] init];
    });
    return _sharedInst;
}

- (id) init
{
	if (self = [super init])
	{
        //可以在这里设置DB的路径
	}
	return self;
}

- (void)dealloc
{
    [localDB close];
    [super dealloc];
}

- (BOOL)openDataBase
{
    localDB = [FMDatabase databaseWithPath:[DBDataHelper sharedService].dbFilePath];
    
    if (![localDB open])
    {
        NSLog(@"Could not open db.");
        return NO;
    }
    return YES;
}

- (void)closeDataBase
{
    [localDB close];
}

#pragma mark -
#pragma mark 数据库操作

@end
