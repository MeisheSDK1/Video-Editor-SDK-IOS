//
//  NvModularStyleView.h
//  SDKDemo
//
//  Created by 刘东旭 on 2020/7/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvModularStyleVM.h"
#import "NvsTimeline.h"
#import "NvRectView.h"
#import "NvStyleListView.h"
#import "NvColorListview.h"
#import "NvBgColorListview.h"
#import "NvStrokeListView.h"
#import "NvFontListView.h"
#import "NvPositionListView.h"
#import "NvTimelineDataModel.h"
#import "NvCaptionSpaceView.h"
#import "NvAnimationView.h"
#import "NvCaptionRendererView.h"
#import "NvCaptionContextView.h"
#import "NvBgColorListview.h"
#import "NvFontRatioView.h"
#import "NvShadowListView.h"

NS_ASSUME_NONNULL_BEGIN
@protocol NvModularStyleViewDelegate <NSObject>
@optional

- (void)fixedItemClicked;

@end

@interface NvModularStyleView : UIView
@property (nonatomic, assign) id<NvModularStyleViewDelegate>delegate;
- (instancetype)initWithStyleVM:(NvModularStyleVM*)vm;

- (NvCaptionRendererView*)rendererListView;
- (NvCaptionContextView*)contextListView;
- (NvColorListview*)colorListView;
- (NvStrokeListView*)strokeListView;
- (NvBgColorListview*)bgColorListView;
- (NvCaptionSpaceView*)spaceView;
- (NvFontListView* )fontListView;
- (NvAnimationView* )animationView;
- (NvFontRatioView* )fontRatioView;
- (NvShadowListView* )shadowListView;
- (CGFloat)getTitleHeight;
- (void)changeSelectedItem:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
