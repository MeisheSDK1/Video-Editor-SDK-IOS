//
//  NvThemeSOperationView.h
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/4.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NVHeader.h"
#import <NvSDKCommon/NvAsset.h>

@class NvCaptureFilterModel;
@class NvThemeSOperationView;
NS_ASSUME_NONNULL_BEGIN

@protocol NvThemeSOperationViewDelegate <NSObject>

@optional

- (void)themeSOperationView:(NvThemeSOperationView *)themeSOperationView withModel:(NvCaptureFilterModel *)filterModel;

- (void)themeSOperationView:(NvThemeSOperationView *)themeSOperationView withValue:(CGFloat)value;

- (void)themeSOperationView:(NvThemeSOperationView *)themeSOperationView withCaption:(NSString *)caption;

@end

@interface NvThemeSOperationView : UIView

@property (nonatomic, weak) id<NvThemeSOperationViewDelegate> delegate;

@property (nonatomic, assign) NSInteger index;

/// 配置标题
/// Configuration title
/// @param title 标题
/// title
- (void)configTitle:(NSString *)title;

/// 配置界面
/// Configuration interface
/// @param filter 是否显示滤镜
/// Whether to display filters
/// @param caption 是否显示字幕
/// Show subtitles or not
- (void)configFilter:(BOOL)filter withCaption:(BOOL)caption;

/// 配置字幕数组
/// Configure subtitle array
/// @param captionArray 字幕数组
/// Subtitle array
- (void)configCaptionArray:(NSMutableArray *)captionArray;

/// 配置滤镜数组
/// Configure the filter array
/// @param ratio 比例
/// proportion
- (void)configFilterArray:(AspectRatio)ratio;

/// 配置选中的滤镜
/// Configure the selected filter
/// @param filter 滤镜数据模型
/// Filter data model
/// @param value 强度
/// strength
- (void)configFilter:(NSString *)filter withValue:(CGFloat)value;

@end

NS_ASSUME_NONNULL_END
