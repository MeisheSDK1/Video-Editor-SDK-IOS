//
//  NvCurveSpeedVM.m
//  SDKDemo
//
//  Created by MS on 2020/11/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvCurveSpeedUtils.h"
#import "NvBezierUtils.h"
@interface NvCurveSpeedUtils ()

@end

@implementation NvCurveSpeedUtils

- (void)applyCurveSpeed:(NvsVideoClip *)clip model:(NvCurveSpeedModel *)model {
    [clip changeSpeed:1.0 keepAudioPitch:YES];
    int64_t inPoint = clip.inPoint;
    int64_t outPoint = clip.outPoint;
    NSString *bezierPoints = @"";
    
    if (model.packageId.length > 0) {
        if (![model.packageId isEqualToString:@"none"]) {
            NSMutableArray *points = self.curveSpeeds[model.packageId];
            if (points.count > 0) {
                NSMutableArray *curvePoints = [NvBezierUtils convertToCurvePoints:points];
                bezierPoints = [NvBezierUtils bezierPointsConvertToString:curvePoints];
                ///保存 点的坐标发生改变
                ///The coordinates of the save point have changed
                self.curveSpeedsId = model.packageId;
            }else{
                if (!_curveSpeeds) {
                    _curveSpeeds = [NSMutableDictionary dictionary];
                }
                points = [NvBezierUtils fetchDefaultCurvePoints:model.packageId duration:outPoint - inPoint];
                NSMutableArray *curvePoints = [NvBezierUtils convertToCurvePoints:points];
                bezierPoints = [NvBezierUtils bezierPointsConvertToString:curvePoints];
                ///保存 点的坐标发生改变
                ///The coordinates of the save point have changed
                self.curveSpeedsId = model.packageId;
                self.curveSpeeds[model.packageId] = points;
            }
        }else{
            self.curveSpeedsId = @"";
            return;
        }
    }
    if (!bezierPoints) {
        ///曲线变速选择“无”
        ///Curve speed change select "None"
        bezierPoints = @"";
    }
    BOOL result = [clip changeCurvesVariableSpeed:bezierPoints keepAudioPitch:YES];
    if (!result) {
        NSLog(@"应用曲线变速失败 Application of curve speed change failed");
    }
}

- (void)applyCurveSpeed:(NvsVideoClip *)clip packageId:(NSString *)packageId points:(NSMutableArray *)points {
    [clip changeSpeed:1.0 keepAudioPitch:YES];
    NSString *bezierPoints = @"";
    
    if (packageId.length > 0) {
        if (![packageId isEqualToString:@"none"]) {
            if (!_curveSpeeds) {
                _curveSpeeds = [NSMutableDictionary dictionary];
            }
            NSMutableArray *curvePoints = [NvBezierUtils convertToCurvePoints:points];
            bezierPoints = [NvBezierUtils bezierPointsConvertToString:curvePoints];
            ///保存 点的坐标发生改变
            ///The coordinates of the save point have changed
            self.curveSpeedsId = packageId;
            self.curveSpeeds[packageId] = points;
        }else{
            return;
        }
    }
    if (!bezierPoints) {
        ///曲线变速选择“无”
        ///Curve speed change select "None"
        bezierPoints = @"";
    }
    BOOL result = [clip changeCurvesVariableSpeed:bezierPoints keepAudioPitch:YES];
    if (!result) {
        NSLog(@"应用曲线变速失败 Application of curve speed change failed");
    }
}

- (void)setPackageId:(NSString *)packageId points:(NSMutableArray *)points {
    if (!_curveSpeeds) {
        _curveSpeeds = [NSMutableDictionary dictionary];
    }
    self.curveSpeeds[packageId] = points;
}
@end
