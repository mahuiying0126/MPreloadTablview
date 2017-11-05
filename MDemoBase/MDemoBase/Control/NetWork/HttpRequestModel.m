///
///  HttpRequestModel.m
///  268EDU_Demo
///
///  Created by EDU268 on 15/10/29.
///  Copyright © 2015年 edu268. All rights reserved.
///

#import "HttpRequestModel.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@implementation HttpRequestModel

static HttpRequestModel *_requestModel = nil;
+(HttpRequestModel *) sharedHttpRequestModel
{
    if (!_requestModel){
        _requestModel = [self init];
    }
    return _requestModel;
}


/** 1 * post 请求 无进度 */
+ (void)request:(NSString *)urlString withParamters:(NSDictionary *)dic success:(void (^)(id responseData))success failure:(void (^)(NSError *error))failure{

    urlString = [NSString stringWithFormat:@"%@.json",urlString];
    
    [self printRequestUrlString:urlString withParamter:dic];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager.requestSerializer setTimeoutInterval:10.f];

    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    
    [manager POST:urlString parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success != nil)
            success(responseObject);
    }
          failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
              
              
              if (failure != nil) {
                  failure(error);
              }
          }];
}


+ (void)printRequestUrlString:(NSString *)urlString withParamter:(NSDictionary *)dic {
    NSArray *dicKeysArray = [dic allKeys];
    NSString *urlWithParamterString = urlString;
    
    if (dicKeysArray.count != 0) {
        
        urlWithParamterString = [urlWithParamterString stringByAppendingString:@"?"];
    }
    
    for (NSInteger i = 0; i < dicKeysArray.count; i++) {
        
        urlWithParamterString = [urlWithParamterString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", dicKeysArray[i], [dic objectForKey:dicKeysArray[i]]]];
        
        if (i == dicKeysArray.count - 1) {
            
            urlWithParamterString = [urlWithParamterString substringToIndex:urlWithParamterString.length - 1];
        }
    }
    NSLog(@"\n\n路径--%@", urlWithParamterString);
}






@end
