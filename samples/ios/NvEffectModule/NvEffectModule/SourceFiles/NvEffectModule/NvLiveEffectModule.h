//
//  NvLiveEffectModule.h
//  NvLiveEffectModule
//
//  Created by meishe on 2023/7/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvLiveEffectModule : NSObject

+ (void)setupHumanDetection;

+ (NSString *)getAssetPackageIdFromAssetPackageFilePath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
