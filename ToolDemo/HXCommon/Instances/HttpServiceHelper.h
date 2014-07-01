//
//  HttpServiceHelper.h
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-20.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

/*
 注：ASIHTTPRequest框架使用说明
    1、导入以下框架
     CFNetwork.framework
     SystemConfiguration.framework
     MobileCoreServices.framework
     CoreGraphics.framework
     libz.dylib
    2、需要libxml2.dylib(libxml2还需要设置连接选项-lxml2 和头文件搜索路径/usr/include/libxml2)
 */
#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "Reachability.h"

typedef enum{
    //在这里定义网络请求的类型,例如:
    Http_FretchAppVersion = 100
}HttpRequestType;

@interface HttpServiceHelper : NSObject
{
    NSMutableDictionary *requests;
    NSMutableArray *httpRequests;
    //判断网络是否连接
    Reachability* internetReach;
    NetworkStatus netStatus;
}

+ (HttpServiceHelper *)sharedService;
- (void)requestForType:(HttpRequestType)type info:(NSDictionary *)requestInfo target:(id)target successSel:(NSString *)successSelector failedSel:(NSString *)failedSelector;
- (void)httpsCancel;

@end
