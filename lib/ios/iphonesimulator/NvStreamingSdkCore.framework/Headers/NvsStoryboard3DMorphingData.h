//================================================================================
//
// (c) Copyright Meishe Co. Ltd, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    May 17. 2022
//   Author:        Meishe video team
//================================================================================

#pragma once
#import "NvsArbitraryData.h"

typedef enum {
    NvsFactorOperationType_None = 0,
    NvsFactorOperationType_OneMinus = 1,
    NvsFactorOperationType_Source = 2
} NvsFactorOperationType;

NVS_EXPORT @interface NvsMorphingInfo : NSObject

@property(strong, nonatomic) NSString *name;
@property(assign, nonatomic) float weight;

@end

NVS_EXPORT @interface NvsTargetLevelFactorDesc : NSObject

@property(assign, nonatomic) NvsFactorOperationType opType;
@property(strong, nonatomic) NSString *morphName;

@end

NVS_EXPORT @interface NvsTargetLevelDesc : NSObject

@property(strong, nonatomic) NSString *name;
@property(assign, nonatomic) float weight;
@property(strong, nonatomic) NvsTargetLevelFactorDesc *targetLevelFactorDesc;

@end

NVS_EXPORT @interface NvsStoryboard3DMorphingData : NvsArbitraryData

@property(strong, nonatomic) NSMutableArray <NvsMorphingInfo*>*morphingInfoList;
@property(strong, nonatomic) NSMutableArray <NvsTargetLevelDesc*>*targetLevelDescList;

@end
