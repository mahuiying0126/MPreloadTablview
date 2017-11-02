//
//  UIButton+MAdd.h
//  Demo_268EDU
//
//  Created by yizhilu on 2017/9/22.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ButtonEdgeInsetsStyle) {
    ButtonEdgeInsetsStyleTop, //image在上，label在下
    ButtonEdgeInsetsStyleLeft, //image在左，label在右
    ButtonEdgeInsetsStyleBottom, //image在下，label在上
    ButtonEdgeInsetsStyleRight //image在右，label在左
};
typedef void(^ClickBlockM)(void);
@interface UIButton (MAdd)

/**
 设置按钮字体 font
 */
@property (nonatomic,copy) UIFont *fontM;
/**
 设置nor 标题
 */
@property (nonatomic,copy)  NSString *normalTitleM;
/**
 设置sel 标题
 */
@property (nonatomic,copy)  NSString *selecTitleM;
/**
 正常字体颜色
 */
@property (nonatomic,copy)  UIColor *normalColorM;
/**
 选择正常字体颜色
 */
@property (nonatomic,copy)  UIColor *selectColorM;
/**
 圆角度数
 */
@property (nonatomic, assign)  CGFloat addRadiuM;
/**
 边框宽度
 */
@property (nonatomic, assign)  CGFloat borderWidthM;
/**
 边框颜色
 */
@property (nonatomic,copy)  UIColor *borderColorM;

/**
 block点击事件
 */
@property (nonatomic,copy)  ClickBlockM clickBlockM;
/** 重复点击加间隔**/
@property (nonatomic, assign) NSTimeInterval custom_acceptEventInterval;



/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)layoutButtonWithEdgeInsetsStyle:(ButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;

@end
