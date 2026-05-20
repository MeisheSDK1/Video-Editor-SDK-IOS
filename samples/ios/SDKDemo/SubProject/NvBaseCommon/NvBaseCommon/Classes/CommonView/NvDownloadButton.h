//
//  NvDownloadButton.h
//  SDKDemo
//
//  Created by 刘东旭 on 2019/1/3.
//  Copyright © 2019年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 下载状态 Download status
typedef enum : NSUInteger {
    NvNoDownload,             ///<未下载 Not downloaded
    NvDownloading,            ///<下载中 downloading
    NvFinish,                 ///<下载完成 Download completed
} NvDownloadStatus;

NS_ASSUME_NONNULL_BEGIN

@interface NvDownloadButton : UIView

/// 进度值 Progress value
@property (nonatomic, assign) CGFloat progress;

/// 按钮状态 Button state
@property (nonatomic, assign) NvDownloadStatus status;

@end

NS_ASSUME_NONNULL_END
