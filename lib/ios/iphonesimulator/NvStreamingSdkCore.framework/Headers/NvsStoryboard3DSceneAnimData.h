//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    May 17. 2022
//   Author:        Meishe video team
//================================================================================

#pragma once
#import "NvsArbitraryData.h"

typedef enum {
    NvsAnimUnfoundBehavior_Default = 0,     // Render as default
    NvsAnimUnfoundBehavior_DontRender = 1   // Don't render anything at all
} NvsAnimUnfoundBehavior;

NVS_EXPORT @interface NvsAnimStateInfo : NSObject

@property(strong, nonatomic) NSString *layerId;
@property(strong, nonatomic) NSString *animName;// [default] means the first available animation stack
@property(assign, nonatomic) int64_t animStartTime; // In milliseconds
@property(assign, nonatomic) int64_t lastAnimStartTime;// 前一个动画的开始时间
@property(assign, nonatomic) int64_t lastAnimStopTime;// 前一个动画的停止时间
@property(strong, nonatomic) NSString *lastAnimName;//前一个动画的名称

@end

NVS_EXPORT @interface NvsStoryboard3DSceneAnimData : NvsArbitraryData

@property(strong, nonatomic) NSMutableArray <NvsAnimStateInfo *>*animStateInfos;
@property(assign, nonatomic) NvsAnimUnfoundBehavior animUnfoundBehavior;    // Behavior should be taken if any animation specified is not found.
@end
