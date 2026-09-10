//
//  NvAudioPlayerView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/3.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvEditSelectMusicItem.h"
@class NvAudioPlayerView;

@protocol NvAudioPlayerViewDelegate
@optional
- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView leftValueChanged:(float)value;
- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView rightValueChanged:(float)value;
- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView withItem:(NvEditSelectMusicItem *)item trimIn:(float)trimIn trimOut:(float)trimOut;
- (void)audioPlayerViewNoMusicClick:(NvAudioPlayerView *)audioPlayerView;

- (void)audioPlayerView:(NvAudioPlayerView *)audioPlayerView imageHandlePanChanged:(float)value;
- (void)audioPlayerViewPlayClick:(NvAudioPlayerView *)audioPlayerView withPlay:(BOOL)state;
- (void)audioPlayerViewImport;
@end

@interface NvAudioPlayerView : UIView

@property (nonatomic, weak) id delegate;

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *currentLabel;

@property (nonatomic, assign) CGFloat currentValue;

- (instancetype)initUrlViewWithFrame:(CGRect)frame;

- (void)renderViewWithItem:(NvEditSelectMusicItem *)item;

- (void)setLeftValue:(float)leftValue rightValue:(float)rightValue;

- (void)hiddenHandleButton;

- (void)showCutHandleImage;

- (void)setCutHandleImageValue:(float)value;

@end
