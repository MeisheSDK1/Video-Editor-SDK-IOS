//
//  NvEditCaptionStyleViewController.h
//  SDKDemo
//
//  Created by MS on 2019/7/17.
//  Copyright © 2019 meishe. All rights reserved.
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
#import "NvStyleView.h"
#import "NvCaptionDialogViewController.h"

@class NvEditCaptionStyleViewController;
@protocol NvEditCaptionStyleViewControllerDelegate <NSObject>

- (void)editCaptionStyleViewController:(NvEditCaptionStyleViewController *)editCaptionStyleViewController closeCaption:(NvsTimelineCaption *)caption;

@end

@interface NvEditCaptionStyleViewController : NvEditBaseViewController

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign) NvCaptionType captionType;

@property (nonatomic, strong) NvsTimelineCaption *currentCaption; 

@property (nonatomic, strong) NvCaptionInfoModel *captionInfo;

@property (nonatomic, strong) NSMutableArray *captionInfos;
/// 样式返回，同步当前时间
/// Style returns to synchronize the current time
@property (nonatomic, copy) void(^popResetPos)(int64_t time, NvsTimelineCaption *caption);

@property (nonatomic, assign) NSInteger selectedIndex;

@end

