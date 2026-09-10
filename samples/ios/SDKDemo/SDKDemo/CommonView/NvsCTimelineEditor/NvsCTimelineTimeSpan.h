//
//  NvsTimelineTimeSpan.h
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#ifndef NvsCTimelineTimeSpan_h
#define NvsCTimelineTimeSpan_h

#pragma once

#import <UIKit/UIKit.h>


@protocol NvsCTimelineTimeSpanDelegate <NSObject>

@optional

/// 开始拖拽
/// Start dragging
/// @param timeSpan 当前对象 Current object
/// @param timeSpanItem 当前对象 Current object
/// @param isLeftHandle 是否是左边的拖拽控件 Whether it is the drag control on the left
- (void)timeSpan:(id)timeSpan dragHandleStarted:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle;

/// 拖拽中
/// Dragging
/// @param timeSpan 当前对象 Current object
/// @param timeSpanItem 当前对象 Current object
/// @param isLeftHandle 是否是左边的拖拽控件 Whether it is the drag control on the left
/// @param xOffset 滑动的距离 Sliding distance
- (void)timeSpan:(id)timeSpan draggingHandle:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle xOffset:(double)xOffset;

/// 拖拽结束
/// Drag to end
/// @param timeSpan 当前对象 Current object
/// @param timeSpanItem 当前对象 Current object
/// @param isLeftHandle 是否是左边的拖拽控件 Whether it is the drag control on the left
- (void)timeSpan:(id)timeSpan dragHandleEnded:(UIView*)timeSpanItem isLeftHandle:(bool)isLeftHandle;

@end



@interface NvsCTimelineTimeSpan : UIView

/// 代理 delegate
@property (nonatomic, weak) id <NvsCTimelineTimeSpanDelegate> delegate;

/// 入点 inPoint
@property (nonatomic, assign) int64_t inPoint;

/// 出点 outPoint
@property (nonatomic, assign) int64_t outPoint;

/// 尺码线起始位置 Starting position of the size line
@property (nonatomic, assign) double padding;

/// 时间和像素比例尺 Time and pixel scale
@property (nonatomic, assign) double pointsPerMicrosecond;

/// 是否选中 is selected
@property (nonatomic, assign) bool selected;

/// 是否可以编辑 Can edit
@property (nonatomic, assign) bool editable;

/// 控件的颜色 The color of the control
@property (nonatomic, strong) UIColor *timeSpanColor;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;

/// 刷新界面状态
/// Refresh interface status
- (void)updateFrame;

@end


#endif /* NvsTimelineTimeSpan_h */
