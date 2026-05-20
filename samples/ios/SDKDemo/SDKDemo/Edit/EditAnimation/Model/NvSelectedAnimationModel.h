//
//  NvSelectedAnimationModel.h
//  SDKDemo
//
//  Created by ms on 2020/8/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvAnimationBottomView.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvSelectedAnimationModel : NSObject
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *packageId;
@property (nonatomic, assign) int64_t begin, end;
@property (nonatomic, assign) float sliderValue;
@property (nonatomic, assign) BOOL isPostPackage;
@property (nonatomic, assign) NVAnimationType animationType;
@property (nonatomic, assign) BOOL isAdjusted;
@end

NS_ASSUME_NONNULL_END
