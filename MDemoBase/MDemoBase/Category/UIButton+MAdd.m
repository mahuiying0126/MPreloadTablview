//
//  UIButton+MAdd.m
//  Demo_268EDU
//
//  Created by yizhilu on 2017/9/22.
//  Copyright © 2017年 Magic. All rights reserved.
//

#import "UIButton+MAdd.h"
#import <objc/runtime.h>
@interface UIButton ()
@property (nonatomic, assign) NSTimeInterval custom_acceptEventTime;
@end
static const void *clickBlockKey = @"clickBlockKey_m";
static const void *acceptEventIntervalKey = @"UIControl_acceptEventInterval_m";
static const void *acceptEventTime = @"UIControl_acceptEventTime_m";


@implementation UIButton (MAdd)

+ (void)load{
    Method systemMethod = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    SEL sysSEL = @selector(sendAction:to:forEvent:);
    
    Method customMethod = class_getInstanceMethod(self, @selector(custom_sendAction:to:forEvent:));
    SEL customSEL = @selector(custom_sendAction:to:forEvent:);
    
    //添加方法 语法：BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types) 若添加成功则返回No
    // cls：被添加方法的类  name：被添加方法方法名  imp：被添加方法的实现函数  types：被添加方法的实现函数的返回值类型和参数类型的字符串
    BOOL didAddMethod = class_addMethod(self, sysSEL, method_getImplementation(customMethod), method_getTypeEncoding(customMethod));
    
    //如果系统中该方法已经存在了，则替换系统的方法  语法：IMP class_replaceMethod(Class cls, SEL name, IMP imp,const char *types)
    if (didAddMethod) {
        class_replaceMethod(self, customSEL, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
    }else{
        method_exchangeImplementations(systemMethod, customMethod);
        
    }
}


#pragma mark - Property

-(UIFont *)fontM{
    return self.titleLabel.font;
}

-(void)setFontM:(UIFont *)fontM{
    self.titleLabel.font = fontM;
}

-(NSString *)normalTitleM{
    return self.titleLabel.text;
}

-(void)setNormalTitleM:(NSString *)normalTitleM{
    [self setTitle:normalTitleM forState:UIControlStateNormal];
}

-(NSString *)selecTitleM{
    return self.titleLabel.text;
}

-(void)setSelecTitleM:(NSString *)selecTitleM{
    [self setTitle:selecTitleM forState:UIControlStateSelected];
}

-(UIColor *)normalColorM{
    return self.titleLabel.textColor;
}

-(void)setNormalColorM:(UIColor *)normalColorM{
    [self setTitleColor:normalColorM forState:UIControlStateNormal];
}

-(UIColor *)selectColorM{
    return self.titleLabel.textColor;
}

-(void)setSelectColorM:(UIColor *)selectColorM{
    [self setTitleColor:selectColorM forState:UIControlStateSelected];
}

-(CGFloat)addRadiuM{
    return self.layer.cornerRadius;
}

-(void)setAddRadiuM:(CGFloat)addRadiuM{
    self.clipsToBounds = YES;
    self.layer.cornerRadius = addRadiuM;
}

-(CGFloat)borderWidthM{
    return self.layer.borderWidth;
}

-(void)setBorderWidthM:(CGFloat)borderWidthM{
    self.layer.borderWidth = borderWidthM;
}

-(UIColor *)borderColorM{
    return [UIColor whiteColor];
}

-(void)setBorderColorM:(UIColor *)borderColorM{
    self.layer.borderColor = borderColorM.CGColor;
}

-(ClickBlockM)clickBlockM{
    return  objc_getAssociatedObject(self, clickBlockKey);
}

-(void)setClickBlockM:(ClickBlockM)clickBlockM{
    objc_setAssociatedObject(self, clickBlockKey, clickBlockM, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self removeTarget:self action:@selector(buttonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    if (clickBlockM) {
        [self addTarget:self action:@selector(buttonClickEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (NSTimeInterval )custom_acceptEventInterval{
    return [objc_getAssociatedObject(self, acceptEventIntervalKey) doubleValue];
}

- (void)setCustom_acceptEventInterval:(NSTimeInterval)custom_acceptEventInterval{
    objc_setAssociatedObject(self,acceptEventIntervalKey, @(custom_acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval )custom_acceptEventTime{
    return [objc_getAssociatedObject(self, acceptEventTime) doubleValue];
}

- (void)setCustom_acceptEventTime:(NSTimeInterval)custom_acceptEventTime{
    objc_setAssociatedObject(self, acceptEventTime, @(custom_acceptEventTime), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}




#pragma mark - Method

- (void)layoutButtonWithEdgeInsetsStyle:(ButtonEdgeInsetsStyle)style imageTitleSpace:(CGFloat)space{
    /**
     *  前置知识点：titleEdgeInsets是title相对于其上下左右的inset，跟tableView的contentInset是类似的，
     *  如果只有title，那它上下左右都是相对于button的，image也是一样；
     *  如果同时有image和label，那这时候image的上左下是相对于button，右边是相对于label的；title的上右下是相对于button，左边是相对于image的。
     */
    // 1. 得到imageView和titleLabel的宽、高
    CGFloat imageWith = self.imageView.frame.size.width;
    CGFloat imageHeight = self.imageView.frame.size.height;
    
    CGFloat labelWidth = self.titleLabel.intrinsicContentSize.width;
    CGFloat labelHeight = self.titleLabel.intrinsicContentSize.height;

    
    // 2. 声明全局的imageEdgeInsets和labelEdgeInsets
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    UIEdgeInsets labelEdgeInsets = UIEdgeInsetsZero;
    
    // 3. 根据style和space得到imageEdgeInsets和labelEdgeInsets的值
    switch (style) {
        case ButtonEdgeInsetsStyleTop:
        {
            imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-space/2.0, 0, 0, -labelWidth-space);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-space/2.0, 0);
        }
            break;
        case ButtonEdgeInsetsStyleLeft:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2.0, 0, space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, space/2.0, 0, -space/2.0);
        }
            break;
        case ButtonEdgeInsetsStyleBottom:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, 0, -labelHeight-space/2.0, -labelWidth);
            labelEdgeInsets = UIEdgeInsetsMake(-imageHeight-space/2.0, -imageWith, 0, 0);
        }
            break;
        case ButtonEdgeInsetsStyleRight:
        {
            imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth+space/2.0, 0, -labelWidth-space/2.0);
            labelEdgeInsets = UIEdgeInsetsMake(0, -imageWith-space/2.0, 0, imageWith+space/2.0);
        }
            break;
        default:
            break;
    }
    
    // 4. 赋值
    self.titleEdgeInsets = labelEdgeInsets;
    self.imageEdgeInsets = imageEdgeInsets;
}

-(void)buttonClickEvent:(UIButton *)sender{
    if (self.clickBlockM) {
        self.clickBlockM();
    }
}

- (void)custom_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    
    // 如果想要设置统一的间隔时间，可以在此处加上以下几句
    // 值得提醒一下：如果这里设置了统一的时间间隔，会影响UISwitch,如果想统一设置，又不想影响UISwitch，建议将UIControl分类，改成UIButton分类，实现方法是一样的
    // if (self.custom_acceptEventInterval <= 0) {
    //     // 如果没有自定义时间间隔，则默认为2秒
    //    self.custom_acceptEventInterval = 2;
    // }
    
    // 是否小于设定的时间间隔
    BOOL needSendAction = (NSDate.date.timeIntervalSince1970 - self.custom_acceptEventTime >= self.custom_acceptEventInterval);
    
    // 更新上一次点击时间戳
    if (self.custom_acceptEventInterval > 0) {
        self.custom_acceptEventTime = NSDate.date.timeIntervalSince1970;
    }
    
    // 两次点击的时间间隔小于设定的时间间隔时，才执行响应事件
    if (needSendAction) {
        [self custom_sendAction:action to:target forEvent:event];
    }
    
    
}
@end
