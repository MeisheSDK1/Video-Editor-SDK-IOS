//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Mar 9. 2020
//   Author:        Meishe video team
//================================================================================

#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"
#import "NvsArbitraryData.h"

NVS_EXPORT @interface NvsMaterialInfoDetail : NSObject

@property (nonatomic, assign) int index;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *diffuseTexture;
@property (nonatomic, assign) NvsColor diffuseColor;

@property (nonatomic, assign) BOOL panoramicReflectionMap;
@property (nonatomic, strong) NSString *reflectionTexture;
@property (nonatomic, assign) float reflectivity;

@property (nonatomic, strong) NSString *normalTexture;
@property (nonatomic, strong) NSString *specularTexture;
@property (nonatomic, assign) float normalMapIntensity;

@property (nonatomic, strong) NSString *emissiveTexture;
@property (nonatomic, assign) float emissiveMapIntensity;
@property (nonatomic, assign) NvsColor emissiveColor;

@property (nonatomic, assign) NvsColor specularColor;

@property (nonatomic, strong) NSString *ambientOcclusionTexture;
@property (nonatomic, assign) NvsColor ambientColor;
@property (nonatomic, assign) float ambientOcclusion;

@property (nonatomic, strong) NSString *roughnessTexture;
@property (nonatomic, assign) float roughness;

@property (nonatomic, strong) NSString *metalnessTexture;
@property (nonatomic, assign) float metalness;

@property (nonatomic, strong) NSString *iblIrradianceTexture;
@property (nonatomic, strong) NSString *iblPrefilterTexture;
@property (nonatomic, assign) float iblIrradianceIntensity;
@property (nonatomic, assign) float iblSpecularIntensity;
@property (nonatomic, assign) float iblIntensity;
@property (nonatomic, assign) float iblRotationAngleY; // In degrees

@property (nonatomic, assign) float shininess;
@property (nonatomic, assign) float opacity;

@property (nonatomic, assign) BOOL shadowCaster;
@property (nonatomic, assign) BOOL shadowReceiver;

@end

NVS_EXPORT @interface NvsMaterialInfo : NSObject

@property (nonatomic, strong) NSMutableDictionary<NSNumber*,NvsMaterialInfoDetail *> *materialInfo;
@property (nonatomic, strong) NSString *fbxName;

@end

NVS_EXPORT @interface NvsStoryboard3DMaterialInfo : NvsArbitraryData
@property (nonatomic, strong) NSMutableArray<NvsMaterialInfo *> *materialInfoList;
@end


