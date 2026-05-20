//
//  NvEffectModel.h
//  SDKDemo
//
//  Created by 刘东旭 on 2019/10/16.
//  Copyright © 2019 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvEffectModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
