//
//  NvVolumeKeyFrameInfo.m
//  SDKDemo
//
//  Created by ms on 2021/8/4.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvVolumeKeyFrameInfo.h"

@implementation NvVolumeKeyFrameInfo

- (instancetype)init {
    self = [super init];
    self.pos = 0;
    self.type = CurveAnimationType1;
    self.leftPoint = CGPointMake(0.333333, 0.333333);
    self.rightPoint = CGPointMake(0.666667, 0.666667);
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvVolumeKeyFrameInfo *model = [NvVolumeKeyFrameInfo new];
    model.pos = self.pos;
    model.leftGainPair = self.leftGainPair;
    model.rightGainPair = self.rightGainPair;
    model.leftGainValue = self.leftGainValue;
    model.rightGainValue = self.rightGainValue;
    model.type = self.type;
    model.leftPoint = self.leftPoint;
    model.rightPoint = self.rightPoint;
    return model;
}

@end
