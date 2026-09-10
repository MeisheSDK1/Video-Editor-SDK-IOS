//
//  NvTrimVideoViewController.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/11/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <NvSDKCommon/NvEditBaseViewController.h>
#import "NvsStreamingContext.h"
@class NvRecordingInfo;

NS_ASSUME_NONNULL_BEGIN

@interface NvTrimVideoViewController : NvEditBaseViewController

@property (nonatomic, assign) BOOL isNoMusic;
@property (nonatomic, strong) NSString *musicPath;
@property (nonatomic, assign) int64_t musicTrimIn;
@property (nonatomic, assign) int64_t musicTrimOut;
@property (nonatomic, strong) NvRecordingInfo *info;


@end

NS_ASSUME_NONNULL_END
