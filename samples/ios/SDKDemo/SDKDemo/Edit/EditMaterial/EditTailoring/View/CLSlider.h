//
//  CLSlider.h
//  CLBrowser
//
//  Created by chuliangliang on 2017/3/15.
//  Copyright © 2017年 chuliangliang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CLSlider;

typedef NS_ENUM(NSInteger,CLSliderStyle)
{
    CLSliderStyle_Nomal = 1,    /*样式例如 Style example|________|________|________|________|*/
    CLSliderStyle_Cross = 2,    /*样式例如 Style example|--------|--------|--------|--------|*/
    CLSliderStyle_Point = 3,    /*样式例如 Style example ●--------●--------●--------●--------●*/
    CLSliderStyle_No_Indicator = 4, /*样式例如 Style example --------------------------------*/
};

@protocol CLSliderDelegate <NSObject>

/// slider 滑动到的位置
/// The position that the slider slides into
/// @param slider self
/// @param ratio 滑动的位置在slider(画线区域)所占比例
/// Percentage of the position of the slide within the slider(the area where the line is drawn)
- (void)clSlider:(CLSlider *)slider selectRatio:(CGFloat)ratio;


/// slider 结束滑动
/// slider end slide
/// @param slider self
- (void)clSliderEndChanged:(CLSlider *)slider;

@end

@interface CLSlider : UIControl
@property (nonatomic, weak) id<CLSliderDelegate>delegate;

/**
 刻度样式 详情参考 枚举值 CLSliderStyle 默认 CLSliderStyle_Nomal
 Enumeration value CLSliderStyle Default CLSliderStyle_Nomal
 */
@property (nonatomic) CLSliderStyle sliderStyle;

/**
 滑块填充颜色
 Slider fill color
 */
@property (nonatomic) UIColor *thumbTintColor;


/**
 滑块阴影颜色
 Slider shadow color
 */
@property (nonatomic) UIColor *thumbShadowColor;


/**
 滑块阴影透明度
 Slider shadow transparency
 */
@property (nonatomic) CGFloat thumbShadowOpacity;


/**
 滑块直径 默认20
 The slider diameter is 20 by default
 */
@property (nonatomic) CGFloat thumbDiameter;

/**
 刻度线 线条颜色
 Scale line color
 */
@property (nonatomic) UIColor *scaleLineColor;


/**
 刻度线 线条宽度
 Scale line width
 */
@property (nonatomic,assign) CGFloat scaleLineWidth;

/**
 刻度线 线条高度
 Scale line height
 */
@property (nonatomic,assign) CGFloat scaleLineHeight;


/**
 刻度线 刻度数量
 Scale line number of scales
 */
@property (nonatomic,assign) NSInteger scaleLineNumber;


/**
 当前滑块所处 刻度的索引 默认0
 The index of the scale on which the current slider is located defaults to 0
 */
@property (nonatomic,assign,readonly) NSInteger currentIdx;


/**
 文字layer 宽度
 Text layer width
 */
@property (nonatomic,assign) CGFloat titleLayerWidth;


/**
 设置 滑块选中的刻度索引 无动画效果
 Set slider selected scale index without animation effect
 */
- (void)setSelectedIndex:(NSInteger)index;


/**
 设置 滑块选中的刻度索引
 Sets the slider's selected scale index
 animated 是否有动画效果
 Animation effect or not
 */
- (void)setSelectedIndex:(NSInteger)index animated:(BOOL)animated;


/// 设置文字内容
/// Set text content
/// @param text 文字内容
/// Text content
- (void)setText:(NSString *)text ;


/// 设置目前滑块位置所占比例
/// Set the proportion of the current slider position
/// @param thumbRatio比例值
/// thumbRatio scale value
- (void)setThumbRatio:(double)thumbRatio;
@end
