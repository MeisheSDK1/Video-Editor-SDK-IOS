//
//  NvCurveSpeedView.h
//  SDKDemo
//
//  Created by MS on 2020/11/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsVideoClip.h"
#import "NvBezierSpeedModel.h"
@class NvCurveSpeedView;

NS_ASSUME_NONNULL_BEGIN
@protocol NvCurveSpeedViewDelegate <NSObject>
/// 结束编辑
/// End edit
/// - Parameter speedView: 曲线变速操作视图
/// Curve variable speed operation view
- (void)nvCurveSpeedViewDidEndEditing:(NvCurveSpeedView *)speedView;

/// liveWindow的播放状态
/// liveWindow Playback status
/// 曲线变速视图控制liveWindow的状态
/// The curve view controls the state of the liveWindow
/// - Parameter speedView: 曲线变速操作视图
/// Curve variable speed operation view
/// - Parameter status: liveWindow的播放状态
/// liveWindow Playback status
/// - Note: 控制播放的回调
/// A callback that controls playback
- (void)nvCurveSpeedView:(NvCurveSpeedView *)speedView playbackStatus:(BOOL)status;

/// 手势滑动时码线，修改timeline的位置
/// To modify the position of the timeline when gesturing along the code line
/// 曲线变速视图控制seek时码线的位置
/// The curve shift view controls the position of the code line when seeking
/// - Parameter speedView: 曲线变速操作视图
/// Curve variable speed operation view
/// - Parameter position: timeline的位置
/// The location of timeline
/// - Parameter isPlayBackFinished: 是否播放完成
/// Play complete or not
///
/// - Note: 控制tineline的位置
/// Control the tineline location
///
- (void)nvCurveSpeedView:(NvCurveSpeedView *)speedView timelineSeekTo:(int64_t)timestamp playbackEOF:(BOOL)playbackEOF;

/// 曲线变速的特征点
/// Characteristic points of curve change
/// 曲线变速点发生改变时，回调此函数
/// This function is called back when the curve shift point changes
/// - Parameter clipData: 曲线变速操作的clip数据模型
/// clip data model for curvilinear variable speed operation
/// - Parameter points: 曲线变速的点
/// The point where the curve changes speed
/// - Note: 贝塞尔曲线的点
/// The point of the Bezier curve
- (void)nvCurveSpeedView:(NvCurveSpeedView *)speedView clip:(NvsVideoClip *)clip inPoint:(int64_t)inPoint outPoint:(int64_t)outPoint speedChangedPoints:(NSMutableArray *)points;
@end

@interface NvCurveSpeedView : UIView

- (instancetype)initWithFrame:(CGRect)frame curveName:(NSString *)curveName clip:(NvsVideoClip *)clip inPoint:(int64_t)inPoint outPoint:(int64_t)outPoint;

@property (nonatomic, weak) id<NvCurveSpeedViewDelegate> delegate;
///引擎状态是否正在播放
///Whether the engine status is playing
@property (nonatomic, assign) BOOL isPlayback;
@property (nonatomic, strong) NvCurveInfo *curveInfo;
@property (nonatomic, strong) NSString *curveId;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;

- (BOOL)updataTimeline:(int64_t)timestamp state:(BOOL)state;
/// 播放状态重置曲线点的选中状态
/// Playback Status Resets the selected status of a curve point
- (void)resetCurvePoints;
@end

NS_ASSUME_NONNULL_END
