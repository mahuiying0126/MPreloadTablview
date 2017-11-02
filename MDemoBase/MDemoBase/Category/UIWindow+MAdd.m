//
//  UIWindow+MAdd.m
//  MDemoBase
//
//  Created by yizhilu on 2017/9/9.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "UIWindow+MAdd.h"
#import "MNavigationViewController.h"
@implementation UIWindow (MAdd)

- (void)rootViewController:(NSString *)controller{

    self.backgroundColor = [UIColor whiteColor];
    MNavigationViewController *navControl = [[MNavigationViewController alloc]initWithRootViewController:[NSClassFromString(controller) new]];
    self.rootViewController = navControl;
    [self makeKeyAndVisible];
}

@end
