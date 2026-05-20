//
//  stMobileDetected.h
//  particle
//
//  鉴权 点位检测
//
//  Created by Meicam on 2017/11/21.
//  Copyright © 2017年 NewAuto video team. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <NvEffectSdkCore/NvsFaceFeaturePoint.h>
//#import "NvsFaceFeaturePoint.h"

#import <NvStreamingSdkCore/NvsFaceFeaturePoint.h>

@interface stMobileDetected : NSObject

- (BOOL)initSTMobileDetected;
- (NvsFaceFeaturePoint *)stMobileDetected:(void *)imageBuffer width:(int)width height:(int)height;

@end
