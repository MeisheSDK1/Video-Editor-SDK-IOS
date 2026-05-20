//
//  NvAdjustFxParamNewCell.h
//  SDKDemo
//
//  Created by ms20221114 on 2023/2/28.
//  Copyright © 2023 meishe. All rights reserved.
//

#import "NvAdjustFxParamCell.h"
#import "BLItemSlider.h"
#import "NvCustomColorControl.h"
NS_ASSUME_NONNULL_BEGIN

@interface NvAdjustFxParamNewCell : NvAdjustFxParamCell<BLItemSliderDelegate,NvCustomColorControlDelegate>

@property (nonatomic, assign) BOOL changeColor;

@property (nonatomic, strong) NSString *colorStr;

@end

NS_ASSUME_NONNULL_END
