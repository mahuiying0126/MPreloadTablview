//
//  TestDataModel.m
//  MDemoBase
//
//  Created by yizhilu on 2017/11/2.
//Copyright © 2017年 Magic. All rights reserved.
//

#import "TestDataModel.h"
#import "MHYTestModel.h"
#import "HttpRequestModel.h"
@interface TestDataModel ()

@end
static NSString *const Test_Page_URL = @"http://sns.268xue.com/app/topic/getHotTopic";
@implementation TestDataModel
- (RACSignal *)siganlForTopicDataIsReload:(BOOL)isReload{
    
    RACReplaySubject *subject = [RACReplaySubject subject];
    MNetConfig *seting = [MNetConfig new];
    seting.hostUrl = Test_Page_URL;
    //    seting.paramet = @{};//如果有页码参数,不要写到字典,将页码参数写到下方
    seting.modelLocalPath = @"entity/topics";//数据定位,即 entity 下的 topics 对应的数据
    seting.keyOfPage = @"page.currentPage";//页码写这
    seting.modelNameOfArray = @"MHYTestModel";//要显示列表对应的数据模型
    seting.isRefresh = isReload;//是否刷新
    seting.isHidenHUD = !isReload;//上拉刷新显示 HUD 上拉更多不显示 HUD
    //    seting.cashSeting = MCacheSave;// 是否进行本地缓存
    //    seting.cashTime = 4;//设置缓存时间为4分钟,默认3分钟
    //    seting.isCashMoreData = YES;//进行多页数据缓存
    
    seting.jsonValidator = @{@"entity":[NSDictionary class],
                             @"entity":@{@"topics":[NSArray class]}
                             };//检测 entity 是否为字典类型,检测 entity 下 topics 字段是否为数组
    [[self singalForSingleRequestWithSet:seting]subscribeNext:^(id  _Nullable x) {
        [subject sendNext:x];
    } error:^(NSError * _Nullable error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

-(RACSignal *)siganlForTopicsDataIsReload:(BOOL)isReload{
    RACReplaySubject *subject = [RACReplaySubject subject];
    MNetConfig *seting = [MNetConfig new];
    seting.hostUrl = Test_Page_URL;
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    [parameter setValue:@"1" forKey:@"page.currentPage"];
    seting.paramet = parameter;
    seting.isRefresh = isReload;
    seting.isHidenHUD = !isReload;
    [[MNetRequestModel netRequestSeting:seting] subscribeNext:^(id  _Nullable x) {
        NSDictionary *request = x;
        if ([request[@"success"] boolValue]) {
            NSDictionary *entity = request[@"entity"];
            NSArray *array = entity[@"topics"];
            NSArray *arrayModel = [NSArray modelArrayWithClass:[MHYTestModel class] json:array];
            [subject sendNext:arrayModel];
        }
    } error:^(NSError * _Nullable error) {
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    
    return subject;
}

- (void)requestSuccess:(void (^)(id responseData))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    [parameter setValue:@"1" forKey:@"page.currentPage"];
    
    [HttpRequestModel request:Test_Page_URL withParamters:parameter success:^(id responseData) {
        NSDictionary *request = responseData;
        if ([request[@"success"] boolValue]) {
            NSDictionary *entity = request[@"entity"];
            NSArray *array = entity[@"topics"];
            NSArray *arrayModel = [NSArray modelArrayWithClass:[MHYTestModel class] json:array];
            if (success) {
                success(arrayModel);
            }
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

@end
