//
//  NvsTimelineEditor.h
//  NvsTimelineEditor
//
//  Created by LionLee on 2017/8/29.
//  Copyright © 2017年 CDV. All rights reserved.
//

#ifndef NvsCTimelineEditor_h
#define NvsCTimelineEditor_h


#pragma once

#import <UIKit/UIKit.h>
#import "NvsCTimelineTimeSpan.h"


@interface NvsCTimelineEditorInfo : NSObject

@property (nonatomic, strong) NSString* mediaFilePath;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;
@property (nonatomic, assign) int64_t trimIn;
@property (nonatomic, assign) int64_t trimOut;
@property (nonatomic, assign) bool stillImageHint;

@end

@protocol NvsCTimelineEditorDelegate <NSObject>

@optional

/// 开始拖拽
/// Start dragging
/// @param timelineEditor 当前对象 Current object
/// @param timestamp 当前时间点 Current time
/// @param isInPoint 当前操作的是否是裁入点 Whether the current operation is the cut-in point
- (void)timelineEditor:(id)timelineEditor dragHandleStarted:(int64_t)timestamp isInPoint:(bool)isInPoint;

/// 正在拖拽
/// Dragging
/// @param timelineEditor 当前对象 Current object
/// @param timestamp 当前时间点 Current time
/// @param isInPoint 当前操作的是否是裁入点 Whether the current operation is the cut-in point
- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint;

/// 结束拖拽
/// End drag
/// @param timelineEditor 当前对象 Current object
/// @param timestamp 当前时间点 Current time
/// @param isInPoint 当前操作的是否是裁入点 Whether the current operation is the cut-in point
- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint;

/// 正在拖拽时间线
/// Dragging timeline
/// @param timelineEditor 当前对象 Current object
/// @param timestamp 当前时间点 Current time
- (void)timelineEditor:(id)timelineEditor dragScrollingTimeline:(int64_t)timestamp;

/// 结束拖拽时间线
/// End drag timeline
/// @param timelineEditor 当前对象 Current object
/// @param timestamp 当前时间点 Current time
- (void)timelineEditor:(id)timelineEditor dragScrollTimelineEnded:(int64_t)timestamp;

@end


@interface NvsCTimelineEditor : UIView

/// 代理 delegate
@property (nonatomic, weak) id <NvsCTimelineEditorDelegate> delegate;

/// 能否重叠 Can overlap
@property (nonatomic, assign) bool canOverlapTimeSpan;

/// 能否重叠编辑 Can overlap edit
@property (nonatomic, assign) bool caneditTimeSpan;

/// 时间点 Point in time
@property (nonatomic, assign) int64_t timelinePosition;

- (instancetype)init;

- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;

/// 配置界面数据
/// Configuration interface data
/// @param timelineEditorInfos 视频片段 Video clip
/// @param timelineDuration timeline时长 timeline duration
- (void) initTimelineEditor:(NSArray*) timelineEditorInfos timelineDuration:(int64_t)timelineDuration;

/// 添加TimeSpan区间控件
/// Add TimeSpan interval control
/// @param inPoint 入点 inPoint
/// @param outPoint 出点 outPoint
- (NvsCTimelineTimeSpan*) addTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint;

/// 删除TimeSpan区间控件
/// Add TimeSpan interval control
- (void) deleteSelectedTimeSpan;

/// 删除所有TimeSpan区间控件
/// Delete all TimeSpan interval controls
- (void) deleteAllTimeSpan;

/// 选中当前TimeSpan区间控件
/// Select the current TimeSpan interval control
/// @param timeSpan 当前控件 Current control
- (void) selectTimeSpan:(NvsCTimelineTimeSpan*)timeSpan;

/// 更新TimeSpan区间控件
/// Update TimeSpan interval control
- (void) updateSelectedItem;

/// 放大当前比例尺
/// Enlarge the current scale
- (void)zoomIn;

/// 缩小当前比例尺
/// Reduce the current scale
- (void)zoomOut;

/// 根据参数选中当前TimeSpan控件
/// Select the current TimeSpan control according to the parameters
/// @param inPoint 入点 inPoint
/// @param outPoint 出点 outPoint
- (void)selectTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint;

/// 根据参数选中删除TimeSpan控件
/// Select and delete TimeSpan control according to parameters
/// @param inPoint 入点 inPoint
/// @param outPoint 出点 outPoint
- (void)deleteTimeSpan:(int64_t)inPoint outPoint:(int64_t)outPoint;

/// 清除所有TimeSpan控件选中状态
/// Clear the selected state of all TimeSpan controls
- (void)clearTimeSpanSelection;

/// 当前时间点是否在TimeSpan区间
/// Whether the current time point is in the TimeSpan interval
/// @param position 当前时间点 Current time
- (bool)isInTimespan:(int64_t)position;

/// 根据传入时间点选中TimeSpan
/// Select TimeSpan according to the incoming time point
/// @param position 当前时间点 Current time
- (void)selectTimeSpanByPosition:(int64_t)position;

/// 配置当前关键帧数据并且选中当前状态
/// Configure the current key frame data and select the current state
/// @param array 关键帧数组 Keyframe array
/// @param inPoint 入点 inPoint
/// @param outPoint 出点 outPoint
- (void)configKeyFrames:(NSMutableArray *)array withSpanInPoint:(int64_t)inPoint withOutPoint:(int64_t)outPoint;

/// 配置当前关键帧数据
/// Configure current key frame data
/// @param array 关键帧数组 Keyframe array
- (void)configKeyFrames:(NSMutableArray *)array;

/// 配置当前选中的关键帧
/// Configure the currently selected key frame
/// @param keyFramesTag 关键帧下标 Keyframe subscript
- (void)configSelectKeyFrames:(NSInteger)keyFramesTag;

/// 清除所有关键帧的选中状态
/// Clear the selected state of all keyframes
- (void)removeAllKeyFramesSelectState;

/// 时码线是否在关键帧界面上
/// Whether the time code line is on the key frame interface
/// @param keyTime 关键帧时间 Key frame time
/// @param time 当前时间 current time
- (BOOL)isInKeyframeView:(int64_t)keyTime time:(int64_t)time;

/// 删除所有关键帧图案
/// Delete all key frame patterns
- (void)removeAllKeyFrameImageViews;

- (CGFloat)getTimelineEditorWidth;
@end


#endif /* NvsTimelineEditor_h */
