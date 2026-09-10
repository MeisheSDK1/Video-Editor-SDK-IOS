//
//  NvEditClipCaptionStyleViewController.h
//  SDKDemo
//
//  Created by ms on 2021/8/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>
#import "NvAddCaptionView.h"
#import "NvRectView.h"
#import "NvCaptionDialog.h"
#import "NvsTimelineCaption.h"
#import "NvCaptionStyleItem.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvAsset.h>
#import "NvTimelineUtils.h"
#import "NvTimelineData.h"
#import "NvInfoModel.h"
#import "NvMoreFilterViewController.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvClipStyleView.h"
#import "NvCaptionDialogViewController.h"
NS_ASSUME_NONNULL_BEGIN

@class NvEditClipCaptionStyleViewController;
@protocol NvEditCaptionStyleViewControllerDelegate <NSObject>

- (void)editCaptionStyleViewController:(NvEditClipCaptionStyleViewController *)editCaptionStyleViewController closeCaption:(NvsClipCaption *)caption;

@end

@interface NvEditClipCaptionStyleViewController : NvEditBaseViewController

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) NvCaptionType captionType;

@property (nonatomic, strong) NvsClipCaption *currentCaption;

@property (nonatomic, strong) NvCaptionInfoModel *captionInfo;

@property (nonatomic, strong) NSMutableArray *captionInfos;
/// 样式返回，同步当前时间
/// Style returns to synchronize the current time
@property (nonatomic, copy) void(^popResetPos)(int64_t time);

@end

NS_ASSUME_NONNULL_END
