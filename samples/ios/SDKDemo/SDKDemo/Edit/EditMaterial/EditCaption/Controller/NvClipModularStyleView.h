//
//  NvClipModularStyleView.h
//  SDKDemo
//
//  Created by ms on 2021/8/26.
//  Copyright © 2021 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvClipModularStyleVM.h"
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

NS_ASSUME_NONNULL_BEGIN

@interface NvClipModularStyleView : UIView
- (instancetype)initWithStyleVM:(NvClipModularStyleVM*)vm;

- (NvCaptionRendererView*)rendererListView;
- (NvCaptionContextView*)contextListView;
- (NvColorListview*)colorListView;
- (NvStrokeListView*)strokeListView;
- (NvBgColorListview*)bgColorListView;
- (NvCaptionSpaceView*)spaceView;
- (NvFontListView* )fontListView;
- (NvAnimationView* )animationView;

@end

NS_ASSUME_NONNULL_END
