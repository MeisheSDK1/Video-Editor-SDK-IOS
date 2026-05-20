//
//  NvCanvasView.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/27.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NvCanvasViewDelegate <NSObject>
///触摸开始
///Start of touch
- (void)canvasViewState:(CGPoint)statePoint;
///触摸改变
///Touch change
- (void)canvasViewDuration:(int64_t)duration withPosition:(CGPoint)position;
///触摸结束
///End of touch
- (void)canvasViewEnd:(int64_t)duration;

@end

@interface NvCanvasView : UIView

@property (weak, nonatomic) id<NvCanvasViewDelegate> delegate;

@end
