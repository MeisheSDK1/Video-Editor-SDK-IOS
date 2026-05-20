//
//  NvEditWatemarkImageView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/3.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvEditWatemarkImageView;
@protocol NvEditWatemarkImageViewDelegate <NSObject>
@optional

/// 删除事件回调  Delete event callback
- (void)nvEditWatemarkImageViewWithDeleteClick;

/// 拖拽框位置刷新委托函数
/// Drag box position refresh delegate function
/// @param watemarkView 当前对象 Current object
/// @param rect 位置信息 location information
/// @param isEnd 是否停止拖拽 Whether to stop dragging
- (void)nvEditWatemarkImageView:(NvEditWatemarkImageView *)watemarkView updateRect:(CGRect) rect withState:(BOOL)isEnd;

@end

@interface NvEditWatemarkImageView : UIImageView

/// 拖拽框横纵比  Aspect Ratio of Drag Frame
@property (nonatomic, assign) CGFloat scale;

/// 代理 delegate
@property (nonatomic, weak) id<NvEditWatemarkImageViewDelegate> delegate;

/// 刷新缩放按钮 Refresh zoom button
- (void)updateDragBar;

/// 隐藏边框、删除按钮等控件
/// Hide border, delete button and other controls
/// @param state 需要隐藏 Need to hide
- (void)hiddenView:(BOOL)state;

@end
