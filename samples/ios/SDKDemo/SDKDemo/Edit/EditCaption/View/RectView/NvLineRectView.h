//
//  NvLineRectView.h
//  
//
//  Created by 刘东旭 on 2019/8/15.
//  Copyright © 2019 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NvLineRectView;

NS_ASSUME_NONNULL_BEGIN

@protocol NvLineRectViewDelegate <NSObject>

@required
///某个点是否包含贴纸或字幕
///Whether a point contains stickers or subtitles
- (BOOL)containObjectForPoint:(CGPoint)point;
///手指按住的两个点是否是一个字幕或贴纸对象
///Whether the two points the finger is holding are a subtitle or sticker object
- (BOOL)containSameObjectForPoint:(CGPoint)point otherPoint:(CGPoint)otherPoint;

@optional
///手势缩放
///Gesture zoom
- (void)gestureRectViewPinchScale:(float)scale;
///手势旋转
///Gesture rotation
- (void)gestureRectViewRotation:(float)rotation;
///手势平移
///Gesture translation
- (void)lineRectView:(NvLineRectView *)lineRectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint;
///开始点击
///Start clicking
- (void)lineRectView:(NvLineRectView *)lineRectView touchBeganPoint:(CGPoint)point;
///Tap手势
///Tap gesture
- (void)lineRectView:(NvLineRectView *)lineRectView touchUpInside:(CGPoint)point;
///点击结束
///Click end
- (void)lineRectView:(NvLineRectView *)lineRectView touchesEnded:(CGPoint)point;
///NvRectView是否被隐藏
///Whether NvRectView is hidden
- (void)lineRectView:(NvLineRectView *)lineRectView isHidden:(BOOL)isHidden;

@end

@interface NvLineRectView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL hiddenRectLine;
- (void)setPoints:(NSArray *)array;
- (CGPoint)getCenter;
- (BOOL)isInRect:(CGPoint)p;

@end

NS_ASSUME_NONNULL_END
