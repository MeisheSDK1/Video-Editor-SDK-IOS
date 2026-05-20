//
//  NvCaptureFilterModel.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvBaseModel.h"

@interface NvCaptureFilterModel : NvBaseModel

@property (nonatomic, assign) BOOL strokeOnly; //漫画滤镜相关配置 Cartoon filter related configuration
@property (nonatomic, assign) BOOL grayscale;  //漫画滤镜相关配置 Cartoon filter related configuration

@end

