//
//  NvARSceneAssetManager.h
//  NvTest
//
//  Created by ms20180425 on 2022/8/22.
//

#import <Foundation/Foundation.h>
#import "NvARScenAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvARSceneAssetManager : NSObject

+ (NvARSceneAssetManager *)sharedInstance;

+ (void)dellocInstance;

- (NSMutableString *)installAssetPackage:(NSString *)path licPath:(NSString *)licPath assetType:(NvsAssetPackageType)assetType;

@end

NS_ASSUME_NONNULL_END
