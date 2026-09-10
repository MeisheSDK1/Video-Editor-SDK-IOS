//
//  NvCompoundCaptionAdjustmentView.h
//  SDKDemo
//
//  Created by ms on 2022/1/6.
//  Copyright © 2022 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NvTimelineData.h"
#import "NvTimelineDataModel.h"
#import "NvFontListView.h"
#import "NvStrokeListView.h"
#import "NvBgColorListview.h"
#import "NvColorListview.h"
#import "NvCompoundCaptionStyleView.h"
NS_ASSUME_NONNULL_BEGIN

@protocol NvCompoundCaptionAdjustmentViewDelegate <NSObject>

- (void)CompoundCaptionAdjustmentViewDelegateNvseekTimeline;
- (void)CompoundCaptionAdjustmentViewDelegatePlayTimeline:(int64_t)start end:(int64_t)end;
- (void)styleOkButtonClick;
@optional
- (void)CompoundCaptionAdjustmentViewDelegateUpdateCaptionView:(NvsClipCaption*_Nonnull)caption;
- (void)CompoundCaptionAdjustmentViewDelegateDidSelecteStyle:(BOOL)selectStyle;

@end

@interface NvCompoundCaptionAdjustmentView : UIView
@property (nonatomic, strong) NvFontListView *fontListView;
@property (nonatomic, strong) NvStrokeListView *strokeListView;
@property (nonatomic, strong) NvColorListview *colorListView;
@property (nonatomic, strong) NvBgColorListview *bgColorListView;

@property (nonatomic, strong) NvsTimelineCompoundCaption *currentCaption;
///字幕数据
///Subtitle data
@property (nonatomic, strong) NvCompoundCaptionInfoModel *captionInfo;
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, assign) NvEditMode editMode;

@property (nonatomic, assign) BOOL isSetUpAll;
@property(nonatomic, assign)int selectedIndex;
@property (nonatomic, weak) id<NvCompoundCaptionAdjustmentViewDelegate> delegate;
///字体列表
///Font list
@property (nonatomic, strong) NSMutableArray *fontDataSource;
@property (nonatomic, strong) NvCompoundCaptionStyleView *compoundStyleView;

- (void)refreshAdjustView;
@end

NS_ASSUME_NONNULL_END
