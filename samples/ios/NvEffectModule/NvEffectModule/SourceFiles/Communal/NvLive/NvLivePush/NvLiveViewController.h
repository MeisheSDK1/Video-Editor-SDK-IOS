//
//  NvLiveViewController.h
//  MeicamLive
//
//  Created by meishe on 2023/7/12.
//  Copyright © 2023 ms20180425. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_include(<NveEffectKit/NveEffectKit.h>)
#import <NveEffectKit/NveEffectKit.h>
#import "NvLiveEffectModule.h"
#else
#import "NvLiveStreamingModule.h"
#import "NvLiveCaptureModularVM.h"
#endif

#import "NvLiveFilterViewModel.h"
#import "NvLivePropViewModel.h"
#import "NvLiveMakeupViewModel.h"
#import "NvLiveBeautyViewModel.h"
#import "NvLiveModel.h"

#import "NvLivePopView.h"
#import "NvLivePushConfigView.h"
#import "NvLivePushOperatingView.h"
#import "NvLiveGarbageView.h"
#import "NvLiveCountDownAnimationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface NvLiveViewController : UIViewController
<
NvLivePushConfigViewDelegate,
NvLivePushOperatingViewDelegate
>

@property (nonatomic, strong) UIView *preview;
@property (nonatomic, strong) NvLivePushConfigView *configView;
@property (nonatomic, strong) NvLivePushOperatingView *operatingView;
@property (nonatomic, strong) NvLiveGarbageView *garbageView;

@property(nonatomic, strong) NvLiveBeautyViewModel *beautyViewModel;
@property(nonatomic, strong) NvLiveFilterViewModel *filterViewModel;
@property(nonatomic, strong) NvLivePropViewModel *propViewModel;
@property(nonatomic, strong) NvLiveMakeupViewModel *makeupViewModel;

@property (nonatomic, readonly) NvLiveModel* liveModel;

-(instancetype)initLiveModel:(NvLiveModel*)model;

- (void)loadBeautyData;

@end

NS_ASSUME_NONNULL_END
