//
//  NvAnimationBottomView.h
//  SDKDemo
//
//  Created by ms on 2020/8/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvGraphicBtn.h"
typedef enum : NSUInteger {
    NVAnimationTypeIn = 0,
    NVAnimationTypeOut,
    NVAnimationTypeCombine,
} NVAnimationType;

NS_ASSUME_NONNULL_BEGIN

@interface NvAnimationBottomView : UIView
@property (nonatomic, copy) void(^selectAnimationTypeBlock)(NVAnimationType);

@property (nonatomic, copy) void(^okBtnClick)(void);

@property (nonatomic, strong) NvGraphicBtn *inButton;
@property (nonatomic, strong) NvGraphicBtn *outButton;
@property (nonatomic, strong) NvGraphicBtn *combineButton;
@end
NS_ASSUME_NONNULL_END
