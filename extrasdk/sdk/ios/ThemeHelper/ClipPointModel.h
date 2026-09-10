//
//  ClipPointModel.h
//  ThemeHelper
//
//  Created by ms20180425 on 2019/12/26.
//  Copyright © 2019 ms20180425. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ClipPointModel : NSObject
/// 开始时间
@property (nonatomic, assign) int64_t cutPoint;

/// 转场持续时间
@property (nonatomic, assign) double transLen;

/// 转场
@property (nonatomic, strong) NSArray *transName;

/// 片段持续时长
@property (nonatomic, assign) int64_t duration;

@end

NS_ASSUME_NONNULL_END
