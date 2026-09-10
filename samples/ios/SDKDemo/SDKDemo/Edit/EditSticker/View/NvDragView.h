//
//  NvDragView.h
//  SDKDemo
//
//  Created by dx on 2018/6/21.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvDragBarView.h"

@protocol NvDragViewDelegate <NSObject>

///拖拽框位置刷新委托函数
///Drag and drop the box position to refresh the delegate function
- (void)updateRect:(CGRect) rect;

@end

@interface NvDragView : UIView

@property (weak, nonatomic) id <NvDragViewDelegate> delegate;
@property (assign, nonatomic) DragMode mode;
@property (assign, nonatomic) CGFloat scale;
@property (assign, nonatomic) CGRect originRect;

- (void) setDragMode:(DragMode)dragMode;
///添加缩放按钮
///Add zoom button
- (void) addDragBar;

///刷新缩放按钮
///Refresh zoom button
- (void) updateDragBar;

@end
