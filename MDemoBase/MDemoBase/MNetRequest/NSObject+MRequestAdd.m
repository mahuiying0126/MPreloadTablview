//
//  NSObject+MRequestAdd.m
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/8.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "NSObject+MRequestAdd.h"
#import "MNetRequestHeader.h"
static char const *key_isNoMoreData = "key_isNoMoreData";

static char const *key_isRequesting = "key_isRequesting";

static char const *key_currentPage = "key_currentPage";

static char const *key_dataArray = "key_dataArray";
static char const *key_orginResponseObject = "key_orginResponseObject";
@implementation NSObject (MRequestAdd)

- (BOOL)isNoMoreData{
    return [objc_getAssociatedObject(self, &key_isNoMoreData) boolValue];
}

- (void)setIsNoMoreData:(BOOL)isNoMoreData{
    objc_setAssociatedObject(self, &key_isNoMoreData, @(isNoMoreData), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isRequesting{
    return [objc_getAssociatedObject(self, &key_isRequesting) boolValue];
}

- (void)setIsRequesting:(BOOL)isRequesting{
    objc_setAssociatedObject(self, &key_isRequesting, @(isRequesting), OBJC_ASSOCIATION_ASSIGN);
}

- (NSInteger)currentPage{
    return [objc_getAssociatedObject(self, &key_currentPage) integerValue];
}

- (void)setCurrentPage:(NSInteger)currentPage{
    objc_setAssociatedObject(self, &key_currentPage, @(currentPage), OBJC_ASSOCIATION_ASSIGN);
}

- (NSMutableArray *)dataArray{
    return objc_getAssociatedObject(self, &key_dataArray);
}

- (void)setDataArray:(NSMutableArray *)dataArray{
    objc_setAssociatedObject(self, &key_dataArray, dataArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (id)orginResponseObject{
    return objc_getAssociatedObject(self, &key_orginResponseObject);
}

- (void)setOrginResponseObject:(id)orginResponseObject{
    objc_setAssociatedObject(self, &key_orginResponseObject, orginResponseObject, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (RACSignal *)singalForSingleRequestWithSet:(MNetConfig *)setting{

    RACReplaySubject *subject = [RACReplaySubject subject];
    
    [[self baseSingleRequestWithSet:setting] subscribeNext:^(id  _Nullable x) {
        self.orginResponseObject = x;
        if (!self.dataArray) {
            self.dataArray = @[].mutableCopy;
        }
        
        if (setting.isRefresh) {
            [self.dataArray removeAllObjects];
        }
        
        NSArray *separateKeyArray = [setting.modelLocalPath componentsSeparatedByString:@"/"];
        for (NSString *sepret_key in separateKeyArray) {
            x = x[sepret_key];
        }
        NSArray *dataArray = [NSArray modelArrayWithClass:NSClassFromString(setting.modelNameOfArray) json:x];

        if (dataArray.count == 0) {
            self.isNoMoreData = YES;
        } else {
            self.isNoMoreData = NO;
            [self.dataArray addObjectsFromArray:dataArray];
        }
        [subject sendNext:self.dataArray];
    } error:^(NSError * _Nullable error) {
        [subject sendError:error];
    }completed:^{
        [subject sendCompleted];
    }];
    return subject;
}

- (RACSignal *)baseSingleRequestWithSet:(MNetConfig *)setting{
    RACReplaySubject *subject = [RACReplaySubject subject];
    
    if (![self isSatisfyLoadMoreRequest]&&!setting.isRefresh) {
        [subject sendError:nil];
        return subject;
    }
    if (!setting.paramet) {
        setting.paramet = [NSMutableDictionary dictionary];
    }
    if (setting.isRefresh) {
        self.currentPage = 0;
    }
//    self.currentPage ++;
    self.currentPage = 1;
    if (setting.keyOfPage) {
      [setting.paramet setValue:@(self.currentPage) forKey:setting.keyOfPage];
    }
    self.isRequesting = YES;
    [[MNetRequestModel netRequestSeting:setting] subscribeNext:^(id  _Nullable x) {
        self.isRequesting = NO;
        [subject sendNext:x];
        
    } error:^(NSError * _Nullable error) {
        self.isRequesting = NO;
        if (self.currentPage > 0) {
            self.currentPage--;
        }
        [subject sendError:error];
    } completed:^{
        [subject sendCompleted];
    }];
    return subject;
    
}


- (BOOL)isSatisfyLoadMoreRequest{
    return (!self.isNoMoreData&&!self.isRequesting);
}



@end
