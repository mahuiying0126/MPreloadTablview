//
//  UITableView+MPreload.h
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/8.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kWeakSelf(type)__weak typeof(type)weak##type = type;

#define kStrongSelf(type)__strong typeof(type)type = weak##type;

/**
 *  预加载触发的数量
 */
static NSInteger const PreloadMinCount = 5;

typedef void(^PreloadBlock)(void);

typedef void(^ReloadBlock)(void);

typedef void (^ReloadMoreBlock)(void);

@interface UITableView (MPreload)

/**
 *  预加载回调
 */
@property (nonatomic, copy) PreloadBlock m_preloadBlock;
/**
 *  tableview数据
 */
@property (nonatomic, strong) NSMutableArray *dataArray;


/**
 *  计算当前index是否达到预加载条件并回调
 *
 *  @param currentIndex row or section
 */
- (void)preloadDataWithCurrentIndex:(NSInteger)currentIndex;
/**
 *  下拉刷新
 *
 *  @param m_reloadBlock 刷新回调
 */
- (void)headerReloadBlock:(ReloadBlock)m_reloadBlock;

/**
 上拉加载

 @param m_reloadMoreBlock 刷新回调
 */
-(void)footerReloadMoreBlock:(ReloadMoreBlock)m_reloadMoreBlock;

/**
 *  结束上拉,下拉刷新
 */
- (void)endReload;

/**
 上拉加载,没有更多数据
 */
-(void)noMoreData;

@end
