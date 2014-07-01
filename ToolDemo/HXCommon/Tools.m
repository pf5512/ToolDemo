//
//  Tools.m
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-18.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

#import "Tools.h"
#import "Reachability.h"
#import <netinet/in.h>
#import <QuartzCore/QuartzCore.h>
#import "FTWCache.h"
#import "DBDataHelper.h"
#import "NetworkManager.h"
#import "PendulumView.h"

@implementation Tools

#pragma mark -
#pragma mark 获取设备信息
//获取设备版本号
+ (NSString *)currentVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

//获取设备名称
+ (NSString *)deviceNickName
{
    return [[UIDevice currentDevice] name];
}

//获取设备类型
+ (NSString *)deviceModel
{
     return [[UIDevice currentDevice] model];
}

//判断是否为iPhone 5
+ (BOOL)isiPhone5
{
    if (iPhone5)
    {
        return  YES;
    }
    return NO;
}

//判断设备是iphone还是ipad
+ (BOOL)getDevieIsPhone
{
	UIDevice *myDevice = [UIDevice currentDevice];
	if ([[myDevice model] isEqualToString:@"iPad"])
	{
		return NO;
	} else {
		return YES;
	}
}

#pragma mark -
#pragma mark 检测网络连接状况
/*
 此函数用于判断网络连接状况
 连接正常返回YES
 无连接返回NO
 
 需要注意的是：函数为底层调用，只能判断手机是否接入网络，不能判断其他网络问题（如服务器响应与否）
 */
+ (BOOL)connectedToNetwork
{
	//创建零地址，0.0.0.0的地址表示查询本机的网络连接状态
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	// Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	//获得连接的标志
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	CFRelease(defaultRouteReachability);
	//如果不能获取连接标志，则不能连接网络，直接返回
	if (!didRetrieveFlags)
	{
		return NO;
	}
	//根据获得的连接标志进行判断
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	BOOL isWWAN = flags & kSCNetworkReachabilityFlagsIsWWAN;
	return (isReachable && (!needsConnection || isWWAN)) ? YES : NO;
}

// 检测可用的网络环境是否为wifi
+ (BOOL)isEnableWIFI {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

// 检测可用的网络环境是否为3G
+ (BOOL)isEnable3G {
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}

// 全局监控网络状态
+ (void)networkStatus
{
    [NetworkManager defaultManager];
}

#pragma mark -
#pragma mark 错误提示
//信息提示
+ (void)ErrorAlert:(NSString *)errorMsg withTitle:(NSString *)titleMsg;
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titleMsg
													message:errorMsg
												   delegate:nil
										  cancelButtonTitle:@"确定"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

#pragma mark -
#pragma mark 时间转换函数模块
/*
 此函数模块用于转换时间戳为格式化时间
 
 输入参数：1970自今的秒数时间戳
 输出参数：格式化的时间字符串
 错误处理：如果传入时间戳为空，返回空字符串
 */

//转换时间格式，精确到秒数
+ (NSString *)convertTimeStyleToSecond:(NSString *)timeStr;
{
	if (timeStr) {
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStr doubleValue]];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
		NSString *timeString = [formatter stringFromDate:date];
		[formatter release];
		return timeString;
	} else {
		NSLog(@"传入时间戳为空");
		return @"";
	}
}

//转换时间格式，精确到分钟
+ (NSString *)convertTimeStyleToMin:(NSString *)timeStr
{
	if (timeStr) {
		NSDate *date=[NSDate dateWithTimeIntervalSince1970:[timeStr doubleValue]];
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy.MM.dd HH:mm"];
		NSString* timeString = [formatter stringFromDate:date];
		[formatter release];
		return timeString;
	}	else {
		NSLog(@"传入时间戳为空");
		return @"";
	}
}

//转换时间格式，精确到天数
+ (NSString *)convertTimeStyleToDay:(NSString *)timeStr
{
	if (timeStr) {
		NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeStr doubleValue]];
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		NSString *timeString = [formatter stringFromDate:date];
		[formatter release];
		return timeString;
	}
	else {
		NSLog(@"传入时间戳为空");
		return @"";
	}
}

//日期性质转换为 秒数的形式
+ (int)convertMinStyleToTime:(NSString *)timeStr
{
    int timeLengh = 0;
    if (timeStr)
    {
        NSArray *timeArray = [timeStr componentsSeparatedByString:@":"];
        if (timeArray && [timeArray count] == 3)
        {
            int hours = [[timeArray objectAtIndex:0] intValue];
            int minutes = [[timeArray objectAtIndex:1] intValue];
            int secondes = [[timeArray objectAtIndex:2] intValue];
            timeLengh = hours * 3600 + minutes *60 + secondes;
        }
        else if (timeArray && [timeArray count] == 1)
        {
            timeLengh = [[timeArray objectAtIndex:0] intValue];
        }
    }
    return  timeLengh;
}

//秒数转换为日期性质的形式
+ (NSString *)convertSecondToDay:(int)second
{
	int timeOut = second;
	int hours = timeOut/(60*60);
	if (hours > 60)
	{
		hours = hours%60;
	}
	
	int minutes = timeOut/(60);
	if (minutes > 60)
	{
		minutes = minutes%60;
	}
	
	int seconds = timeOut%(60);
	NSString *hourStr;
	NSString *minuteStr;
	NSString *secondStr;
	
	if (hours < 10)
	{
		hourStr = [NSString stringWithFormat:@"0%d", hours];
	}
	else
	{
		hourStr = [NSString stringWithFormat:@"%d", hours];
	}
	
	if (minutes < 10)
	{
		minuteStr = [NSString stringWithFormat:@"0%d", minutes];
	}
	else
	{
		minuteStr = [NSString stringWithFormat:@"%d", minutes];
	}
	
	if (seconds < 10)
	{
		secondStr = [NSString stringWithFormat:@"0%d", seconds];
	}
	else
	{
		secondStr = [NSString stringWithFormat:@"%d", seconds];
	}
	
	NSString *timeString = [NSString stringWithFormat:@"%@ : %@ : %@",hourStr,minuteStr,secondStr];
	return timeString;
}

//时间转化为时间戳
+ (NSString *)timeToTimeStamp:(NSDate *)date
{
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return timeSp;
}

//获取当前时间"yyyy-MM-dd hh:mm:ss"
+ (NSString *)getNowTime
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    return  [formatter stringFromDate:date];
}

//返回年份
+ (NSUInteger)getYear:(NSDate *)date
{
    return [date getYear];
}

//返回月份
+ (NSUInteger)getMonth:(NSDate *)date
{
    return [date getMonth];
}

//返回日
+ (NSUInteger)getDay:(NSDate *)date
{
    return [date getDay];
}

//返回时
+ (int)getHour:(NSDate *)date
{
    return [date getHour];
}

//返回分
+ (int)getMinute:(NSDate *)date
{
    return [date getMinute];
}

//返回该日期属于本年度的第几周
+ (int)getWeekOfYear:(NSDate *)date
{
    return [date getWeekOfYear];
}

#pragma mark -
#pragma mark 判断模块
// 判断该email是否合法
+ (BOOL)isMatchedEmail:(NSString *)str
{
    NSRegularExpression *regularexpression = [[NSRegularExpression alloc]
                                              initWithPattern:@"^[a-zA-Z0-9_\\-\\.]+@[a-zA-Z0-9]+(\\.(com|cn|org|edu|hk))$"
                                              options:NSRegularExpressionCaseInsensitive
                                              error:nil];
    NSUInteger numberofMatch = [regularexpression numberOfMatchesInString:str
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, str.length)];
    [regularexpression release];
    
    if (numberofMatch == 0) {
        return NO;
    }
	return YES;
}

// 判断该mobile number是否合法（因为虚拟运营商的原因，该方法待扩充）
+ (BOOL)isMatchedMobile:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
        || ([regextestphs evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//将手机号码转化为标准形式
+ (NSString *)formatTelephoneNumber:(NSString *)telephone
{
    return [telephone telephoneWithReformat];
}

#pragma mark -
#pragma mark UIView相关
/*
 此函数用于将图片变灰
 输入参数：(UIImage *)需要改变的图片
 输出参数：(UIImage *)变色后的图片
 */
+ (UIImage *) convertToGrayStyle:(UIImage *)img
{
    int kRed = 1;
    int kGreen = 2;
    int kBlue = 4;
    int colors = kGreen;
    int m_width = img.size.width;
    int m_height = img.size.height;
    uint32_t *rgbImage = (uint32_t *) malloc(m_width * m_height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImage, m_width, m_height, 8, m_width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, m_width, m_height), [img CGImage]);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // now convert to grayscale
    uint8_t *m_imageData = (uint8_t *) malloc(m_width * m_height);
    for(int y = 0; y < m_height; y++) {
        for(int x = 0; x < m_width; x++) {
            uint32_t rgbPixel=rgbImage[y*m_width+x];
            uint32_t sum=0,count = 0;
            
            if (colors & kRed) {
                sum += (rgbPixel>>24) & 255;
                count++;
            }
            
            if (colors & kGreen) {
                sum += (rgbPixel>>16) & 255;
                count++;
            }
            
            if (colors & kBlue) {
                sum += (rgbPixel>>8) & 255;
                count++;
            }
            m_imageData[y*m_width+x]=sum/count;
        }
    }
    free(rgbImage);
    // convert from a gray scale image back into a UIImage
    uint8_t *result = (uint8_t *) calloc(m_width * m_height * sizeof(uint8_t) * 4, 1);
    // process the image back to rgb
    for(int i = 0; i < m_height * m_width; i++) {
        result[i*4] = 0;
        int val = m_imageData[i];
        result[i*4+1] = val;
        result[i*4+2] = val;
        result[i*4+3] = val;
    }
    free(m_imageData);
    // create a UIImage
    colorSpace = CGColorSpaceCreateDeviceRGB();
    context = CGBitmapContextCreate(result, m_width, m_height, 8, m_width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    // make sure the data will be released by giving it to an autoreleased NSData
    [NSData dataWithBytesNoCopy:result length:m_width * m_height];
    
    return resultUIImage;
}

//设置个边框并且给个颜色
+ (UIView *)setButtnBorderColor:(UIView *)aView viewColor:(UIColor *)color
{	
 	[aView.layer setMasksToBounds:YES];
	aView.clipsToBounds = YES;
	//圆角 边框的宽度
 	aView.layer.borderWidth = 2;
	//是否允许弯曲
 	aView.layer.masksToBounds = NO;
	//要弯的弧度
 	aView.layer.cornerRadius = 8.0;
	//边框的颜色
 	aView.layer.borderColor = [color CGColor];
	return aView;
}

//返回一个阴影的view
+ (UIView *)getShadowView:(UIView *)aView
{
    //UIView设置阴影
    [[aView layer] setShadowOffset:CGSizeMake(1, 1)];
    [[aView layer] setShadowRadius:5];
    [[aView layer] setShadowOpacity:2];
    [[aView layer] setShadowColor:[UIColor blackColor].CGColor];
    //UIView设置边框
    [[aView layer] setCornerRadius:5];
    [[aView layer] setBorderWidth:2];
    [[aView layer] setBorderColor:[UIColor whiteColor].CGColor];
	return aView;
}

/*
 WebView的背景颜色去除
 输入参数：需要处理的WebView
 */
+ (void)clearWebViewBackground:(UIWebView *)webView
{
    UIWebView *web = webView;
    for (id v in web.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            [v setBounces:NO];
        }
    }
}

/*
 释放WebView（当内存警告时调用）
 输入参数：需要处理的WebView
 */
+ (void)releaseWebView:(UIWebView *)webView {
    [webView stopLoading];
    [webView setDelegate:nil];
    webView = nil;
}

/*
 图片修改成圆角的view
 注：需要导入QuartzCore框架 导入头文件#import <QuartzCore/QuartzCore.h>
 输入参数：需要改变的view
 输出参数：经过圆角处理的view
 */
+ (UIView *)getRoundView:(UIView *)aView
{
	//圆角 边框的宽度
 	aView.layer.borderWidth = 1.0f;
	//是否允许弯曲
 	aView.layer.masksToBounds = YES;
	//要弯的弧度
 	aView.layer.cornerRadius = 5;
	//边框的颜色
 	aView.layer.borderColor = [[UIColor clearColor] CGColor];
	return aView;
}

//截屏
+ (UIImage *)getScreenWithView:(UIView *)view
{
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 1);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
	return image;
}

#pragma mark -
#pragma mark 文件操作
//获取应用沙盒路径
+ (NSString *)appSandboxDir
{
    return NSHomeDirectory();
}

//获取应用文档路径
+ (NSString *)appDocDir
{
    //参数NSDocumentDirectory要获取那种路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
}

//获取应用缓存路径
+ (NSString *)appCachesDir
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
	return cachesDirectory;
}

//获取应用临时文件路径
+ (NSString *)appTempDir
{
	return NSTemporaryDirectory();
}

//获取某路径下文件列表(包含所有文件和文件夹)
+ (NSArray *)allFilesAtPaths:(NSString *)path
{
    NSArray *fileList = [[NSArray alloc] init];
    fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    return fileList;
}

//判断文件是否存在
+ (BOOL)isFileExist:(NSString*)fileName subDir:(NSString *)subDir
{
    //判断目录是否存在，不存在创建该目录并返回NO
    BOOL isDir = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *fileDir = [[Tools appDocDir] stringByAppendingPathComponent:subDir];
    BOOL existed = [fileManager fileExistsAtPath:fileDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
        return NO;
    }
    
    //判断文件是否存在
    NSString *_filename = [fileDir stringByAppendingPathComponent:fileName];
	return ([fileManager fileExistsAtPath:_filename]);
}

//创建文件夹
+ (void)createNewDocument:(NSString *)dir
{
    BOOL isDir = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *fileDir = [[Tools appDocDir] stringByAppendingPathComponent:dir];
    BOOL existed = [fileManager fileExistsAtPath:fileDir isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) )
    {
        [fileManager createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

//根据相对路径得到全路径
+ (NSString *)fullPathWithFileName:(NSString*)fileName subDir:(NSString *)subDir
{
    NSString *_filename = [[Tools appDocDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",subDir,fileName]];
    return _filename;
}

//获取相应文件大小
+ (NSInteger)getFileSize:(NSString*)path
{
    NSFileManager * filemanager = [[[NSFileManager alloc]init] autorelease];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize integerValue];
        else
            return -1;
    }
    else
    {
        return -1;
    }
}

#pragma mark -
#pragma mark URL编码解码
//URL编码
+(NSString*)urlEncode:(NSString *)str
{
	int length = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
	const char* buffer = [str UTF8String];
	
	
	NSMutableString* returndata = [NSMutableString string];
	
	for(int i=0;i<length;i++)
	{
		unsigned char ch = (unsigned char)buffer[i];
		[returndata appendFormat:@"%%%02x",ch];
	}
	
	return returndata;
}

//URL解码
+(NSString*)urlDecode:(NSString*)str
{
	return [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark -
#pragma mark 获取随机字符串
/*
 此函数用于获取一个随机字符串
 1.用于webservice发送时的分隔符
 2.用于全局常量中标识链接的字符串头
 */
+ (NSString *)generateBoundaryString
{
    CFUUIDRef uuid;
    CFStringRef uuidStr;
    NSString *result;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSString stringWithFormat:@"%@", uuidStr];
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

/*
 过滤字符串中的&nbsp;换行
 输入参数：需要过滤的字符串
 输出参数：过滤完成的字符串
 */
+ (NSString *)checkNewlineValue:(NSString *)str
{
	return [str stringByReplacingOccurrencesOfString:@"&nbsp;" withString:[NSString stringWithFormat:@"%c",'\n']];
}

//NSData转化NSString
+ (NSString *)convertDataToString:(NSData *)data
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return string;
}

//NSString转化NSData
+ (NSData *)convertStringToData:(NSString *)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

#pragma mark -
#pragma mark 等待框
//添加简单等待框
+ (void)showHUD:(NSString *)text andView:(UIView *)view
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:view];
	[view addSubview:hud];
    hud.animationType = MBProgressHUDAnimationZoom;
    hud.labelText = text;
	[hud show:YES];
}

//加载成功取消等待框
+ (void)hideHUDForView:(UIView *)view andText:(NSString *)text completed:(BOOL)flag
{
	MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    for (id view in hud.subviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            [view removeFromSuperview];
        }
    }
    NSString *iconName = nil;
    if (flag)
    {
        iconName = @"completed.png";
    }
    else
    {
        iconName = @"failed.png";
    }
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    logo.frame = CGRectMake(CGRectGetWidth(hud.frame)/2-15, CGRectGetHeight(hud.frame)/2-25, 30, 30);
    [hud addSubview:logo];
    
	if (hud != nil)
    {
        hud.labelText = text;
        hud.removeFromSuperViewOnHide = YES;
        [hud hide:YES afterDelay:1];
	}
}

#pragma mark -
#pragma mark 缓存处理
//存储到缓存中
+ (void)setObject:(id)object forkey:(NSString *)key
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    [FTWCache setObject:data forKey:key];
}

//从缓存中读取
+ (id)objectForKey:(NSString*)key
{
    NSData *data = [FTWCache objectForKey:key];
    id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return object;
}

//清空缓存
+ (void)resetCaches
{
    [FTWCache resetCache];
}

#pragma mark -
#pragma mark json的解析和生成

//将json转化为NSDictionary或者NSArray
+ (id)convertJsonToObject:(NSData *)jsonData
{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil)
    {
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
}

//将NSDictionary或者NSArray转化为Json
+ (NSData *)convertObjectToJson:(id)object
{
    if ([NSJSONSerialization isValidJSONObject:object])
    {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        if ([jsonData length] > 0 && error == nil)
        {
            return jsonData;
        }
    }
    return  nil;
}

#pragma mark -
#pragma mark 用于加解密的操作
//MD5加密
+ (NSString *)convertToMD5:(NSString *)string
{
    return [string md5];
}

//加解密（NSData-->NSData）
+ (NSData *)desData:(NSData *)data key:(NSString *)keyString CCOperation:(CCOperation)op
{
    return [NSString desData:data key:keyString CCOperation:op];
}

//加解密（NSString-->NSString）
+ (NSString *)tripleDES:(NSString*)dataString encryptOrDecrypt:(CCOperation)encryptOrDecrypt key:(NSString*)key
{
    return [NSString tripleDES:dataString encryptOrDecrypt:encryptOrDecrypt key:key];
}

#pragma mark -
#pragma mark 用于开启关闭状态栏动画

//开启状态栏动画
+ (void)showStatusBarActivityIndicator
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

//关闭状态栏动画
+ (void)hideStatusBarActivityIndicator
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark -
#pragma mark 用于处理网络上的图片

//获取网络图片
+ (UIImage *)getImageFromURL:(NSString *)fileURL {
    
    NSLog(@"执行图片下载函数");
    
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    
    result = [UIImage imageWithData:data];
    
    return result;
}

//获取图片缩略图
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image {
    
    // Create a thumbnail version of the image for the event object.
    
    CGSize size = image.size;
    
    CGSize croppedSize;
    
    CGFloat ratioX = 75.0;
    
    CGFloat ratioY = 60.0;
    
    CGFloat offsetX = 0.0;
    
    CGFloat offsetY = 0.0;
    
    
    
    // check the size of the image, we want to make it
    
    // a square with sides the size of the smallest dimension
    
    if (size.width > size.height) {
        
        offsetX = (size.height - size.width) / 2;
        
        croppedSize = CGSizeMake(size.height, size.height);
        
    } else {
        
        offsetY = (size.width - size.height) / 2;
        
        croppedSize = CGSizeMake(size.width, size.width);
        
    }
    
    
    
    // Crop the image before resize
    
    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    
    // Done cropping
    
    // Resize the image
    
    CGRect rect = CGRectMake(0.0, 0.0, ratioX, ratioY); // 设置图片缩微图的区域（（0，0），宽：75  高：60）
    
    UIGraphicsBeginImageContext(rect.size);
    
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    // Done Resizing
    
    return thumbnail;
    
}

#pragma mark -
#pragma mark 用于PDF文档的相关操作

//获取PDF文档的页数
+ (NSInteger)getPDFDocumentPages:(NSString *)filePath
{
    NSURL *pdfUrl = [NSURL fileURLWithPath:filePath];
    CGPDFDocumentRef document = CGPDFDocumentCreateWithURL((__bridge CFURLRef)pdfUrl);
    NSInteger totalPage = CGPDFDocumentGetNumberOfPages(document);
    
    return totalPage;
}

@end
