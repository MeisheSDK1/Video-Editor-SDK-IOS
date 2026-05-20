//
//  NvAddCaptionView.h
//  SDKDemo
//
//  Created by Meicam on 2018/5/31.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVHeader.h"
#import "NvsTimeline.h"
#import "NvsCTimelineEditor.h"
@class NvAddCaptionView;

@protocol NvAddCaptionViewDelegate
@optional
- (void)nvAddCaptionViewdidAddCaptionClick:(int)index;
- (void)nvAddCaptionViewdidAddStyleClick;
- (void)nvAddCaptionViewdidAddOkClick;
- (void)nvAddCaptionViewdidAddKeyFrameClick;
- (void)nvAddCaptionCurveAdjustmentClick;
- (void)dragScrollTimelineEnded:(int64_t)timestamp;

- (void)dragTimelineEditor:(int64_t)timestamp;
- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint;
- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint;
- (void)captionTimelineEditorZoomIn;
- (void)captionTimelineEditorZoomOut;

@end

@interface NvAddCaptionView : UIView

@property (nonatomic, strong) UIButton *styleButton;
@property (nonatomic, strong) UIButton *keyframeButton;
@property (weak, nonatomic)id delegate;
@property (strong, nonatomic) NvsTimeline *timeline;
@property (nonatomic, strong) NvsCTimelineEditor *timelineEditor;
@property (nonatomic, strong) UIButton *playButton;
///设置当前sequence显示时间
///Set the sequence display time
- (void)setcurrentTime:(int64_t)time;
///重置关键帧状态
///Reset the keyframe state
- (void)setKeyframeState:(BOOL)hasKeyframe;

- (void)setKeyframeAddCurve;

@end
