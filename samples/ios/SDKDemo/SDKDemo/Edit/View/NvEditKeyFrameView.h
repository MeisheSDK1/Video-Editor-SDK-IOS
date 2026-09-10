//
//  NvEditKeyFrameView.h
//  SDKDemo
//
//  Created by MS on 2020/6/5.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"
#import "NvsCTimelineEditor.h"
#import "NvTimelineDataModel.h"
@class NvEditKeyFrameView;

NS_ASSUME_NONNULL_BEGIN
@protocol NvEditKeyFrameViewDelegate <NSObject>

///点击结束按钮
///Click the end button
- (void)nvEditKeyFrameViewFinishButtonClicked:(NvEditKeyFrameView *)keyFrameView ;

///滑动条拖动方法
///Slider drag method
- (void)nvEditKeyFrameViewSliderChanged:(NvEditKeyFrameView *)keyFrameView val:(CGFloat)value time:(int64_t)time ;

///点击上一帧按钮
///Click the previous frame button
- (void)nvEditKeyFrameViewPreButtonClicked:(NvEditKeyFrameView *)keyFrameView ;

///点击上一帧按钮
///Click the previous frame button
- (void)nvEditKeyFrameViewNextButtonClicked:(NvEditKeyFrameView *)keyFrameView ;

///点击添加关键帧按钮
///Click the Add Keyframe button
- (void)nvEditKeyFrameViewAddKeyFrame:(NvEditKeyFrameView *)keyFrameView val:(CGFloat)value time:(int64_t)time ;

///点击删除关键帧按钮
///Click the Delete Keyframe button
- (void)nvEditKeyFrameViewDeleteKeyFrame:(NvEditKeyFrameView *)keyFrameView time:(int64_t)time ;

///拖动时间线
///Drag timeline
- (void)nvEditKeyFrameViewDragTimeline:(NvEditKeyFrameView *)keyFrameView time:(int64_t)time;

///拖动时间线
///Drag timeline
- (void)nvEditKeyFrameViewDragTimelineEnded:(NvEditKeyFrameView *)keyFrameView time:(int64_t)time;
@end

@interface NvEditKeyFrameView : UIView
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, strong) UIImageView *btnImageView;
///缩略图界面
///Thumbnail interface
@property (nonatomic, strong) NvsCTimelineEditor *timelineEditor;
@property (nonatomic, assign) id <NvEditKeyFrameViewDelegate>delegate;
///时码线是否在关键帧上
///Whether the time code line is on the keyframe
@property (nonatomic, assign) BOOL atKeyFrameTime;
///是否播放状态（播放/停止）
///Play status or not (Play/stop)
@property (nonatomic, assign) BOOL assetStatus;
///关键帧信息
///Keyframe information
@property (nonatomic, strong) NSMutableArray <NvKeyFrameFilterModel *>*keyFrameArr;

- (void)setTrimIn:(int64_t)trimIn trimOut:(int64_t)trimOut;

///设置关键帧按钮状态
///Set the keyframe button state
- (void)setKeyFrameStatus:(int64_t)time hasKeyFrame:(BOOL)hasKeyFrame hasPreKeyFrame:(BOOL)hasPreKeyFrame hasNextKeyFrame:(BOOL)hasNextKeyFrame ;

///更新滤镜slider value值
///Update the filter slider value
- (void)updateFilterSliderStrength:(double)value;
@end

NS_ASSUME_NONNULL_END
