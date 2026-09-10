//
//  NvLivePushConfigView.h
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/16.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 代理事件，处理点击回调
@protocol NvLivePushConfigViewDelegate <NSObject>

@optional

/// 开始直播
- (void)start;

/// 退出
- (void)exit;

/// 切换摄像头
- (void)switchCamera;

/// 点击美颜
- (void)beauty;
@end

@interface NvLivePushConfigView : UIView

@property (nonatomic, weak) id<NvLivePushConfigViewDelegate>delegate;

/// 是否隐藏界面
/// @param hidden 默认是NO
- (void)interfaceisHidden:(BOOL)hidden;

@end

NS_ASSUME_NONNULL_END
