//
//  NvLiveCaptureFilterModel.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvLiveBaseModel.h"

@interface NvLiveCaptureFilterModel : NvLiveBaseModel
// Comic filter config
@property(nonatomic, assign) BOOL strokeOnly; //漫画滤镜相关配置
@property(nonatomic, assign) BOOL grayscale;

@end
