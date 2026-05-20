//
//  NvOriginSoundView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/16.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvOriginSoundView;

@protocol NvOriginSoundViewDelegate

- (void)applyClick:(NvOriginSoundView *)originSoundView;
- (void)originSoundView:(NvOriginSoundView *)originSoundView originSound:(float)originSound;
- (void)originSoundView:(NvOriginSoundView *)originSoundView musicSound:(float)musicSound;
- (void)originSoundView:(NvOriginSoundView *)originSoundView dubbing:(float)dubbing;

@end

@interface NvOriginSoundView : UIView

@property (nonatomic, weak)id delegate;

- (void)setOriginSound:(float)originSound musicSound:(float)musicSound dubbing:(float)dubbing;

@end
