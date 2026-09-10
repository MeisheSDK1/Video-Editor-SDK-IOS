//
//  NvBezierSpeedView.h
//  SDKDemo
//
//  Created by MS on 2020/11/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvBezierSpeedModel.h"
NS_ASSUME_NONNULL_BEGIN
@class NvBezierSpeedView;

@protocol NvBezierSpeedViewDelegate <NSObject>

/// 移动时码线
/// Move time code line
/// 通过移动时码线获取当前位置的速度
/// Get the speed of the current position by moving the code line
///
/// @param speedView 贝塞尔曲线视图
/// Bezier curve view
/// @param nextIndex 时码线位置处的变速信息
/// Variable speed information at the time code line position
/// @param speed 时码线位置处的变速信息
/// Variable speed information at the time code line position
/// @param isTouchPoint 时码线位置处的变速信息
/// Variable speed information at the time code line position
- (void)nvBezierSpeedView:(NvBezierSpeedView *)speedView timelineDidChangedNextIndex:(NSInteger)nextIndex speed:(CGPoint)speed isTouchPoint:(BOOL)isTouchPoint;


/// 移动贝塞尔曲线上的特征点
/// Move the feature points on the Bezier curve
/// 通过移动曲线上的点获取当前位置的速度
/// Get the speed of the current position by moving a point on the curve
/// Note: 垂直移动曲线上的点会回调此函数
/// Moving points on the curve vertically calls back this function
/// @param speedView 贝塞尔曲线视图
/// Bezier curve view
/// @param currentIndex 移动后点的变速信息
/// Variable speed information after moving point
/// @param speed 移动后点的变速信息
/// Variable speed information after moving point

- (void)nvBezierSpeedView:(NvBezierSpeedView *)speedView timelineDidChangedCurrentIndex:(NSInteger)currentIndex speed:(CGPoint)speed;

@end


@interface NvBezierSpeedView : UIView

@property (nonatomic, weak) id<NvBezierSpeedViewDelegate> delegate;
///传入曲线坐标
///Incoming curvilinear coordinates
@property (nonatomic, strong) NvCurveInfo *originSpeed;
@property (nonatomic, assign) NSInteger pointIndex;

- (instancetype)initWithFrame:(CGRect)frame edgeInsets:(UIEdgeInsets)edgeInsets;

- (void)insertPoint:(CGPoint)point index:(NSInteger)index;

- (void)deletePoint:(NSInteger)index;

- (NSMutableArray *)fetchBezierPoint;

- (void)resetPointSelectState;

- (void)positionAnimation:(CGFloat)chartX;

- (void)positionAnimation:(CGFloat)chartX isPlaying:(BOOL)isPlaying;
@end

NS_ASSUME_NONNULL_END
