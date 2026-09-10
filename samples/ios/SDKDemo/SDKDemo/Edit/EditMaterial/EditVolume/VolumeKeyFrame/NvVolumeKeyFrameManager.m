//
//  NvVolumeKeyFrameManager.m
//  SDKDemo
//
//  Created by ms on 2021/8/4.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvVolumeKeyFrameManager.h"
#import "NvsAudioFx.h"
#import "NvsControlPointPair.h"

@implementation NvVolumeKeyFrameManager

+ (BOOL)isExistKeyFrame:(NSArray<NSString *> *)keys
             audioFx:(NvsFx *)fx
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

+ (NvVolumeKeyFrameInfo *)isExistKeyFrame:(NSMutableArray<NvVolumeKeyFrameInfo *> *)keyframes
                        timelinePos:(int64_t)timePos
{
    __block NvVolumeKeyFrameInfo *keyModel = nil;
    [keyframes enumerateObjectsUsingBlock:^(NvVolumeKeyFrameInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (llabs(obj.pos - timePos) < 100000) {
            keyModel = obj;
            *stop = YES;
        }
    }];
    return keyModel;
}

+ (BOOL)isExistPreKeyFrame:(int64_t)pos
                 frameKeys:(NSArray<NSString *> *)keys
                   audioFx:(NvsFx *)fx
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
                    audioFx:(NvsFx *)fx
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
                  frameKeys:(NSArray<NSString *> *)keys
             keyframeSource:(NSMutableArray<NvVolumeKeyFrameInfo *> *)source
                    audioFx:(NvsFx *)fx
            completeHandler:(void(^)(BOOL previous, BOOL next, NvVolumeKeyFrameInfo *_Nullable keyModel, int index))handler
{
    __block NvVolumeKeyFrameInfo *cur = nil;
    __block int64_t realPos = 0;
    __block int index = 0;
    [source enumerateObjectsUsingBlock:^(NvVolumeKeyFrameInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (llabs(obj.pos - timePos) < 100000) {
            cur = obj;
            index = (int)idx;
            realPos = obj.pos;
            *stop = YES;
        }
    }];
    __block BOOL pre = NO;
    __block BOOL nex = NO;
    realPos = realPos == 0 ? timePos : realPos;
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
        keyframeSource:(NSMutableArray<NvVolumeKeyFrameInfo *> *)source
               audioFx:(NvsFx *)fx
                fxType:(NvKeyframeType)type
       completeHandler:(void(^)(NvVolumeKeyFrameInfo *keyModel, int index))handler
{
    if (source == nil) {
        source = @[].mutableCopy;
    }
    /// 设置关键帧模型
    /// Set the keyframe model
    NvVolumeKeyFrameInfo *keyModel = [[NvVolumeKeyFrameInfo alloc] init];
    keyModel.pos = timePos;
    [source addObject:keyModel];
    int index = (int)[source indexOfObject:keyModel];
    /// 设置关键帧
    /// Set key frame
    /// 保存数据在block回调处理
    /// Save data in block callback processing
    handler(keyModel, index);
}
+ (void)removeKeyFrame:(NvVolumeKeyFrameInfo *)key
         withIsForward:(BOOL)isForward
               audioFx:(NvsFx *)fx
{
    if (!fx || !key) {
        return;
    }
}

+ (void)removeKeyFrame:(NSArray<NSString *> *)keys
        keyframeSource:(NSMutableArray<NvVolumeKeyFrameInfo *> *)source
        keyframeTarget:(NvVolumeKeyFrameInfo *)target
               audioFx:(NvsFx *)fx
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
        keyframeSource:(NSMutableArray<NvVolumeKeyFrameInfo *> *)source
               audioFx:(NvsFx *)fx
       completeHandler:(void(^)(NvVolumeKeyFrameInfo *keyModel, int index,  BOOL previous))handler
{
    /// 查找上一帧的位置
    /// Finds the position of the previous frame
    __block int64_t prePos = 0;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        prePos = [fx findKeyframeTime:obj time:pos flags:NvsKeyFrameFindModeFlag_Before];
        if (prePos != -1) {
            *stop = YES;
        }
    }];
    __block NvVolumeKeyFrameInfo *keyModel = nil;
    __block int keyIndex = 0;
    [source enumerateObjectsUsingBlock:^(NvVolumeKeyFrameInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
         keyframeSource:(NSMutableArray<NvVolumeKeyFrameInfo *> *)source
                audioFx:(NvsFx *)fx
        completeHandler:(void(^)(NvVolumeKeyFrameInfo *keyModel, int index,  BOOL next))handler
{
    
    /// 查找下一帧的位置
    /// Find the location of the next frame
    __block int64_t nextPos = 0;
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        nextPos = [fx findKeyframeTime:obj time:pos flags:NvsKeyFrameFindModeFlag_After];
        if (nextPos != -1) {
            *stop = YES;
        }
    }];
    __block NvVolumeKeyFrameInfo *keyModel = nil;
    __block int keyIndex = 0;
    [source enumerateObjectsUsingBlock:^(NvVolumeKeyFrameInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
       keyframeSource:(NSMutableArray<NvVolumeKeyFrameInfo *> *)source
               fxType:(NvKeyframeType)type
              audioFx:(NvsFx *)fx
{
    
}

+ (void)resetControlPointkeyframeSource:(NSMutableArray<NvVolumeKeyFrameInfo *> *)source
               fxType:(NvKeyframeType)type
                                audioFx:(NvsFx *)fx
{
    if (!fx) {
        return;
    }
}

+ (void)insertKeyframeControlPoint:(NvVolumeKeyFrameInfo *)leftKeyframe
                     RightKeyframe:(NvVolumeKeyFrameInfo *)rightKeyframe
                         LeftPoint:(CGPoint)leftPoint
                        RightPoint:(CGPoint)rightPoint
                           audioFx:(NvsFx *)fx

{
    if (!leftKeyframe || !rightKeyframe || !fx) {
        return;
    }
    
    NvsAudioFx *audioFx = (NvsAudioFx *)fx;
    
    int64_t timeStamp1 = leftKeyframe.pos;
    int64_t timeStamp2 = rightKeyframe.pos;
    
    CGFloat temp_1 = 0;
    CGFloat temp_2 = 0;
    
    NSArray *strS = @[@"Left Gain", @"Right Gain"];
        
    [audioFx removeKeyframeAtTime:@"Left Gain" time:timeStamp1];
    [audioFx removeKeyframeAtTime:@"Right Gain" time:timeStamp1];

    
    for (int i = 0; i < strS.count; i++) {
        if (i == 0) {
            temp_1 = rightKeyframe.leftGainValue - leftKeyframe.leftGainValue;
            temp_2 = leftKeyframe.leftGainValue;
        }else if(i == 1){
            temp_1 = rightKeyframe.rightGainValue - leftKeyframe.rightGainValue;
            temp_2 = leftKeyframe.rightGainValue;
        }
        CGPoint tempPoint = [self mapCanonicalToView:leftPoint ViewSize:CGSizeMake(timeStamp2 - timeStamp1, temp_1)];
        CGPoint viewPointLeft = CGPointMake(tempPoint.x+timeStamp1, tempPoint.y+temp_2);

        CGPoint tempPoint_1 = [self mapCanonicalToView:rightPoint ViewSize:CGSizeMake(timeStamp2 - timeStamp1, temp_1)];
        CGPoint viewPointRight = CGPointMake(tempPoint_1.x+timeStamp1, tempPoint_1.y+temp_2);

        
        if (i == 0) {
            [audioFx setFloatValAtTime:@"Left Gain" val:leftKeyframe.leftGainValue time:timeStamp1];
            NvsControlPointPair *pairPreL = [audioFx getKeyFrameControlPoint:@"Left Gain" time:timeStamp1];
            if (pairPreL) {
                NvsPointD point1 = {viewPointLeft.x , viewPointLeft.y};
                pairPreL.forwardControlPoint = point1;
                [audioFx setKeyFrameControlPoint:@"Left Gain" time:timeStamp1 controlPointPair:pairPreL];
            }

            [audioFx setFloatValAtTime:@"Left Gain" val:rightKeyframe.leftGainValue time:timeStamp2];
            NvsControlPointPair *pairPreR = [audioFx getKeyFrameControlPoint:@"Left Gain" time:timeStamp2];
            if (pairPreR) {
                NvsPointD point2 = {viewPointRight.x , viewPointRight.y};
                pairPreR.backwardControlPoint = point2;
                [audioFx setKeyFrameControlPoint:@"Left Gain" time:timeStamp2 controlPointPair:pairPreR];
            }
        }else if(i == 1){
            [audioFx setFloatValAtTime:@"Right Gain" val:leftKeyframe.rightGainValue time:timeStamp1];
            NvsControlPointPair *pairPreL = [audioFx getKeyFrameControlPoint:@"Right Gain" time:timeStamp1];
            if (pairPreL) {
                NvsPointD point1 = {viewPointLeft.x , viewPointLeft.y};
                pairPreL.forwardControlPoint = point1;
                [audioFx setKeyFrameControlPoint:@"Right Gain" time:timeStamp1 controlPointPair:pairPreL];
            }

            [audioFx setFloatValAtTime:@"Right Gain" val:rightKeyframe.rightGainValue time:timeStamp2];
            NvsControlPointPair *pairPreR = [audioFx getKeyFrameControlPoint:@"Right Gain" time:timeStamp2];
            if (pairPreR) {
                NvsPointD point2 = {viewPointRight.x , viewPointRight.y};
                pairPreR.backwardControlPoint = point2;
                [audioFx setKeyFrameControlPoint:@"Right Gain" time:timeStamp2 controlPointPair:pairPreR];
            }
        }
    }
    
    leftKeyframe.leftGainPair = [audioFx getKeyFrameControlPoint:@"Left Gain" time:timeStamp1];
    leftKeyframe.rightGainPair = [audioFx getKeyFrameControlPoint:@"Right Gain" time:timeStamp1];
    
    rightKeyframe.leftGainPair = [audioFx getKeyFrameControlPoint:@"Left Gain" time:timeStamp2];
    rightKeyframe.rightGainPair = [audioFx getKeyFrameControlPoint:@"Right Gain" time:timeStamp2];

    leftKeyframe.leftPoint = leftPoint;
    leftKeyframe.rightPoint = rightPoint;
}

+(CGPoint)mapCanonicalToView:(CGPoint)canoPoint ViewSize:(CGSize)size{
    if (size.width == 0 || size.height == 0) {
        return CGPointMake(0, 0);
    }
    return CGPointMake(canoPoint.x * size.width, canoPoint.y * size.height);
}

@end
