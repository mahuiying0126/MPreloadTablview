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


@end

@implementation TestTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.viewModel = [TestDataModel new];
        self.dataSource = self;
        self.delegate   = self;
        self.rowHeight = 100;
        [self registerClass:[TestTableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        kWeakSelf(self)
        [self headerReloadBlock:^{
            kStrongSelf(self)
            [self requestGoodListIsReload:YES];
        }];
        self.m_preloadBlock = ^{
            kStrongSelf(self)
            [self requestGoodListIsReload:NO];
        };
        
        [self footerReloadMoreBlock:^{
            kStrongSelf(self)
            [self requestGoodListIsReload:NO];
        }];
        [self requestGoodListIsReload:YES];
        
    }
    return self;
}



- (void)requestGoodListIsReload:(BOOL)isReload{
    kWeakSelf(self)
    
    [[self.viewModel siganlForJokeDataIsReload:isReload] subscribeNext:^(id  _Nullable x) {
        self.dataArray = x;
    }  error:^(NSError * _Nullable error) {
        kStrongSelf(self)
        [self noMoreData];
        [self endReload];
    } completed:^{
        kStrongSelf(self)
        
        [self reloadData];
        [self endReload];
    }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    MHYTestModel *model = self.dataArray[indexPath.row];
    cell.textLB.text = model.content ;
    [self preloadDataWithCurrentIndex:indexPath.row];

    return cell;
}



@end
