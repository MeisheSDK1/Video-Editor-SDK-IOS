//
//  NvEditStickerKeyFrameView.h
//  SDKDemo
//
//  Created by ms20180425 on 2020/6/15.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimeline.h"
#import "NvTimelineDataModel.h"

///操作类型
///Type of operation
typedef enum{
    NvKeyFrameTypeAdd = 0,       ///< 添加
    NvKeyFrameTypeDelete,        ///< 删除
    NvKeyFrameTypeSelected,      ///< 选中
    NvKeyFrameTypeNoSelected     ///< 未选中
}NvKeyFrameType;

NS_ASSUME_NONNULL_BEGIN
@class NvsTimelineAnimatedSticker;
@class NvEditStickerKeyFrameView;
@protocol NvEditStickerKeyFrameViewDelegate <NSObject>

@optional

/// 回调函数
/// Callback function
/// @param keyFrame 关键帧
/// @param type 当前的操作类型
/// @param pos 当前的时间点
- (void)keyFrameView:(NvEditStickerKeyFrameView *)keyFrame withState:(NvKeyFrameType)type withModel:(NvKeyFrameStickerModel*)keyModel;

/// 完成回调
/// Complete callback
/// @param keyFrame 关键帧
- (void)keyFrameViewFinsh:(NvEditStickerKeyFrameView *)keyFrame;

@end

@interface NvEditStickerKeyFrameView : UIView

/// 代理
/// delegate
@property (nonatomic, weak) id<NvEditStickerKeyFrameViewDelegate>delegate;

/// 当前贴纸model对象
/// Current sticker model object
@property (nonatomic, strong) NvStickerInfoModel *model;

/// 当前贴纸对象
/// Current sticker object
@property (nonatomic, strong) NvsTimelineAnimatedSticker *sticker;

/// 准备删除的相对贴纸时间的关键帧点
/// Ready to remove keyframe points relative to sticker time
@property (nonatomic, assign) int64_t deletePos;

/// 当前关键帧数据
/// Current keyframe data
@property (nullable, nonatomic, strong) NvKeyFrameStickerModel *currentModel;

/// 当前关键帧所在数据组中的位置
/// The location of the current keyframe in the data group
@property (nonatomic, assign) int indexPath;

/// 根据传入的时间点，正确配置内部按钮的状态
/// Correctly configure the state of the internal button based on the point in time passed in
/// @param time 当前时间点
/// Current point in time
/// @param end 是否拖拽结束，如果不是在拖拽状态下调用，传yes就可以
/// Whether the drag is finished? If it is not called in the drag state, pass yes
- (void)configTime:(int64_t)time withEnd:(BOOL)end;

/// 禁用所有操作按钮
/// Disable all action buttons
- (void)prohibitOperation;

/// 添加关键帧
/// Add keyframe
/// @param pos 当前时间点
/// Current point in time
- (void)addKey:(int64_t)pos;
@end

NS_ASSUME_NONNULL_END
