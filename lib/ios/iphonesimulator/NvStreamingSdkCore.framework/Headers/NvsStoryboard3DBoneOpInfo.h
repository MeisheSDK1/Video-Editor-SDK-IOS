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
#import "NvsCommonDef.h"

NVS_EXPORT @interface NvsBoneOpInfo : NSObject

@property(strong, nonatomic) NSString *name;
@property(assign, nonatomic) NvsPosition3D scale3D;
@property(assign, nonatomic) NvsPosition3D rotation3D;
@property(assign, nonatomic) NvsPosition3D translation3D;

@end

NVS_EXPORT @interface NvsStoryboard3DBoneOpInfo : NvsArbitraryData

@property(strong, nonatomic) NSMutableDictionary <NSString*, NvsBoneOpInfo *>*boneOpInfo;

@end
