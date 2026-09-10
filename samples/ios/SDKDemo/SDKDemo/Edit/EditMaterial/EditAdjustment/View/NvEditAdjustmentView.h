//
//  NvEditAdjustmentView.h
//  SDKDemo
//
//  Created by MS on 2020/12/2.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"
#import "SDKDemo-Swift.h"
@class NvEditAdjustmentView;

NS_ASSUME_NONNULL_BEGIN
@interface NvEditAdjustmentModel : NSObject
///素材自身宽高比
///Aspect ratio of the material itself
@property (nonatomic, assign) double assetRatio;
@property (nonatomic, assign) double targetRatio;
@property (nonatomic, assign) double timelineRatio;
@property (nonatomic, assign) double angle;
@end

@protocol NvEditAdjustmentViewDelegate <NSObject>


/// 选中底部选项
/// Check the bottom option
/// @param view self
/// @param index 索引值
- (void)nvEditAdjustmentView:(NvEditAdjustmentView *)view selectIndex:(NSInteger)index;


/// 滑杆滑动值
/// Slide value of slide bar
/// @param view self
/// @param rotation 滑动值
/// Slip value
- (void)nvEditAdjustmentView:(NvEditAdjustmentView *)view rotate:(double)rotation;

/// 退出调整页面
/// Exit adjustment page
/// @param view self
- (void)nvEditAdjustmentViewFinished:(NvEditAdjustmentView *)view cropperModel:(NvCropperModel *)cropperModel;

@end

@interface NvEditAdjustmentView : UIView

@property (nonatomic, weak) id<NvEditAdjustmentViewDelegate> delegate;
@property (nonatomic, strong) NvCropperScrollView *liveWindowPanel;

/// 编辑界面livewindow
/// Edit interface livewindow
@property (nonatomic, strong) NvsLiveWindow *timelineLivewindow;

/// 编辑界面timeline VideoRes
/// Edit the timeline VideoRes interface
@property (nonatomic, assign) NvsVideoResolution timelineVideoRes;

@property (nonatomic, strong) NvSourceInfo *sourceInfo;
- (instancetype)initWithModel:(NvEditAdjustmentModel *)model;

- (void)connectTimeline:(NvsTimeline *)timeline;

- (void)playTimelineAtTime:(int64_t)timeStamp;

- (void)setSliderValue:(CGFloat)value;

- (void)selectAspectRatio:(NvVideoEditAspectRatioMode)ratioMode;

- (NvVideoEditAspectRatioMode)getAspectRatioMode;
@end

NS_ASSUME_NONNULL_END
