//
//  NetworkManager.h
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-20.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

/*
 注：该类负责处理网络状况变化时的行为
 */

@interface NetworkManager : NSObject
{
    Reachability* internetReach;
    NetworkStatus netStatus;
}

+ (NetworkManager *)defaultManager;

@end
