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

@property(nonatomic, assign) float defaultValue;

//把效果程度回调出去
@property(nonatomic, copy) void (^valueBlock)(float value);

- (instancetype)initWithFrame:(CGRect)frame withType:(CapturePopup)type;

/**
 配置最大值最小值

 @param Minimum 最小值
 @param Maximum 最大值
 */
- (void)configMinimumValue:(float)Minimum MaximumValue:(float)Maximum;

@end
