//
//  NvMakeupColorView.h
//  GradientColorSlider
//
//  Created by MS on 2020/3/3.
//  Copyright © 2020 MS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvMakeupModel.h"
@class NvMakeupColorView;
NS_ASSUME_NONNULL_BEGIN

@protocol NvMakeupColorViewDelegate <NSObject>

/// 获取自定义颜色选择值
/// Get custom color selection value
/// @param colorView 当前视图 Current view
/// @param r 颜色值 Color value
/// @param g 颜色值 Color value
/// @param b 颜色值 Color value
/// @param alpha 透明度 alpha
/// @param point 点击的位置 point to click
- (void)colorView:(NvMakeupColorView *)colorView R:(CGFloat)r G:(CGFloat)g B:(CGFloat)b alpha:(CGFloat)alpha point:(CGPoint)point;

/// 点击自定义颜色按钮
/// Click the custom color button
/// @param colorView 当前视图 Current view
/// @param index 下标 index
- (void)colorView:(NvMakeupColorView *)colorView selectColorButton:(NSInteger)index;

@end
@interface NvMakeupColorView : UIView

/// 默认颜色数组 Default color array
@property (nonatomic, strong) NSArray *defaultColorArr;

/// 代理 delegate
@property (weak, nonatomic) id<NvMakeupColorViewDelegate> delegate;

/// 美妆模型数据 Make up model data
@property (nonatomic, strong) NvMakeupContentModel *model;


@end

NS_ASSUME_NONNULL_END
