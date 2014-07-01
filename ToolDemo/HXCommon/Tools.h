//
//  Tools.h
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-18.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//
/*
 注：需要导入QuartzCore框架 导入头文件#import <QuartzCore/QuartzCore.h>
 */
#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "MacroDefines.h"
#import "ImageUtil.h"
#import "NSString+MD5.h"
#import "NSString+TKUtilities.h"
#import "NSDate-Helper.h"

@interface Tools : NSObject

#pragma mark -
#pragma mark 获取设备信息
/*
                    以下方法用于获取设备的相关信息
 ------------------------------------------------------------------
 */
//获取设备版本号
+ (NSString *)currentVersion;

//获取设备名称
+ (NSString *)deviceNickName;

//获取设备类型
+ (NSString *)deviceModel;

//判断是否为iPhone 5
+ (BOOL)isiPhone5;

//判断设备是iphone还是ipad
+ (BOOL)getDevieIsPhone;

#pragma mark -
#pragma mark 检测网络连接状况
/*
                    以下方法用于获取设备当前网络状态
 ------------------------------------------------------------------
 */
//检测网络连接状况
+ (BOOL)connectedToNetwork;

// 检测可用的网络环境是否为wifi
+ (BOOL)isEnableWIFI;

// 检测可用的网络环境是否为3G
+ (BOOL)isEnable3G;

//全局监控网络状态
+ (void)networkStatus;

#pragma mark -
#pragma mark 错误提示
/*
                    以下方法用于开发中的提示框
 ------------------------------------------------------------------
 */
//信息提示
+ (void)ErrorAlert:(NSString *)errorMsg withTitle:(NSString *)titleMsg;

#pragma mark -
#pragma mark 时间转换函数模块
/*
                    以下方法用于转换时间格式
 ------------------------------------------------------------------
 */
//转换时间格式，精确到秒数
+ (NSString *)convertTimeStyleToSecond:(NSString *)timeStr;

//转换时间格式，精确到分钟
+ (NSString *)convertTimeStyleToMin:(NSString *)timeStr;

//转换时间格式，精确到天数
+ (NSString *)convertTimeStyleToDay:(NSString *)timeStr;

//日期性质转换为秒数的形式(如：00:01:20-->80s)
+ (int)convertMinStyleToTime:(NSString *)timeStr;

//秒数转换为日期性质的形式(如：80s-->00:01:20)
+ (NSString *)convertSecondToDay:(int)second;

//时间转化为时间戳
+ (NSString *)timeToTimeStamp:(NSDate *)date;

//获取当前时间"yyyy-MM-dd hh:mm:ss"
+ (NSString *)getNowTime;

//返回年份
+ (NSUInteger)getYear:(NSDate *)date;

//返回月份
+ (NSUInteger)getMonth:(NSDate *)date;

//返回日
+ (NSUInteger)getDay:(NSDate *)date;

//返回时
+ (int)getHour:(NSDate *)date;

//返回分
+ (int)getMinute:(NSDate *)date;

//返回该日期属于本年度的第几周
+ (int)getWeekOfYear:(NSDate *)date;

#pragma mark -
#pragma mark 判断模块
/*
                    以下方法用于常见规则的判断
 ------------------------------------------------------------------
 */
//判断该email是否合法
+ (BOOL)isMatchedEmail:(NSString *)str;

//判断该mobile number是否合法
+ (BOOL)isMatchedMobile:(NSString *)str;

//将手机号码转化为标准形式,如13587651234
+ (NSString *)formatTelephoneNumber:(NSString *)telephone;

#pragma mark -
#pragma mark UIView相关
/*
                    以下方法用于UIView相关操作
 ------------------------------------------------------------------
 */
/*
 注:更多图片效果请查看ImageUtil类
 */
//将图片变灰
+ (UIImage *)convertToGrayStyle:(UIImage *)img;

//设置个边框并且给个颜色
+ (UIView *)setButtnBorderColor:(UIView *)aView viewColor:(UIColor *)color;

//返回一个阴影的view
+ (UIView *)getShadowView:(UIView *)aView;

//WebView的背景颜色去除
+ (void)clearWebViewBackground:(UIWebView *)webView;

//释放WebView（当内存警告时调用）
+ (void)releaseWebView:(UIWebView *)webView;

//图片修改成圆角的view
+ (UIView *)getRoundView:(UIView *)aView;

//截屏
+ (UIImage *)getScreenWithView:(UIView *)view;

#pragma mark -
#pragma mark 文件操作
/*
                    以下方法用于文件操作
 ------------------------------------------------------------------
 */
//获取应用沙盒路径
+ (NSString *)appSandboxDir;

//获取应用文档路径
+ (NSString *)appDocDir;

//获取应用缓存路径
+ (NSString *)appCachesDir;

//获取应用临时文件路径
+ (NSString *)appTempDir;

//获取某路径下文件列表
+ (NSArray *)allFilesAtPaths:(NSString *)path;

//判断文件是否存在(Document根路径下)
+ (BOOL)isFileExist:(NSString*)fileName subDir:(NSString *)subDir;

//创建文件夹(Document根路径下)
+ (void)createNewDocument:(NSString *)dir;

//根据相对路径得到全路径(Document根路径下)
+ (NSString*)fullPathWithFileName:(NSString*)fileName subDir:(NSString *)subDir;

//获取相应文件大小
+ (NSInteger)getFileSize:(NSString*)path;

#pragma mark -
#pragma mark URL编码解码
/*
                    以下方法用于URL编码解码
 ------------------------------------------------------------------
 */
//URL编码（UTF－8编码）
+(NSString*)urlEncode:(NSString *)str;

//URL解码
+(NSString*)urlDecode:(NSString*)str;


#pragma mark -
#pragma mark 获取随机字符串
/*
                    以下方法用于常见字符串操作
 ------------------------------------------------------------------
 */
//获取随机字符串
+ (NSString *)generateBoundaryString;

//过滤字符串中的&nbsp;换成换行
+ (NSString *)checkNewlineValue:(NSString *)str;

//NSData转化NSString(UTF-8编码)
+ (NSString *)convertDataToString:(NSData *)data;

//NSString转化NSData(UTF-8编码)
+ (NSData *)convertStringToData:(NSString *)string;


#pragma mark -
#pragma mark 等待框
/*
                    以下方法用于添加删除等待框
 ------------------------------------------------------------------
 */
//等待框显示
+ (void)showHUD:(NSString  *)text andView:(UIView *)view;

//等待框取消(flag==YES时为加载成功，flag==NO时为加载失败)
+ (void)hideHUDForView:(UIView *)view andText:(NSString *)text completed:(BOOL)flag;

#pragma mark -
#pragma mark 缓存处理
/*
                    以下方法用于缓存处理
 ------------------------------------------------------------------
 */
//存储到缓存中（默认缓存3天->在三方类中修改）
+ (void)setObject:(id)object forkey:(NSString *)key;

//从缓存中读取
+ (id)objectForKey:(NSString*)key;

//清空缓存
+ (void)resetCaches;

#pragma mark -
#pragma mark json的解析和生成
/*
                    以下方法用于对Json数据的处理
 ------------------------------------------------------------------
 */
//将json转化为NSDictionary或者NSArray
+ (id)convertJsonToObject:(NSData *)jsonData;

//将NSDictionary或者NSArray转化为Json
+ (NSData *)convertObjectToJson:(id)object;

#pragma mark -
#pragma mark 用于加解密的操作
 /*
                    以下方法用于加解密数据
 ------------------------------------------------------------------
 
 enum {
 kCCEncrypt = 0,   //加密
 kCCDecrypt,       //解密
 };
 typedef uint32_t CCOperation;
 
 */
//MD5加密
+ (NSString *)convertToMD5:(NSString *)string;

//加解密（NSData-->NSData）
+ (NSData *)desData:(NSData *)data key:(NSString *)keyString CCOperation:(CCOperation)op;

//3DES加解密（NSString-->NSString）
+ (NSString *)tripleDES:(NSString*)dataString encryptOrDecrypt:(CCOperation)encryptOrDecrypt key:(NSString*)key;

#pragma mark -
#pragma mark 用于加解密的操作
/*
                    以下方法用于开启关闭状态栏动画
 ------------------------------------------------------------------
 */
//开启状态栏动画
+ (void)showStatusBarActivityIndicator;

//关闭状态栏动画
+ (void)hideStatusBarActivityIndicator;


#pragma mark -
#pragma mark 用于处理网络上的图片
/*
                    以下方法用于处理网络上的图片
 ------------------------------------------------------------------
 */

//获取网络图片(同步方式)
+ (UIImage *)getImageFromURL:(NSString *)fileURL;

//获取图片缩略图
+ (UIImage *)generatePhotoThumbnail:(UIImage *)image;

#pragma mark -
#pragma mark 用于PDF文档的相关操作
/*
                    以下方法用于PDF文档的相关操作
 ------------------------------------------------------------------
 */
//获取PDF文档的页数
+ (NSInteger)getPDFDocumentPages:(NSString *)filePath;

@end
