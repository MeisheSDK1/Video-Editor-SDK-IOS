//
//  NvAudioEqualizerView.h
//  SDKDemo
//
//  Created by MS on 2021/6/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvAudioEqualizerView;
NS_ASSUME_NONNULL_BEGIN
@protocol NvAudioEqualizerViewDelegate <NSObject>

/// 音频均衡器slider滑动中
/// the callback of slider in changing
/// @param audioEqualizerView audioEqualizerView
/// @param pageNum 当前改动所属页面数值
/// pageNum the pageNum of current changing value
/// @param index 当前页面改动slider index
/// index the index of slider
/// @param value 正在变化中slider value
/// value  slider value in changing
- (void)audioEqualizerView:(NvAudioEqualizerView *)audioEqualizerView page:(NSInteger)pageNum index:(NSInteger)index changeValue:(double)value;

/// 音频均衡器slider滑动结束
/// the callback of slider end changing
/// @param audioEqualizerView audioEqualizerView
/// @param pageNum 当前改动所属页面数值
/// pageNum the pageNum of current changing value
/// @param index 当前页面改动slider index
/// index the index of slider
/// @param value 结束变化slider value
/// value  slider value after end change
- (void)audioEqualizerView:(NvAudioEqualizerView *)audioEqualizerView page:(NSInteger)pageNum index:(NSInteger)index endValue:(double)value;

- (void)audioEqualizerViewSelectData:(NvAudioEqualizerView *)rectView contents:(NSArray *)contents values:(NSArray *)values;
@end

@interface NvAudioEqualizerView : UIView
@property (nonatomic, assign) id<NvAudioEqualizerViewDelegate>delegate;


/// 配置数据
/// connfig the data of view
/// @param dataArr 频段数据
///        dataArr data of frequencies
/// @param valueArr 值的大小
/// @param valueArr values of frequencies
- (void)configData:(NSArray *)dataArr valueArr:(NSArray *)valueArr;
@end

NS_ASSUME_NONNULL_END
