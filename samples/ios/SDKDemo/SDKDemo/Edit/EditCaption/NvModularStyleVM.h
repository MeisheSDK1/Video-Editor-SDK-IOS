//
//  NvModularStyleVM.h
//  SDKDemo
//
//  Created by 刘东旭 on 2020/7/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NvsTimelineCaption.h"
#import "NvTimelineData.h"
#import "NvTimelineDataModel.h"
#import "NvStyleListView.h"
#import "NvFontListView.h"
#import "NvColorListview.h"
#import "NvStrokeListView.h"
#import "NvCaptionSpaceView.h"
#import "NvBgColorListview.h"
#import "NvPositionListView.h"
#import "NvsTimeline.h"
#import "NvAnimationView.h"
#import "NvCaptionRendererView.h"
#import "NvCaptionContextView.h"
#import "NvFontRatioView.h"
#import "NvShadowListView.h"

@protocol NvModularStyleVMUIDelegate <NSObject>
@optional
- (NvStyleListView* _Nullable)styleListView;
- (NvFontListView* _Nullable)fontListView;
- (NvColorListview* _Nullable)colorListView;
- (NvStrokeListView* _Nullable)strokeListView;
- (NvCaptionSpaceView* _Nullable)spaceView;
- (NvBgColorListview *_Nullable)bgColorListView;
- (NvPositionListView *_Nullable)positionListView;
- (NvAnimationView* _Nullable)animationView;
- (NvCaptionRendererView* _Nullable)rendererListView;
- (NvCaptionContextView* _Nullable)contextListView;
- (NvShadowListView* _Nullable)shadowListView;
- (NvFontRatioView *_Nullable)fontRatioView;
- (void)selectAnimation:(NvCaptionAnimationItem *_Nonnull)item type:(NvAnimationType)type inValue:(CGFloat)inVal outValue:(CGFloat)outVal;
- (void)changeAnimation:(NvAnimationType)type data:(NvCaptionAnimationItem *_Nonnull)item;
@end

@protocol NvModularStyleVMDelegate <NSObject>

- (void)nvseekTimeline;
- (void)updateCaptionRect;
- (void)playTimeline:(int64_t)start end:(int64_t)end;
- (void)styleOkClick;
- (void)moreStyleClick;
- (void)moreRendererClick;
- (void)moreContextClick;
- (void)moreAnimationClick;
- (void)moreInAnimationClick;
- (void)moreOutAnimationClick;
- (void)updateCaptionView:(NvsTimelineCaption*_Nonnull)caption;
- (void)didSelecteStyle:(BOOL)selectStyle;
- (NSRange)selectedPartialText;
- (void)alertDisabledFontRatio:(BOOL)disable;
@end

@protocol NvModularStyleAnimationDurationDelegate <NSObject>

- (void)animationValue:(float)value;
- (void)inAnimationValue:(float)value;
- (void)outAnimationValue:(float)value;

@end

NS_ASSUME_NONNULL_BEGIN
@interface NvModularStyleVM : NSObject<NvFontRatioViewDelegate,NvShadowListViewDelegate>

@property (nonatomic, weak) id<NvModularStyleVMDelegate> delegate;
@property (nonatomic, weak) id<NvModularStyleVMUIDelegate> uiDelegate;
@property (nonatomic, weak) id<NvModularStyleAnimationDurationDelegate> animationDelegate;
@property (nonatomic, strong) NvsTimelineCaption *currentCaption;
@property (nonatomic, strong) NvCaptionInfoModel *captionInfo;
@property (nonatomic, strong) NSMutableArray *captionInfos;
@property (nonatomic, strong) NvsTimeline *timeline;
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, assign) BOOL applyPart;

- (void)searchFonts;
- (void)searchStyle;
- (void)searchCaptionRenderer;
- (void)searchCaptionContext;
- (void)searchCaptionAnimation;
- (void)searchCaptionInAnimation;
- (void)searchCaptionOutAnimation;

- (void)applyStyleToAllCaption:(BOOL)applyToAllCaption;
- (void)selectStyle:(NvCaptionStyleItem *)item;

- (void)selectColor:(NvCaptionColorItem *)item;
- (void)alphaChanged:(float)value;
- (void)applyColorToAllCaption:(BOOL)applyToAllCaption;

- (void)selectBgColor:(NvCaptionColorItem *)item;
- (void)alphaBgChanged:(float)value;
- (void)bgRadiusChanged:(float)value;
- (void)marginBgChanged:(float)value;
- (void)applyBgColorToAllCaption:(BOOL)applyToAllCaption;

- (void)selectStroke:(NvCaptionStrokeItem *)item;
- (void)selectStroke:(NvCaptionStrokeItem *)item withWidth:(CGFloat)width;
- (void)selectStroke:(NvCaptionStrokeItem *)item withAlpha:(CGFloat)alpha;
- (void)applyStrokeToAllCaption:(BOOL)applyToAllCaption;

- (void)applyFontToAllCaption:(BOOL)applyToAllCaption;
- (void)selectFont:(NvCaptionFontItem *)item;
- (void)nvFontListView:(NvFontListView *)nvFontListView blodClick:(UIButton *)sender;
- (void)nvFontListView:(NvFontListView *)nvFontListView italicClick:(UIButton *)sender;

- (void)nvFontListView:(NvFontListView *)nvFontListView underLineClick:(UIButton *)sender;
- (void)captionSpaceView:(NvCaptionSpaceView *)captionSpaceView didSelectCaptionLetterSpaceType:(float)letterSpace Type:(NvCaptionLetterSpaceType)type;
- (void)captionSpaceView:(NvCaptionSpaceView *)captionSpaceView didSelectCaptionLineLetterSpace:(float)letterSpace;
- (void)applyCaptionSpaceToAllCaption:(BOOL)applyToAllCaption;

-(void)translateCaption:(NvsTimelineCaption*)caption textAlignmentType:(NvCaptionTextAlignment)type;

- (void)applyPositionWithType:(NvCaptionTextAlignment)type;
- (void)applyPositionToAllCaption:(BOOL)applyToAllCaption;

- (void)applyModularCaptionRenderer:(NSString *)rendererId;
- (void)applyModularCaptionContext:(NSString *)contextId;
- (void)applyModularCaptionInAnimation:(NSString *)inAnimationId;
- (void)setModularCaptionInAnimationDuration:(int)duration;
- (void)applyModularCaptionOutAnimation:(NSString *)outAnimationId;
- (void)setModularCaptionOutAnimationDuration:(int)duration;
- (void)applyModularCaptionAnimation:(NSString *)captionAnimationId;
- (void)setModularCaptionAnimationDuration:(int)duration;
- (void)setModularCaptionAnimationValue:(CGFloat)value;
- (void)setDefaultTextBgRadius;
- (void)cancelAllSelected;
- (void)checkIsFrameCaption;
@end

NS_ASSUME_NONNULL_END
