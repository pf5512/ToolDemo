//
//  NSDate-Helper.h
//  ViewImage
//
//  Created by QQ on 10-8-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSDate (Helpers)

- (NSString *)getFormatYearMonthDay;
- (int )getWeekNumOfMonth;
- (int )getWeekOfYear;
- (NSDate *)dateAfterDay:(int)day;    //几天后的时间
- (NSDate *)dateafterMonth:(int)month;//几月后的时间， 几月前的时间则传入month为 负数即可
- (NSUInteger)getDay;
- (NSUInteger)getMonth;
- (NSUInteger)getYear;
- (int )getHour;
- (int )getMinute;
- (int )getHour:(NSDate *)date;
- (int )getMinute:(NSDate *)date;
- (NSUInteger)daysAgo;           // 计算间隔多少天
- (NSUInteger)daysAgoWithDate: (NSDate *)date;

- (NSUInteger)daysAgoAgainstMidnight;
- (NSString *)stringDaysAgo;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSUInteger)weekday;
- (NSString *)weekdayWithPrefixString:(NSString *)preStr;

+ (NSDate *)dateFromString:(NSString *)string;
//////   [NSDate dateFromString:@"2011-5-12" withFormat:@"yyyy-M-dd"];
/////	NSDate *adate = [NSDate dateFromString:@"2011年5月12日" withFormat:@"yyyy年M月dd日"];
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed;

- (NSString *)string;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfMonth;
- (NSDate *)endOfMonth;
- (NSDate *)beginningOfDay;
- (NSDate *)endOfWeek;

+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSString *)dbFormatString;

@end