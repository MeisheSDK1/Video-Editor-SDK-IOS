//
//  NvCapturePopupView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/1.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CapturePopupTypeExposure = 1,
    CapturePopupTypeZoom = 2,
} CapturePopup;

@interface NvCapturePopupView : UIView

/// 默认值  Default value
@property (nonatomic, assign) float defaultValue;

/// 效果发生改变的回调  Callback with effect change
@property (nonatomic, copy) void(^ValueBlook)(float value);

/// 初始化
/// initialization
/// @param frame 位置 frame
/// @param type 类型 type
- (instancetype)initWithFrame:(CGRect)frame withType:(CapturePopup)type;

/// 配置最大值最小值
/// Configure max min
/// @param Minimum 最小值  Minimum
/// @param Maximum 最大值  Maximum
- (void)configMinimumValue:(float)Minimum MaximumValue:(float)Maximum;

@end
