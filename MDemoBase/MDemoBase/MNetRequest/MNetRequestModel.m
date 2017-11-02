//
//  MNetRequestModel.m
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/7.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "MNetRequestModel.h"
#import "MNetRequestHeader.h"
@implementation MNetRequestModel
+ (RACSignal *)netRequestSeting:(MNetConfig *)seting{
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    seting.paramet = [MNetworkUtils parameterExchange:seting];
    __block MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication].windows lastObject] animated:YES];
    HUD.animationType = MBProgressHUDAnimationFade;
    if (seting.HUDLabelText) {
        HUD.label.text = seting.HUDLabelText;
    }
    [HUD showAnimated:YES];
    HUD.hidden = seting.isHidenHUD;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval:10.f];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
    response.removesKeysWithNullValues = YES;
    manager.responseSerializer = response;
    if (seting.isHttpsRequest) {
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"" ofType:@"cer"];
        NSData * certData =[NSData dataWithContentsOfFile:cerPath];
        NSSet * certSet = [[NSSet alloc] initWithObjects:certData, nil];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        // 是否允许,NO-- 不允许无效的证书
        [securityPolicy setAllowInvalidCertificates:NO];
        //设置证书
        [securityPolicy setValidatesDomainName:YES];
        [securityPolicy setPinnedCertificates:certSet];
        manager.securityPolicy = securityPolicy;
    }
    if (seting.cashSeting == MCacheNoSave) {
        switch (seting.requestStytle) {
                //默认,不缓存,比如登录
            case NRequestMethodGET:
            {}break;
            case MRequestMethodPOST:{
                [[self requestManager:manager requestSet:seting mbpHUD:HUD] subscribeNext:^(id  _Nullable x) {
                    [subject sendNext:x];
                    
                } error:^(NSError * _Nullable error) {
                    [subject sendError:error];
                }completed:^{
                    [subject sendCompleted];
                }];
            }break;
        }
    }else{
        switch (seting.requestStytle) {
            case NRequestMethodGET:
            {}break;
            case MRequestMethodPOST:{
                ///有缓存
                //设置了缓存,如果没有设置缓存时间,默认3分钟缓存时间
                NSString *path = [MNetworkUtils cacheFilePath:seting];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                //检测文件路径存不存在
                BOOL isFileExist = [fileManager fileExistsAtPath:path isDirectory:nil];
                //如果没有网络
                if ([MNetworkUtils isNoNet]) {
                    if (isFileExist){
                        //如果本地缓存存在
                        dispatch_async
                        (dispatch_get_global_queue
                         (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                             id noNetData = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
                             [subject sendNext:noNetData];
                             dispatch_async
                             (dispatch_get_main_queue(), ^{
                                 [HUD performSelector
                                  :@selector(removeFromSuperview) withObject:nil afterDelay:0.0];
                                 [subject sendCompleted];
                             });
                         });
                        
                    }else{
                        [HUD performSelector
                         :@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
                        [subject sendError:nil];
                    }
                }else{
                    ///有网络
                    if (isFileExist && !seting.isRefresh) {
                        //上拉加载更多,且文件存在
                        //将本地文件取出
                        id data = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
                        NSInteger time = [MNetworkUtils compareFileAvailability:seting];
                        if (time == 1) {
                            [[self requestManager:manager requestSet:seting mbpHUD:HUD] subscribeNext:^(id  _Nullable x) {
                                [subject sendNext:x];
                            } error:^(NSError * _Nullable error) {
                                [subject sendError:error];
                            } completed:^{
                                [subject sendCompleted];
                            }];
                        }else{
                            dispatch_async
                            (dispatch_get_global_queue
                             (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                [subject sendNext:data];
                                dispatch_async
                                 (dispatch_get_main_queue(), ^{
                                    [HUD performSelector
                                     :@selector(removeFromSuperview) withObject:nil afterDelay:0.0];
                                    [subject sendCompleted];
                                });
                            });
                        }
                        
                    }else{
                        [[self requestManager:manager requestSet:seting mbpHUD:HUD] subscribeNext:^(id  _Nullable x) {
                            [subject sendNext:x];
                            
                        } error:^(NSError * _Nullable error) {
                            [subject sendError:error];
                        }completed:^{
                            [subject sendCompleted];
                        }];
                        
                    }
                }
                
            }break;
        }
    }
    
    return subject;
}

+(RACSignal *)requestManager:(AFHTTPSessionManager *)manager requestSet:(MNetConfig *)seting mbpHUD:(MBProgressHUD *)HUD{
    RACReplaySubject *subject = [RACReplaySubject subject];
    [manager POST:seting.hostUrl
       parameters:seting.paramet
         progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject){
              if (responseObject != nil) {
                  dispatch_async
                  (dispatch_get_global_queue
                   (DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                      
                      if (seting.cashSeting == MCacheSave) {
                          
                          if (seting.isCashMoreData && !seting.isRefresh) {
                              //上拉加载缓存数据
                              [self saveCashData:responseObject requestSeting:seting];
                          }else if(seting.isRefresh){
                              //下拉刷新,刷新数据
                              [self saveCashData:responseObject requestSeting:seting];
                          }else{
                              //缓存更多和刷新都没设置
                              [self saveCashData:responseObject requestSeting:seting];
                          }
                      }
                      //有字段校验
                      if (seting.jsonValidator) {
                          BOOL result = [MNetworkUtils validateJSON:responseObject withValidator:seting.jsonValidator];
                          if (result) {
                              [subject sendNext:responseObject];
                          }
                      }else{
                          [subject sendNext:responseObject];
                      }
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [HUD performSelector
                           :@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
                          [subject sendCompleted];
                      });
                  });
              }
          }
          failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error){
              HUD.animationType = MBProgressHUDModeText;
              HUD.label.text = @"请求失败,重新发送请求";
              if (seting.isHidenHUD) {
              }
              [HUD performSelector
               :@selector(removeFromSuperview)  withObject:nil afterDelay:0.0];
              [subject sendError:error];
              [subject sendCompleted];
          }];
    
    return subject;
}

+(void)saveCashData:(id)responseData requestSeting:(MNetConfig *)seting{
    [MNetworkUtils saveCashDataForArchiver:responseData requestSeting:seting];
}

+(RACSignal *)uploadWithImagesInSeting:(MNetConfig *)seting{
    RACReplaySubject *subject = [RACReplaySubject subject];
    __block NSMutableArray *tempArr = @[].mutableCopy;
    __block int tmp_count = 0;
    /// UIImage对象 -> NSData对象
    NSArray *icons = seting.uploadImages;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    seting.paramet = [MNetworkUtils parameterExchange:seting];
    [manager POST:seting.hostUrl parameters:seting.paramet constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i = 0; i < icons.count; i++) {
            UIImage *image = icons[i];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            if (imageData.length > 1024*1024) {
//                image = (YYImage *)[image imageByResizeToSize:CGSizeMake(kScreen_width, kScreen_width*(image.size.height/image.size.width)) contentMode:UIViewContentModeScaleAspectFill];
                
                imageData = UIImageJPEGRepresentation(image, 1);
            }
            // 可以在上传时使用当前的系统事件作为文件名
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            // 设置时间格式
            [formatter setDateFormat:@"yyyyMMddHHmmss"];
            NSString *dateString = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%d%@.png", i, dateString];
            
            [formData appendPartWithFileData:imageData name:@"fileupload" fileName:fileName mimeType:@"image/png"];
        }
    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (responseObject) {
            tmp_count ++;
            NSData *reciveData = responseObject;
            
            NSString *reciveString = [[NSString alloc]initWithData:reciveData encoding:NSUTF8StringEncoding];
            [tempArr addObject:reciveString];
            
            if (tmp_count == icons.count) {
                [subject sendNext:tempArr];
                [subject sendCompleted];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [subject sendError:error];
    }];
    
    
    return subject;
}

@end

@implementation MNetConfig



@end
