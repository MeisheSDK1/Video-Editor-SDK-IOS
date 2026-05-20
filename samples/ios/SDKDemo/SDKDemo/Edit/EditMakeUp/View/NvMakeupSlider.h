//
//  NvMakeupSlider.h
//  SDKDemo
//
//  Created by ms on 2021/12/2.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class NvThinSlider;
@protocol NvMakeupSliderViewDelegate <NSObject>
@optional
/// 滑动回调
/// Sliding callback
/// @param paramSender 当前滑杆 Current slider
-(void)sliderValueChanged:(UISlider *)paramSender;

/// 滑动结束回调
/// Sliding end callback
/// @param paramSender 当前滑杆 Current slider
-(void)sliderValueEnd:(UISlider *)paramSender;
@end

@interface NvMakeupSlider : UIView

/// 当前值 The current value
@property (nonatomic, assign) CGFloat value;

/// 最大值 Max value
@property (nonatomic, assign) CGFloat maxValue;

/// 最小值 Max value
@property (nonatomic, assign) CGFloat minValue;

/// 当前滑杆 Current slider
@property (nonatomic, strong) NvThinSlider *slider;

@property (nonatomic, copy) NSString *thumbImage;
@property (nonatomic, strong) UIColor *indicatorTextColor;
@property (nonatomic, copy) NSString *pointForamt;

/// 是否显示数值背景图  Whether to display the numerical background image
@property (nonatomic, assign) BOOL hiddenIndicatorView;

/// 代理 delegate
@property(nonatomic, weak) id<NvMakeupSliderViewDelegate> delegate;

/// 刷新界面状态 Refresh interface status
- (void)refreshView;

@end

NS_ASSUME_NONNULL_END
