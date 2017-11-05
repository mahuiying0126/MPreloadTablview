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


- (RACSignal *)siganlForTopicDataIsReload:(BOOL)isReload;

- (void)requestSuccess:(void (^)(id responseData))success failure:(void (^)(NSError *error))failure ;

@end
