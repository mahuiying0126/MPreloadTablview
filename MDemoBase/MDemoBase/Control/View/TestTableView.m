//
//  TestTableView.m
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/12.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "TestTableView.h"
#import "TestTableViewCell.h"
#import "UITableView+MPreload.h"
#import "MHYTestModel.h"
#import "TestDataModel.h"
@interface TestTableView ()<UITableViewDelegate,UITableViewDataSource>
/**
 viewModel
 */
@property (nonatomic, strong) TestDataModel *viewModel;
/**
 网络数据请求
 */
@property (nonatomic, strong)  NSMutableArray *tempDataArray;


@end

@implementation TestTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.viewModel = [TestDataModel new];
        self.tempDataArray = [NSMutableArray new];
        self.dataSource = self;
        self.delegate   = self;
        self.rowHeight = 100;
        [self registerClass:[TestTableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        kWeakSelf(self)
        [self headerReloadBlock:^{
            kStrongSelf(self)
            [self requestGoodListIsReload:YES];
//            [self requestForSecondMethodIsRelod:YES];
        }];
        self.m_preloadBlock = ^{
            kStrongSelf(self)
            [self requestGoodListIsReload:NO];
//            [self requestForSecondMethodIsRelod:NO];
        };
        
        [self footerReloadMoreBlock:^{
            kStrongSelf(self)
            [self requestGoodListIsReload:NO];
//            [self requestForSecondMethodIsRelod:NO];
        }];
        [self requestGoodListIsReload:YES];
//        [self requestForSecondMethodIsRelod:YES];
    }
    return self;
}


//预加载方法
- (void)requestGoodListIsReload:(BOOL)isReload{
    kWeakSelf(self)
    
    [[self.viewModel siganlForTopicDataIsReload:isReload] subscribeNext:^(id  _Nullable x) {
        self.dataArray = x;
        self.tempDataArray = x;
    }  error:^(NSError * _Nullable error) {
        kStrongSelf(self)
        [self noMoreData];
    } completed:^{
        kStrongSelf(self)
        [self reloadData];
        [self endReload];
    }];
}
//普通加载方法
-(void)requestForSecondMethodIsRelod:(BOOL)isReload{

    [self.viewModel requestSuccess:^(id responseData) {
        NSArray *array = responseData;
        if (isReload) {
            [self.tempDataArray removeAllObjects];
        }
        [self.tempDataArray addObjectsFromArray:array];
        [self reloadData];
        [self endReload];
    } failure:^(NSError *error) {
        [self endReload];
    }];
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.tempDataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    MHYTestModel *model = self.tempDataArray[indexPath.row];
    cell.textLB.text = model.content;
    [self preloadDataWithCurrentIndex:indexPath.row];
//    if (self.tempDataArray.count - 3 == indexPath.row) {
//        [self requestForSecondMethodIsRelod:NO];
//    }
    return cell;
}



@end
