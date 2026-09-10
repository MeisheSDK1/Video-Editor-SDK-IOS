//
//  TransModel.h
//  ThemeHelper
//
//  Created by ms20180425 on 2019/12/26.
//  Copyright © 2019 ms20180425. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransModel : NSObject
/// 转场特效包Packageid
@property (nonatomic, strong) NSString *packageid;

/// 转场内建特效
@property (nonatomic, strong) NSString *builtin;
@end

NS_ASSUME_NONNULL_END
