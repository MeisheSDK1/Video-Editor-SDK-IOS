//
//  NvNormalSpeedView.h
//  SDKDemo
//
//  Created by MS on 2020/11/30.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvNormalSpeedView;

NS_ASSUME_NONNULL_BEGIN
@protocol NvNormalSpeedViewDelegate <NSObject>


/// 应用普通变速
/// Application of ordinary speed change
/// @param speedView self
/// @param speed 普通变速值
/// Ordinary speed change value
- (void)nvNormalSpeedView:(NvNormalSpeedView *)speedView speed:(double)speed;


/// 普通变速是否保持音调
/// Whether the normal transmission maintains pitch
/// @param speedView self
/// @param keepAudioPitch 是否保持音调
/// Keep pitch or not
- (void)nvNormalSpeedView:(NvNormalSpeedView *)speedView keepAudioPitch:(BOOL)keepAudioPitch;


/// 点击底部完成按钮
/// Click the bottom Finish button
/// @param speedView self
- (void)nvFinishNormalSpeedView:(NvNormalSpeedView *)speedView;


/// 结束滑动
/// End slide
/// @param speedView self
- (void)nvNormalSpeedViewChangedEnd:(NvNormalSpeedView *)speedView;
@end

@interface NvNormalSpeedView : UIView

@property (nonatomic, weak) id<NvNormalSpeedViewDelegate> delegate;
@property (nonatomic, assign) BOOL keepAudioPitch;

- (void)setSpeed:(double)speed;
@end

NS_ASSUME_NONNULL_END
