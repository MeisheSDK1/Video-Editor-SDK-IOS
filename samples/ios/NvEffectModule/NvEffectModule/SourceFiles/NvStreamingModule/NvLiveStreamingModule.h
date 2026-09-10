//
//  NvLiveStreamingModule.h
//  NvEffectModule
//
//  Created by ms20221114 on 2024/6/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvLiveStreamingModule : NSObject

+ (void)setupHumanDetection;

+ (NSString *)getAssetPackageIdFromAssetPackageFilePath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
