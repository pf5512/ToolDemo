//
//  NSDictionary+XMLParser.h
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-21.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpServiceHelper.h"

@interface NSDictionary (XMLParser)

+ (NSDictionary *)dictionaryFromXML:(NSString *)xmlString withType:(HttpRequestType)type;

@end

