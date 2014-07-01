//
//  NSDictionary+XMLParser.m
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-21.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

#import "NSDictionary+XMLParser.h"
#import "GDataXMLNode.h"

@interface NSDictionary(PrivateXMLParser)
//针对不同的返回数据做出不同的处理
+ (NSDictionary *)dictionaryWithAPPVersionXMLElement:(GDataXMLElement *)rootElement;

@end

@implementation NSDictionary (XMLParser)

+ (NSDictionary *)dictionaryFromXML:(NSString *)xmlString withType:(HttpRequestType)type
{
	NSError          *error         = nil;
	GDataXMLDocument *document      = [[[GDataXMLDocument alloc] initWithXMLString:xmlString options:0 error:&error] autorelease];
	NSDictionary     *newDictionary = nil;
	switch (type)
	{
		case Http_FretchAppVersion:
		{
			newDictionary = [NSDictionary dictionaryWithAPPVersionXMLElement:[document rootElement]];
		}break;
            
		default:
			break;
	}
	return newDictionary;
}

@end

@implementation NSDictionary(PrivateXMLParser)

+ (NSDictionary *)dictionaryWithAPPVersionXMLElement:(GDataXMLElement *)rootElement
{
    NSLog(@"rootElement  %@",rootElement);
    NSString *version = [[[rootElement elementsForName:@"product_publish_version"] objectAtIndex:0] stringValue];
    
    NSString *info = [[[rootElement elementsForName:@"product_lastVersionInfo"] objectAtIndex:0] stringValue];
    
    NSString *downloadUrl = [[[rootElement elementsForName:@"product_publish_apk"] objectAtIndex:0] stringValue];
    
    NSString *mustUpdate = [[[rootElement elementsForName:@"product_mustupdate"] objectAtIndex:0] stringValue];
    
    NSMutableDictionary *parsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:version,@"Version",info,@"Info",downloadUrl,@"URL",mustUpdate,@"MustUpdate",nil];
    
    return parsDic;
}

@end