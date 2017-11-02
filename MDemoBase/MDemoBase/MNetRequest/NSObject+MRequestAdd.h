//
//  NSObject+MRequestAdd.h
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/8.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal,MNetConfig;

@interface NSObject (MRequestAdd)

/**
 *  数据数组
 */
@property (nonatomic, strong) NSMutableArray *dataArray;
/**
 *  原始请求数据
 */
@property (nonatomic, strong) id orginResponseObject;
/**
 *  当前页码
 */
@property (nonatomic, assign) NSInteger currentPage;
/**
 *  是否请求中
 */
@property (nonatomic, assign) BOOL isRequesting;
/**
 *  是否数据加载完
 */
@property (nonatomic, assign) BOOL isNoMoreData;

-(RACSignal *)singalForSingleRequestWithSet:(MNetConfig *)setting;




@end
