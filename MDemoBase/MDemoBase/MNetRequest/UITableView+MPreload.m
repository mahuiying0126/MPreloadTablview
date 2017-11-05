//
//  UITableView+MPreload.m
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/8.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "UITableView+MPreload.h"
#import <objc/runtime.h>
#import <MJRefresh/MJRefresh.h>
static const char * key_m_dataArray = "key_m_dataArray";
static const char * key_m_preloadBlock = "key_m_preloadBlock";

@implementation UITableView (MPreload)

-(PreloadBlock)m_preloadBlock{
    return objc_getAssociatedObject(self, &key_m_preloadBlock);
}

-(void)setM_preloadBlock:(PreloadBlock)m_preloadBlock{
    objc_setAssociatedObject(self, &key_m_preloadBlock, m_preloadBlock, OBJC_ASSOCIATION_COPY);
}

-(NSMutableArray *)dataArray{
    return objc_getAssociatedObject(self, &key_m_dataArray);
}

-(void)setDataArray:(NSMutableArray *)dataArray{
    objc_setAssociatedObject(self, &key_m_dataArray, dataArray, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)headerReloadBlock:(ReloadBlock)js_reloadBlock{
//    MJRefreshGifHeader *gifHead = [MRunMenHeader headerWithRefreshingBlock:js_reloadBlock];
//    self.mj_header = gifHead;
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:js_reloadBlock];
    self.mj_header = header;
}

-(void)footerReloadMoreBlock:(ReloadMoreBlock)js_reloadMoreBlock{
    
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:js_reloadMoreBlock];
    self.mj_footer = footer;
}

- (void)endReload{
    
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshing];
}
-(void)noMoreData{
    [self.mj_header endRefreshing];
    [self.mj_footer endRefreshingWithNoMoreData];
}

- (void)preloadDataWithCurrentIndex:(NSInteger)currentIndex{
    NSInteger totalCount = self.dataArray.count;
    if ([self isSatisfyPreloadDataWithTotalCount:totalCount currentIndex:currentIndex]&&self.m_preloadBlock) {
        self.m_preloadBlock();
    }
}

- (BOOL)isSatisfyPreloadDataWithTotalCount:(NSInteger)totalCount currentIndex:(NSInteger)currentIndex{
    
    return  ((currentIndex == totalCount - PreloadMinCount) && (currentIndex >= PreloadMinCount));
}

@end
