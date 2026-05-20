//
//  YWISOSlider.h
//  YaoWang
//
//  Created by 出出 on 2020/1/9.
//  Copyright © 2020 JingLan. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YWISOSlider;

NS_ASSUME_NONNULL_BEGIN
@protocol YWISOSliderDelegate <NSObject>
@optional

/// 开始滑动
/// Start sliding
/// @param slider 滑杆 slider
- (void)YWISOSliderValueStarted:(YWISOSlider *)slider ;

/// 滑动中
/// Sliding
/// @param slider 滑杆 slider
- (void)YWISOSliderValueChanged:(YWISOSlider *)slider ;

/// 滑动结束
/// End of slide
/// @param slider 滑杆 slider
- (void)YWISOSliderValueEnded:(YWISOSlider *)slider ;
@end

@interface YWISOSlider : UIControl

/// 效果值控件 Effect value control
@property (nonatomic, strong) UILabel *tagLabel;

/// 滑动按钮 Slide button
@property (nonatomic, strong) UIImage *thumbImage;

/// 未滑过的颜色 Unslid color
@property (nonatomic, strong) UIColor *minimumTrackTintColor;

/// 滑过的颜色 slid color
@property (nonatomic, strong) UIColor *maximumTrackTintColor;

/// 最小值 Minimum
@property (nonatomic, assign) CGFloat minimumValue;

/// 最大值 Max
@property (nonatomic, assign) CGFloat maximumValue;

/// 效果值 Effect value
@property (nonatomic, assign) CGFloat value;

/// 指示label 与slider 之间间距更近些
@property (nonatomic, assign) BOOL closerIndicator;

/// 代理 delegate
@property (nonatomic, weak) id<YWISOSliderDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
