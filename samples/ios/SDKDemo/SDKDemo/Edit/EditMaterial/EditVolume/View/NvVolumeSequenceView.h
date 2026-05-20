//
//  NvVolumeSequenceView.h
//  SDKDemo
//
//  Created by ms on 2021/8/4.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVHeader.h"
#import "NvsTimeline.h"
#import "NvsCTimelineEditor.h"
@class NvVolumeSequenceView;

@protocol NvVolumeSequenceViewDelegate

- (void)nvVolumeSequenceViewdidAddOkClick;
- (void)nvVolumeSequenceViewdidAddKeyFrameClick;
- (void)nvVolumeSequenceCurveAdjustmentClick;
- (void)dragScrollTimelineEnded:(int64_t)timestamp;

- (void)dragTimelineEditor:(int64_t)timestamp;
- (void)timelineEditor:(id)timelineEditor dragHandleEnded:(int64_t)timestamp isInPoint:(bool)isInPoint;
- (void)timelineEditor:(id)timelineEditor draggingHandle:(int64_t)timestamp isInPoint:(bool)isInPoint;
- (void)volumeTimelineEditorZoomIn;
- (void)volumeTimelineEditorZoomOut;

@end

@interface NvVolumeSequenceView : UIView

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

-(void)setBtnHidden;

- (CGFloat)getTimelineEditorWidth;
@end
