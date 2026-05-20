//
//  EFAudioOperationView.h
//  EffectSdkDemo
//
//  Created by LiYong on 2021/12/21.
//  Copyright © 2021 美摄. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EFAudioOperationViewDelegate <NSObject>

- (void)EFAudioOperationViewDelegateChangeVolum:(CGFloat)value;
- (void)EFAudioOperationViewDelegateAudioPlay;
- (void)EFAudioOperationViewDelegateAudioPause;
- (void)EFAudioOperationViewDelegateChangeAudioWithPath:(NSString *)path;

@end

@interface EFAudioOperationView : UIView
@property(nonatomic,weak)id<EFAudioOperationViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
