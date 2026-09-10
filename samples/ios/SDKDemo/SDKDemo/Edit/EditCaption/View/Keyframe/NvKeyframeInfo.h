//
//  NvKeyframeInfo.h
//  SDKDemo
//
//  Created by chengww on 2020/8/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvCaptionCurveItem.h"
#import "NvsControlPointPair.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvKeyframeInfo: NSObject<NSCopying>
///关键帧相对特效的时间点
///The point in time when the keyframe is relative to the effect
@property (nonatomic, assign) int64_t pos;
///关键帧相对时间线的时间点
///The point in time when the keyframe is relative to the timeline
@property (nonatomic, assign) int64_t time;
///锚点旋转角度
///Angle of rotation of anchor point
@property (nonatomic, assign) CGFloat rotation;
///缩放
///scale
@property (nonatomic, assign) CGFloat scale;
///平移
///translation
@property (nonatomic, assign) CGPoint translation;
///透明度
///transparency
@property (nonatomic, assign) CGFloat opacity;
///锚点
///Anchor point
@property (nonatomic, assign) CGPoint anchor;
///平移控制点对
///Translation control point pair
@property (nullable, nonatomic, strong) NvsControlPointPair *translationPairX;
///平移控制点对
///Translation control point pair
@property (nullable ,nonatomic, strong) NvsControlPointPair *translationPairY;
///透明控制点对
///Transparent control point pairs
@property (nullable ,nonatomic, strong) NvsControlPointPair *opacityPairY;
///缩放控制点对
///Scale control point pairs
@property (nonatomic, strong) NvsControlPointPair *scalePairX;
///缩放控制点对
///Scale control point pairs
@property (nonatomic, strong) NvsControlPointPair *scalePairY;
///旋转控制点对
///Rotate control point pairs
@property (nonatomic, strong) NvsControlPointPair *rotationPair;
@property (nonatomic, assign) CurveAnimationType type;
@property (nonatomic, assign) CGPoint leftPoint;
@property (nonatomic, assign) CGPoint rightPoint;
@end

NS_ASSUME_NONNULL_END

