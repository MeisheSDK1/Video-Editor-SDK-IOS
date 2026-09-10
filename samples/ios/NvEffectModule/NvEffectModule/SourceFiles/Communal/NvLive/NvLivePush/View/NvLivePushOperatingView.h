//
//  NvLivePushOperatingView.h
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/16.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NvLiveFunctionModel.h"

@class NvLivePushOperatingView;
NS_ASSUME_NONNULL_BEGIN
/// 代理事件，处理点击回调
@protocol NvLivePushOperatingViewDelegate <NSObject>

@optional

- (void)pushOperatingView:(NvLivePushOperatingView *)pushOperatingView withFunction:(NvLiveFunctionModel *)model;

@end
@interface NvLivePushOperatingView : UIView
@property (nonatomic, weak) id<NvLivePushOperatingViewDelegate>delegate;

/// 功能类型
@property (nonatomic, assign) FunctionType functionType;

- (void)configData:(NSMutableArray *)source;

@end

NS_ASSUME_NONNULL_END
