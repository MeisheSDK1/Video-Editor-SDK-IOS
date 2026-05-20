//
//  NvCurveSpeedVM.h
//  SDKDemo
//
//  Created by MS on 2020/11/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsVideoClip.h"
#import "NvCurveSpeedModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvCurveSpeedUtils : NSObject
@property (nonatomic, strong) NvsVideoClip *clip;
@property (nonatomic, strong) NSMutableDictionary *curveSpeeds;
@property (nonatomic, strong) NSString *curveSpeedsId;
- (void)applyCurveSpeed:(NvsVideoClip *)clip model:(NvCurveSpeedModel *)model;

- (void)applyCurveSpeed:(NvsVideoClip *)clip packageId:(NSString *)packageId points:(NSMutableArray *)points;

- (void)setPackageId:(NSString *)packageId points:(NSMutableArray *)points;
@end

NS_ASSUME_NONNULL_END
