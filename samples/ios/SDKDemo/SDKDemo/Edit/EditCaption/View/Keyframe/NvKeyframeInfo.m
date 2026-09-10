//
//  NvKeyframeInfo.m
//  SDKDemo
//
//  Created by chengww on 2020/8/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvKeyframeInfo.h"
#import "YYModel.h"
@implementation NvKeyframeInfo
- (instancetype)init {
    self = [super init];
    self.time = 0;
    self.pos = 0;
    self.rotation = 0;
    self.scale = 1;
    self.translation = CGPointZero;
    self.type = CurveAnimationType1;
    self.leftPoint = CGPointMake(0.333333, 0.333333);
    self.rightPoint = CGPointMake(0.666667, 0.666667);
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NvKeyframeInfo *model = [NvKeyframeInfo new];
    model.time = self.time;
    model.pos = self.pos;
    model.rotation = self.rotation;
    model.scale = self.scale;
    model.opacity = self.opacity;
    model.anchor = self.anchor;
    model.translation = self.translation;
    model.translationPairX = self.translationPairX;
    model.translationPairY = self.translationPairY;
    model.opacityPairY = self.opacityPairY;
    /*
    model.scalePairX = self.scalePairX;
    model.scalePairY = self.scalePairY;
    model.rotationPair = self.rotationPair;
     */
    model.type = self.type;
    model.leftPoint = self.leftPoint;
    model.rightPoint = self.rightPoint;
    return model;
}
@end
