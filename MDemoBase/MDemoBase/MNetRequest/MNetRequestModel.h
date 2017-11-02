//
//  MNetRequestModel.h
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/7.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RACSignal,MNetConfig;
@interface MNetRequestModel : NSObject

+ (RACSignal *)netRequestSeting:(MNetConfig *)seting;

+(RACSignal *)uploadWithImagesInSeting:(MNetConfig *)seting;
@end


/**
 缓存设置
 
 - MCacheNoSave: 不缓存数据
 - MCacheSave: 缓存数据
 */
typedef NS_ENUM(NSUInteger, MCacehTime) {
    MCacheNoSave = 0,
    MCacheSave,
};

/**
 网络请求方式
 
 - MRequestMethodPOST: POST请求
 - NRequestMethodGET: GET请求
 */
typedef NS_ENUM(NSUInteger, MRequesttMethod) {
    MRequestMethodPOST = 0,
    NRequestMethodGET = 1,
};

@interface MNetConfig : NSObject

/** *是否显示HUD,默认显示*/
@property (nonatomic, assign) BOOL isHidenHUD;
/** HUD提示语*/
@property (nonatomic, strong)  NSString *HUDLabelText;

/** *是否是HTTPS请求,默认是NO*/
@property (nonatomic, assign) BOOL isHttpsRequest;
/** *缓存设置策略*/
@property (nonatomic, assign) MCacehTime cashSeting;
/** *是否刷新数据*/
@property (nonatomic, assign) BOOL isRefresh;
/** *是否缓存多页数据*/
@property (nonatomic, assign) BOOL isCashMoreData;
/** *缓存时间*/
@property (nonatomic, assign) NSInteger cashTime;
/** *请求方式,默认POST请求*/
@property (nonatomic, assign) MRequesttMethod requestStytle;
/** *地址*/
@property (nonatomic, strong) NSString *hostUrl;
/** *参数*/
@property (nonatomic, strong) NSMutableDictionary *paramet;
/** *验证json格式*/
@property (nonatomic, strong) id jsonValidator;
/** *预缓存的 model*/
@property (nonatomic, strong) NSString *modelNameOfArray;
/** *预缓存的数据位置*/
@property (nonatomic, strong) NSString *modelLocalPath;
/** *预缓存的page*/
@property (nonatomic, strong) NSString *keyOfPage;
/**上传图片数组*/
@property (nonatomic, strong) NSArray *uploadImages;


@end
