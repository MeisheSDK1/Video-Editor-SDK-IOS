//
//  StickerItem.h
//  Caption
//
//  Created by meishe01 on 2017/8/23.
//  Copyright © 2017年 NewAuto video team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimelineVideoFx.h"
#import "NvsAssetPackageParticleDescParser.h"
#import "NvBaseModel.h"

@interface NvFilterItem : NSObject

@property (assign, nonatomic) BOOL isParticle;//因为粒子也采用此cell，涂鸦粒子的cell蒙层不同，做一个区分
@property (strong, nonatomic) NSString *builtinName;
@property (nonatomic, assign) BOOL strokeOnly;
@property (nonatomic, assign) BOOL grayscale;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *package;
@property (strong, nonatomic) NSString *cover;
@property (assign, nonatomic) BOOL selected;
@property (assign, nonatomic) BOOL longPressed;
@property (strong, nonatomic) NSString *size;
@property (strong, nonatomic) NSString *draw;
@property (assign, nonatomic) DownloadState state;      
@property (strong, nonatomic) NSString * packID;
@property (nonatomic, assign) NSUInteger categoryId;
@property (nonatomic, strong) NvsAssetPackageParticleDescParser *parser;
@property (nonatomic, strong) NSString *color;

@end

@interface NvVideoFxData : NSObject

@property (assign, nonatomic) NvsTimelineVideoFxType type;
@property (strong, nonatomic) NSString *package;
@property (assign, nonatomic) int64_t inPoint;
@property (assign, nonatomic) int64_t duration;

@end
