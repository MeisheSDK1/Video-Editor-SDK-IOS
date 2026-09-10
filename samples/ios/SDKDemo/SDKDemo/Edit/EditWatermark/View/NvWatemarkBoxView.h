//
//  NvWatemarkBoxView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/4.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvWatemarkBoxView;
@protocol NvWatemarkBoxViewDelegate <NSObject>
@optional

/// 缩放功能委托函数回调
/// Zoom function delegate function callback
/// @param point 当前位置 current position
/// @param isEnd 是否结束拖拽 Whether to end the drag
- (void)movePoint:(CGPoint) point withEnd:(BOOL)isEnd;

@end

@interface NvWatemarkBoxView : UIView

/// 代理 delegate
@property (nonatomic, weak) id <NvWatemarkBoxViewDelegate> delegate;

/// 拖拽框横纵比  Aspect Ratio of Drag Frame
@property (nonatomic, assign) CGFloat scale;


@end
