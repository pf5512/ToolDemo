//
//  NetworkManager.m
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-20.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

static NetworkManager *_sharedInst = nil;

+ (NetworkManager *)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInst=[[NetworkManager alloc] init];
    });
    return _sharedInst;
}

- (id) init
{
	if (self = [super init])
	{
		//通知 (网络状态变化)
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(reachabilityChangedRecent:) name: kReachabilityChangedNotification object: nil];
		//Change the host name here to change the server your monitoring
		internetReach = [[Reachability reachabilityForInternetConnection]retain];
	    [internetReach startNotifier];
		netStatus = [internetReach currentReachabilityStatus];
	}
	
	return self;
}

#pragma mark Reachability
//监视网络状态,状态变化调用该方法.
- (void)reachabilityChangedRecent: (NSNotification* )note
{
	netStatus = [internetReach currentReachabilityStatus];
	if (netStatus != kNotReachable)
	{
		//网络可用
		NSLog(@"reachabilityChangedRecent-->网络可用");
    }
	else
	{
		//网络不可用
		NSLog(@"reachabilityChangedRecent-->网络不可用");
        [Tools ErrorAlert:@"网络不可用" withTitle:@"提示"];
	}
}

@end
