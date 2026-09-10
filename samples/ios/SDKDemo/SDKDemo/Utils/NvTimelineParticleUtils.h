//
//  NvTimelineParticleUtils.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvTimelineDataModel.h"
#import "NvsTimeline.h"

@interface NvTimelineParticleUtils : NSObject

/*
 * 长按开始添加粒子 Long press to start adding particles
 */
+ (NSString *)startParticle:(NvsTimeline *)timeline particleInfo:(NvParticleInfoModel *)particleInfo;

/*
 * 长按滑动更新粒子 Press and slide to update particles
 */
+ (void)updateParticle:(NvsTimeline *)timeline
          particleInfo:(NvParticleInfoModel *)particleInfo
            liveWindow:(NvsLiveWindow *)liveWindow
                 point:(CGPoint)point;

/*
 * 长按停止添加粒子 Long press to stop adding particles
 */
+ (void)stopParticle:(NvsTimeline *)timeline particleInfo:(NvParticleInfoModel *)particleInfo;

/*
 * 删除粒子 Deletion particle
 */
+ (void)removeParticle:(NvsTimeline *)timeline particleInfo:(NvParticleInfoModel *)particleInfo;

@end
