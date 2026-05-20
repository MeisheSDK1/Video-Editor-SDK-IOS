//
//  NvTimelineFilterUtils.m
//  SDKDemo
//
//  Created by shizhouhu on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvTimelineFilterUtils.h"
#import <NvSDKCommon/NvUtils.h>
#import "NvTimelineUtils.h"
#import <NvSDKCommon/NvSDKUtils.h>

@implementation NvTimelineFilterUtils

+ (void)addFilter:(NvsTimeline *)timeline filterInfo:(NvTimeFilterInfoModel *)filterInfo {
    if ([NvSDKUtils isBuiltinFilter:filterInfo.name]) {
        [timeline addBuiltinTimelineVideoFx:filterInfo.inPoint
                                   duration:[timeline duration] - filterInfo.inPoint
                                videoFxName:filterInfo.name];
    } else {
        [timeline addPackagedTimelineVideoFx:filterInfo.inPoint
                                    duration:[timeline duration] - filterInfo.inPoint
                            videoFxPackageId:filterInfo.name];
    }
}

+ (void)startFilter:(NvsTimeline *)timeline filterInfo:(NvTimeFilterInfoModel *)filterInfo {
    if ([NvSDKUtils isBuiltinFilter:filterInfo.name]) {
        [timeline addBuiltinTimelineVideoFx:filterInfo.inPoint
                                   duration:[timeline duration] - filterInfo.inPoint
                                videoFxName:filterInfo.name];
    } else {
        [timeline addPackagedTimelineVideoFx:filterInfo.inPoint
                                    duration:[timeline duration] - filterInfo.inPoint
                            videoFxPackageId:filterInfo.name];
    }
}

+ (void)stopFilter:(NvsTimeline *)timeline filterInfo:(NvTimeFilterInfoModel *)filterInfo {
    [NvTimelineFilterUtils updateFxList:timeline inPoint:filterInfo.inPoint outPoint:filterInfo.outPoint];
    [NvTimelineUtils resetVideoFx:timeline videoFxDataArray:[[NvTimelineData sharedInstance] videoFxDataArray]];
}

+ (void)removeFilter:(NvsTimeline *)timeline filterInfo:(NvTimeFilterInfoModel *)filterInfo {
    NSMutableArray *videofxList = [[NvTimelineData sharedInstance] videoFxDataArray];
    for (id videofx in videofxList) {
        if ([filterInfo.uuid isEqualToString:[(NvParticleInfoModel *)videofx uuid]]) {
            [videofxList removeObject:videofx];
            break;
        }
    }
    [NvTimelineUtils resetVideoFx:timeline videoFxDataArray:videofxList];
}

+ (void)updateFxList:(NvsTimeline *)timeline inPoint:(int64_t)inPoint outPoint:(int64_t)outPoint {
    NSMutableArray *newtlFilterInfos = [[NSMutableArray alloc] init];
    
    NvTimelineData *timelineData = [NvTimelineData sharedInstance];
    NSMutableArray *filterinfos = [timelineData videoFxDataArray];
    for (int i = 0; i < filterinfos.count; i++) {
        NvTimeFilterInfoModel *info = filterinfos[i];
        int64_t infoInPoint = info.inPoint;
        int64_t infoOutPoint = info.outPoint;
        if (info.addInReverseMode) {
            int64_t tmp = infoInPoint;
            infoInPoint = [timeline duration] - infoOutPoint;
            infoOutPoint = [timeline duration] - tmp;
        }
        
        if (infoInPoint <= inPoint) {
            if (infoOutPoint <= inPoint) {
                NvTimeFilterInfoModel *newInfo = NvTimeFilterInfoModel.new;
                newInfo.name = info.name;
                newInfo.inPoint = infoInPoint;
                newInfo.outPoint = infoOutPoint;
                newInfo.addInReverseMode = info.addInReverseMode;
                [newtlFilterInfos addObject:newInfo];
            } else {
                NvTimeFilterInfoModel *newInfo = NvTimeFilterInfoModel.new;
                newInfo.name = info.name;
                newInfo.inPoint = infoInPoint;
                newInfo.outPoint = inPoint;
                newInfo.addInReverseMode = info.addInReverseMode;
                [newtlFilterInfos addObject:newInfo];
                if (infoOutPoint > outPoint) {
                    NvTimeFilterInfoModel *newInfo = NvTimeFilterInfoModel.new;
                    newInfo.name = info.name;
                    newInfo.inPoint = outPoint;
                    newInfo.outPoint = infoOutPoint;
                    newInfo.addInReverseMode = info.addInReverseMode;
                    [newtlFilterInfos addObject:newInfo];
                }
            }
        } else if (infoInPoint < outPoint) {
            if (infoOutPoint <= outPoint) {
                // do nothing
            } else {
                NvTimeFilterInfoModel *newInfo = NvTimeFilterInfoModel.new;
                newInfo.name = info.name;
                newInfo.inPoint = outPoint;
                newInfo.outPoint = infoOutPoint;
                newInfo.addInReverseMode = info.addInReverseMode;
                [newtlFilterInfos addObject:newInfo];
            }
        } else {
            NvTimeFilterInfoModel *newInfo = NvTimeFilterInfoModel.new;
            newInfo.name = info.name;
            newInfo.inPoint = infoInPoint;
            newInfo.outPoint = infoOutPoint;
            newInfo.addInReverseMode = info.addInReverseMode;
            [newtlFilterInfos addObject:newInfo];
        }
    }
    
    [[NvTimelineData sharedInstance] setVideoFxDataArray:newtlFilterInfos];
}
@end
