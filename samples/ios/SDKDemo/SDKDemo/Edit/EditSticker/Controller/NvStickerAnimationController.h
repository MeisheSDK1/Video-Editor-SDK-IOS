//
//  NvStickerAnimationController.h
//  SDKDemo
//
//  Created by ms on 2021/4/20.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>
#import "NvTimelineUtils.h"
@interface NvStickerAnimationController : NvEditBaseViewController
@property (nonatomic, strong) NvsTimelineAnimatedSticker *currentSticker;
@property (nonatomic, strong) NvStickerInfoModel *currentStickerInfoModel;
@end
