//
//  ViewController.m
//  MDemoBase
//
//  Created by yizhilu on 2017/9/9.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "ViewController.h"
#import "MNavigationViewController.h"
#import "TestDataModel.h"
#import "TestTableView.h"
@interface ViewController ()
/**
 表格
 */
@property (nonatomic, strong)  TestTableView *testTableView;


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view msetWhiteBackground];
    [self testTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - 响应事件



#pragma mark - 私有方法


#pragma mark - 懒加载

-(TestTableView *)testTableView{
    
    if (!_testTableView) {
        _testTableView = [[TestTableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) style:UITableViewStylePlain];
        [self.view addSubview:_testTableView];
    }
    return _testTableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
