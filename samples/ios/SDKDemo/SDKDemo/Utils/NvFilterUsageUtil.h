//
//  NvFilterUsageUtil.h
//  SDKDemo
//
//  Created by meishe20241218 on 2025/7/1.
//  Copyright © 2025 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvFilterUsageUtil : NSObject

/// 拍摄模式下添加滤镜特效
/// append filter effect in shooting mode
/// - Parameter uuid: 滤镜特效的uuid
+ (NvsCaptureVideoFx *)appendPackagedCaptureVideoFx:(NSString *)uuid;
@end

NS_ASSUME_NONNULL_END
