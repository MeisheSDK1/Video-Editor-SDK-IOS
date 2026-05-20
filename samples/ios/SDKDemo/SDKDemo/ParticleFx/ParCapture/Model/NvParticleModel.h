//
//  NvParticleModel.h
//  SDKDemo
//
//  Created by ms20180425 on 2019/1/3.
//  Copyright © 2019年 meishe. All rights reserved.
//

#import "NvBaseModel.h"
#import "NvsAssetPackageParticleDescParser.h"

@interface NvParticleModel : NvBaseModel

@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NvsAssetPackageParticleDescParser *parser;
@property (nonatomic, assign) BOOL isParGraffiti;
@end
