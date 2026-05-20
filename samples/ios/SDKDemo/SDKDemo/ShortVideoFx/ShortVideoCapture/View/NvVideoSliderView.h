//
//  NNvVideoSliderView.h
//  NvCheez
//
//  Created by 刘东旭 on 2017/12/5.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NvVideoSliderViewDelegate <NSObject>

@optional

/// 开始拖拽
/// start to drag handle
/// @param timeSpan timeSpan
/// @param timeSpanItem timeSpanItem
/// @param handleIndex handleIndex
/// handle索引值
- (void)timeSpan:(id)timeSpan dragHandleStarted:(UIView*)timeSpanItem handleIndex:(int)handleIndex;


/// 拖拽控件过程中
/// drag the handle
/// @param timeSpan timeSpan
/// @param timeSpanItem timeSpanItem
/// @param handleIndex handleIndex
/// handle索引值
/// @param xOffset xOffset of handle
/// handle偏移值
- (void)timeSpan:(id)timeSpan draggingHandle:(UIView*)timeSpanItem handleIndex:(int)handleIndex xOffset:(double)xOffset;


/// 结束拖拽
/// stop dragging the handle
/// @param timeSpan timeSpan
/// @param timeSpanItem timeSpanItem
/// @param handleIndex handleIndex
/// handle索引值
- (void)timeSpan:(id)timeSpan dragHandleEnded:(UIView*)timeSpanItem handleIndex:(int)handleIndex;

@end

@interface NvVideoSliderView : UIView

@property (nonatomic, weak) id <NvVideoSliderViewDelegate> delegate;
@property (nonatomic, assign) int64_t inPoint;
@property (nonatomic, assign) int64_t outPoint;
@property (nonatomic, assign) int64_t middlePoint;

@property (nonatomic, assign) double padding;
@property (nonatomic, assign) double pointsPerMicrosecond;
@property (nonatomic, assign) bool selected;
@property (nonatomic, assign) bool editable;
@property (nonatomic, strong) UIImageView *middleHandle;
@property (nonatomic, strong) UIImageView* leftHandle;
@property (nonatomic, strong) UIImageView* rightHandle;

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)updateFrame;

@end
