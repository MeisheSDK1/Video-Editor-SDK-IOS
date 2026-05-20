//
//  NvTimelineParticleUtils.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTimelineParticleUtils.h"
#import "NvsStreamingContext.h"
#import "NvsAssetPackageParticleDescParser.h"
#import <NvSDKCommon/NvUtils.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvTimelineData.h"
#import "NvsTimelineVideoFx.h"
#import "NvTimelineUtils.h"
#import "NvsParticleSystemContext.h"

@implementation NvTimelineParticleUtils

+ (NSString *)startParticle:(NvsTimeline *)timeline particleInfo:(NvParticleInfoModel *)particleInfo {
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    if (![context.assetPackageManager isParticleFx:particleInfo.name])
        return nil;
    
    NSString *effectDesc = [context.assetPackageManager GetVideoFxAssetPackageDescription:particleInfo.name];
    NvsAssetPackageParticleDescParser *effectDescParser = [[NvsAssetPackageParticleDescParser alloc] initWithEffectDesc:effectDesc];
    if ([effectDescParser getParticleType] != NvsParticleType_Touch && [effectDescParser getParticleType] != NvsParticleType_Normal) {
        return nil;
    }
    
    NSArray *mCurrentEmitterList = [effectDescParser getParticlePartitionEmitter:0];
    particleInfo.emitterName = (NSMutableArray *)mCurrentEmitterList;
    NvsTimelineVideoFx *currentVideoFx = [timeline addPackagedTimelineVideoFx:particleInfo.inPoint
                                                  duration:[timeline duration] - particleInfo.inPoint
                                          videoFxPackageId:particleInfo.name];
    [currentVideoFx setFloatVal:@"Tail Fading Duration" val:.5];
    [[[NvTimelineData sharedInstance] particleDataArray] addObject:particleInfo];
    return particleInfo.uuid;
}

+ (void)updateParticle:(NvsTimeline *)timeline particleInfo:(NvParticleInfoModel *)particleInfo liveWindow:(NvsLiveWindow *)liveWindow point:(CGPoint)point {
    CGPoint nowPoint = [liveWindow mapViewToCanonical:point];
    
    NvsTimelineVideoFx *particle = [NvTimelineParticleUtils findParticleObject:timeline particleUUID:particleInfo.uuid];
    
    CGPoint particlePoint = [particle mapPointFromCanonicalToParticleSystem:nowPoint];
    NvsParticleSystemContext *particleContext = [particle getParticleSystemContext];
    if (particleContext == nil) {
        return;
    }
    
    NSArray *emitter = particleInfo.emitterName;
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    int64_t time = [context getTimelineCurrentPosition:timeline];
    NSMutableDictionary *dict = NSMutableDictionary.new;
    [dict setValue:[NSValue valueWithCGPoint:particlePoint]
            forKey:[NSString stringWithFormat:@"%lld", time]];
    [particleInfo.particleLocation addObject:dict];
    for (id name in emitter) {
        [particleContext appendPositionToEmitterPositionCurve:name
                                                    curveTime:(float)(time - particleInfo.inPoint)/NV_TIME_BASE
                                             emitterPositionX:particlePoint.x
                                             emitterPositionY:particlePoint.y];
        [particleContext setEmitterRateGain:name emitterGain:particleInfo.particleRateValue];
        [particleContext SetEmitterParticleSizeGain:name emitterGain:particleInfo.particleSizeValue];
    }

}

+ (void)stopParticle:(NvsTimeline *)timeline particleInfo:(NvParticleInfoModel *)particleInfo {
    NvParticleInfoModel *info = [NvTimelineParticleUtils findParticleInfo:particleInfo.uuid];
    info.outPoint = particleInfo.outPoint;
    
    [NvTimelineUtils resetParticle:timeline particleDataArray:[[NvTimelineData sharedInstance] particleDataArray]];
}

+ (void)removeParticle:(NvsTimeline *)timeline particleInfo:(NvParticleInfoModel *)particleInfo {
    NSMutableArray *particleList = [[NvTimelineData sharedInstance] particleDataArray];
    for (id particle in particleList) {
        if ([particleInfo.uuid isEqualToString:[(NvParticleInfoModel *)particle uuid]]) {
            [particleList removeObject:particle];
            break;
        }
    }
    [NvTimelineUtils resetParticle:timeline particleDataArray:particleList];
}

+ (NvsTimelineVideoFx *)findParticleObject:(NvsTimeline *)timeline particleUUID:(NSString *)particleUUID {
    
    NSMutableArray *particlelist = [[NvTimelineData sharedInstance] particleDataArray];
    if (particlelist.count == 0 || [NvUtils isStringEmpty:particleUUID]) {
        return nil;
    }
    
    int index = -1;
    for (id info in particlelist) {
        index++;
        if ([particleUUID isEqualToString:[(NvParticleInfoModel *)info uuid]]) {
            break;
        }
    }
    if (index < 0) {
        return nil;
    }
    int indexObj = -1;
    NvsTimelineVideoFx *currentobj = [timeline getFirstTimelineVideoFx];
    NvsStreamingContext *context = [NvSDKUtils getSDKContext];
    while (currentobj) {
        NvParticleInfoModel *info = [NvTimelineParticleUtils findParticleInfo:particleUUID];
        //由于粒子也是timeline videofx，需要过滤掉非粒子的videofx.
        //Since particles are also timeline videofx, non-particle videofx needs to be filtered out.
        if ([context.assetPackageManager isParticleFx:info.name]) {
            indexObj++;
            if (indexObj == index) {
                return currentobj;
            }
        }
        currentobj = [timeline getNextTimelineVideoFx:currentobj];
    }
    return nil;
}

+ (NvParticleInfoModel *)findParticleInfo:(NSString *)particleUUID {
    NvTimelineData *timelineData = [NvTimelineData sharedInstance];
    for (NvParticleInfoModel *info in timelineData.particleDataArray) {
        if ([info.uuid isEqualToString:particleUUID])
            return info;
    }
    return nil;
}

@end
