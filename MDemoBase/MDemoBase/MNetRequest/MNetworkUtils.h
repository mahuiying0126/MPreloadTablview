//
//  MNetworkUtils.h
//  268EDU_Demo
//
//  Created by yizhilu on 2017/7/21.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MNetConfig;
@interface MNetworkUtils : NSObject

/**
 将路径进行md5加密

 @param string 数据文件储存路径
 @return 加密后的文件路径
 */
+ (NSString *)md5StringFromString:(NSString *)string;

/**
 时间戳秒

 @return 时间戳
 */
+(NSString *)currentTimeStampS;

/**
 时间戳毫秒

 @return 时间戳
 */
+(NSString *)currentTimeStampMS;

/**
 生成sign加密串,时间戳,授权码

 @param setting 网络设置
 @return 请求参数
 */
+(NSMutableDictionary *)parameterExchange:(MNetConfig *)setting;

/**
 缓存目录路径

 @param setting 网络请求参数设置
 @return 缓存目录
 */
+ (NSString *)cacheFilePath:(MNetConfig *)setting;

/**
 比较当前时间与缓存本地文件是否过期

 @param setting 网络请求参数设置
 @return 如果没达到指定日期返回-1，刚好是这一时间，返回0，否则返回1(过期)
 */
+(NSInteger)compareFileAvailability:(MNetConfig *)setting;

/**
 将请求数据保存到本地

 @param responseData 当前请求数据
 @param seting 网络请求的配置
 */
+(void)saveCashDataForArchiver:(id)responseData
                 requestSeting:(MNetConfig *)seting;

/**
 如果没达到指定日期返回-1，刚好是这一时间，返回0，否则返回1

 @param currentTime 当前时间
 @param fileCreatTime 文件创建时间
 @return -1 文件没有过期; 0 时间刚好相等; 1 文件已过期需要刷新数据
 */
+ (NSInteger)compareCurrentTime:(NSDate *)currentTime
              withFileCreatTime:(NSDate *)fileCreatTime;

/**
 将原数据进行json字段类型检验

 @param json 请求下来的原数据
 @param jsonValidator 要检验的json字段类型
 @return YES 要检测的字段类型符合; NO 反之
 */
+ (BOOL)validateJSON:(id)json
       withValidator:(id)jsonValidator;


/**
 wifi网络是否可用
 
 @return YES,可用 NO,不可用
 */
+ (BOOL) isEnableWIFI;

/**
 蜂窝数据是否可用
 
 @return YES,可用 NO,不可用
 */
+ (BOOL) isEnableWWAN;

/**
 当前网络状态是否可用
 
 @return YES,网络状态不可用 NO,网络状态可用
 */
+ (BOOL) isNoNet;
@end
