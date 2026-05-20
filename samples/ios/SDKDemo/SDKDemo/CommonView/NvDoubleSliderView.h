//
//  NvDoubleSliderView.h
//  NvDoubleSliderView-OC
//
//  Created by 杜奎 on 2019/1/13.
//  Copyright © 2019 DU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvDoubleSliderView : UIView

/// 左边时间显示控件 Time display control on the left
@property (nonatomic, strong) UILabel *leftLabel;

/// 右边时间显示控件 Time display control on the right
@property (nonatomic, strong) UILabel *rightLabel;

/// 时长 duration
@property (nonatomic, assign) double duration;

/// 当前最小的值 Current minimum value
@property (nonatomic, assign) CGFloat curMinValue;

/// 当前最大的值 Current maximum value
@property (nonatomic, assign) CGFloat curMaxValue;

/// 是否需要动画 Do you need animation
@property (nonatomic, assign) BOOL needAnimation;

/// 间隔大小 Interval size
@property (nonatomic, assign) CGFloat minInterval;

/// 滑块位置改变后的回调 isLeft 是否是左边 finish手势是否结束
/// The callback after the slider position is changed isLeft Whether it is the left side whether the finish gesture is over
@property (nonatomic, copy)   void (^sliderBtnLocationChangeBlock)(BOOL isLeft, BOOL finish);

/// 左边划过的颜色 Color across left
@property (nonatomic, strong) UIColor *minTintColor;

/// 中间的颜色 Middle color
@property (nonatomic, strong) UIColor *midTintColor;

/// 右边划过的颜色 Color swiped on the right
@property (nonatomic, strong) UIColor *maxTintColor;

/// 隐藏左边的控件 Hide the controls on the left
@property (nonatomic, assign) BOOL hiddenLeftIcon;

/// 隐藏右边边的控件 Hide the controls on the right
@property (nonatomic, assign) BOOL hiddenRightIcon;

/// 根据当前最小和最大的值改变滑块位置
/// Change the position of the slider according to the current minimum and maximum values   
- (void)changeLocationFromValue;

@end

