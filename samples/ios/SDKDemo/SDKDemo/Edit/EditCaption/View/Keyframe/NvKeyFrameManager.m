//
//  NvKeyFrameManager.m
//  SDKDemo
//
//  Created by chengww on 2020/8/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvKeyFrameManager.h"
#import "NvsTimelineCaption.h"

@implementation NvKeyFrameManager

+ (BOOL)isExistKeyFrame:(NSArray<NSString *> *)keys
        timelineVideoFx:(NvsFx *)fx
{
    __block BOOL flags = NO;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int64_t nextPos = [fx findKeyframeTime:obj time:-1 flags:NvsKeyFrameFindModeFlag_After];
        if (nextPos != -1) {
            flags = YES;
            *stop = YES;
        }
    }];
    return flags;
}

+ (NvKeyframeInfo *)isExistKeyFrame:(NSMutableArray<NvKeyframeInfo *> *)keyframes
                        timelinePos:(int64_t)timePos
{
    __block NvKeyframeInfo *keyModel = nil;
    [keyframes enumerateObjectsUsingBlock:^(NvKeyframeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (llabs(obj.time - timePos) < 100000) {
            keyModel = obj;
            *stop = YES;
        }
    }];
    return keyModel;
}

+ (BOOL)isExistPreKeyFrame:(int64_t)pos
                 frameKeys:(NSArray<NSString *> *)keys
           timelineVideoFx:(NvsFx *)fx
{
    __block BOOL flags = NO;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int64_t prePos = [fx findKeyframeTime:obj time:pos flags:NvsKeyFrameFindModeFlag_Before];
        if (prePos != -1) {
            flags = YES;
            *stop = YES;
        }
    }];
    return flags;
}

+ (BOOL)isExistNextKeyFrame:(int64_t)pos
                  frameKeys:(NSArray<NSString *> *)keys
            timelineVideoFx:(NvsFx *)fx
{
    __block BOOL flags = NO;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int64_t nextPos = [fx findKeyframeTime:obj time:pos flags:NvsKeyFrameFindModeFlag_After];
        if (nextPos != -1) {
            flags = YES;
            *stop = YES;
        }
    }];
    return flags;
}

+ (void)fetchKeyframeStatus:(int64_t)timePos
                    inPoint:(int64_t)inPoint
                  frameKeys:(NSArray<NSString *> *)keys
             keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
            timelineVideoFx:(NvsFx *)fx
            completeHandler:(void(^)(BOOL previous, BOOL next, NvKeyframeInfo *_Nullable keyModel, int index))handler
{
    __block NvKeyframeInfo *cur = nil;
    __block int64_t realPos = 0;
    __block int index = 0;
    [source enumerateObjectsUsingBlock:^(NvKeyframeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (llabs(obj.time - timePos) < 100000) {
            cur = obj;
            index = (int)idx;
            realPos = obj.pos;
            *stop = YES;
        }
    }];
    __block BOOL pre = NO;
    __block BOOL nex = NO;
    realPos = realPos == 0 ? (timePos - inPoint) : realPos;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!pre) {
            int64_t prePos = [fx findKeyframeTime:obj time:realPos flags:NvsKeyFrameFindModeFlag_Before];
            if (prePos != -1) { pre = YES; }
        }
        if (!nex) {
            int64_t nextPos = [fx findKeyframeTime:obj time:realPos flags:NvsKeyFrameFindModeFlag_After];
            if (nextPos != -1) { nex = YES; }
        }
        if (pre && nex) { *stop = YES; }
    }];
    handler(pre, nex, cur, index);
}

+ (void)insertKeyframe:(int64_t)timePos
               inPoint:(int64_t)inPoint
        keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
       timelineVideoFx:(NvsFx *)fx
                fxType:(NvKeyframeType)type
       completeHandler:(void(^)(NvKeyframeInfo *keyModel, int index))handler
{
    if (source == nil) {
        source = @[].mutableCopy;
    }
    /// 设置关键帧模型
    /// Set the keyframe model
    NvKeyframeInfo *keyModel = [[NvKeyframeInfo alloc] init];
    keyModel.time = timePos;
    keyModel.pos  = timePos - inPoint;
    [source addObject:keyModel];
    int index = (int)[source indexOfObject:keyModel];
    /// 设置关键帧
    /// Set key frame
    if (type == NvKeyframe_Caption) {
        NvsTimelineCaption *captionFx = (NvsTimelineCaption *)fx;
        [captionFx setCurrentKeyFrameTime:keyModel.pos];
    }
    /// 保存数据在block回调处理
    /// Save data in block callback processing
    handler(keyModel, index);
}

+ (void)removeKeyFrame:(NvKeyframeInfo *)key
         withIsForward:(BOOL)isForward
       timelineVideoFx:(NvsFx *)fx
{
    if (!fx || !key) {
        return;
    }
    NvsTimelineCaption *captionFx = (NvsTimelineCaption *)fx;
    
    [captionFx setCurrentKeyFrameTime:key.pos];
    key.translationPairX = [captionFx getControlPoint:@"Caption TransX"];
    key.translationPairY = [captionFx getControlPoint:@"Caption TransY"];
    key.opacityPairY = [captionFx getControlPoint:@"Track Opacity"];
    if (isForward) {
        key.leftPoint = CGPointMake(0.25, 0.25);
        key.rightPoint = CGPointMake(0.75, 0.75);
        key.type = CurveAnimationType1;
    }
    [captionFx setCurrentKeyFrameTime:-1];
}

+ (void)removeKeyFrame:(NSArray<NSString *> *)keys
        keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
        keyframeTarget:(NvKeyframeInfo *)target
       timelineVideoFx:(NvsFx *)fx
       completeHandler:(void(^)(void))handler
{
    if (source.count && target) {
        [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [fx removeKeyframeAtTime:obj time:target.pos];
        }];
        [source removeObject:target];
    }
    handler();
}

+ (void)getPreKeyFrame:(NSArray<NSString *> *)keys
           timelinePos:(int64_t)pos
               inPoint:(int64_t)inPoint
        keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
       timelineVideoFx:(NvsFx *)fx
       completeHandler:(void(^)(NvKeyframeInfo *keyModel, int index,  BOOL previous))handler
{
    int64_t timePos = pos - inPoint;
    /// 查找上一帧的位置
    /// Finds the position of the previous frame
    __block int64_t prePos = 0;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        prePos = [fx findKeyframeTime:obj time:timePos flags:NvsKeyFrameFindModeFlag_Before];
        if (prePos != -1) {
            *stop = YES;
        }
    }];
    __block NvKeyframeInfo *keyModel = nil;
    __block int keyIndex = 0;
    [source enumerateObjectsUsingBlock:^(NvKeyframeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pos == prePos) {
            keyModel = obj;
            keyIndex = (int)idx;
            *stop = YES;
        }
    }];
    /// 查找是否还有上一帧
    /// Find if there is a previous frame
    __block BOOL flags = NO;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int64_t pp = [fx findKeyframeTime:obj time:prePos flags:NvsKeyFrameFindModeFlag_Before];
        if (pp != -1) {
            flags = YES;
            *stop = YES;
        }
    }];
    handler(keyModel, keyIndex, flags);
}

+ (void)getNextKeyFrame:(NSArray<NSString *> *)keys
            timelinePos:(int64_t)pos
                inPoint:(int64_t)inPoint
         keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
        timelineVideoFx:(NvsFx *)fx
        completeHandler:(void(^)(NvKeyframeInfo *keyModel, int index,  BOOL next))handler
{
    
    int64_t timePos = pos - inPoint;
    /// 查找下一帧的位置
    /// Find the location of the next frame
    __block int64_t nextPos = 0;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        nextPos = [fx findKeyframeTime:obj time:timePos flags:NvsKeyFrameFindModeFlag_After];
        if (nextPos != -1) {
            *stop = YES;
        }
    }];
    __block NvKeyframeInfo *keyModel = nil;
    __block int keyIndex = 0;
    [source enumerateObjectsUsingBlock:^(NvKeyframeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.pos == nextPos) {
            keyModel = obj;
            keyIndex = (int)idx;
            *stop = YES;
        }
    }];
    /// 查找是否还有下一帧
    /// Find out if there is another frame
    __block BOOL flags = NO;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        int64_t np = [fx findKeyframeTime:obj time:nextPos flags:NvsKeyFrameFindModeFlag_After];
        if (np != -1) {
            flags = YES;
            *stop = YES;
        }
    }];
    handler(keyModel, keyIndex, flags);
}

+ (void)resetKeyFrame:(NSArray<NSString *> *)keys
       keyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
               fxType:(NvKeyframeType)type
      timelineVideoFx:(NvsFx *)fx
{
    /// 设置关键帧
    /// Set key frame
    if (type == NvKeyframe_Caption) {
        NvsTimelineCaption *captionFx = (NvsTimelineCaption *)fx;
        [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [captionFx removeAllKeyframe:obj];
        }];
        /// 再添加关键帧
        /// Add a keyframe
        [source enumerateObjectsUsingBlock:^(NvKeyframeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [captionFx setCurrentKeyFrameTime:obj.pos];
            [captionFx setScaleX:obj.scale];
            [captionFx setScaleY:obj.scale];
            [captionFx setRotationZ:obj.rotation];
            [captionFx setCaptionTranslation:obj.translation];
            [captionFx setOpacity:obj.opacity];
        }];
    }
}

+ (void)resetControlPointkeyframeSource:(NSMutableArray<NvKeyframeInfo *> *)source
               fxType:(NvKeyframeType)type
      timelineVideoFx:(NvsFx *)fx
{
    if (!fx) {
        return;
    }
    /// 设置关键帧控制点对
    /// Sets key frame control point pairs
    if (type == NvKeyframe_CaptionControlPoint) {
        NvsTimelineCaption *captionFx = (NvsTimelineCaption *)fx;
        /// 再添加关键帧点对
        /// Add a keyframe point pair
        [source enumerateObjectsUsingBlock:^(NvKeyframeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [captionFx setCurrentKeyFrameTime:obj.pos];
            if (obj.translationPairX) {
                [captionFx setControlPoint:@"Caption TransX" controlPointPair:obj.translationPairX];
            }
            if (obj.translationPairY) {
                [captionFx setControlPoint:@"Caption TransY" controlPointPair:obj.translationPairY];
            }
            if (obj.opacity) {
                [captionFx setControlPoint:@"Track Opacity" controlPointPair:obj.opacityPairY];
            }
        }];
    }
}

+ (void)insertKeyframeControlPoint:(NvKeyframeInfo *)leftKeyframe
                     RightKeyframe:(NvKeyframeInfo *)rightKeyframe
                         LeftPoint:(CGPoint)leftPoint
                        RightPoint:(CGPoint)rightPoint
                   timelineVideoFx:(NvsFx *)fx
              captionAttributeType:(NvCaptionAttributeType)attributeType

{
    if (!leftKeyframe || !rightKeyframe || !fx) {
        return;
    }
    
    NvsTimelineCaption *captionFx = (NvsTimelineCaption *)fx;
    
    int64_t timeStamp1 = leftKeyframe.pos;
    int64_t timeStamp2 = rightKeyframe.pos;
    
    CGFloat temp_1 = 0;
    CGFloat temp_2 = 0;
    
    NSArray *array = @[];
    CGPoint point = CGPointZero;
    CGPoint point_1 = CGPointZero;

    switch (attributeType) {
        case NvCaptionAttribute_Trans:
            array = @[@"Caption TransX",@"Caption TransY"];
            
            point = leftKeyframe.translation;
            point_1 = rightKeyframe.translation;
            break;
        case NvCaptionAttribute_Sacle:
            array = @[@"Caption SacleX",@"Caption ScaleY"];
            
            point = CGPointMake(leftKeyframe.scale, leftKeyframe.scale);
            point_1 = CGPointMake(rightKeyframe.scale, rightKeyframe.scale);
            break;
        case NvCaptionAttribute_RotZ:
            array = @[@"Caption RotZ"];
            
            point = CGPointMake(leftKeyframe.rotation, leftKeyframe.rotation);
            point_1 = CGPointMake(rightKeyframe.rotation, rightKeyframe.rotation);
            break;
        case NvCaptionAttribute_Opacity:
            array = @[@"Track Opacity"];
            
            point = CGPointMake(leftKeyframe.opacity, leftKeyframe.opacity);
            point_1 = CGPointMake(rightKeyframe.opacity, rightKeyframe.opacity);
            break;
        default:
            break;
    }
    
    for (int i = 0; i < array.count; i++) {
        if (i == 0) {
            temp_1 = point_1.x - point.x;
            temp_2 = point.x;
        }else if(i == 1){
            temp_1 = point_1.y - point.y;
            temp_2 = point.y;
        }
        CGPoint tempPoint = [self mapCanonicalToView:leftPoint ViewSize:CGSizeMake(timeStamp2 - timeStamp1, temp_1)];
        CGPoint viewPointLeft = CGPointMake(tempPoint.x+timeStamp1, tempPoint.y+temp_2);
        
        CGPoint tempPoint_1 = [self mapCanonicalToView:rightPoint ViewSize:CGSizeMake(timeStamp2 - timeStamp1, temp_1)];
        CGPoint viewPointRight = CGPointMake(tempPoint_1.x+timeStamp1, tempPoint_1.y+temp_2);
        
        [captionFx setCurrentKeyFrameTime:leftKeyframe.pos];
        NvsControlPointPair *pairPreY = [captionFx getControlPoint:array[i]];
        if (pairPreY) {
            NvsPointD point1 = {viewPointLeft.x , viewPointLeft.y};
            pairPreY.forwardControlPoint = point1;
            [captionFx setControlPoint:array[i] controlPointPair:pairPreY];
        }
        
        [captionFx setCurrentKeyFrameTime:rightKeyframe.pos];
        NvsControlPointPair *pairPreY1 = [captionFx getControlPoint:array[i]];
        if (pairPreY1) {
            NvsPointD point2 = {viewPointRight.x , viewPointRight.y};
            pairPreY1.backwardControlPoint = point2;
            [captionFx setControlPoint:array[i] controlPointPair:pairPreY1];
        }
    }
    
    switch (attributeType) {
        case NvCaptionAttribute_Trans:
            [captionFx setCurrentKeyFrameTime:leftKeyframe.pos];
            leftKeyframe.translationPairX = [captionFx getControlPoint:@"Caption TransX"];
            leftKeyframe.translationPairY = [captionFx getControlPoint:@"Caption TransY"];
            [captionFx setCurrentKeyFrameTime:rightKeyframe.pos];
            rightKeyframe.translationPairX = [captionFx getControlPoint:@"Caption TransX"];
            rightKeyframe.translationPairY = [captionFx getControlPoint:@"Caption TransY"];
            break;
        case NvCaptionAttribute_Sacle:
            [captionFx setCurrentKeyFrameTime:leftKeyframe.pos];
            leftKeyframe.scalePairX = [captionFx getControlPoint:@"Caption SacleX"];
            leftKeyframe.scalePairY = [captionFx getControlPoint:@"Caption ScaleY"];
            [captionFx setCurrentKeyFrameTime:rightKeyframe.pos];
            rightKeyframe.scalePairX = [captionFx getControlPoint:@"Caption SacleX"];
            rightKeyframe.scalePairY = [captionFx getControlPoint:@"Caption ScaleY"];
            break;
        case NvCaptionAttribute_RotZ:
            [captionFx setCurrentKeyFrameTime:leftKeyframe.pos];
            leftKeyframe.rotationPair = [captionFx getControlPoint:@"Caption RotZ"];
            [captionFx setCurrentKeyFrameTime:rightKeyframe.pos];
            rightKeyframe.rotationPair = [captionFx getControlPoint:@"Caption RotZ"];
            break;
        case NvCaptionAttribute_Opacity:
            [captionFx setCurrentKeyFrameTime:leftKeyframe.pos];
            leftKeyframe.opacityPairY = [captionFx getControlPoint:@"Track Opacity"];
            [captionFx setCurrentKeyFrameTime:rightKeyframe.pos];
            rightKeyframe.opacityPairY = [captionFx getControlPoint:@"Track Opacity"];
            break;
        default:
            break;
    }
    [captionFx setCurrentKeyFrameTime:-1];
}

///归一化坐标转视图坐标
///Normalized coordinates are converted to view coordinates
+(CGPoint)mapCanonicalToView:(CGPoint)canoPoint ViewSize:(CGSize)size{
    if (size.width == 0 || size.height == 0) {
        return CGPointMake(0, 0);
    }
    return CGPointMake(canoPoint.x * size.width, canoPoint.y * size.height);
}

@end
