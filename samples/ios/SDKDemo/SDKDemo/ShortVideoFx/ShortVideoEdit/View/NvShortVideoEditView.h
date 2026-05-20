//
//  NvShortVideoEditView.h
//  SDKDemo
//
//  Created by shizhouhu on 2018/8/31.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsLiveWindow.h"
#import "NvEffectWrapper.h"
#import "NvTimelineEditor.h"
#import "NvFilterFxModel.h"

typedef enum {
    NV_TIMELINE_FX_TYPE_INVALID = -1,
    NV_TIMELINE_FX_TYPE_REVERSE = 1,
    NV_TIMELINE_FX_TYPE_REPEAT,
    NV_TIMELINE_FX_TYPE_SLOW
} NvTimelineFxType;

@protocol NvShortVideoEditViewDelegate <NSObject>
@optional
- (void)cancelBtnClicked;
- (void)saveBtnClicked;
- (void)liveWindowTappedStop;
- (void)imageViewTappedPlay;
- (void)startFilter:(NSString *)filterId;
- (void)stopFilter;
- (BOOL)canStart;
- (void)revertClick;
- (void)fxLongWithFxName:(NSString *)fxName;
- (void)sliderValueChanged:(UISlider *)slider;
- (void)sliderValueEnd:(UISlider *)slider;
- (void)timeFxClick:(NSIndexPath*)indexPath;
///点击滤镜特效
///Click on Filter effects
- (void)videoFxClick;
///点击时间特效
///Click time effect
- (void)timeFxClick;

/// 重复特效
/// repeat timefx
/// @param value [0,1]
/// @param status status
- (void)repeatPointValue:(float)value forStatus:(UIGestureRecognizerState)status;

/// 拖拽timelineEditor
/// drag timelineEditor
/// @param timelineEditor timelineEditor
/// @param timestamp timestamp
- (void)timelineEditor:(id)timelineEditor dragTimeAxis:(int64_t)timestamp;

- (void)timelineEditorDragTimeAxisEnded;

/// 当前转码状态
/// get the current convert status
- (BOOL)currentConvertStatus;

/// 下载素材
/// download asset
/// @param model model
- (void)downloadAsset:(NvFilterFxModel *)model;

@end

@interface NvShortVideoEditView : UIView

@property (weak, nonatomic) id<NvShortVideoEditViewDelegate> delegate;
///滤镜特效控件：包含缩略图，颜色条，拖动条
///Filter effects control: contains thumbnail, color bar, drag bar
@property (strong, nonatomic) NvEffectWrapper *effectWrapper;
///视频播放窗口播放按钮
///Play button in the video player window
@property (strong, nonatomic) UIImageView *playImageView;
@property (strong, nonatomic) NvTimelineEditor *timelineEditor;
@property (strong, nonatomic) UIImageView *repeatView;
///撤销按钮
///Undo button
@property (strong, nonatomic) UIButton *revertBtn;

///是否可以添加滤镜
///could be added filter whether or not
@property (atomic, assign) BOOL isAddFilterFx;

@property (strong, nonatomic) NSMutableArray <NvFilterFxModel*> *videoFxDataSource;

- (void)setupEffectWrapper:(NSMutableArray *)descArray duration:(int64_t)duration;
- (void)updateColorBarView:(NSMutableArray *)filterModelArray;
- (NvsLiveWindow *)getLiveWindow;
- (void)setupTimelineEditor:(NSMutableArray *)descArray duration:(int64_t)duration;

- (void)finishConvert;

- (void)selectIndex:(int)index;

- (void)updateProgress:(float)progress uuid:(NSString *)uuid;
- (void)downloadFailduuid:(NSString *)uuid;

@end
