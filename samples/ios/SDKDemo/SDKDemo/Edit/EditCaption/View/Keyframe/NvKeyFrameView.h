//
//  NvKeyFrameView.h
//  SDKDemo
//
//  Created by chengww on 2020/8/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvKeyFrameView;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KeyFrameRespone) {
    KeyFrame_Previous = 0, ///< 上一帧 Previous frame
    KeyFrame_Next     = 1, ///< 下一帧 Next frame
    KeyFrame_Add      = 2, ///< 添加关键帧 Add keyframe
    KeyFrame_Delete   = 3, ///< 删除关键帧 Delete key frame
};

@protocol NvKeyFrameViewDelegate

- (void)nvKeyFrameViewDidFinished:(NvKeyFrameView *)view;

- (void)nvKeyFrameView:(NvKeyFrameView *)view didReceive:(KeyFrameRespone)response;

@end

@interface NvKeyFrameView : UIView
/**
 * @brief 代理
 * delegate
 */
@property (nonatomic, weak) id delegate;
/**
 * @brief 是否可以编辑
 * Whether it can be edited
 */
@property (nonatomic, assign, getter=isEnablePrebutton) BOOL enablePrebutton;
@property (nonatomic, assign, getter=isEnableNextbutton) BOOL enableNextbutton;
@property (nonatomic, assign, getter=isEnableAddbutton) BOOL enableAddbutton;

/**
 * @brief 弹入/弹出
 * Pop in/out
 */
- (void)nv_fadeIn:(UIView *)onView;
- (void)nv_fadeOut;
/**
 * @brief 重置中间按钮，添加或者删除关键帧
 * Reset the middle button to add or remove keyframes
 * @param isDelete 是否为删除关键帧
 * Whether to delete key frames
 */
- (void)resetOptKeyFrameButton:(BOOL)isDelete;

@end

NS_ASSUME_NONNULL_END
