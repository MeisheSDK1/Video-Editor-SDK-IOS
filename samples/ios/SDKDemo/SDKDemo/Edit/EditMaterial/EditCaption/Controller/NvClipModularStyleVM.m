//
//  NvClipModularStyleVM.m
//  SDKDemo
//
//  Created by ms on 2021/8/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvClipModularStyleVM.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvAsset.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvCaptionAnimationItem.h"
#import "NvCaptionRendererItem.h"
#import "NvCaptionContextItem.h"
#import "NvKeyFrameManager.h"
@interface NvClipModularStyleVM ()<NvAssetManagerDelegate>

@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvAssetManager *assetManager;
@property (nonatomic, strong) NSMutableArray *fontDataSource;
@property (nonatomic, strong) NSMutableArray *styleDataSource;
@property (nonatomic, strong) NSMutableArray *captionRendererDataSource;
@property (nonatomic, strong) NSMutableArray *captionContextDataSource;
@property (nonatomic, strong) NSMutableArray *captionAnimationDataSource;
@property (nonatomic, strong) NSMutableArray *captionInAnimationDataSource;
@property (nonatomic, strong) NSMutableArray *captionOutAnimationDataSource;

@property (nonatomic, assign) BOOL styleApplyAll;
@property (nonatomic, assign) BOOL colorApplyAll;
@property (nonatomic, assign) BOOL strokeApplyAll;
@property (nonatomic, assign) BOOL colorBgApplyAll;
@property (nonatomic, assign) BOOL fontApplyAll;
@property (nonatomic, assign) BOOL captionSpaceApplyAll;
@property (nonatomic, assign) BOOL positionApplyAll;
@property (nonatomic, assign) BOOL applyToAllCaptionAnimation;
@property (nonatomic, assign) BOOL applyToAllCaptionInAnimation;
@property (nonatomic, assign) BOOL applyToAllCaptionOutAnimation;
@property (nonatomic, assign) BOOL applyCaptionRendererToAllCaption;
@property (nonatomic, assign) BOOL applyCaptionContextToAllCaption;

@property (nonatomic, assign) NvAnimationType animationType;

@property (nonatomic, strong) NvCaptionStyleItem *styleItem;
@property (nonatomic, strong) NvCaptionColorItem *colorItem;
@property (nonatomic, strong) NvCaptionStrokeItem *strokeItem;
@property (nonatomic, assign) NvCaptionTextAlignment positionType;
@property (nonatomic, assign) float letterSpace;
@property (nonatomic, assign) float letterLineSpace;
///用户点过粗体
///The user clicked in bold
@property (nonatomic, assign) BOOL isUserBold;
///用户点过斜体
///The user has clicked italics
@property (nonatomic, assign) BOOL isUserItalic;
///用户点过阴影
///The user clicked on the shadow
@property (nonatomic, assign) BOOL isUserDrawShadow;
///用户点过下划线
///The user underlined
@property (nonatomic, assign) BOOL isUserUnderLine;
@end

@implementation NvClipModularStyleVM

- (instancetype)init {
    if (self = [super init]) {
        self.streamingContext = [NvSDKUtils getSDKContext];
        self.assetManager = [NvAssetManager sharedInstance];
        self.assetManager.delegate = self;
    }
    return self;
}

- (void)searchFonts {
    
    self.fontDataSource = [NSMutableArray array];
    [self.assetManager searchLocalAssets:ASSET_FONT];
    [self.assetManager downloadRemoteAssetsInfo:ASSET_FONT categoryId:1 page:1 pageSize:20 kind:1 modular:NvAssetModularAll ratioFlag:0 ratio:AspectRatio_All sdkVerskon:[NvSDKUtils getSdkVersion]];
}

- (void)searchStyle {
    [self.assetManager searchLocalAssets:ASSET_CAPTION_STYLE];
    ///普通字幕样式
    ///Normal title style
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"caption" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_CAPTION_STYLE bundlePath:itemPath];
    ///花字字幕样式
    ///render captioning style
    NSString *newItemPath = [[NSBundle mainBundle] pathForResource:@"newCaptionStyle" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_CAPTION_STYLE bundlePath:newItemPath];
    [self getStyleDefaultData];
    ///更改样式后需要更改颜色字体描边等属性
    ///After changing the style, you need to change the color, font, stroke and other properties
    [self setViewDefaultData:self.currentCaption];
}

- (void)searchCaptionRenderer {
    [self.assetManager searchLocalAssets:ASSET_CAPTION_RENDERER];
    ///普通字幕样式
    ///Normal title style
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"captionRenderer" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_CAPTION_RENDERER bundlePath:itemPath];
    NSArray *array = [self.assetManager getUsableAssets:ASSET_CAPTION_RENDERER aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    self.captionRendererDataSource = [NSMutableArray array];
    for (NvAsset *asset in array) {
        [self initReservedAssetName:asset];
        NvCaptionRendererItem *item = [NvCaptionRendererItem new];
        item.imageUrl = asset.coverUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.name = asset.displayNamezhCN;
                }else{
                    item.name = asset.displayName;
                }
        item.packageId = asset.uuid;
        [self.captionRendererDataSource addObject:item];
    }
    NvCaptionRendererItem *item = [NvCaptionRendererItem new];
    item.imageUrl = @"NvsFilterNone";
    item.name = NvLocalString(@"None", @"无");
    item.packageId = @"";
    item.isSelect = YES;
    [self.captionRendererDataSource insertObject:item atIndex:0];
    ///设置花字字幕
    ///Set render Caption
    NSString *packageId = self.currentCaption.modularCaptionRendererPackageId;
    if ([packageId isEqualToString:@""] || packageId == nil) {
        for (NvCaptionRendererItem *item in self.captionRendererDataSource) {
            item.isSelect = NO;
        }
        NvCaptionRendererItem *item = [self.captionRendererDataSource firstObject];
        item.isSelect = YES;
    } else {
        for (int i = 0; i < self.captionRendererDataSource.count; i++) {
            NvCaptionRendererItem *item = [self.captionRendererDataSource objectAtIndex:i];
            if ([item.packageId isEqualToString:packageId]) {
                item.isSelect = YES;
            } else {
                item.isSelect = NO;
            }
        }
    }
    if ([self.uiDelegate respondsToSelector:@selector(rendererListView)] && [self.uiDelegate.rendererListView respondsToSelector:@selector(renderListWithItems:)]) {
        [self.uiDelegate.rendererListView renderListWithItems:self.captionRendererDataSource];
    }
}

- (void)searchCaptionContext {
    [self.assetManager searchLocalAssets:ASSET_CAPTION_CONTEXT];
    ///普通字幕样式
    ///Normal caption style
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"captionContext" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_CAPTION_CONTEXT bundlePath:itemPath];
    NSArray *array = [self.assetManager getUsableAssets:ASSET_CAPTION_CONTEXT aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    self.captionContextDataSource = [NSMutableArray array];
    for (NvAsset *asset in array) {
        [self initReservedAssetName:asset];
        NvCaptionRendererItem *item = [NvCaptionRendererItem new];
        item.imageUrl = asset.coverUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.name = asset.displayNamezhCN;
                }else{
                    item.name = asset.displayName;
                }
        item.packageId = asset.uuid;
        [self.captionContextDataSource addObject:item];
        
    }
    NvCaptionRendererItem *item = [NvCaptionRendererItem new];
    item.imageUrl = @"NvsFilterNone";
    item.name = NvLocalString(@"None", @"无");
    item.packageId = @"";
    item.isSelect = YES;
    [self.captionContextDataSource insertObject:item atIndex:0];
    ///设置气泡
    ///Set bubble
    NSString *packageId = self.currentCaption.modularCaptionContextPackageId;
    if ([packageId isEqualToString:@""] || packageId == nil) {
        for (NvCaptionRendererItem *item in self.captionContextDataSource) {
            item.isSelect = NO;
        }
        NvCaptionRendererItem *item = [self.captionContextDataSource firstObject];
        item.isSelect = YES;
    } else {
        for (int i = 0; i < self.captionContextDataSource.count; i++) {
            NvCaptionRendererItem *item = [self.captionContextDataSource objectAtIndex:i];
            if ([item.packageId isEqualToString:packageId]) {
                item.isSelect = YES;
            } else {
                item.isSelect = NO;
            }
        }
    }
    if ([self.uiDelegate respondsToSelector:@selector(contextListView)] && [self.uiDelegate.contextListView respondsToSelector:@selector(renderListWithItems:)]) {
        [self.uiDelegate.contextListView renderListWithItems:self.captionContextDataSource];
    }
}

- (void)searchCaptionAnimation {
    [self.assetManager searchLocalAssets:ASSET_CAPTION_ANIMATION];
    ///普通字幕样式
    ///Normal caption style
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"captionAnimation" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_CAPTION_ANIMATION bundlePath:itemPath];
    NSArray *array = [self.assetManager getUsableAssets:ASSET_CAPTION_ANIMATION aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    self.captionAnimationDataSource = [NSMutableArray array];
    for (NvAsset *asset in array) {
        [self initReservedAssetName:asset];
        NvCaptionAnimationItem *item = [NvCaptionAnimationItem new];
        item.imageUrl = asset.coverUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.name = asset.displayNamezhCN;
                }else{
                    item.name = asset.displayName;
                }
        item.packageId = asset.uuid;
        [self.captionAnimationDataSource addObject:item];
    }
    NvCaptionAnimationItem *item = [NvCaptionAnimationItem new];
    item.imageUrl = @"NvsFilterNone";
    item.name = NvLocalString(@"None", @"无");
    item.packageId = @"";
    item.isSelect = YES;
    [self.captionAnimationDataSource insertObject:item atIndex:0];
    ///设置组合动画
    ///Set composite animation
    float value = 0;
    NSString *packageId = self.currentCaption.modularCaptionAnimationPackageId;
    if ([packageId isEqualToString:@""] || packageId == nil) {
        for (NvCaptionAnimationItem *item in self.captionAnimationDataSource) {
            item.isSelect = NO;
        }
        NvCaptionAnimationItem *item = [self.captionAnimationDataSource firstObject];
        item.isSelect = YES;
    } else {
        for (int i = 0; i < self.captionAnimationDataSource.count; i++) {
            NvCaptionAnimationItem *item = [self.captionAnimationDataSource objectAtIndex:i];
            if ([item.packageId isEqualToString:packageId]) {
                item.isSelect = YES;
            } else {
                item.isSelect = NO;
            }
        }
        value = 1.0*self.currentCaption.getModularCaptionAnimationPeroid/((self.currentCaption.outPoint - self.currentCaption.inPoint)/1000);
    }
    if ([self.animationDelegate respondsToSelector:@selector(animationValue:)]) {
        [self.animationDelegate animationValue:value];
    }
    if ([self.uiDelegate respondsToSelector:@selector(animationView)] && [self.uiDelegate.animationView respondsToSelector:@selector(renderListWithOpenItems:withType:)]) {
        [self.uiDelegate.animationView renderListWithOpenItems:self.captionAnimationDataSource withType:NvComAnimationType];
    }
}

- (void)searchCaptionInAnimation {
    [self.assetManager searchLocalAssets:ASSET_CAPTION_INANIMATION];
    ///普通字幕样式
    ///Normal caption style
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"captionInAnimation" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_CAPTION_INANIMATION bundlePath:itemPath];
    NSArray *array = [self.assetManager getUsableAssets:ASSET_CAPTION_INANIMATION aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    self.captionInAnimationDataSource = [NSMutableArray array];
    for (NvAsset *asset in array) {
        [self initReservedAssetName:asset];
        NvCaptionAnimationItem *item = [NvCaptionAnimationItem new];
        item.imageUrl = asset.coverUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.name = asset.displayNamezhCN;
                }else{
                    item.name = asset.displayName;
                }
        item.packageId = asset.uuid;
        [self.captionInAnimationDataSource addObject:item];
        
    }
    NvCaptionAnimationItem *item = [NvCaptionAnimationItem new];
    item.imageUrl = @"NvsFilterNone";
    item.name = NvLocalString(@"None", @"无");
    item.packageId = nil;
    item.isSelect = YES;
    [self.captionInAnimationDataSource insertObject:item atIndex:0];
    ///设置入动画
    ///Set in animation
    float value = 0;
    NSString *packageId = self.currentCaption.modularCaptionInAnimationPackageId;
    if ([packageId isEqualToString:@""] || packageId == nil) {
        for (NvCaptionAnimationItem *item in self.captionInAnimationDataSource) {
            item.isSelect = NO;
        }
        NvCaptionAnimationItem *item = [self.captionInAnimationDataSource firstObject];
        item.isSelect = YES;
    } else {
        for (int i = 0; i < self.captionInAnimationDataSource.count; i++) {
            NvCaptionAnimationItem *item = [self.captionInAnimationDataSource objectAtIndex:i];
            if ([item.packageId isEqualToString:packageId]) {
                item.isSelect = YES;
            } else {
                item.isSelect = NO;
            }
        }
        value = 1.0*self.currentCaption.getModularCaptionInAnimationDuration/((self.currentCaption.outPoint - self.currentCaption.inPoint)/1000);
    }
    if ([self.animationDelegate respondsToSelector:@selector(inAnimationValue:)]) {
        [self.animationDelegate inAnimationValue:value];
    }
    
    if ([self.uiDelegate respondsToSelector:@selector(animationView)] && [self.uiDelegate.animationView respondsToSelector:@selector(renderListWithOpenItems:withType:)]) {
        [self.uiDelegate.animationView renderListWithOpenItems:self.captionInAnimationDataSource withType:NvInAnimationType];
    }
    
}

- (void)searchCaptionOutAnimation {
    [self.assetManager searchLocalAssets:ASSET_CAPTION_OUTANIMATION];
    
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"captionOutAnimation" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_CAPTION_OUTANIMATION bundlePath:itemPath];
    NSArray *array = [self.assetManager getUsableAssets:ASSET_CAPTION_OUTANIMATION aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    self.captionOutAnimationDataSource = [NSMutableArray array];
    for (NvAsset *asset in array) {
        [self initReservedAssetName:asset];
        NvCaptionAnimationItem *item = [NvCaptionAnimationItem new];
        item.imageUrl = asset.coverUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.name = asset.displayNamezhCN;
                }else{
                    item.name = asset.displayName;
                }
        item.packageId = asset.uuid;
        [self.captionOutAnimationDataSource addObject:item];
        
    }
    NvCaptionAnimationItem *item = [NvCaptionAnimationItem new];
    item.imageUrl = @"NvsFilterNone";
    item.name = NvLocalString(@"None", @"无");
    item.packageId = @"";
    item.isSelect = YES;
    [self.captionOutAnimationDataSource insertObject:item atIndex:0];
    ///设置出动画
    ///set outanimate
    float value = 1;
    NSString *packageId = self.currentCaption.modularCaptionOutAnimationPackageId;
    if ([packageId isEqualToString:@""] || packageId == nil) {
        for (NvCaptionAnimationItem *item in self.captionOutAnimationDataSource) {
            item.isSelect = NO;
        }
        NvCaptionAnimationItem *item = [self.captionOutAnimationDataSource firstObject];
        item.isSelect = YES;
    } else {
        for (int i = 0; i < self.captionOutAnimationDataSource.count; i++) {
            NvCaptionAnimationItem *item = [self.captionOutAnimationDataSource objectAtIndex:i];
            if ([item.packageId isEqualToString:packageId]) {
                item.isSelect = YES;
            } else {
                item.isSelect = NO;
            }
        }
        value = 1-1.0*self.currentCaption.getModularCaptionOutAnimationDuration/((self.currentCaption.outPoint - self.currentCaption.inPoint)/1000);
        
    }
    if ([self.animationDelegate respondsToSelector:@selector(inAnimationValue:)]) {
        [self.animationDelegate inAnimationValue:value];
    }
    if ([self.uiDelegate respondsToSelector:@selector(animationView)] && [self.uiDelegate.animationView respondsToSelector:@selector(renderListWithOpenItems:withType:)]) {
        [self.uiDelegate.animationView renderListWithOpenItems:self.captionOutAnimationDataSource withType:NvOutAnimationType];
    }
}

///获取字幕样式默认数据
///Gets the subtitle style default data
- (void)getStyleDefaultData {
    NSArray *array = [self.assetManager getUsableAssets:ASSET_CAPTION_STYLE aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    self.styleDataSource = [NSMutableArray array];
    for (NvAsset *asset in array) {
        [self initReservedAssetName:asset];
        NvCaptionStyleItem *item = [NvCaptionStyleItem new];
        item.imageUrl = asset.coverUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.name = asset.displayNamezhCN;
                }else{
                    item.name = asset.displayName;
                }
        item.packageId = asset.uuid;
        [self.styleDataSource addObject:item];
        
    }
    NvCaptionStyleItem *item = [NvCaptionStyleItem new];
    item.imageUrl = @"NvsFilterNone";
    item.name = NvLocalString(@"None", @"无");
    item.packageId = @"";
    item.isSelect = YES;
    [self.styleDataSource insertObject:item atIndex:0];
    if ([self.uiDelegate respondsToSelector:@selector(styleListView)] && [self.uiDelegate.styleListView respondsToSelector:@selector(renderListWithItems:)]) {
        [self.uiDelegate.styleListView renderListWithItems:self.styleDataSource];
    }
}

- (void)initReservedAssetName:(NvAsset *)asset {
    if ([asset isReserved]) {
        if ([asset.uuid isEqualToString:@"DF34A143-A1AF-475B-A59D-3350B2E406BC"]) {
            asset.displayName = NvLocalString(@"FlameSpray", @"火焰喷射");
            asset.aspectRatio = AspectRatio_1v1|AspectRatio_16v9|AspectRatio_9v16;
        }
        if ([asset.uuid isEqualToString:@"2EFFCD4F-B03A-487E-AC6A-282694AAF238"]) {
            asset.displayName = NvLocalString(@"Banana", @"小黄人");
            asset.aspectRatio = AspectRatio_1v1|AspectRatio_16v9|AspectRatio_9v16;
        }
        if ([asset.uuid isEqualToString:@"5DCC70E9-122F-455E-A72E-35FE2FACEF02"]) {
            asset.displayName = NvLocalString(@"Fashion", @"时尚闪现");
        }
        if ([asset.uuid isEqualToString:@"127CB6CE-E957-4BD1-8C18-19D44328A85D"]) {
            asset.displayName = NvLocalString(@"Black Frame", @"上下边框");
        }
        if ([asset.uuid isEqualToString:@"56D3AC84-B3D4-4AE5-A7B6-53F03AC238C7"]) {
            asset.displayName = NvLocalString(@"Cat", @"小猫咪");
        }
        if ([asset.uuid isEqualToString:@"565591C2-2227-468A-AFC7-4429EAD3C21C"]) {
            asset.displayName = NvLocalString(@"Effect 01", @"花字1");
        }
        if ([asset.uuid isEqualToString:@"72D49EAD-B9E4-4ADC-A188-545046835F65"]) {
            asset.displayName = NvLocalString(@"flower caption1", @"花字2");;
        }
        if ([asset.uuid isEqualToString:@"6B9154D8-88B0-4367-BB3D-82AE1F62ED21"]) {
            asset.displayName = NvLocalString(@"typewriter1", @"打字机");
        }
        if ([asset.uuid isEqualToString:@"36486C78-EC5F-471E-A5B0-1F41A7E60BBB"]) {
            asset.displayName = NvLocalString(@"typewriter1", @"打字机");
        }
        if ([asset.uuid isEqualToString:@"71DC50E4-D5DD-48D4-92C6-63199C45E905"]) {
            asset.displayName = NvLocalString(@"fade in", @"渐显");
        }
        if ([asset.uuid isEqualToString:@"912B258B-9BFA-4498-93FC-297F2A2BBD2C"]) {
            asset.displayName = NvLocalString(@"opening", @"开幕");
        }
        if ([asset.uuid isEqualToString:@"E7806454-9C5E-49E3-8AE6-EE22BD22BD09"]) {
            asset.displayName = NvLocalString(@"fade out", @"渐隐");
        }
        if ([asset.uuid isEqualToString:@"387D91E7-79B1-44E5-9A81-5C2F695C586D"]) {
            asset.displayName = NvLocalString(@"closing", @"闭幕");
        }
        if ([asset.uuid isEqualToString:@"84C83050-2D7C-4CE2-998D-87E93910B2CF"]) {
            asset.displayName = NvLocalString(@"Jump", @"跳动");
        }
        if ([asset.uuid isEqualToString:@"63629AF7-C487-4687-9214-1F20A9AC1450"]) {
            asset.displayName = NvLocalString(@"Heartbeat", @"心跳");
        }
        if ([asset.uuid isEqualToString:@"0DC345B0-A396-4818-A27D-F1BC3D89DEF3"]) {
            asset.displayName = NvLocalString(@"shake", @"摇晃");
        }
        if ([asset.uuid isEqualToString:@"DAFD12C9-FFB2-4D9E-A4EA-465C7E6F0B3F"]) {
            asset.displayName = NvLocalString(@"default1", @"气泡1");
        }
        if ([asset.uuid isEqualToString:@"AF7074A8-C39C-4CB5-B782-176D93035FCA"]) {
            asset.displayName = NvLocalString(@"Bubble 01", @"气泡2");
        }
        if ([asset.uuid isEqualToString:@"A3A2DA15-209D-471F-BE0A-A7A4B3DB8260"]) {
            asset.displayName = NvLocalString(@"JY2", @"JY2");
        }
        if ([asset.uuid isEqualToString:@"985CA8FD-DACC-46C5-99D4-610B2F97BF09"]) {
            asset.displayName = NvLocalString(@"JY8", @"JY8");
        }
        if ([asset.uuid isEqualToString:@"91FC65DD-AE99-4079-B6A4-BDE60A3F6DF9"]) {
            asset.displayName = NvLocalString(@"vertical poem", @"竖行诗");
        }
    }
}

#pragma mark - 点击确定
- (void)okClick {
    [self.streamingContext stop];
    [self applyToAllCaptions];
    if ([self.delegate respondsToSelector:@selector(styleOkClick)]) {
        [self.delegate styleOkClick];
    }
}
#pragma mark - 更多样式 More type
- (void)moreStyleClick {
    if ([self.delegate respondsToSelector:@selector(moreStyleClick)]) {
        [self.delegate moreStyleClick];
    }
}
#pragma mark - 应用所有样式 Apply all styles
- (void)applyStyleToAllCaption:(BOOL)applyToAllCaption {
    self.styleApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

- (void)playCaption:(NvsClipCaption *)currentCaption animationType:(NvAnimationType)type animationDuration:(int64_t)duration {
    int64_t inPoint;
    if (type == NvInAnimationType) {
        inPoint = currentCaption.inPoint;
    } else if (type == NvOutAnimationType) {
        inPoint = currentCaption.outPoint - duration;
    } else {
        inPoint = currentCaption.inPoint;
        duration = currentCaption.outPoint - inPoint;
    }
    if ([self.delegate respondsToSelector:@selector(playTimeline:end:)]) {
        [self.delegate playTimeline:inPoint end:inPoint + duration];
    }
    
}

- (void)playCaption:(NvsClipCaption *)currentCaption {
    if ([self.delegate respondsToSelector:@selector(playTimeline:end:)]) {
        [self.delegate playTimeline:currentCaption.inPoint end:currentCaption.outPoint];
    }
}
#pragma mark - 应用样式 Application style
- (void)selectStyle:(NvCaptionStyleItem * _Nonnull)item {
    self.styleItem = item;
    if ([self.delegate respondsToSelector:@selector(didSelecteStyle:)]) {
        [self.delegate didSelecteStyle:YES];
    }
    if (item.packageId.length > 0) {
        [self.currentCaption applyCaptionStyle:item.packageId];
        NvCaptionInfoModel *info = self.captionInfo;
        info.styleId = item.packageId;
        self.captionInfo.translation = [self.currentCaption getCaptionTranslation];
        self.captionInfo.scale = [self.currentCaption getScaleX];
        self.captionInfo.rotation = [self.currentCaption getRotationZ];
        CGFloat radius = [self getRadiusWithCaption:self.currentCaption];
        if ([self.uiDelegate respondsToSelector:@selector(bgColorListView)] && [self.uiDelegate.bgColorListView respondsToSelector:@selector(setDefaultTextBgRadius:maxValue:)]) {
            [self.uiDelegate.bgColorListView setDefaultTextBgRadius:info.textBgRadius maxValue:radius];
        }
    } else {
        NvCaptionInfoModel *info = self.captionInfo;
        info.styleId = nil;
        NvsClipCaption *nextCaption = self.currentCaption;
        [nextCaption applyCaptionStyle:nil];
        CGFloat radius = [self getRadiusWithCaption:self.currentCaption];
        if ([self.uiDelegate respondsToSelector:@selector(bgColorListView)] && [self.uiDelegate.bgColorListView respondsToSelector:@selector(setDefaultTextBgRadius:maxValue:)]) {
            [self.uiDelegate.bgColorListView setDefaultTextBgRadius:info.textBgRadius maxValue:radius];
        }
    }
    
    /// 切换字幕样式，重置关键帧
    /// Toggle subtitles style, reset keyframe
    if (self.captionInfo.keyFramesArray.count > 0) {
        /// 先移除关键帧
        /// Remove the keyframe first
        [self.captionInfo.keyArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.currentCaption removeAllKeyframe:obj];
        }];
        /// 再添加关键帧
        /// Add a keyframe
        [self.captionInfo.keyFramesArray enumerateObjectsUsingBlock:^(NvKeyframeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.currentCaption setCurrentKeyFrameTime:obj.pos];
            [self.currentCaption setScaleX:obj.scale];
            [self.currentCaption setScaleY:obj.scale];
            [self.currentCaption setRotationZ:obj.rotation];
            [self.currentCaption setCaptionTranslation:obj.translation];
        }];

        [self.captionInfo.keyFramesArray enumerateObjectsUsingBlock:^(NvKeyframeInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.currentCaption setCurrentKeyFrameTime:obj.pos];
            if (obj.translationPairX) {
                [self.currentCaption setControlPoint:@"Caption TransX" controlPointPair:obj.translationPairX];
            }
            if (obj.translationPairY) {
                [self.currentCaption setControlPoint:@"Caption TransY" controlPointPair:obj.translationPairY];
            }
        }];
    }

    [self setViewDefaultData:self.currentCaption];
    [self playCaption:self.currentCaption];
    
    self.styleApplyAll = false;
}
#pragma mark - 应用所有花字 Apply all render Caption
- (void)applyCaptionRendererToAllCaption:(BOOL)applyToAllCaption {
    self.applyCaptionRendererToAllCaption = applyToAllCaption;
    [self applyToAllCaptions];
}
#pragma mark - 应用花字 Applied render Caption
- (void)selectCaptionRenderer:(NvCaptionRendererItem *)item {
    [self applyModularCaptionRenderer:item.packageId];
    [self playCaption:self.currentCaption];
}
#pragma mark - 点击更多花字 Click on more render Caption
- (void)moreCaptionRendererClick {
    if ([self.delegate respondsToSelector:@selector(moreRendererClick)]) {
        [self.delegate moreRendererClick];
    }
}
#pragma mark - 应用所有气泡 Apply all bubbles
- (void)applyCaptionContextToAllCaption:(BOOL)applyToAllCaption {
    self.applyCaptionContextToAllCaption = applyToAllCaption;
    [self applyToAllCaptions];
}
#pragma mark - 应用气泡 Application bubble
- (void)selectCaptionContext:(NvCaptionContextItem *)item {
    [self applyModularCaptionContext:item.packageId];
    [self playCaption:self.currentCaption];
}
#pragma mark - 更多气泡 More bubbles
- (void)moreCaptionContextClick {
    if ([self.delegate respondsToSelector:@selector(moreContextClick)]) {
        [self.delegate moreContextClick];
    }
}
#pragma mark - 应用动画 Application animation
- (void)selectAnimation:(NvCaptionAnimationItem *)item withAnimationType:(NvAnimationType)type {
    self.animationType = type;
    int duration = (int)((self.currentCaption.outPoint - self.currentCaption.inPoint) / 1000);
    int inDuration = 0;
    int outDuration = 0;
    if (type == NvInAnimationType) {
        if (item.packageId.length > 0) {
            inDuration = self.currentCaption.getModularCaptionInAnimationDuration;
            outDuration = self.currentCaption.getModularCaptionOutAnimationDuration;
            if (inDuration == 0) { inDuration = 500; }
        }else {
            inDuration = 0;
        }
        [self applyModularCaptionInAnimation:item.packageId];
        if (item.packageId) {
            if (duration - outDuration < inDuration) {
                outDuration = duration - inDuration;
                [self.currentCaption setModularCaptionOutAnimationDuration:outDuration];
            }
            [self.currentCaption setModularCaptionInAnimationDuration:inDuration];
            
        }
        outDuration = self.currentCaption.getModularCaptionOutAnimationDuration;
        self.captionInfo.animationModel.inputDuration = self.currentCaption.getModularCaptionInAnimationDuration;
        self.captionInfo.animationModel.outputDuration = outDuration;
        [self playCaption:self.currentCaption animationType:type animationDuration:self.captionInfo.animationModel.inputDuration*1000];
        if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(selectAnimation:type:inValue:outValue:)]) {
            [self.uiDelegate selectAnimation:item type:type inValue:1.0 * self.captionInfo.animationModel.inputDuration / duration outValue:(1 - 1.0 * self.captionInfo.animationModel.outputDuration / duration)];
        }
    } else if (type == NvOutAnimationType) {
        if (item.packageId.length > 0) {
            inDuration = self.currentCaption.getModularCaptionInAnimationDuration;
            outDuration = self.currentCaption.getModularCaptionOutAnimationDuration;
            if (outDuration == 0) { outDuration = 500; }
        }else {
            outDuration = 0;
        }
        [self applyModularCaptionOutAnimation:item.packageId];
        if (duration - inDuration < outDuration) {
            inDuration = duration - outDuration;
            [self.currentCaption setModularCaptionInAnimationDuration:inDuration];
        }
        [self.currentCaption setModularCaptionOutAnimationDuration:outDuration];
        inDuration = self.currentCaption.getModularCaptionInAnimationDuration;
        self.captionInfo.animationModel.outputDuration = self.currentCaption.getModularCaptionOutAnimationDuration;
        self.captionInfo.animationModel.inputDuration = inDuration;
        [self playCaption:self.currentCaption animationType:type animationDuration:self.captionInfo.animationModel.outputDuration*1000];
        if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(selectAnimation:type:inValue:outValue:)]) {
            [self.uiDelegate selectAnimation:item type:type inValue:1.0 * self.captionInfo.animationModel.inputDuration / duration outValue:(1 - 1.0 * self.captionInfo.animationModel.outputDuration / duration)];
        }
    } else {
        if (item.packageId.length > 0) {
            if (outDuration == 0) { outDuration = 600; }
        }else {
            outDuration = 0;
        }
        [self applyModularCaptionAnimation:item.packageId];
        [self.currentCaption setModularCaptionAnimationPeroid:outDuration];
        self.captionInfo.animationModel.captionDuration = self.currentCaption.getModularCaptionAnimationPeroid;
        [self playCaption:self.currentCaption animationType:type animationDuration:self.captionInfo.animationModel.captionDuration*1000];
        if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(selectAnimation:type:inValue:outValue:)]) {
            [self.uiDelegate selectAnimation:item type:type inValue:1.0 * self.captionInfo.animationModel.captionDuration / duration outValue:1.0 * self.captionInfo.animationModel.captionDuration / duration];
        }
    }
}

- (void)changeAnimationType:(NvAnimationType)type data:(NvCaptionAnimationItem *)item {
    if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(changeAnimation:data:)]) {
        [self.uiDelegate changeAnimation:type data:item];
    }
}
#pragma mark - 应用所有动画  Apply all animations
- (void)applyAnimationAllCaption:(BOOL)applyToAllCaption withAnimationType:(NvAnimationType)type {
    if (type == NvInAnimationType) {
        self.applyToAllCaptionInAnimation = applyToAllCaption;
    } else if (type == NvOutAnimationType) {
        self.applyToAllCaptionOutAnimation = applyToAllCaption;
    } else {
        self.applyToAllCaptionAnimation = applyToAllCaption;
    }
    
    [self applyToAllCaptions];
}
#pragma mark - 点击更多动画 Click more animation
- (void)moreAnimationClickWithAnimationType:(NvAnimationType)type {
    if (type == NvInAnimationType) {
        if ([self.delegate respondsToSelector:@selector(moreInAnimationClick)]) {
            [self.delegate moreInAnimationClick];
        }
    } else if (type == NvOutAnimationType) {
        if ([self.delegate respondsToSelector:@selector(moreOutAnimationClick)]) {
            [self.delegate moreOutAnimationClick];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(moreAnimationClick)]) {
            [self.delegate moreAnimationClick];
        }
    }
}

#pragma mark - 应用到所有字幕
/// Applies to all subtitles
- (void)applyToAllCaptions {
    NvTimelineData *data = [NvTimelineData sharedInstance];
    NSMutableArray *captions = data.captionDataArray;
    captions = self.captionInfos;
    NvsClipCaption *nextCaption = [self.videoClip getFirstCaption];
    NvCaptionInfoModel *infoModel = self.captionInfo;
    
    ///应用样式
    ///Application style
    if (self.styleApplyAll) {
        int i = 0;
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                NvCaptionInfoModel *info = captions[i];
                [nextCaption applyCaptionStyle:infoModel.styleId];
                info.styleId = infoModel.styleId;
                i++;
            }
            nextCaption = [self.videoClip getNextCaption:nextCaption];
        } while (nextCaption);
    }
    ///应用颜色
    ///Applied color
    if (self.colorApplyAll) {
        nextCaption = [self.videoClip getFirstCaption];
        
        NvsColor currentColor = [self.currentCaption getTextColor];
        
        for (NvCaptionInfoModel *info in captions) {
            info.textColor = currentColor;
            info.isModifyTextColor = YES;
        }
        
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                NvsColor color = [nextCaption getTextColor];
                color.r = currentColor.r;
                color.g = currentColor.g;
                color.b = currentColor.b;
                color.a = currentColor.a;
                [nextCaption setTextColor:&color];
            }
            
            nextCaption = [self.videoClip getNextCaption:nextCaption];
        } while (nextCaption);
        
    }
    ///应用背景所有
    ///Application background owned
    if (self.colorBgApplyAll) {
        nextCaption = [self.videoClip getFirstCaption];
        NvsColor currentColor = [self.currentCaption getBackgroundColor];
        float radius = [self.currentCaption getBackgroundRadius];
        float margin = [self.currentCaption getBoundaryPaddingRatio];
        for (NvCaptionInfoModel *info in captions) {
            info.textBgColor = currentColor;
            info.textBgRadius = radius;
            info.boundaryMargin = margin;
        }
        
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                NvsColor color = [nextCaption getBackgroundColor];
                color.r = currentColor.r;
                color.g = currentColor.g;
                color.b = currentColor.b;
                color.a = currentColor.a;
                [nextCaption setBackgroundColor:&color];
                [nextCaption setBackgroundRadius:radius];
                [nextCaption setBoundaryPaddingRatio:margin];
            }
            nextCaption = [self.videoClip getNextCaption:nextCaption];
        } while (nextCaption);
    }
    
    ///应用描边
    ///Apply stroke
    if (self.strokeApplyAll) {
        nextCaption = [self.videoClip getFirstCaption];
        NvsColor currentColor = [self.currentCaption getOutlineColor];
        float outlineWidth = [self.currentCaption getOutlineWidth];
        for (NvCaptionInfoModel *info in captions) {
            info.isUserDrawOutline = YES;
            if (![self.currentCaption getDrawOutline]) {
                info.isDrawOutline = NO;
            } else {
                info.isDrawOutline = YES;
                info.outlineColor = currentColor;
                info.outlineWidth = outlineWidth;
            }
        }
        
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                if (![self.currentCaption getDrawOutline]) {
                    [nextCaption setDrawOutline:NO];
                } else {
                    NvsColor color = [nextCaption getOutlineColor];
                    color.r = currentColor.r;
                    color.g = currentColor.g;
                    color.b = currentColor.b;
                    color.a = currentColor.a;
                    [nextCaption setDrawOutline:YES];
                    [nextCaption setOutlineColor:&color];
                    [nextCaption setOutlineWidth:outlineWidth];
                }
            }
            nextCaption = [self.videoClip getNextCaption:nextCaption];
        } while (nextCaption);
    }
    ///应用字体
    ///Application font
    if (self.fontApplyAll) {
        nextCaption = [self.videoClip getFirstCaption];
        
        for (NvCaptionInfoModel *info in captions) {
            info.fontFilePath = [self.currentCaption getFontFilePath];
            info.isUserBold = YES;
            info.isUserItalic = YES;
            info.isUserUnderLine = YES;
            info.isUserDrawShadow = YES;
        }
        
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                [nextCaption setFontWithFilePath:[self.currentCaption getFontFilePath]];
                if (self.isUserBold || [self.currentCaption getBold]) {
                    [nextCaption setBold:self.captionInfo.isBold];
                }
                if (self.isUserItalic || [self.currentCaption getItalic]) {
                    [nextCaption setItalic:self.captionInfo.isItalic];
                }
                if (self.isUserDrawShadow || [self.currentCaption getDrawShadow]) {
                    [nextCaption setDrawShadow:self.captionInfo.isDrawShadow];
                    if (self.captionInfo.isDrawShadow) {
                        [nextCaption setDrawShadow:YES];
                        NvsColor shadowColor = {0,0,0,0.5};
                        [nextCaption setShadowColor:&shadowColor];
                        CGPoint originOffset = CGPointMake(10, -10);
                        [nextCaption setShadowOffset:originOffset];
                    }
                }
                if (self.isUserUnderLine || [self.currentCaption getUnderline]) {
                    [nextCaption setUnderline:self.captionInfo.isUnderLine];
                }
            }
            nextCaption = [self.videoClip getNextCaption:nextCaption];
        } while (nextCaption);
    }
    ///应用字间距
    ///Applied word spacing
    if (self.captionSpaceApplyAll) {
        nextCaption = [self.videoClip getFirstCaption];
        
        for (NvCaptionInfoModel *info in captions) {
            info.letterSpace = [self.currentCaption getLetterSpacing];
            info.letterLineSpace = [self.currentCaption getLineSpacing];
        }
        
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                [nextCaption setLetterSpacingType:NvsLetterSpacingTypeAbsolute];
                [nextCaption setLetterSpacing:[self.currentCaption getLetterSpacing]];
                [nextCaption setLineSpacing:[self.currentCaption getLineSpacing]];
            }
            nextCaption = [self.videoClip getNextCaption:nextCaption];
        } while (nextCaption);
    }
    ///应用位置
    ///Application location
    if (self.positionApplyAll) {
        nextCaption = [self.videoClip getFirstCaption];
        
        int i =0;
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                [self translateCaption:nextCaption textAlignmentType:self.positionType];
                NvCaptionInfoModel *info = captions[i];
                info.translation = [nextCaption getCaptionTranslation];
                info.isUserTranslation = YES;
                i++;
            }
            
            nextCaption = [self.videoClip getNextCaption:nextCaption];
        } while (nextCaption);
        
    }
    
    ///应用所有花字
    ///Apply all flowery characters
    if (self.applyCaptionRendererToAllCaption) {
        nextCaption = [self.videoClip getFirstCaption];
        NSString *modularCaptionRendererPackageId = self.currentCaption.modularCaptionRendererPackageId;
        for (NvCaptionInfoModel *info in captions) {
            if (info.type == Modular) {
                info.renderId = modularCaptionRendererPackageId;
            }
        }
        
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                if (nextCaption.isModular) {
                    [nextCaption applyModularCaptionRenderer:modularCaptionRendererPackageId];
                }
            }
            nextCaption = [self.videoClip getNextCaption:nextCaption];
        } while (nextCaption);
    }
    
    ///应用所有动画
    ///Apply all animations
    if (self.applyToAllCaptionAnimation || self.applyToAllCaptionInAnimation || self.applyToAllCaptionOutAnimation) {
        nextCaption = [self.videoClip getFirstCaption];
        NSString *modularCaptionAnimationPackageId = self.currentCaption.modularCaptionAnimationPackageId;
        NSString *modularCaptionInAnimationPackageId = self.currentCaption.modularCaptionInAnimationPackageId;
        NSString *modularCaptionOutAnimationPackageId = self.currentCaption.modularCaptionOutAnimationPackageId;
        for (NvCaptionInfoModel *info in captions) {
            if (info.type == Modular) {
                if (self.animationType == NvComAnimationType) {
                    info.animationModel.type = Caption;
                    info.animationModel.captionId = modularCaptionAnimationPackageId;
                    info.animationModel.inputId = nil;
                    info.animationModel.outputId = nil;
                    info.animationModel.captionDuration = self.captionInfo.animationModel.captionDuration;
                } else if (self.animationType == NvInAnimationType) {
                    info.animationModel.type = InOutput;
                    info.animationModel.captionId = nil;
                    info.animationModel.inputId = modularCaptionInAnimationPackageId;
                    info.animationModel.inputDuration = self.captionInfo.animationModel.inputDuration;
                } else {
                    info.animationModel.type = InOutput;
                    info.animationModel.captionId = nil;
                    info.animationModel.outputId = modularCaptionOutAnimationPackageId;
                    info.animationModel.outputDuration = self.captionInfo.animationModel.outputDuration;
                }
            }
        }
        
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                if (nextCaption.isModular) {
                    if (self.animationType == NvComAnimationType) {
                        [nextCaption applyModularCaptionInAnimation:nil];
                        [nextCaption applyModularCaptionOutAnimation:nil];
                        [nextCaption applyModularCaptionAnimation:modularCaptionAnimationPackageId];
                        [nextCaption setModularCaptionAnimationPeroid:self.captionInfo.animationModel.captionDuration];
                    } else if (self.animationType == NvInAnimationType) {
                        [nextCaption applyModularCaptionAnimation:nil];
                        [nextCaption applyModularCaptionInAnimation:modularCaptionInAnimationPackageId];
                        [nextCaption setModularCaptionInAnimationDuration:self.captionInfo.animationModel.inputDuration];
                    } else {
                        [nextCaption applyModularCaptionAnimation:nil];
                        [nextCaption applyModularCaptionOutAnimation:modularCaptionOutAnimationPackageId];
                        [nextCaption setModularCaptionOutAnimationDuration:self.captionInfo.animationModel.outputDuration];
                    }
                }
            }
            nextCaption = [self.videoClip getNextCaption:nextCaption];
        } while (nextCaption);
    }
    
    ///应用所有气泡
    ///Apply all bubbles
    if (self.applyCaptionContextToAllCaption) {
        nextCaption = [self.videoClip getFirstCaption];
        NSString *modularCaptionContextPackageId = self.currentCaption.modularCaptionContextPackageId;
        for (NvCaptionInfoModel *info in captions) {
            if (info.type == Modular) {
                info.contextId = modularCaptionContextPackageId;
            }
        }
        
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                if (nextCaption.isModular) {
                    [nextCaption applyModularCaptionContext:modularCaptionContextPackageId];
                }
            }
            nextCaption = [self.videoClip getNextCaption:nextCaption];
        } while (nextCaption);
    }
    
    [self nvseekTimeline];
}

- (void)setDefaultTextBgRadius {
    NvCaptionInfoModel *currentModel = self.captionInfo;
    CGFloat radius = [self getRadiusWithCaption:self.currentCaption];
    if ([self.uiDelegate respondsToSelector:@selector(bgColorListView)] && [self.uiDelegate.bgColorListView respondsToSelector:@selector(setDefaultTextBgRadius:maxValue:)]) {
        [self.uiDelegate.bgColorListView setDefaultTextBgRadius:currentModel.textBgRadius maxValue:radius];
    }
}

///给试图设置默认数据
///Set default data for the attempt
- (void)setViewDefaultData:(NvsClipCaption *)currentCaption {
    NvCaptionInfoModel *currentModel = self.captionInfo;
    ///设置样式
    ///Set style
    NSString *packageId = currentModel.styleId;
    if ([packageId isEqualToString:@""] || packageId == nil) {
        for (NvCaptionStyleItem *item in self.styleDataSource) {
            item.isSelect = NO;
        }
        NvCaptionStyleItem *item = [self.styleDataSource firstObject];
        item.isSelect = YES;
    } else {
        for (int i = 0; i < self.styleDataSource.count; i++) {
            NvCaptionStyleItem *item = [self.styleDataSource objectAtIndex:i];
            if ([item.packageId isEqualToString:packageId]) {
                item.isSelect = YES;
            } else {
                item.isSelect = NO;
            }
        }
    }
    
    if ([self.uiDelegate respondsToSelector:@selector(styleListView)] && [self.uiDelegate.styleListView respondsToSelector:@selector(renderListWithItems:)]) {
        [self.uiDelegate.styleListView renderListWithItems:self.styleDataSource];
    }
    ///设置颜色
    ///Set color
    NvCaptionInfoModel *colorModel = self.captionInfo;
    
    if (colorModel.isModifyTextColor) {
        [self.uiDelegate.colorListView.dataSource enumerateObjectsUsingBlock:^(NvCaptionColorItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isSelect = NO;
            NSArray *rgb = [obj.colorString componentsSeparatedByString:@","];
            if (rgb.count == 4) {
                if (([rgb[0] floatValue] == colorModel.textColor.r) && ([rgb[1] floatValue] == colorModel.textColor.g) && ([rgb[2] floatValue] == colorModel.textColor.b) ) {
                    obj.isSelect = YES;
                }
            }
        }];
    }
    
    if ([self.uiDelegate respondsToSelector:@selector(colorListView)] && [self.uiDelegate.colorListView respondsToSelector:@selector(setDefaultDataSource:alpha:)]) {
        [self.uiDelegate.colorListView setDefaultDataSource:self.uiDelegate.colorListView.dataSource alpha:[self.currentCaption getTextColor].a];
    }
    
    ///设置背景颜色
    ///Setting background color
    __block BOOL isSelect = NO;
    [self.uiDelegate.bgColorListView.dataSource enumerateObjectsUsingBlock:^(NvCaptionColorItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelect = NO;
        NSArray *rgb = [obj.colorString componentsSeparatedByString:@","];
        if (rgb.count == 4) {
            if (([rgb[0] floatValue] == colorModel.textBgColor.r) && ([rgb[1] floatValue] == colorModel.textBgColor.g) && ([rgb[2] floatValue] == colorModel.textBgColor.b)) {
                obj.isSelect = YES;
                if (colorModel.textBgColor.r == 0 && colorModel.textBgColor.g == 0 && colorModel.textBgColor.b == 0 && colorModel.textBgColor.a == 0) {
                    isSelect = YES;
                }
            }
        }
    }];

    if (isSelect) {
        for (NvCaptionColorItem *item in self.uiDelegate.bgColorListView.dataSource) {
            item.isSelect = NO;
        }
        NvCaptionColorItem *item = self.uiDelegate.bgColorListView.dataSource.firstObject;
        item.isSelect = YES;
    }

    if ([self.uiDelegate respondsToSelector:@selector(bgColorListView)] && [self.uiDelegate.bgColorListView respondsToSelector:@selector(setDefaultDataSource:alpha:)]) {
        [self.uiDelegate.bgColorListView setDefaultDataSource:self.uiDelegate.bgColorListView.dataSource alpha:currentModel.isModifyTextBgColor ? currentModel.textBgColor.a : 1.0];
    }
    
    if ([self.uiDelegate respondsToSelector:@selector(bgColorListView)] && [self.uiDelegate.bgColorListView respondsToSelector:@selector(setDefaultTextBgMargin:maxValue:)]) {
        [self.uiDelegate.bgColorListView setDefaultTextBgMargin:[self.currentCaption getBoundaryPaddingRatio] maxValue:1.0];
    }
    
    CGFloat radius = [self getRadiusWithCaption:self.currentCaption];
    if ([self.uiDelegate respondsToSelector:@selector(bgColorListView)] && [self.uiDelegate.bgColorListView respondsToSelector:@selector(setDefaultTextBgRadius:maxValue:)]) {
        [self.uiDelegate.bgColorListView setDefaultTextBgRadius:currentModel.textBgRadius maxValue:radius];
    }
    
    ///描边
    ///stroke
    NSMutableArray *strokeDataSource = self.uiDelegate.strokeListView.dataSource;
    BOOL outLine = [self.currentCaption getDrawOutline];
    float outLineWidth = [self.currentCaption getOutlineWidth];
    float outLineAlpha = [self.currentCaption getOutlineColor].a;
    if (outLine) {
        [strokeDataSource enumerateObjectsUsingBlock:^(NvCaptionStrokeItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.isSelect = NO;
            NSArray *rgb = [obj.colorString componentsSeparatedByString:@","];
            if (rgb.count == 4) {
                if (([rgb[0] floatValue] == colorModel.outlineColor.r) && ([rgb[1] floatValue] == colorModel.outlineColor.g) && ([rgb[2] floatValue] == colorModel.outlineColor.b)) {
                    obj.isSelect = YES;
                }
            }
        }];
    } else {
        NvCaptionStrokeItem * strokeItem = strokeDataSource.firstObject;
        [strokeDataSource enumerateObjectsUsingBlock:^(NvCaptionStrokeItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            strokeItem.isSelect = NO;
        }];
        strokeItem.isSelect = YES;
    }
    
    [self.uiDelegate.strokeListView setDefaultDataSource:strokeDataSource width:outLineWidth/10.0 alpha:outLineAlpha];

    ///设置字体
    ///Set the font
    NSString *fontFilePath = [self.currentCaption getFontFilePath];
    NSMutableArray *fontDataSource = self.uiDelegate.fontListView.dataSource;
    if (fontFilePath) {
        for (NvCaptionFontItem *item1 in fontDataSource) {
            if ([fontFilePath isEqualToString:item1.packagePath]) {
                item1.selected = YES;
            } else {
                item1.selected = NO;
            }
        }
    } else {
        [fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                obj.selected = YES;
            } else {
                obj.selected = NO;
            }
        }];
    }
    
    [self.uiDelegate.fontListView setDefauleDataSource:fontDataSource];
    [self.uiDelegate.fontListView setDefaultFontBoldButton:[self.currentCaption getBold] italic:[self.currentCaption getItalic] shadow:[self.currentCaption getDrawShadow] underline:[self.currentCaption getUnderline]];
    [self.uiDelegate.spaceView selectCaptionLetterSpace:[self.currentCaption getLetterSpacing]];
    [self.uiDelegate.spaceView selectCaptionLetterSpaceType:self.captionInfo.letterSpaceType];
    [self.uiDelegate.spaceView selectCaptionLineLetterSpace:[self.currentCaption getLineSpacing]];
    ///设置位置
    ///Set position
    [self.uiDelegate.positionListView resetApplyButton];
}

- (CGFloat)getRadiusWithCaption:(NvsClipCaption*) caption {
    NSArray *array = [caption getCaptionBoundingVertices:NvsBoundingType_Text_Frame];
    NSValue *leftTopValue = array[0];
    NSValue *leftBottomValue = array[1];
    NSValue *rightTopValue = array[3];
    CGFloat height = [self distanceWithFirst:[leftTopValue CGPointValue] second:[leftBottomValue CGPointValue]];
    CGFloat width = [self distanceWithFirst:[leftTopValue CGPointValue] second:[rightTopValue CGPointValue]];
    return MIN(height/2, width/2);
}

///获取两点之间距离
///Get the distance between two points
- (CGFloat)distanceWithFirst:(CGPoint)first second:(CGPoint)second {
    CGFloat deltaX = second.x - first.x;
    CGFloat deltaY = second.y - first.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY );
};

- (CGPoint)getCenterWithArray:(NSArray*)array {
    NSValue *leftTopValue = array[0];
    NSValue *rightBottomValue = array[2];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    return CGPointMake((topLeftCorner.x+rightBottomCorner.x)/2, (topLeftCorner.y+rightBottomCorner.y)/2);
}

#pragma mark - 选择颜色 Choose color
- (void)selectColor:(NvCaptionColorItem *)item {
    self.colorItem = item;
    NvCaptionInfoModel *info = self.captionInfo;
    NvsClipCaption *lastCaption = self.currentCaption;
    NvsColor color = [lastCaption getTextColor];
    NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
    if (rgb.count == 4) {
        color.r = [rgb[0] floatValue];
        color.g = [rgb[1] floatValue];
        color.b = [rgb[2] floatValue];
        color.a = [rgb[3] floatValue];;
        info.textColor = color;
        info.isModifyTextColor = YES;
        [lastCaption setTextColor:&color];
    }
    
    [self playCaption:self.currentCaption];
}

- (void)nvseekTimeline {
    if ([self.delegate respondsToSelector:@selector(nvseekTimeline)]) {
        [self.delegate nvseekTimeline];
    }
}

///滑动透明度
///Sliding transparency
- (void)alphaChanged:(float)value {
    NvCaptionInfoModel *info = self.captionInfo;
    NvsColor color = info.textColor;
    color.a = value;
    info.textColor = color;
    info.isModifyTextColor = YES;
    NvsClipCaption *lastCaption = self.currentCaption;
    [lastCaption setTextColor:&color];
    [self nvseekTimeline];
}

- (void)applyColorToAllCaption:(BOOL)applyToAllCaption {
    self.colorApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

#pragma mark - 选择背景颜色 Select background color
- (void)selectBgColor:(NvCaptionColorItem *)item{
    self.colorItem = item;
    NvCaptionInfoModel *info = self.captionInfo;
    info.isModifyTextBgColor = YES;
    NvsClipCaption *lastCaption = self.currentCaption;
    NvsColor color = [lastCaption getBackgroundColor];
    NSArray *rgb = @[];
    if ([item.colorString isEqualToString:@"0"]) {
        rgb = @[@"0",@"0",@"0",@"0"];
    }else{
        rgb = [item.colorString componentsSeparatedByString:@","];
    }
    if (rgb.count == 4) {
        color.r = [rgb[0] floatValue];
        color.g = [rgb[1] floatValue];
        color.b = [rgb[2] floatValue];
        color.a = [rgb[3] floatValue];;
        info.textBgColor = color;
        
        [lastCaption setBackgroundColor:&color];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self playCaption:self.currentCaption];
    });
}

///点击透明度
///Click transparency
- (void)alphaBgChanged:(float)value{
    NvCaptionInfoModel *info = self.captionInfo;
    NvsColor color = info.textBgColor;
    color.a = value;
    info.textBgColor = color;
    info.isModifyTextBgColor = YES;
    NvsClipCaption *lastCaption = self.currentCaption;
    [lastCaption setBackgroundColor:&color];
    [self nvseekTimeline];
}

- (void)bgRadiusChanged:(float)value{
    NvCaptionInfoModel *info = self.captionInfo;
    info.textBgRadius = value;
    info.isModifyTextBgRadius = YES;
    NvsClipCaption *lastCaption = self.currentCaption;
    [lastCaption setBackgroundRadius:value];
    [self nvseekTimeline];
}

- (void)marginBgChanged:(float)value{
    NvCaptionInfoModel *info = self.captionInfo;
    info.boundaryMargin = value;
    
    NvsClipCaption *lastCaption = self.currentCaption;
    [lastCaption setBoundaryPaddingRatio:value];
    [self updateCaptionView];
    [self nvseekTimeline];
}


- (void)applyBgColorToAllCaption:(BOOL)applyToAllCaption{
    self.colorBgApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}
#pragma mark - 选择描边 Select stroke
- (void)selectStroke:(NvCaptionStrokeItem *)item {
    self.strokeItem = item;
    self.captionInfo.isUserDrawOutline = YES;
    NvCaptionInfoModel *info = self.captionInfo;
    if (item.isNone) {
        info.isDrawOutline = NO;
    } else {
        info.isDrawOutline = YES;
        NvsColor color;
        NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
        if (rgb.count == 4) {
            color.r = [rgb[0] floatValue];
            color.g = [rgb[1] floatValue];
            color.b = [rgb[2] floatValue];
            color.a = [rgb[3] floatValue];;
            info.outlineColor = color;
        }
        info.outlineWidth = item.width*10;
    }
    
    NvsClipCaption *lastCaption = self.currentCaption;
    if (item.isNone) {
        [lastCaption setDrawOutline:NO];
    } else {
        NvsColor color = [lastCaption getOutlineColor];
        NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
        if (rgb.count == 4) {
            color.r = [rgb[0] floatValue];
            color.g = [rgb[1] floatValue];
            color.b = [rgb[2] floatValue];
            color.a = [rgb[3] floatValue];;
            info.outlineColor = color;
            [lastCaption setDrawOutline:YES];
            [lastCaption setOutlineColor:&color];
            [lastCaption setOutlineWidth:item.width*10];
        }
    }
    [self playCaption:self.currentCaption];
}

- (void)selectStroke:(NvCaptionStrokeItem *)item withWidth:(CGFloat)width {
    self.captionInfo.isUserDrawOutline = YES;
    NvCaptionInfoModel *info = self.captionInfo;
    info.outlineWidth = width*10;
    
    NvsClipCaption *lastCaption = self.currentCaption;
    [lastCaption setOutlineWidth:width*10];
    
    [self nvseekTimeline];
}

///选择描边的透明度
///Select the opacity of the stroke
- (void)selectStroke:(NvCaptionStrokeItem *)item withAlpha:(CGFloat)alpha {
    self.captionInfo.isUserDrawOutline = YES;
    NvCaptionInfoModel *info = self.captionInfo;
    NvsClipCaption *lastCaption = self.currentCaption;
    NvsColor color1 = [lastCaption getOutlineColor];
    color1.a = alpha;
    info.outlineColor = color1;
    [lastCaption setOutlineColor:&color1];
    
    [self nvseekTimeline];
}

- (void)applyStrokeToAllCaption:(BOOL)applyToAllCaption {
    self.strokeApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

#pragma mark - 字体 font
- (void)applyFontToAllCaption:(BOOL)applyToAllCaption {
    self.fontApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

- (void)selectFont:(NvCaptionFontItem *)item {
    if (item.packageId && !item.packagePath) {
        [self downloadFont:item];
    } else {
        NvCaptionInfoModel *info = self.captionInfo;
        info.fontFilePath = item.packagePath;
        NvsClipCaption *lastCaption = self.currentCaption;
        [lastCaption setFontWithFilePath:item.packagePath];
        
        [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selected = NO;
        }];
        item.selected = YES;
        [self.uiDelegate.fontListView setDefauleDataSource:self.fontDataSource];

        [self playCaption:self.currentCaption];
    }
}

- (void)downloadFont:(NvCaptionFontItem *)item {
    [self.assetManager downloadAsset:item.packageId];
}

- (void)nvFontListView:(NvFontListView *)nvFontListView blodClick:(UIButton *)sender {
    self.isUserBold = YES;
    [self.currentCaption setBold:sender.selected];
    self.captionInfo.isUserBold = YES;
    self.captionInfo.isBold = sender.selected;
    [self nvseekTimeline];
}
- (void)nvFontListView:(NvFontListView *)nvFontListView italicClick:(UIButton *)sender {
    self.isUserItalic = YES;
    [self.currentCaption setItalic:sender.selected];
    self.captionInfo.isUserItalic = YES;
    self.captionInfo.isItalic = sender.selected;
    [self nvseekTimeline];
}

- (void)nvFontListView:(NvFontListView *)nvFontListView underLineClick:(UIButton *)sender {
    self.isUserUnderLine = YES;
    [self.currentCaption setUnderline:sender.selected];
    self.captionInfo.isUserUnderLine = YES;
    self.captionInfo.isUnderLine = sender.selected;
    [self nvseekTimeline];
}

#pragma mark - 选择字幕间距 Select subtitle spacing
- (void)captionSpaceView:(NvCaptionSpaceView *)captionSpaceView didSelectCaptionLetterSpaceType:(float)letterSpace Type:(NvCaptionLetterSpaceType)type {
    CGFloat space = self.timeline.videoRes.imageWidth > self.timeline.videoRes.imageHeight ? self.timeline.videoRes.imageWidth : self.timeline.videoRes.imageHeight;
    if (type == LetterSpaceLess) {
        space = space * 0.005 * -1;
    }else if (type == LetterSpaceStandard){
        space = 0;
    }else if (type == LetterSpaceMore){
        space = space * 0.02;
    }else if (type == LetterSpacelarge){
        space = space * 0.04;
    }else{
        space = 0;
    }
    self.captionInfo.isModifyLetterSpace = YES;
    self.letterSpace = space;
    [self.currentCaption setLetterSpacingType:NvsLetterSpacingTypeAbsolute];
    [self.currentCaption setLetterSpacing:self.letterSpace];
    self.captionInfo.letterSpace = self.letterSpace;
    self.captionInfo.letterSpaceType = type;
    ///更新rect
    ///Update rect
    [self updateCaptionView];
    
    [self nvseekTimeline];
}

///选择字幕行间距
///Select subtitles line spacing
- (void)captionSpaceView:(NvCaptionSpaceView *)captionSpaceView didSelectCaptionLineLetterSpace:(float)letterSpace {
    self.letterLineSpace = letterSpace;
    [self.currentCaption setLineSpacing:letterSpace];
    self.captionInfo.letterLineSpace = letterSpace;

    ///更新rect
    ///Update rect
    [self updateCaptionView];
    [self nvseekTimeline];
}

- (void)updateCaptionView {
    if ([self.delegate respondsToSelector:@selector(updateCaptionView:)]) {
        [self.delegate updateCaptionView:self.currentCaption];
    }
}

///字幕间距应用所有
///Subtitle spacing is all applied
- (void)applyCaptionSpaceToAllCaption:(BOOL)applyToAllCaption {
    self.captionSpaceApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

#pragma mark - 选择位置 Select location
- (void)applyPositionWithType:(NvCaptionTextAlignment)type {
    self.positionType = type;
    
    [self translateCaption:self.currentCaption textAlignmentType:type];
    NvCaptionInfoModel *info = self.captionInfo;
    info.isUserTranslation = YES;
    info.translation = [self.currentCaption getCaptionTranslation];
    
    ///更新rect
    ///Update rect
    [self updateCaptionView];
    
    [self nvseekTimeline];
}

- (void)applyPositionToAllCaption:(BOOL)applyToAllCaption {
    self.positionApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

-(void)translateCaption:(NvsClipCaption*)caption textAlignmentType:(NvCaptionTextAlignment)type{
    NSArray *list = [caption getCaptionBoundingVertices:NvsBoundingType_Text];
    switch (type) {
        case NvCaptionTextAlignmentLeft:{
            CGPoint minx = [self getLeftMinPointFrom:list];
            float xOffset = -(self.timeline.videoRes.imageWidth/2 + minx.x);
            [caption translateCaption:CGPointMake(xOffset, 0)];
        }
            break;
        case NvCaptionTextAlignmentRight:{
            CGPoint maxP = [self getRightMaxPointFrom:list];
            float xOffset = self.timeline.videoRes.imageWidth/2 - maxP.x;;
            [caption translateCaption:CGPointMake(xOffset, 0)];
        }
            break;
        case NvCaptionTextAlignmentUp:{
            CGPoint miny = [self getTopMinPointFrom:list];
            CGPoint maxy = [self getBottomMaxPointFrom:list];
            float y_dis = maxy.y - miny.y;
            float yOffset = self.timeline.videoRes.imageHeight/2 - miny.y - y_dis;
            [caption translateCaption:CGPointMake(0, yOffset)];
        }
            break;
        case NvCaptionTextAlignmentDown:{
            CGPoint miny = [self getTopMinPointFrom:list];
            CGPoint maxy = [self getBottomMaxPointFrom:list];
            float y_dis = maxy.y - miny.y;
            float yOffset = -(self.timeline.videoRes.imageHeight/2 + maxy.y - y_dis);
            [caption translateCaption:CGPointMake(0, yOffset)];
        }
            break;
        case NvCaptionTextAlignmentVertical:{
            CGPoint miny = [self getTopMinPointFrom:list];
            CGPoint maxy = [self getBottomMaxPointFrom:list];
            float yOffset = -((maxy.y - miny.y)/2 + miny.y);
            [caption translateCaption:CGPointMake(0, yOffset)];
        }
            break;
        case NvCaptionTextAlignmentHorizontal:{
            CGPoint minx = [self getLeftMinPointFrom:list];
            CGPoint maxx = [self getRightMaxPointFrom:list];
            float xOffset = -((maxx.x - minx.x)/2 + minx.x);
            [caption translateCaption:CGPointMake(xOffset, 0)];
        }
            break;
            
        default:
            break;
    }
}

- (CGPoint)getLeftMinPointFrom:(NSArray *)array {
    float leftx = [[array firstObject] CGPointValue].x;
    float lefty = [[array firstObject] CGPointValue].y;
    for (NSValue *v in array) {
        CGPoint p = [v CGPointValue];
        if (leftx > p.x) {
            leftx = p.x;
            lefty = p.y;
        }
    }
    return CGPointMake(leftx, lefty);
}

- (CGPoint)getRightMaxPointFrom:(NSArray *)array {
    float rightx = [[array firstObject] CGPointValue].x;
    float righty = [[array firstObject] CGPointValue].y;
    for (NSValue *v in array) {
        CGPoint p = [v CGPointValue];
        if (p.x > rightx) {
            rightx = p.x;
            righty = p.y;
        }
    }
    return CGPointMake(rightx, righty);
}

- (CGPoint)getTopMinPointFrom:(NSArray *)array {
    float leftx = [[array firstObject] CGPointValue].x;
    float lefty = [[array firstObject] CGPointValue].y;
    for (NSValue *v in array) {
        CGPoint p = [v CGPointValue];
        if (lefty > p.y) {
            lefty = p.y;
            leftx = p.x;
        }
    }
    return CGPointMake(leftx, lefty);
}

- (CGPoint)getBottomMaxPointFrom:(NSArray *)array {
    float rightx = [[array firstObject] CGPointValue].x;
    float righty = [[array firstObject] CGPointValue].y;
    for (NSValue *v in array) {
        CGPoint p = [v CGPointValue];
        if (p.y > righty) {
            righty = p.y;
            rightx = p.x;
        }
    }
    return CGPointMake(rightx, righty);
}
#pragma mark - 选择花字 Select character
- (void)applyModularCaptionRenderer:(NSString *)rendererId {
    [self.currentCaption applyModularCaptionRenderer:rendererId];
    self.captionInfo.renderId = rendererId;
}
#pragma mark - 选择气泡 Selective bubble
- (void)applyModularCaptionContext:(NSString *)contextId {
    [self.currentCaption applyModularCaptionContext:contextId];
    self.captionInfo.contextId = contextId;
}
#pragma mark - 选择入动画 Select in animation
- (void)applyModularCaptionInAnimation:(NSString *)inAnimationId {
    if (inAnimationId && ![inAnimationId isEqualToString:@""]) {
        [self.currentCaption applyModularCaptionAnimation:nil];
    }
    [self.currentCaption applyModularCaptionInAnimation:inAnimationId];
    self.captionInfo.animationModel.inputId = inAnimationId;
    self.captionInfo.animationModel.captionId = nil;
    self.captionInfo.animationModel.type = InOutput;
}
- (void)setModularCaptionInAnimationDuration:(int)duration {
    [self.currentCaption setModularCaptionInAnimationDuration:duration];
    self.captionInfo.animationModel.inputDuration = self.currentCaption.getModularCaptionInAnimationDuration;
}
#pragma mark - 出动画 outnimation
- (void)applyModularCaptionOutAnimation:(NSString *)outAnimationId {
    [self.currentCaption applyModularCaptionAnimation:nil];
    [self.currentCaption applyModularCaptionOutAnimation:outAnimationId];
    self.captionInfo.animationModel.outputId = outAnimationId;
    self.captionInfo.animationModel.captionId = nil;
    self.captionInfo.animationModel.type = InOutput;
}
- (void)setModularCaptionOutAnimationDuration:(int)duration {
    [self.currentCaption setModularCaptionOutAnimationDuration:duration];
    self.captionInfo.animationModel.outputDuration = self.currentCaption.getModularCaptionOutAnimationDuration;
}
#pragma mark - 组合动画 Composite animation
- (void)applyModularCaptionAnimation:(NSString *)captionAnimationId {
    [self.currentCaption applyModularCaptionInAnimation:nil];
    [self.currentCaption applyModularCaptionOutAnimation:nil];
    [self.currentCaption applyModularCaptionAnimation:captionAnimationId];
    self.captionInfo.animationModel.captionId = captionAnimationId;
    self.captionInfo.animationModel.type = Caption;
    self.captionInfo.animationModel.inputId = nil;
    self.captionInfo.animationModel.outputId = nil;
}
- (void)setModularCaptionAnimationDuration:(int)duration {
    [self.currentCaption setModularCaptionAnimationPeroid:duration];
    self.captionInfo.animationModel.captionDuration = self.currentCaption.getModularCaptionAnimationPeroid;
}

- (void)setModularCaptionAnimationValue:(CGFloat)value {
    int duration = (int)(value*(self.currentCaption.outPoint - self.currentCaption.inPoint)/1000);
    [self setModularCaptionAnimationDuration:duration];
}

#pragma mark NvAssetManagerDelegate
- (void)onRemoteAssetsChanged:(BOOL)hasNext {
    
    ///查询字体信息
    ///Querying Font Information
    [self.assetManager searchLocalAssets:ASSET_FONT];
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"fontPackage" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_FONT bundlePath:fontPath];
    
    NSArray *useArray = [self.assetManager getUsableAssets:ASSET_FONT aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    NSArray *array = [self.assetManager getRemoteAssets:ASSET_FONT aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    [self.fontDataSource removeAllObjects];
    NvCaptionFontItem *item = [NvCaptionFontItem new];
    item.selected = NO;
    item.showName = NO;
    item.coverName = @"NvsFilterNone";
    item.packagePath = nil;
    item.packageNetPath = nil;
    item.displayName = NvLocalString(@"None", @"无");
    item.state = Finish;
    [self.fontDataSource addObject:item];
    for (NvAsset *asset in useArray) {
        NvCaptionFontItem *item = [NvCaptionFontItem new];
        item.selected = NO;
        item.showName = NO;
        item.coverDefault = @"Nvfont";
        item.coverName = asset.coverUrl;
        item.packageId = asset.uuid;
        item.packagePath = asset.bundledLocalDirPath ? asset.bundledLocalDirPath : asset.localDirPath;
        item.packageNetPath = asset.packageUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.displayName = asset.displayNamezhCN;
        }else{
            item.displayName = asset.displayName;
        }
        item.state = Finish;
        [self.fontDataSource addObject:item];
    }
    
    for (NvAsset *asset in array) {
        NvCaptionFontItem *item = [NvCaptionFontItem new];
        item.selected = NO;
        item.showName = NO;
        item.coverDefault = @"Nvfont";
        item.coverName = asset.coverUrl;
        item.packageId = asset.uuid;
        item.packagePath = asset.bundledLocalDirPath;
        item.packageNetPath = asset.packageUrl;
        if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
            item.displayName = asset.displayNamezhCN;
        }else{
            item.displayName = asset.displayName;
        }
        __block BOOL isHavaAssetInLocal = NO;
        [useArray enumerateObjectsUsingBlock:^(NvAsset *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.uuid isEqualToString:asset.uuid]) {
                item.packagePath = asset.localDirPath;
                item.state = Finish;
                isHavaAssetInLocal = YES;
            }
        }];
        if (!isHavaAssetInLocal) {
            [self.fontDataSource addObject:item];
        }
    }
    ///设置字体
    ///Set the font
    NSString *fontFilePath = [self.currentCaption getFontFilePath];
    if (fontFilePath && ![fontFilePath isEqualToString:@""]) {
        for (NvCaptionFontItem *item1 in self.fontDataSource) {
            if ([fontFilePath isEqualToString:item1.packagePath]) {
                item1.selected = YES;
            } else {
                item1.selected = NO;
            }
        }
    } else {
        [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                obj.selected = YES;
            } else {
                obj.selected = NO;
            }
        }];
    }
    if ([self.uiDelegate respondsToSelector:@selector(fontListView)] && [self.uiDelegate.fontListView respondsToSelector:@selector(setDefauleDataSource:)]) {
        [self.uiDelegate.fontListView setDefauleDataSource:self.fontDataSource];
    }
}

- (void)onGetRemoteAssetsFailed {
    [NvToast showErrorWithMessage:NvLocalString(@"CheckNetwork", @"请检查网络是否连接")];
}

- (void)onDownloadAssetProgress:(NSString *)uuid
                       progress:(int)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.uiDelegate.fontListView updateProgress:progress/100.0 uuid:uuid];
    });
}

- (void)onDonwloadAssetFailed:(NSString *)uuid {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NvToast showErrorWithMessage:NvLocalString(@"downloadFaild", @"下载失败！")];
        [self.uiDelegate.fontListView downloadFailduuid:uuid];
    });
}

- (void)onDonwloadAssetSuccess:(NSString *)uuid {
    [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.packageId isEqualToString:uuid]) {
            obj.state = Finish;
            obj.packagePath = [NSString stringWithFormat:@"%@%@/%@",NSHomeDirectory(),NV_ASSET_DOWNLOAD_PATH_FONT,obj.packageNetPath.lastPathComponent];
        }
    }];
    [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.lastSelect && [obj.packageId isEqualToString:uuid]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self applyDownloadFont:obj];
            });
        }
    }];
    [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.lastSelect) {
            obj.selected = YES;
        } else {
            obj.selected = NO;
        }
    }];
    [self.uiDelegate.fontListView renderListWithItems:self.fontDataSource];
}

- (void)applyDownloadFont:(NvCaptionFontItem *)item {
    NvCaptionInfoModel *info = self.captionInfo;
    info.fontFilePath = item.packagePath;
    
    NvsClipCaption *lastCaption = self.currentCaption;
    [lastCaption setFontWithFilePath:item.packagePath];
    [self nvseekTimeline];
}

@end
