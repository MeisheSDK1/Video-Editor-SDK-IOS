//
//  NvCustomColorControl.h
//  SDKDemo
//
//  Created by MS on 2020/7/20.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvCustomColorControl;

NS_ASSUME_NONNULL_BEGIN
@protocol NvCustomColorControlDelegate <NSObject>

/// 颜色选择回调
/// Color selection callback
/// @param colorView 当前视图 Current view
/// @param r 颜色值 Color value
/// @param g 颜色值 Color value
/// @param b 颜色值 Color value
/// @param alpha 透明度 alpha
/// @param point 点击的位置 point to click
- (void)colorControl:(NvCustomColorControl *)colorView R:(CGFloat)r G:(CGFloat)g B:(CGFloat)b alpha:(CGFloat)alpha point:(CGPoint)point;

@end

@interface NvCustomColorControl : UIControl

@property (nonatomic, assign) BOOL endChange;

@property (strong, nonatomic) UIImageView *imageView;

/// 是否是垂直布局 Whether it is vertical layout
@property (nonatomic, assign) BOOL isVertical;

/// 代理 delegate
@property (weak, nonatomic) id<NvCustomColorControlDelegate> delegate;

/// 最后点击的位置 Last click location
@property (nonatomic, assign) CGPoint endPoint;

/// 初始化
/// initialization
/// @param frame 位置 frame
/// @param colors 颜色数组 Color Array
- (instancetype)initWithFrame:(CGRect)frame withColors:(NSArray *)colors;

/// 设置控件的默认状态  Sets the default state of the control
- (void)setDefaultMode;

/// 取消设置cornerRadius
- (void)cancelSetCornerRadius;

/// 设置indicator 高度
- (void)setIndicatorHeight:(CGFloat)height;
@end

NS_ASSUME_NONNULL_END
