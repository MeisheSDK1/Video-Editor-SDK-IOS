//
//  NvClipStyleView.h
//  SDKDemo
//
//  Created by ms on 2021/8/26.
//  Copyright © 2021 meishe. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NvStyleListView.h"
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
#import "NvClipModularStyleVM.h"

@interface NvClipStyleView : UIView
@property (nonatomic, strong) NvStyleListView *styleListView;
@property (nonatomic, strong) NvColorListview *colorListView;
@property (nonatomic, strong) NvStrokeListView *strokeListView;
@property (nonatomic, strong) NvBgColorListview *bgColorListView;
@property (nonatomic, strong) NvFontListView *fontListView;
@property (nonatomic, strong) NvCaptionSpaceView *spaceView;
@property (nonatomic, strong) NvPositionListView *positionListView;

- (instancetype)initWithStyleVM:(NvClipModularStyleVM*)vm;

@end
