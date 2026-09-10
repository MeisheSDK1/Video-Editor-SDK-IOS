//
//  NvVolumeKeyFrameInfo.h
//  SDKDemo
//
//  Created by ms on 2021/8/4.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvCaptionCurveItem.h"
#import "NvsControlPointPair.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvVolumeKeyFrameInfo : NSObject
///关键帧相对时间线/特效的时间点
///The point in time when the keyframe is relative to the timeline/effect
@property (nonatomic, assign) int64_t pos;
@property (nonatomic, assign) CGFloat leftGainValue;
@property (nonatomic, assign) CGFloat rightGainValue;
@property (nonatomic, assign) CurveAnimationType type;
@property (nonatomic, assign) CGPoint leftPoint;
@property (nonatomic, assign) CGPoint rightPoint;
@property (nonatomic, strong) NvsControlPointPair *leftGainPair;
@property (nonatomic, strong) NvsControlPointPair *rightGainPair;
@end

NS_ASSUME_NONNULL_END
