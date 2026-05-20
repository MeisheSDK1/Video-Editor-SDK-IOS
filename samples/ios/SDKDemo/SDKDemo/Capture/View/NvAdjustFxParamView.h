//
//  NvAdjustFxParamView.h
//  SDKDemo
//
//  Created by Meishe on 2022/8/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvAjustFxParamModel.h"
@class NvAdjustFxParamView;
NS_ASSUME_NONNULL_BEGIN
@protocol NvAdjustFxParamViewDelegate <NSObject>

- (void)nvAdjustFxParamView:(NvAdjustFxParamView *)view valueChanged:(NSArray <NvAjustFxParamModel *> *)models;

- (void)nvAdjustFxParamView:(NvAdjustFxParamView *)view endChange:(NSArray <NvAjustFxParamModel *> *)models;

@end

@interface NvAdjustFxParamView : UIView

@property (nonatomic, assign) BOOL newStyle;

@property (nonatomic, assign) id <NvAdjustFxParamViewDelegate>delegate;
- (instancetype)initWithFrame:(CGRect)frame fxParams:(NSArray * _Nullable)fxParams translation:(NSDictionary *_Nullable)translation;

- (void)updateFxParams:(NSArray *)fxParams translation:(NSDictionary *)translation;

- (void)updateInfoFxParams:(NSArray *)fxParams;

- (void)cancelAnimation;

- (void)delayaf;

@end

NS_ASSUME_NONNULL_END
