//
//  NvKeyFrameManager.h
//  SDKDemo
//
//  Created by chengww on 2020/8/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvKeyframeInfo.h"
@class NvsFx;
NS_ASSUME_NONNULL_BEGIN

typedef enum {
    NvKeyframe_Caption,
    NvKeyframe_CaptionControlPoint,
}NvKeyframeType;

typedef enum {
    NvCaptionAttribute_Trans,
    NvCaptionAttribute_Sacle,
    NvCaptionAttribute_RotZ,
    NvCaptionAttribute_Opacity,
}NvCaptionAttributeType;

@interface NvKeyFrameManager : NSObject
/**
 * @brief 特效区域查找是否含有关键帧
 * The effects area looks for keyframes
 * @param keys 设置关键帧的keys
 * Set the keys of the keyframe
 * @param fx 特效
 * Special effect
 */
+ (BOOL)isExistKeyFrame:(NSArray<NSString *> *)keys
        timelineVideoFx:(NvsFx *)fx;
/**
 * @brief 指定时码线位置是否存在关键帧
 * Specifies whether key frames exist at the codeline position
 * @param keyframes 关键帧数据源
 * Keyframe data source
 * @param timePos 时码线位置
 * Time code line position
 */
+ (NvKeyframeInfo *)isExistKeyFrame:(NSMutableArray<NvKeyframeInfo *> *)keyframes
                        timelinePos:(int64_t)timePos;
/**
 * @brief 是否存在上一个关键帧
 * Whether a previous keyframe exists
 * @param pos 关键帧相对特效的时间点
 * The point in time when the keyframe is relative to the effect
 * @param keys 设置关键帧的keys
 * Set the keys of the keyframe
 * @param fx 特效
 * Special effect
 */
+ (BOOL)isExistPreKeyFrame:(int64_t)pos
                 frameKeys:(NSArray<NSString *> *)keys
           timelineVideoFx:(NvsFx *)fx;
/**
 * @brief 是否存在下一个关键帧
 * Whether the next keyframe exists
 * @param pos 关键帧相对特效的时间点
 * The point in time when the keyframe is relative to the effect
 * @param keys 设置关键帧的keys
 * Set the keys of the keyframe
 * @param fx 特效
 * Special effect
*/
+ (BOOL)isExistNextKeyFrame:(int64_t)pos
                  frameKeys:(NSArray<NSString *> *)keys
            timelineVideoFx:(NvsFx *)fx;
/**
 * @brief 查询关键帧的配置状态
 * Example Query the configuration status of key frames
 * @param timePos 时码线的位置
 * The position of the time code line
 * @param inPoint 特效的入点位置
 * The entry position of the effect
 * @param keys 设置关键帧的keys
 * Set the keys of the keyframe
 * @param source 关键帧数据源
 * Keyframe data source
 * @param fx 特效
 * Special effect
 * @param handler 添加结果回调：previous：是否存在上一帧 next：是否存在下一帧 keyModel: 关键帧数据, index: 数据索引
 * Add result callback: previous: Whether the previous frame exists next: whether the next frame exists keyModel: key frame data, index: data index
 */
+ (void)fetchKeyframeStatus:(int64_t)timePos
                    inPoint:(int64_t)inPoint
                  frameKeys:(NSArray<NSString *> *)keys
             keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
            timelineVideoFx:(NvsFx *)fx
            completeHandler:(void(^)(BOOL previous, BOOL next, NvKeyframeInfo *_Nullable keyModel, int index))handler;

/**
 * @brief 添加一个关键帧
 * Add a keyframe
 * @param timePos 时码线的位置
 * The position of the time code line
 * @param inPoint 特效的入点位置
 * The entry position of the effect
 * @param source 关键帧数据源
 * Keyframe data source
 * @param fx 特效
 * Special effect
 * @param type 特效类型
 * Special effect type
 * @param handler 添加结果回调：keyModel: 关键帧数据, index: 数据索引
 * Add result callbacks: keyModel: keyframe data, index: data index
 */
+ (void)insertKeyframe:(int64_t)timePos
               inPoint:(int64_t)inPoint
        keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
       timelineVideoFx:(NvsFx *)fx
                fxType:(NvKeyframeType)type
       completeHandler:(void(^)(NvKeyframeInfo *keyModel, int index))handler;

/**
 * @brief 添加关键帧控制点对
 * Add a pair of keyframe control points
 * @param leftKeyframe 左侧的关键帧
 * The keyframe on the left
 * @param rightKeyframe 右侧的关键帧
 * Keyframe on the right
 * @param leftPoint 左侧的控制点
 * The control point on the left
 * @param rightPoint 右侧的控制点
 * The control point on the right
 * @param fx 特效
 * Special effect
 * @param attributeType 特效属性类型
 * Effect attribute type
 */
+ (void)insertKeyframeControlPoint:(NvKeyframeInfo *)leftKeyframe
                     RightKeyframe:(NvKeyframeInfo *)rightKeyframe
                         LeftPoint:(CGPoint)leftPoint
                        RightPoint:(CGPoint)rightPoint
                   timelineVideoFx:(NvsFx *)fx
              captionAttributeType:(NvCaptionAttributeType)attributeType;

/**
 * @brief 获取上一个关键帧
 * Gets the previous keyframe
 * @param keys 设置关键帧的keys
 * Set the keys of the keyframe
 * @param pos 时码线的位置
 * The position of the time code line
 * @param inPoint 特效的入点位置
 * The entry position of the effect
 * @param source 关键帧数据源
 * Keyframe data source
 * @param fx 特效
 * Special effect
 * @param handler 查询结果回调：keyModel: 关键帧数据, index: 数据索引,  previous: 是否存在上一帧
 * Query result callback: keyModel: keyframe data, index: data index, previous: indicates whether the previous frame exists
 */
+ (void)getPreKeyFrame:(NSArray<NSString *> *)keys
           timelinePos:(int64_t)pos
               inPoint:(int64_t)inPoint
        keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
       timelineVideoFx:(NvsFx *)fx
       completeHandler:(void(^)(NvKeyframeInfo *keyModel, int index,  BOOL previous))handler;
/**
 * @brief 获取下一个关键帧
 * Gets the next keyframe
 * @param keys 设置关键帧的keys
 * Set the keys of the keyframe
 * @param pos 时码线的位置
 * The position of the time code line
 * @param inPoint 特效的入点位置
 * The entry position of the effect
 * @param source 关键帧数据源
 * Keyframe data source
 * @param fx 特效
 * Special effect
 * @param handler 查询结果回调：keyModel: 关键帧数据, index: 数据索引,  next: 是否存在下一帧
 * Query result callback: keyModel: keyframe data, index: data index, next: whether the next frame exists
 */
+ (void)getNextKeyFrame:(NSArray<NSString *> *)keys
            timelinePos:(int64_t)pos
                inPoint:(int64_t)inPoint
         keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
        timelineVideoFx:(NvsFx *)fx
        completeHandler:(void(^)(NvKeyframeInfo *keyModel, int index,  BOOL next))handler;

/**
 * @brief 删除指定关键帧
 * Deletes the specified keyframe
 * @param keys 设置关键帧的keys
 * Set the keys of the keyframe
 * @param source 关键帧数据源
 * Keyframe data source
 * @param target 需要删除的关键帧
 * Key frame to delete
 * @param fx 特效
 * Special effect
 */
+ (void)removeKeyFrame:(NSArray<NSString *> *)keys
        keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
        keyframeTarget:(NvKeyframeInfo *)target
       timelineVideoFx:(NvsFx *)fx
       completeHandler:(void(^)(void))handler;

/**
 * @brief 删除指定关键帧控制点对
 * Deletes the specified keyframe control point pair
 * @param key 关键帧
 * Key frame
 * @param isForward 是否是前置控制点
 * Whether it is a leading control point
 * @param fx 特效
 * Special effect
 */
+ (void)removeKeyFrame:(NvKeyframeInfo *)key
         withIsForward:(BOOL)isForward
       timelineVideoFx:(NvsFx *)fx;

/**
 * @brief 重置关键帧
 * Reset keyframe
 * @param keys 设置关键帧的keys
 * Set the keys of the keyframe
 * @param source 关键帧数据源
 * Keyframe data source
 * @param type 特效类型
 * Special effect type
 * @param fx 特效
 * Special effect
 */
+ (void)resetKeyFrame:(NSArray<NSString *> *)keys
       keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
               fxType:(NvKeyframeType)type
      timelineVideoFx:(NvsFx *)fx;

/**
 * @brief 重置关键帧控制点对
 * Reset key frame control point pairs
 * @param source 关键帧数据源
 * Keyframe data source
 * @param type 特效类型
 * Special effect type
 * @param fx 特效
 * Special effect
 */
+ (void)resetControlPointkeyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
                                 fxType:(NvKeyframeType)type
                        timelineVideoFx:(NvsFx *)fx;
@end

NS_ASSUME_NONNULL_END
