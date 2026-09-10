//
//  NvTitleListDataManger.h
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/21.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvTitleListDataManger : NSObject

@property (nonatomic, strong) NSString *lastClickPackId;

+ (NvTitleListDataManger *)standardDefaults;

@end

NS_ASSUME_NONNULL_END
