//
//  NvVideoSlider.h
//  NvCheez
//
//  Created by 刘东旭 on 2017/12/5.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvVideoSliderInfo : NSObject

@property (nonatomic, strong) NSString* mediaFilePath;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;
@property (nonatomic, assign) int64_t trimIn;
@property (nonatomic, assign) int64_t trimOut;
@property (nonatomic, assign) bool stillImageHint;

@end

@protocol NvVideoSliderDelegate <NSObject>

@optional

/// 开始拖动滑块
/// start to drag handle
/// @param timelineEditor timelineEditor
/// @param trimin trimin in timeline
/// @param trimout trimout in timeline
- (void)timelineEditor:(id)timelineEditor dragHandleStarted:(int64_t)trimin trimOut:(int64_t)trimout;


/// 拖动滑块
/// drag the handle
/// @param timelineEditor timelineEditor
/// @param trimin trimin in timeline
/// @param trimout trimout in timeline
- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)trimin trimOut:(int64_t)trimout;


/// 停止拖动滑块
/// stop dragging the handle
/// @param timelineEditor timelineEditor
/// @param trimin trimin in timeline
/// @param trimout trimout in timeline
- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)trimin trimOut:(int64_t)trimout;


/// 滑动缩略图
/// drag the scrollview of timeline
/// @param timelineEditor timelineEditor
/// @param timestamp timestamp
- (void)timelineEditor:(id)timelineEditor dragScrollingTimeline:(int64_t)timestamp;


/// 停止滑动缩略图
/// stop to drag the scrollview of timeline
/// @param timelineEditor timelineEditor
/// @param timestamp timestamp
- (void)timelineEditor:(id)timelineEditor dragScrollTimelineEnded:(int64_t)timestamp;
@end

@interface NvVideoSlider : UIView

@property (nonatomic, weak) id <NvVideoSliderDelegate> delegate;
@property (nonatomic, assign) bool canOverlapTimeSpan;
@property (nonatomic, assign) bool caneditTimeSpan;
@property (nonatomic, assign) int64_t timelinePosition;
@property (nonatomic) CGFloat startPadding;
@property (nonatomic, assign) double displayDuration;
@property (nonatomic, assign) int64_t timelineDuration;
@property (nonatomic, assign) int64_t maximumDuration;

@property (nonatomic, strong, readonly) UIImageView *leftSliderView;
@property (nonatomic, strong, readonly) UIImageView *rightSliderView;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame withOffset:(CGFloat)offset;

- (void) initTimelineEditor:(NSArray*) timelineEditorInfos timelineDuration:(int64_t)timelineDuration;
- (void)setSequencePointsPerMicrosecond:(int)duration;

- (void)setMinimumDuration:(double)minDuration;

- (void)setTimespanMiddleHandlePosition:(int64_t)position;

- (CGFloat)getTimelineEditorWidth;

@end
