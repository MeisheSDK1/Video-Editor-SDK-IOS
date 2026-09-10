//
//  NvClipStickerAnimationController.h
//  SDKDemo
//
//  Created by ms on 2021/8/26.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>
#import "NvTimelineUtils.h"
@interface NvClipStickerAnimationController : NvEditBaseViewController
@property (nonatomic, strong) NvsClipAnimatedSticker *currentSticker;
@property (nonatomic, strong) NvStickerInfoModel *currentStickerInfoModel;
@end
