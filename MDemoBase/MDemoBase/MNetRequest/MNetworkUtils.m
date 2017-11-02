//
//  MNetworkUtils.m
//  268EDU_Demo
//
//  Created by yizhilu on 2017/7/21.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "MNetworkUtils.h"
#import<CommonCrypto/CommonDigest.h>
#import <YYKit.h>
#import "MNetRequestModel.h"
@implementation MNetworkUtils
//md5加密
+ (NSString *)md5StringFromString:(NSString *)string {
    NSParameterAssert(string != nil && [string length] > 0);
    
    const char *value = [string UTF8String];
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

+(NSString *)currentTimeStampS{
    return [self currentTimeForamt:@"YYYY-MM-dd HH:mm:ss"];
}
+(NSString *)currentTimeStampMS{
    return [self currentTimeForamt:@"YYYY-MM-dd HH:mm:ss SSS"];
}

+(NSMutableDictionary *)parameterExchange:(MNetConfig *)setting{
    //拼接url参数
    NSString *urlWithParamterString = setting.hostUrl;
    
    NSArray *dicKeysArray = [setting.paramet allKeys];
    if (dicKeysArray.count > 0) {
        //对 key 进行排序
        NSStringCompareOptions comparisonOptions = NSCaseInsensitiveSearch|NSNumericSearch|
        NSWidthInsensitiveSearch|NSForcedOrderingSearch;
        NSComparator sort = ^(NSString *obj1,NSString *obj2){
            NSRange range = NSMakeRange(0,obj1.length);
            return [obj1 compare:obj2 options:comparisonOptions range:range];
        };
        NSArray *resultArray = [dicKeysArray sortedArrayUsingComparator:sort];
    
        urlWithParamterString = [urlWithParamterString stringByAppendingString:@"?"];
        for (NSString *key in resultArray){
            
            urlWithParamterString = [urlWithParamterString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, [setting.paramet objectForKey:key]]];
        }
        //删除最后一个字符"|"
        urlWithParamterString = [urlWithParamterString substringToIndex:urlWithParamterString.length - 1];
    }
    
   
    NSLog(@"\n\n路径--%@", urlWithParamterString);
    return setting.paramet;
}



+ (NSString *)cacheFilePath:(MNetConfig *)setting{
    NSString *requestInfo = [NSString stringWithFormat:@"%@%@",setting.hostUrl,setting.paramet];
    NSString *cacheFileName = [self md5StringFromString:requestInfo];
    NSString *path = [self cacheBasePath];
    path = [path stringByAppendingPathComponent:cacheFileName];
    return path;
}

+ (NSString *)cacheBasePath{
    //放入cash文件夹下,为了让手机自动清理缓存文件,避免产生垃圾
    NSString *pathOfLibrary = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [pathOfLibrary stringByAppendingPathComponent:@"MLazyRequestCache"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {
        [self createBaseDirectoryAtPath:path];
    } else {
        if (!isDir) {
            NSError *error = nil;
            [fileManager removeItemAtPath:path error:&error];
            [self createBaseDirectoryAtPath:path];
        }
    }
    return path;
}

//创建文件夹
+(void)createBaseDirectoryAtPath:(NSString *)path{
    NSError *error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
}

+(NSInteger)compareFileAvailability:(MNetConfig *)setting{
    NSInteger time = [self compareCurrentTime:[self getCurrentTime:setting] withFileCreatTime:[self getFileCreateTime:setting]];
    return time;
}

//获取当前时间
+ (NSDate *)getCurrentTime:(MNetConfig *)setting{
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    NSString *dateTime=[formatter stringFromDate:[NSDate date]];
    NSDate *date = [formatter dateFromString:dateTime];
    NSTimeInterval time = (setting.cashTime == 0 ? 3 * 60 : setting.cashTime * 60);
    NSDate *currentTime = [date dateByAddingTimeInterval:-time];
    return currentTime;
}

//获取文件夹创建时间
+ (NSDate *)getFileCreateTime:(MNetConfig *)setting{
    NSString *path = [self cacheFilePath:setting];
    NSError * error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //通过文件管理器来获得属性
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:&error];
    NSDate *fileCreateDate = [fileAttributes objectForKey:NSFileCreationDate];
    return fileCreateDate;
}

//如果没达到指定日期返回-1，刚好是这一时间，返回0，否则返回1
+ (NSInteger)compareCurrentTime:(NSDate *)currentTime withFileCreatTime:(NSDate *)fileCreatTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd-MM-yyyy-HHmmss"];
    NSString *currentStr = [dateFormatter stringFromDate:currentTime];
    NSString *fileStr = [dateFormatter stringFromDate:fileCreatTime];
    NSDate *currentDate = [dateFormatter dateFromString:currentStr];
    NSDate *fileDate = [dateFormatter dateFromString:fileStr];
    NSComparisonResult result = [currentDate compare:fileDate];
//    NSLog(@"currentTime : %@, fileCreatTime : %@", currentTime, fileCreatTime);
    NSInteger aa = 0;
    if (result == NSOrderedDescending) {
        //文件创建时间超过当前时间,刷新数据
        aa = 1;
    }else if (result == NSOrderedAscending){
        //文件创建时间小于当前时间,返回缓存数据
        aa = -1;
    }
    return aa;
    
}

+(void)saveCashDataForArchiver:(id)responseData requestSeting:(MNetConfig *)seting{
    NSString *path = [self cacheFilePath:seting];
    if (responseData != nil) {
        @try {
            if (seting.jsonValidator) {
                //如果有格式验证就进行验证
                BOOL result = [MNetworkUtils validateJSON:responseData withValidator:seting.jsonValidator];
                if (result) {
                    [NSKeyedArchiver archiveRootObject:responseData toFile:path];
                }else{
                    //格式不正确
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    //检测文件路径存不存在
                    BOOL isFileExist = [fileManager fileExistsAtPath:path isDirectory:nil];
                    if (isFileExist) {
                        //如果文件存在,肯定是老数据,把文件删掉
                        NSError *error = nil;
                        [fileManager removeItemAtPath:path error:&error];
                    }
                }
            }else{
                //没有验证直接存储
                [NSKeyedArchiver archiveRootObject:responseData toFile:path];
            }
        } @catch (NSException *exception) {
            NSLog(@"Save cache failed, reason = %@", exception.reason);
        }
    }
}

//json字段检验
+ (BOOL)validateJSON:(id)json withValidator:(id)jsonValidator {
    if ([json isKindOfClass:[NSDictionary class]] &&
        [jsonValidator isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = json;
        NSDictionary * validator = jsonValidator;
        BOOL result = YES;
        NSEnumerator * enumerator = [validator keyEnumerator];
        NSString * key;
        while ((key = [enumerator nextObject]) != nil) {
            id value = dict[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]]
                || [value isKindOfClass:[NSArray class]]) {
                result = [self validateJSON:value withValidator:format];
                if (!result) {
                    break;
                }
            } else {
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO) {
                    result = NO;
                    break;
                }
            }
        }
        return result;
    } else if ([json isKindOfClass:[NSArray class]] &&
               [jsonValidator isKindOfClass:[NSArray class]]) {
        NSArray * validatorArray = (NSArray *)jsonValidator;
        if (validatorArray.count > 0) {
            NSArray * array = json;
            NSDictionary * validator = jsonValidator[0];
            for (id item in array) {
                BOOL result = [self validateJSON:item withValidator:validator];
                if (!result) {
                    return NO;
                }
            }
        }
        return YES;
    } else if ([json isKindOfClass:jsonValidator]) {
        return YES;
    } else {
        return NO;
    }
}

+(NSString *)currentTimeForamt:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    return timeSp;
}
// 是否wifi
+ (BOOL)isEnableWIFI{
    YYReachability *reachable = [[YYReachability alloc] init];
    BOOL iswifi = NO;
    if (reachable.status ==  YYReachabilityStatusWiFi){
        
        iswifi = YES;
    }
    return iswifi;
}

// 是否3G
+ (BOOL)isEnableWWAN{
    YYReachability *reachable = [[YYReachability alloc] init];
    
    
    if ( reachable.status == YYReachabilityStatusWWAN)//有网且不是wifi
        return YES;
    else
        return NO;
    
    
}
//网络是否可用
+ (BOOL)isNoNet{
    
    YYReachability *reachable = [[YYReachability alloc] init];
    
    if (reachable.status == YYReachabilityStatusNone) {
        return YES;
    }
    else
        return NO;
    
    
}

@end
