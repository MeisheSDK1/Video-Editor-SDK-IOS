//
//  NvAudioEqualizerRectView.h
//  SDKDemo
//
//  Created by MS on 2021/6/23.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN
@class NvAudioEqualizerRectView;
@protocol NvAudioEqualizerRectViewDelegate <NSObject>

/// 正在滑动中的回调方法
/// call back of slider in changing
/// @param rectView rectView
/// @param index 当前页面改动slider index
/// index the index of slider
/// @param value 正在变化中slider value
/// value  slider value in changing
- (void)audioEqualizerRect:(NvAudioEqualizerRectView *)rectView index:(NSInteger)index changeValue:(double)value;


/// 结束滑动的回调方法
/// call back of end changing
/// @param rectView rectView
/// @param index 当前页面改动slider index
/// index the index of slider
/// @param value 结束变化slider value
/// value  slider value after end change
- (void)audioEqualizerRect:(NvAudioEqualizerRectView *)rectView index:(NSInteger)index endValue:(double)value ;


@end

@interface NvAudioEqualizerRectView : UIView
@property (nonatomic, assign) id<NvAudioEqualizerRectViewDelegate> delegate;

/// 设置数据
/// config the data of view
/// @param leftTopTitle 左上角文字
/// @param leftBottomTitle 左下角文字
/// @param maxVoice 最大音量值
/// @param minVoice 最小音量值
/// @param middelVoice 中间音量值
/// @param frequencyRangeArr 音频数组
/// @param voiceValueArr 音频值数组
- (void)configData:(NSString *)leftTopTitle leftBottomTitle:(NSString *)leftBottomTitle maxVoice:(double)maxVoice minVoice:(double)minVoice middelVoice:(double)middelVoice frequencyRangeArr:(NSArray*)frequencyRangeArr voiceValueArr:(NSArray*)voiceValueArr ;

-(void)configValueData:(NSArray *)voiceValueArr;
@end

NS_ASSUME_NONNULL_END
