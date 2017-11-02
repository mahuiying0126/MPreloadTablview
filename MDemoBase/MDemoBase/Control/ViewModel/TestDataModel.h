//
//  TestDataModel.h
//  MDemoBase
//
//  Created by yizhilu on 2017/11/2.
//Copyright © 2017年 Magic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MRequestAdd.h"
@interface TestDataModel : NSObject


- (RACSignal *)siganlForJokeDataIsReload:(BOOL)isReload;


@end
