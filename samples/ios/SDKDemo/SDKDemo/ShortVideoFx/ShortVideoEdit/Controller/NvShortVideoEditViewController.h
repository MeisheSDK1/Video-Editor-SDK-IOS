//
//  NvShortVideoEditViewController.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/8/31.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NvBaseCommon/NvBaseViewController.h>
@class NvRecordingInfo;

@interface NvShortVideoEditViewController : NvBaseViewController

@property (nonnull, strong) NSMutableArray <NvRecordingInfo *>*videoPathArray;

/**
 如果音乐路径为nil则认为没有音乐
 if the musicPath is nil, means no music
 */
@property (nonatomic, strong) NSString * _Nullable musicPath;

@property (nonatomic, assign) float trimIn;
@property (nonatomic, assign) float trimOut;

@end
