//
//  HttpServiceHelper.m
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-20.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

#import "HttpServiceHelper.h"
#import "NetworkManager.h"
#import "NSDictionary+XMLParser.h"

@implementation HttpServiceHelper
static HttpServiceHelper *_sharedInst = nil;

+ (id) sharedService
{
	@synchronized(self){
		if(_sharedInst == nil)
		{
			_sharedInst = [[self alloc] init];
		}
	}
	return _sharedInst;
}

- (id) init
{
	if (self = [super init])
	{
		requests = [[NSMutableDictionary alloc] init];
        httpRequests = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(void)requestFinished:(ASIHTTPRequest *)request
{
    //返回数据大小
    NSString *_contentLengend = [request.responseHeaders valueForKey:@"Content-Length"];
    NSLog(@"size:%.3fKB",[_contentLengend intValue]/1024.0);
    
	NSString *backstring = [request responseString];
	NSLog(@"backstring %@",backstring);
	if (!backstring)
	{
        for (int i = 1; i < 30; i++)
		{
			backstring = [[[NSString alloc] initWithData:[request responseData] encoding:i] autorelease];
			NSLog(@"back %@ %d",backstring , i);
			if (backstring)
			{
				break;
			}
		}
	}
    
    HttpRequestType type = (HttpRequestType)[[request.userInfo objectForKey:@"type"] intValue];
    //在这里对返回的数据进行处理,下面为处理XML数据
    NSMutableDictionary *parsedData = [NSMutableDictionary dictionaryWithDictionary:[NSDictionary dictionaryFromXML:backstring withType:type]];

	//归档并写入缓存（这里需要对key值进行处理，避免出现"/"等字符）
    [Tools setObject:parsedData forkey:[request.url absoluteString]];

	NSDictionary *targetCallBack = [requests objectForKey:request.requestFlagMark];
	
    [[targetCallBack objectForKey:@"delegate"] performSelector:NSSelectorFromString([targetCallBack objectForKey:@"onsuccess"]) withObject:parsedData];

	[requests removeObjectForKey:request.requestFlagMark];
    
    [httpRequests removeObject:request];
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
	NSDictionary *targetCallBack = [requests objectForKey:request.requestFlagMark];
	NSLog(@"request %@ went wrong with status code %d, and feedback body %@",request.requestFlagMark, [request responseStatusCode], [request responseString]);
    
	NSData *data = [Tools objectForKey:[request.url absoluteString]];
	if (data)
	{
		NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		[[targetCallBack objectForKey:@"delegate"] performSelector:NSSelectorFromString([targetCallBack objectForKey:@"onsuccess"]) withObject:dic];
		//NSLog(@"cache dic %@",dic);
	}
	else
	{
		[[targetCallBack objectForKey:@"delegate"] performSelector:NSSelectorFromString([targetCallBack objectForKey:@"onfailed"]) withObject:@"connection error"];
	}
	[requests removeObjectForKey:request.requestFlagMark];
    
    [httpRequests removeObject: request];
}

- (void)requestForType:(HttpRequestType)type info:(NSDictionary *)requestInfo target:(id)target successSel:(NSString *)successSelector failedSel:(NSString *)failedSelector;
{
	NSString *urlString = nil;
    
	srand((unsigned)time(NULL)<<2);
    
	switch (type)
	{
		case Http_FretchAppVersion:
		{
//            urlString = @"http://111.11.28.30/app/ios/upgrade/IosUpdateSoftware.xml";
            urlString = @"http://111.11.28.9:8087/partyViewzq/phoneInterface.action?cmd=querycoursedetail&courseid=297edb1345079a96014507bc10630006";
		}break;
            
		default:
			break;
	}
    
	NSLog(@"urlString:%@",urlString);
    
    if (![Tools connectedToNetwork])
    {
        for (int i = 0; i < [httpRequests count]; ++i) {
            [self requestFailed:[httpRequests objectAtIndex:i]];
        }
        [self httpsCancel];
        
        NSDictionary *dic = (NSDictionary *)[Tools objectForKey:urlString];
        if(dic)
		{
            [target performSelector:NSSelectorFromString(successSelector) withObject:dic];
		}
        else
        {
            [target performSelector:NSSelectorFromString(failedSelector) withObject:dic];
        }
		return;
    }
	   
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
	request.requestFlagMark = [Tools generateBoundaryString];
    [httpRequests addObject:request];
    request.userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:type] forKey:@"type"];
    [request setUseCookiePersistence:NO];
    //登录成功后存储cookie
    NSData *oldData = [Tools objectForKey:@"Cookie"];
    NSMutableArray *cookie = [NSKeyedUnarchiver unarchiveObjectWithData:oldData];
    request.requestCookies = cookie;
    [request setShouldAttemptPersistentConnection:NO];
    [request setTimeOutSeconds:60];
    [request setDelegate:self];
    [request setDownloadProgressDelegate:self];
    request.showAccurateProgress = YES;
    
    NSLog(@"%@",cookie);

	if (target)
	{
		NSDictionary *tempDic = [NSDictionary dictionaryWithObjectsAndKeys:target, @"delegate", successSelector, @"onsuccess", failedSelector, @"onfailed", nil];
		[requests setObject:tempDic forKey:request.requestFlagMark];
	}
	[request setDelegate:self];
 	
	//异步
    [request startAsynchronous];
}

- (NSUInteger)retainCount{
	return NSUIntegerMax;
}

- (oneway void)release{
}

- (id)retain{
	return _sharedInst;
}

- (id)autorelease{
	return _sharedInst;
}

- (void)httpsCancel
{
    for(ASIHTTPRequest *httpRequest in httpRequests)
    {
        [httpRequest clearDelegatesAndCancel];
    }
    [httpRequests removeAllObjects];
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[internetReach release];
	[requests release];
    [httpRequests release];
	[super dealloc];
}

@end
