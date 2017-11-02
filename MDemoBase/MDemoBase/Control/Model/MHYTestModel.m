//
//  MHYTestModel.m
//  MLoadMoreService
//
//  Created by yizhilu on 2017/9/7.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "MHYTestModel.h"
#import "NSString+MAdd.h"
@implementation MHYTestModel
-(void)setContent:(NSString *)content{
    NSString *text = [NSString exchangeHTMLToString:content];
    _content = text;
}
@end
