//
//  NvRectView.h
//  aa
//
//  Created by 刘东旭 on 2017/8/11.
//  Copyright © 2017年 刘东旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvsTimelineCompoundCaption.h"
@class NvRectView;

typedef enum : NSUInteger {
    NvLeft = 0,
    NvCenter,
    NvRight,
} NvTextAlign;

typedef enum: NSUInteger {
    NV_ANIMATED_STICKER = 0,
    NV_CAPTION
}NvType;

@protocol NvRectViewDelegate <NSObject>
@optional
- (void)rectView:(NvRectView*)rectView close:(UIButton*)close;
- (void)rectView:(NvRectView *)rectView align:(UIButton *)align;
- (void)rectView:(NvRectView*)rectView rotate:(float)rotate scale:(float)scale;
- (void)rectView:(NvRectView*)rectView scale:(float)scale;
- (void)rectView:(NvRectView*)rectView currentPoint:(CGPoint)currentPoint previousPoint:(CGPoint)previousPoint;
- (void)rectView:(NvRectView *)rectView touchBeganPoint:(CGPoint)point;
- (void)rectView:(NvRectView *)rectView touchUpInside:(CGPoint)point;
- (void)rectView:(NvRectView *)rectView touchesEnded:(CGPoint)point;
- (void)rectView:(NvRectView *)rectView toggleVolume:(UIButton *)toggleVolume;
- (void)rectView:(NvRectView *)rectView horizontalFlip:(UIButton *)horizontalFlip;
- (void)rectView:(NvRectView *)rectView verticalSwitch:(BOOL)isVertical;

- (void)rectView:(NvRectView *)rectView isHidden:(BOOL)isHidden;

- (void)rectViewtouchBegan:(NvRectView *)rectView;
- (void)rectView:(NvRectView *)rectView rotationEnded:(CGPoint)point;
@end

@interface NvRectView : UIView

@property(weak, nonatomic)id delegate;

- (instancetype)initWithFrame:(CGRect)frame type:(NvType)type;
- (void)hidenAlignImage:(BOOL)hiden;
- (void)hideVoiceButton:(BOOL)hidden;
- (void)setPoints:(NSArray *)array;
- (CGPoint)getCenter;
- (void)setTextAlign:(NvTextAlign)align;
- (void)setVolume:(BOOL)isVoice;
- (BOOL)allImagesDontSetCenter;
- (void)showAllImage;
- (void)hiddenAllImage;
- (void)removeSublayer;
///可修改字幕重新绘制边框
///You can modify subtitles and redraw borders
- (void)changeModifiableInternalCaptionsWithPoints:(NSArray *)points;
@property(assign, nonatomic) NvType type;
@property (nonatomic, strong) UIColor *rectLineColor;

-(void)setSubCaptionLineColorWithIndex:(int)index color:(UIColor *)color;

- (void)setInnerPoints:(NSMutableArray *)innerPoints;

- (void)hiddenAllDecorates;

- (void)enableDecorate;

- (BOOL)isEnableDecorate;
@end
