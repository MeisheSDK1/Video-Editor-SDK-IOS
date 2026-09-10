//
//  NvBeautyLogic.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/9.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsCaptureVideoFx.h"

//NS_ASSUME_NONNULL_BEGIN

@interface NvBeautyLogic : NSObject

///美颜相关
///Beauty correlation
@property (nonatomic, assign) BOOL beauty;

- (void)startBeauty;

@property (nonatomic, assign) double strength;
@property (nonatomic, assign) double whitening;
@property (nonatomic, assign) double reddening;

- (void)closeBeauty;

///美型相关
///Beauty type correlation
@property (nonatomic, strong) NvsCaptureVideoFx *fx,*arfaceVideoFx;

@property (nonatomic, assign) BOOL enAbleAI;

@property (nonatomic, strong) NSString *faceOrnament;
@property (nonatomic, assign) double eyeEnlarging;
@property (nonatomic, assign) double cheekThinning;

@end

//NS_ASSUME_NONNULL_END
