//
//  NvARScenAsset.h
//  NvTest
//
//  Created by ms20180425 on 2022/8/22.
//

#import <Foundation/Foundation.h>
#import "NvARSceneMacro.h"

#import "NvsEffectSdkContext.h"
#import "NvsARSceneManipulate.h"
#import "NvsMakeupEffectInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvARScenAsset : NSObject

@property (nonatomic, assign) NvsAssetPackageType assetType;

@property (nonatomic, strong) NSString *path;

@end

NS_ASSUME_NONNULL_END
