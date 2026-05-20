//
//  NvStyleView.h
//  SDKDemo
//
//  Created by Meicam on 2018/6/5.
//  Copyright © 2018年 刘东旭. All rights reserved.
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
#import "NvModularStyleVM.h"
#import "NvAnimationView.h"
#import "NvFontRatioView.h"
#import "NvShadowListView.h"

@protocol NvStyleViewDelegate <NSObject>
@optional

- (void)fixedItemClicked;
@end

@interface NvStyleView : UIView
@property (nonatomic, assign) id<NvStyleViewDelegate> delegate;
@property (nonatomic, strong) NvStyleListView *styleListView;
@property (nonatomic, strong) NvColorListview *colorListView;
@property (nonatomic, strong) NvStrokeListView *strokeListView;
@property (nonatomic, strong) NvBgColorListview *bgColorListView;
@property (nonatomic, strong) NvFontListView *fontListView;
@property (nonatomic, strong) NvCaptionSpaceView *spaceView;
@property (nonatomic, strong) NvPositionListView *positionListView;
@property (nonatomic, strong) NvFontRatioView *fontRatioView;
@property (nonatomic, strong) NvShadowListView *shadowListView;
@property (nonatomic, assign) NSInteger selectedIndex;

- (instancetype)initWithStyleVM:(NvModularStyleVM*)vm;

///获取标签栏高度
///Gets the height of the label bar
- (CGFloat)getTitleHeight;
@end
