//
//  NvModularStyleVM.m
//  SDKDemo
//
//  Created by 刘东旭 on 2020/7/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvModularStyleVM.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvAsset.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvCaptionAnimationItem.h"
#import "NvCaptionRendererItem.h"
#import "NvCaptionContextItem.h"
#import "NvKeyFrameManager.h"
#import "NvsCaptionSpan.h"

@interface NvModularStyleVM ()<NvAssetManagerDelegate,NvFontRatioViewDelegate>

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
@property (nonatomic, assign) BOOL fontRatioApplyAll;
@property (nonatomic, assign) BOOL shadowColorApplyAll;
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
@property (nonatomic, assign) NSRange selectedRange;
@end

@implementation NvModularStyleVM

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
    ///查询字体数据
    ///Query font data
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

- (void)searchStyle {
    [self.assetManager searchLocalAssets:ASSET_CAPTION_STYLE];
    ///普通字幕样式
    ///Normal captioning style
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"caption" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_CAPTION_STYLE bundlePath:itemPath];
    ///花字字幕样式
    ///render captioning style
    NSString *newItemPath = [[NSBundle mainBundle] pathForResource:@"newCaptionStyle" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_CAPTION_STYLE bundlePath:newItemPath];
    [self getStyleDefaultData];
    ///给UI设置默认数据
    ///Set the default data for the UI
    [self setViewDefaultData:self.currentCaption];
}

- (void)searchCaptionRenderer {
    [self.assetManager searchLocalAssets:ASSET_CAPTION_RENDERER];
    ///普通字幕样式
    ///Normal captioning style
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
    ///设置花字
    ///Set render captioning
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
    ///Normal captioning style
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
    ///Normal Caption style
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
    ///Normal Caption style
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
    ///Set into animation
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
    ///普通字幕样式
    ///Normal Caption style
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
    ///set out animate
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

- (NSRange)selectedPartialText {
    NSRange selectedRange = [self.delegate selectedPartialText];
    self.selectedRange = selectedRange;
    return selectedRange;
}

#pragma mark - 样式点击确定
///Style hit OK
- (void)okClick {
    [self.streamingContext stop];
    [self applyToAllCaptions];
    if ([self.delegate respondsToSelector:@selector(styleOkClick)]) {
        [self.delegate styleOkClick];
    }
}

- (void)applyToAllCaptions {
    NvTimelineData *data = [NvTimelineData sharedInstance];
    NSMutableArray *captions = data.captionDataArray;
    captions = self.captionInfos;
    NvsTimelineCaption *nextCaption = [self.timeline getFirstCaption];
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
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
    }
    ///应用颜色
    ///Applied color
    if (self.colorApplyAll) {
        nextCaption = [self.timeline getFirstCaption];
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
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
        
    }
    ///应用背景所有
    ///Application background owned
    if (self.colorBgApplyAll) {
        nextCaption = [self.timeline getFirstCaption];
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
            }
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
    }
    
    ///应用描边
    ///Apply stroke
    if (self.strokeApplyAll) {
        nextCaption = [self.timeline getFirstCaption];
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
        
        NvsTimelineCaption *nextCaption = [self.timeline getFirstCaption];
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
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
    }
    
    ///应用阴影
    ///Applied shadow
    if (self.shadowColorApplyAll) {
        nextCaption = [self.timeline getFirstCaption];
        NvsColor currentColor = [self.currentCaption getShadowColor];
        for (NvCaptionInfoModel *info in captions) {
            info.shadowColor = currentColor;
            info.isUserDrawShadow = YES;
            info.isDrawShadow = YES;
        }
        
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                NvsColor color = [nextCaption getShadowColor];
                color.r = currentColor.r;
                color.g = currentColor.g;
                color.b = currentColor.b;
                color.a = currentColor.a;
                [nextCaption setDrawShadow:YES];
                CGPoint originOffset = CGPointMake(10, -10);
                [nextCaption setShadowOffset:originOffset];
                [nextCaption setShadowColor:&color];
                
            }
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
        
    }
    
    ///应用字体
    ///Application font
    if (self.fontApplyAll) {
        nextCaption = [self.timeline getFirstCaption];
        for (NvCaptionInfoModel *info in captions) {
            info.fontFilePath = [self.currentCaption getFontFilePath];
            info.isUserBold = YES;
            info.isUserItalic = YES;
            info.isUserUnderLine = YES;
            info.isUserDrawShadow = YES;
        }
        NvsTimelineCaption *nextCaption = [self.timeline getFirstCaption];
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
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
    }
    ///应用字间距
    ///Applied word spacing
    if (self.captionSpaceApplyAll) {
        nextCaption = [self.timeline getFirstCaption];
        for (NvCaptionInfoModel *info in captions) {
            info.letterSpace = [self.currentCaption getLetterSpacing];
            info.letterLineSpace = [self.currentCaption getLineSpacing];
        }
        NvsTimelineCaption *nextCaption = [self.timeline getFirstCaption];
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                [nextCaption setLetterSpacingType:NvsLetterSpacingTypeAbsolute];
                [nextCaption setLetterSpacing:[self.currentCaption getLetterSpacing]];
                [nextCaption setLineSpacing:[self.currentCaption getLineSpacing]];
            }
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
    }
    ///应用位置
    ///Application location
    if (self.positionApplyAll) {
        nextCaption = [self.timeline getFirstCaption];
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
            
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
        
    }
    
    ///应用字号
    ///Application number
    if (self.fontRatioApplyAll) {
        nextCaption = [self.timeline getFirstCaption];
        float fontSize = [self.currentCaption getFontSize];
        for (NvCaptionInfoModel *info in captions) {
            info.fontSize = fontSize;
        }
        
        do {
            if (nextCaption.category == NvsThemeCategory && nextCaption.roleInTheme != NvsRoleInThemeGeneral) {
                
            }else{
                [nextCaption setFontSize:fontSize];
            }
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
    }
    
    ///应用所有花字
    ///Apply all Modular Caption
    if (self.applyCaptionRendererToAllCaption) {
        nextCaption = [self.timeline getFirstCaption];
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
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
    }
    
    ///应用所有动画
    ///Apply all animations
    if (self.applyToAllCaptionAnimation || self.applyToAllCaptionInAnimation || self.applyToAllCaptionOutAnimation) {
        nextCaption = [self.timeline getFirstCaption];
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
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
    }
    
    ///应用所有气泡
    ///Apply all bubbles
    if (self.applyCaptionContextToAllCaption) {
        nextCaption = [self.timeline getFirstCaption];
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
            nextCaption = [self.timeline getNextCaption:nextCaption];
        } while (nextCaption);
    }
    [self nvseekTimeline];
}

#pragma mark - 更多样式
///More type
- (void)moreStyleClick {
    if ([self.delegate respondsToSelector:@selector(moreStyleClick)]) {
        [self.delegate moreStyleClick];
    }
}
#pragma mark - 应用所有样式
///Apply all styles
- (void)applyStyleToAllCaption:(BOOL)applyToAllCaption {
    self.styleApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

- (void)playCaption:(NvsTimelineCaption *)currentCaption animationType:(NvAnimationType)type animationDuration:(int64_t)duration {
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

- (void)playCaption:(NvsTimelineCaption *)currentCaption {
    if ([self.delegate respondsToSelector:@selector(playTimeline:end:)]) {
        [self.delegate playTimeline:currentCaption.inPoint end:currentCaption.outPoint];
    }
}
#pragma mark - 应用样式
///Application style
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
        NvsTimelineCaption *nextCaption = self.currentCaption;
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
}
#pragma mark - 应用所有花字
///Apply all Modular Captions
- (void)applyCaptionRendererToAllCaption:(BOOL)applyToAllCaption {
    self.applyCaptionRendererToAllCaption = applyToAllCaption;
    [self applyToAllCaptions];
}
#pragma mark - 应用花字
///Apply Modular Captions
- (void)selectCaptionRenderer:(NvCaptionRendererItem *)item {
    [self applyModularCaptionRenderer:item.packageId];
    [self playCaption:self.currentCaption];
}
#pragma mark - 点击更多花字
///Click More Modular Captions
- (void)moreCaptionRendererClick {
    if ([self.delegate respondsToSelector:@selector(moreRendererClick)]) {
        [self.delegate moreRendererClick];
    }
}
#pragma mark - 应用所有气泡
///Apply all bubbles
- (void)applyCaptionContextToAllCaption:(BOOL)applyToAllCaption {
    self.applyCaptionContextToAllCaption = applyToAllCaption;
    [self applyToAllCaptions];
}
#pragma mark - 应用气泡
///Application bubble
- (void)selectCaptionContext:(NvCaptionContextItem *)item {
    [self applyModularCaptionContext:item.packageId];
    [self playCaption:self.currentCaption];
}
#pragma mark - 更多气泡
///More bubbles
- (void)moreCaptionContextClick {
    if ([self.delegate respondsToSelector:@selector(moreContextClick)]) {
        [self.delegate moreContextClick];
    }
}
#pragma mark - 应用动画
///Application animation
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
            if (duration <= 0){
                [self.uiDelegate selectAnimation:item type:type inValue:0 outValue:0];
            }else{
                [self.uiDelegate selectAnimation:item type:type inValue:1.0 * self.captionInfo.animationModel.inputDuration / duration outValue:(1 - 1.0 * self.captionInfo.animationModel.outputDuration / duration)];
            }
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
            if (duration <= 0){
                [self.uiDelegate selectAnimation:item type:type inValue:0 outValue:0];
            }else{
                [self.uiDelegate selectAnimation:item type:type inValue:1.0 * self.captionInfo.animationModel.inputDuration / duration outValue:(1 - 1.0 * self.captionInfo.animationModel.outputDuration / duration)];
            }
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
            if (duration <= 0){
                [self.uiDelegate selectAnimation:item type:type inValue:0 outValue:0];
            }else{
                [self.uiDelegate selectAnimation:item type:type inValue:1.0 * self.captionInfo.animationModel.captionDuration / duration outValue:1.0 * self.captionInfo.animationModel.captionDuration / duration];
            }
        }
    }
}

- (void)changeAnimationType:(NvAnimationType)type data:(NvCaptionAnimationItem *)item {
    if (self.uiDelegate && [self.uiDelegate respondsToSelector:@selector(changeAnimation:data:)]) {
        [self.uiDelegate changeAnimation:type data:item];
    }
}
#pragma mark - 应用所有动画
///Apply all animations
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
#pragma mark - 点击更多动画
///Click more animation
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

- (void)setDefaultTextBgRadius {
    NvCaptionInfoModel *currentModel = self.captionInfo;
    CGFloat radius = [self getRadiusWithCaption:self.currentCaption];
    if ([self.uiDelegate respondsToSelector:@selector(bgColorListView)] && [self.uiDelegate.bgColorListView respondsToSelector:@selector(setDefaultTextBgRadius:maxValue:)]) {
        [self.uiDelegate.bgColorListView setDefaultTextBgRadius:currentModel.textBgRadius maxValue:radius];
    }
}

///给试图设置默认数据
///Set default data for the attempt
- (void)setViewDefaultData:(NvsTimelineCaption *)currentCaption {
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
    NSNumber *number = [[NSUserDefaults standardUserDefaults] valueForKey:@"defaultFontSize"];
    if (number && currentModel.fontSize && currentModel.fontSize != -1 ) {
        if ([self.uiDelegate.fontRatioView respondsToSelector:@selector(setDefaultFontRatio:)]) {
            float fontRatio = [number floatValue];
            [self.uiDelegate.fontRatioView setDefaultFontRatio:currentModel.fontSize/fontRatio];
        }
    }
    [self checkIsFrameCaption];
    
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
        float alpha = self.currentCaption ? [self.currentCaption getTextColor].a : 1.f;
        [self.uiDelegate.colorListView setDefaultDataSource:self.uiDelegate.colorListView.dataSource alpha:alpha];
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
    float outLineWidth = self.currentCaption ? [self.currentCaption getOutlineWidth] : 5.f;
    float outLineAlpha = self.currentCaption ? [self.currentCaption getOutlineColor].a : 1.f;
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
    
    ///阴影
    ///shadow
    NSMutableArray *shadowArray = [NSMutableArray array];
    NvsColor shadowColor =  [self.currentCaption getShadowColor];
    BOOL isShadow = [self.currentCaption getDrawShadow];
    [[NvUtils rgbBgColors] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NvCaptionColorItem *item = [NvCaptionColorItem new];
        item.isSelect = NO;
        item.colorString = obj;
        NSArray *rgb = [obj componentsSeparatedByString:@","];
        if (rgb.count == 4 && isShadow) {
            if (([rgb[0] floatValue] == shadowColor.r) && ([rgb[1] floatValue] == shadowColor.g) && ([rgb[2] floatValue] == shadowColor.b)) {
                item.isSelect = YES;
            }
        }
        [shadowArray addObject:item];
    }];
    
    [self.uiDelegate.shadowListView setDefaultDataSource:shadowArray alpha:shadowColor.a];
    
    [self.uiDelegate.fontListView setDefauleDataSource:fontDataSource];
    [self.uiDelegate.fontListView setDefaultFontBoldButton:[self.currentCaption getBold] italic:[self.currentCaption getItalic] shadow:[self.currentCaption getDrawShadow] underline:[self.currentCaption getUnderline]];
    [self.uiDelegate.spaceView selectCaptionLetterSpace:[self.currentCaption getLetterSpacing]];
    [self.uiDelegate.spaceView selectCaptionLetterSpaceType:self.captionInfo.letterSpaceType];
    [self.uiDelegate.spaceView selectCaptionLineLetterSpace:[self.currentCaption getLineSpacing]];
    ///设置位置
    ///Set position
    [self.uiDelegate.positionListView resetApplyButton];
}

- (void)checkIsFrameCaption {
    BOOL isFrameCaption = self.currentCaption.isFrameCaption;
    [self selectedPartialText];
    BOOL enable = NO;
    if ((isFrameCaption && self.selectedRange.length > 0) || !isFrameCaption) {
        enable = YES;
    }
    [self.uiDelegate.fontRatioView enableFontRatio:enable];
}

- (CGFloat)getRadiusWithCaption:(NvsTimelineCaption*) caption {
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

#pragma mark - 选择颜色
///Choose color
- (void)selectColor:(NvCaptionColorItem *)item {
    self.colorItem = item;
    NvCaptionInfoModel *info = self.captionInfo;
    NvsTimelineCaption *lastCaption = self.currentCaption;
    NvsColor color = [lastCaption getTextColor];
    NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
    if (rgb.count == 4) {
        [self selectedPartialText];
        if (self.selectedRange.length > 0) {
            [self setTextSpanList:NVS_SPAN_TYPE_COLOR value:item.colorString];
        }else{
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_COLOR];
            color.r = [rgb[0] floatValue];
            color.g = [rgb[1] floatValue];
            color.b = [rgb[2] floatValue];
            color.a = [rgb[3] floatValue];;
            info.textColor = color;
            info.isModifyTextColor = YES;
            [lastCaption setTextColor:&color];
        }
    }
    
    [self playCaption:self.currentCaption];
}

- (void)nvseekTimeline {
    if ([self.delegate respondsToSelector:@selector(nvseekTimeline)]) {
        [self.delegate nvseekTimeline];
    }
    if ([self.delegate respondsToSelector:@selector(updateCaptionRect)]) {
        [self.delegate updateCaptionRect];
    }
}

///滑动填充透明度
///Sliding fill transparency
- (void)alphaChanged:(float)value {
    NvCaptionInfoModel *info = self.captionInfo;
    NvsColor color = info.textColor;
    color.a = value;
    NvsTimelineCaption *lastCaption = self.currentCaption;
    [self selectedPartialText];
    if (self.selectedRange.length > 0) {
        [self setTextSpanList:NVS_SPAN_TYPE_BODY_OPACITY value:[NSNumber numberWithFloat:color.a]];
    }else{
        [self selectNoneForTextSpanList:NVS_SPAN_TYPE_BODY_OPACITY];
        info.textColor = color;
        info.isModifyTextColor = YES;
        [lastCaption setTextColor:&color];
    }
    
    [self nvseekTimeline];
}

- (void)applyColorToAllCaption:(BOOL)applyToAllCaption {
    self.colorApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

#pragma mark - 选择背景颜色
///Select background color
- (void)selectBgColor:(NvCaptionColorItem *)item{
    self.colorItem = item;
    NvCaptionInfoModel *info = self.captionInfo;
    info.isModifyTextBgColor = YES;
    NvsTimelineCaption *lastCaption = self.currentCaption;
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
    NvsTimelineCaption *lastCaption = self.currentCaption;
    [lastCaption setBackgroundColor:&color];
    [self nvseekTimeline];
}

- (void)bgRadiusChanged:(float)value{
    NvCaptionInfoModel *info = self.captionInfo;
    info.textBgRadius = value;
    info.isModifyTextBgRadius = YES;
    NvsTimelineCaption *lastCaption = self.currentCaption;
    [lastCaption setBackgroundRadius:value];
    
    [self nvseekTimeline];
}

- (void)marginBgChanged:(float)value{
    NvCaptionInfoModel *info = self.captionInfo;
    info.boundaryMargin = value;
    
    NvsTimelineCaption *lastCaption = self.currentCaption;
    [lastCaption setBoundaryPaddingRatio:value];
    [self setDefaultTextBgRadius];
    [self updateCaptionView];
    [self nvseekTimeline];
}

- (void)applyBgColorToAllCaption:(BOOL)applyToAllCaption{
    self.colorBgApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

#pragma mark - 选择阴影
///Selective shading
- (void)applyShadowColorToAllCaption:(BOOL)applyToAllCaption {
    self.shadowColorApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

- (void)selectShadowColor:(NvCaptionColorItem *_Nullable)item {
    NvCaptionInfoModel *info = self.captionInfo;
    NvsTimelineCaption *lastCaption = self.currentCaption;
    NvsColor color = [lastCaption getTextColor];
    NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
    if (rgb.count == 4) {
        [self selectedPartialText];
        color.r = [rgb[0] floatValue];
        color.g = [rgb[1] floatValue];
        color.b = [rgb[2] floatValue];
        color.a = [rgb[3] floatValue];
    
        info.shadowColor = color;
        info.isDrawShadow = YES;
        info.isUserDrawShadow = YES;
        [self.currentCaption setDrawShadow:YES];
        CGPoint originOffset = CGPointMake(10, -10);
        [self.currentCaption setShadowOffset:originOffset];
        [lastCaption setShadowColor:&color];
    }else{
        //delete the shadow effct
        info.isDrawShadow = NO;
        info.isUserDrawShadow = NO;
        [self.currentCaption setDrawShadow:NO];
        [self.currentCaption setShadowOffset:CGPointZero];

    }
    [self nvseekTimeline];
}

- (void)alphaShadowChanged:(float)value {
    NvCaptionInfoModel *info = self.captionInfo;
    NvsColor color = info.shadowColor;
    color.a = value;
    NvsTimelineCaption *lastCaption = self.currentCaption;
    [self selectedPartialText];
    info.shadowColor = color;
    info.isDrawShadow = YES;
    info.isUserDrawShadow = YES;
    [self.currentCaption setDrawShadow:YES];
    [lastCaption setShadowColor:&color];
    CGPoint originOffset = CGPointMake(10, -10);
    [self.currentCaption setShadowOffset:originOffset];
    [self nvseekTimeline];
}

#pragma mark - 选择描边
///Select stroke
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
    
    NvsTimelineCaption *lastCaption = self.currentCaption;
    [self selectedPartialText];
    if (item.isNone) {
        if (self.selectedRange.length > 0) {
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_OUTLINE_WIDTH];
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_OUTLINE_COLOR];
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_NORMAL_TEXT];
        }else{
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_OUTLINE_WIDTH];
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_OUTLINE_COLOR];
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_NORMAL_TEXT];
            [lastCaption setDrawOutline:NO];
        }
        
    } else {
        NvsColor color = [lastCaption getOutlineColor];
        NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
        if (rgb.count == 4) {
            color.r = [rgb[0] floatValue];
            color.g = [rgb[1] floatValue];
            color.b = [rgb[2] floatValue];
            color.a = [rgb[3] floatValue];;
            info.outlineColor = color;
            if (self.selectedRange.length > 0) {
                [self setTextSpanList:NVS_SPAN_TYPE_NORMAL_TEXT value:[NSNumber numberWithFloat:item.width*10]];
                [self setTextSpanList:NVS_SPAN_TYPE_OUTLINE_COLOR value:item.colorString];
                [self setTextSpanList:NVS_SPAN_TYPE_OUTLINE_WIDTH value:[NSNumber numberWithFloat:item.width*10]];
            }else{
                [self selectNoneForTextSpanList:NVS_SPAN_TYPE_OUTLINE_WIDTH];
                [self selectNoneForTextSpanList:NVS_SPAN_TYPE_OUTLINE_COLOR];
                [self selectNoneForTextSpanList:NVS_SPAN_TYPE_NORMAL_TEXT];
                [lastCaption setDrawOutline:YES];
                [lastCaption setOutlineColor:&color];
                [lastCaption setOutlineWidth:item.width*10];
            }

        }
    }
    [self playCaption:self.currentCaption];
}

- (void)selectStroke:(NvCaptionStrokeItem *)item withWidth:(CGFloat)width {
    self.captionInfo.isUserDrawOutline = YES;
    NvCaptionInfoModel *info = self.captionInfo;
    info.outlineWidth = width*10;
    
    NvsTimelineCaption *lastCaption = self.currentCaption;
    [self selectedPartialText];
    if (self.selectedRange.length > 0) {
        [self setTextSpanList:NVS_SPAN_TYPE_OUTLINE_WIDTH value:[NSNumber numberWithFloat:width*10]];
    }else{
        [self selectNoneForTextSpanList:NVS_SPAN_TYPE_OUTLINE_WIDTH];
        [self selectNoneForTextSpanList:NVS_SPAN_TYPE_OUTLINE_COLOR];
        [self selectNoneForTextSpanList:NVS_SPAN_TYPE_NORMAL_TEXT];
        [lastCaption setOutlineWidth:width*10];
    }
    
    
    [self nvseekTimeline];
}

///选择描边的透明度
///Select the opacity of the stroke
- (void)selectStroke:(NvCaptionStrokeItem *)item withAlpha:(CGFloat)alpha {
    [self selectedPartialText];
    if (self.selectedRange.length > 0) {
        [self setTextSpanList:NVS_SPAN_TYPE_OUTLINE_OPACITY value:[NSNumber numberWithFloat:alpha]];
    }else{
        [self selectNoneForTextSpanList:NVS_SPAN_TYPE_OUTLINE_OPACITY];
        self.captionInfo.isUserDrawOutline = YES;
        NvCaptionInfoModel *info = self.captionInfo;
        NvsTimelineCaption *lastCaption = self.currentCaption;
        NvsColor color1 = [lastCaption getOutlineColor];
        color1.a = alpha;
        info.outlineColor = color1;
        [lastCaption setOutlineColor:&color1];
    }
    
    
    [self nvseekTimeline];
}

- (void)applyStrokeToAllCaption:(BOOL)applyToAllCaption {
    self.strokeApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

#pragma mark - 字体
///font
- (void)applyFontToAllCaption:(BOOL)applyToAllCaption {
    self.fontApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

- (void)selectFont:(NvCaptionFontItem *)item {
    if (item.packageId && !item.packagePath) {
        [self downloadFont:item];
    } else {
        NvCaptionInfoModel *info = self.captionInfo;
        NvsTimelineCaption *lastCaption = self.currentCaption;
        [self selectedPartialText];
        if (self.selectedRange.length > 0) {
            NSString *fontFamily = [self.streamingContext registerFontByFilePath:item.packagePath];
            if (fontFamily.length > 0) {
                [self setTextSpanList:NVS_SPAN_TYPE_FONT_FAMILY value:fontFamily];
            }else {
                [self selectNoneForTextSpanList:NVS_SPAN_TYPE_FONT_FAMILY];
            }
            
        }else{
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_FONT_FAMILY];
            info.fontFilePath = item.packagePath;
            [lastCaption setFontWithFilePath:item.packagePath];
        }
        
        
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
    [self selectedPartialText];
    if (self.selectedRange.length > 0) {
        [self setTextSpanList:NVS_SPAN_TYPE_ITALIC value:[NSNumber numberWithBool:sender.selected]];
    }else{
        [self selectNoneForTextSpanList:NVS_SPAN_TYPE_ITALIC];
        [self.currentCaption setItalic:sender.selected];
        self.captionInfo.isUserItalic = YES;
        self.captionInfo.isItalic = sender.selected;
    }
    [self nvseekTimeline];
}

- (void)nvFontListView:(NvFontListView *)nvFontListView underLineClick:(UIButton *)sender {
    self.isUserUnderLine = YES;
    [self selectedPartialText];
    if (self.selectedRange.length > 0) {
        [self setTextSpanList:NVS_SPAN_TYPE_UNDERLINE value:[NSNumber numberWithBool:sender.selected]];
    }else{
        [self selectNoneForTextSpanList:NVS_SPAN_TYPE_UNDERLINE];
        [self.currentCaption setUnderline:sender.selected];
        self.captionInfo.isUserUnderLine = YES;
        self.captionInfo.isUnderLine = sender.selected;
    }
    [self nvseekTimeline];
}

#pragma mark - 选择字幕间距
///Select subtitle spacing
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
    
    self.letterSpace = space;
    self.captionInfo.isModifyLetterSpace = YES;
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

#pragma mark - 选择位置
///Select location
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

-(void)translateCaption:(NvsTimelineCaption*)caption textAlignmentType:(NvCaptionTextAlignment)type{
    NSArray *list = [caption getCaptionBoundingVertices:NvsBoundingType_Text_Frame];
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

#pragma mark - 选择字号
///Select size
- (void)applyFontRatioToAllCaption:(BOOL)applyToAllCaption {
    self.fontRatioApplyAll = applyToAllCaption;
    [self applyToAllCaptions];
}

- (void)fontRatioChanged:(float)value {
    [self selectedPartialText];
    if (self.selectedRange.length > 0) {
        [self setTextSpanList:NVS_SPAN_TYPE_FONT_SIZE_RATIO value:[NSNumber numberWithFloat:value]];
    }else {
        NSNumber *number = [[NSUserDefaults standardUserDefaults] valueForKey:@"defaultFontSize"];
        float defaultFontSize = [number floatValue];
        float fontSize = value*defaultFontSize;
        [self.currentCaption setFontSize:fontSize];
    }
    [self nvseekTimeline];
}

- (void)disableFontRatio:(BOOL)disable {
    if ([self.delegate respondsToSelector:@selector(alertDisabledFontRatio:)]) {
        [self.delegate alertDisabledFontRatio:disable];
    }
}

#pragma mark - 选择花字
///选择花字
///Select Modular Caption
- (void)applyModularCaptionRenderer:(NSString *)rendererId {
    [self selectedPartialText];
    /* 应用花字需要保证花字自身效果不受已应用字幕效果的影响
     * To apply the  Modular Caption, ensure that the  Modular Caption itself is not affected by the effect of the applied subtitles
     */
    
    [self.currentCaption resetTextColorState];
    [self.currentCaption resetOutlineColorState];
    if (self.selectedRange.length > 0) {
        if (rendererId.length > 0) {
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_COLOR];
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_OUTLINE_WIDTH];
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_OUTLINE_COLOR];
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_NORMAL_TEXT];
            [self setTextSpanList:NVS_SPAN_TYPE_RENDERERID value:rendererId];
        }else {
            [self selectNoneForTextSpanList:NVS_SPAN_TYPE_RENDERERID];
        }
        
    }else{
        [self selectNoneForTextSpanList:NVS_SPAN_TYPE_RENDERERID];
        [self.currentCaption applyModularCaptionRenderer:rendererId];
        self.captionInfo.renderId = rendererId;
    }
    
}
#pragma mark - 选择气泡
///Selective bubble
- (void)applyModularCaptionContext:(NSString *)contextId {
    [self.currentCaption applyModularCaptionContext:contextId];
    self.captionInfo.contextId = contextId;
}
#pragma mark - 选择入动画
///Select in animation
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
#pragma mark - 出动画
///出动画
///out animation
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
#pragma mark - 组合动画
///Composite animation
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

#pragma mark - Set text span
- (void)setTextSpanList:(NSString *)type value:(NSObject *)value {
    NSArray *spanArr = [self.currentCaption getTextSpanList];
    NSMutableArray *applyCaptionSpans = [NSMutableArray arrayWithArray:spanArr];
    ///[start end)
    NSInteger start = self.selectedRange.location;
    NSInteger end = self.selectedRange.location + self.selectedRange.length;
    NvsCaptionSpan *captionSpan = applyCaptionSpans.lastObject;
    if (captionSpan.start == start && captionSpan.end == end && [captionSpan.type isEqualToString:type]) {
        if ([type isEqualToString:NVS_SPAN_TYPE_COLOR]) {
            NvsCaptionColorSpan *span = (NvsCaptionColorSpan *)captionSpan;
            NSString *colorStr = (NSString *)value;
            NSArray *colors = [colorStr componentsSeparatedByString:@","];
            if (colors.count == 4) {
                span.r = [colors[0] floatValue];
                span.g = [colors[1] floatValue];
                span.b = [colors[2] floatValue];
            }

        }else if ([type isEqualToString:NVS_SPAN_TYPE_FONT_FAMILY]) {
            NvsCaptionFontFamilySpan *span = (NvsCaptionFontFamilySpan *)captionSpan;
            NSString *valueStr = (NSString *)value;
            span.fontFamily = valueStr;
        }else if ([type isEqualToString:NVS_SPAN_TYPE_ITALIC]) {
            NvsCaptionItalicSpan *span = (NvsCaptionItalicSpan *)captionSpan;
            NSNumber *valueNumber = (NSNumber *)value;
            span.italic = [valueNumber boolValue];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_UNDERLINE]) {
            NvsCaptionUnderlineSpan *span = (NvsCaptionUnderlineSpan *)captionSpan;
            NSNumber *valueNumber = (NSNumber *)value;
            span.underline = [valueNumber boolValue];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_OPACITY]) {
            NvsCaptionOpacitySpan *span = (NvsCaptionOpacitySpan *)captionSpan;
            NSNumber *valueNumber = (NSNumber *)value;
            span.opacity = [valueNumber floatValue];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_RENDERERID]) {
            NvsCaptionRendererIdSpan *span = (NvsCaptionRendererIdSpan *)captionSpan;
            NSString *rendererId = (NSString *)value;
            span.rendererId = rendererId;
        }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_COLOR]) {
            NvsCaptionOutlineColorSpan *span = (NvsCaptionOutlineColorSpan *)captionSpan;
            NSString *colorStr = (NSString *)value;
            NSArray *colors = [colorStr componentsSeparatedByString:@","];
            if (colors.count == 4) {
                span.r = [colors[0] floatValue];
                span.g = [colors[1] floatValue];
                span.b = [colors[2] floatValue];
            }
        }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_WIDTH]) {
            NvsCaptionOutlineWidthSpan *span = (NvsCaptionOutlineWidthSpan *)captionSpan;
            NSNumber *valueNumber = (NSNumber *)value;
            span.outlineWidth = [valueNumber floatValue];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_NORMAL_TEXT]) {
            NvsCaptionNormalTextSpan *normalSpan = (NvsCaptionNormalTextSpan *)captionSpan;
            NSNumber *valueNumber = (NSNumber *)value;
            normalSpan.outlineWidth = [valueNumber floatValue];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_FONT_SIZE_RATIO]) {
            NvsCaptionFontSizeRatioSpan *fontSizeRatioSpan = (NvsCaptionFontSizeRatioSpan *)captionSpan;
            NSNumber *valueNumber = (NSNumber *)value;
            fontSizeRatioSpan.fontSizeRatio = [valueNumber floatValue];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_BODY_OPACITY]) {
            NvsCaptionBodyOpacitySpan *bodyOpacitySpan = (NvsCaptionBodyOpacitySpan *)captionSpan;
            NSNumber *valueNumber = (NSNumber *)value;
            bodyOpacitySpan.bodyOpacity = [valueNumber floatValue];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_OPACITY]) {
            NvsCaptionOutlineOpacitySpan *outlineOpacitySpan = (NvsCaptionOutlineOpacitySpan *)captionSpan;
            NSNumber *valueNumber = (NSNumber *)value;
            outlineOpacitySpan.outlineOpacity = [valueNumber floatValue];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_SHADOW_OPACITY]) {
            NvsCaptionShadowOpacitySpan *shadowOpacitySpan = (NvsCaptionShadowOpacitySpan *)captionSpan;
            NSNumber *valueNumber = (NSNumber *)value;
            shadowOpacitySpan.shadowOpacity = [valueNumber floatValue];
        }
    }else {
        /// add new span
        if ([type isEqualToString:NVS_SPAN_TYPE_COLOR]) {
            NvsCaptionColorSpan *span = [NvsCaptionColorSpan new];
            span.type = type;
            span.start = start;
            span.end = end;
            NSString *colorStr = (NSString *)value;
            NSArray *colors = [colorStr componentsSeparatedByString:@","];
            if (colors.count == 4) {
                span.r = [colors[0] floatValue];
                span.g = [colors[1] floatValue];
                span.b = [colors[2] floatValue];
            }
            [applyCaptionSpans addObject:span];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_FONT_FAMILY]) {
            NvsCaptionFontFamilySpan *span = [NvsCaptionFontFamilySpan new];
            span.type = type;
            span.start = start;
            span.end = end;
            NSString *valueStr = (NSString *)value;
            span.fontFamily = valueStr;
            [applyCaptionSpans addObject:span];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_ITALIC]) {
            NvsCaptionItalicSpan *span = [NvsCaptionItalicSpan new];
            span.type = type;
            span.start = start;
            span.end = end;
            NSNumber *valueNumber = (NSNumber *)value;
            span.italic = [valueNumber boolValue];
            [applyCaptionSpans addObject:span];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_UNDERLINE]) {
            NvsCaptionUnderlineSpan  *span = [NvsCaptionUnderlineSpan new];
            span.type = type;
            span.start = start;
            span.end = end;
            NSNumber *valueNumber = (NSNumber *)value;
            span.underline = [valueNumber boolValue];
            [applyCaptionSpans addObject:span];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_OPACITY]) {
            NvsCaptionOpacitySpan *span = [NvsCaptionOpacitySpan new];
            span.type = type;
            span.start = start;
            span.end = end;
            NSNumber *valueNumber = (NSNumber *)value;
            span.opacity = [valueNumber floatValue];
            [applyCaptionSpans addObject:span];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_RENDERERID]) {
            NvsCaptionRendererIdSpan *span = [NvsCaptionRendererIdSpan new];
            span.type = type;
            span.start = start;
            span.end = end;
            NSString *rendererId = (NSString *)value;
            span.rendererId = rendererId;
            [applyCaptionSpans addObject:span];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_COLOR]) {
            NvsCaptionOutlineColorSpan *span = [NvsCaptionOutlineColorSpan new];
            span.type = type;
            span.start = start;
            span.end = end;
            NSString *colorStr = (NSString *)value;
            NSArray *colors = [colorStr componentsSeparatedByString:@","];
            if (colors.count == 4) {
                span.r = [colors[0] floatValue];
                span.g = [colors[1] floatValue];
                span.b = [colors[2] floatValue];
            }
            [applyCaptionSpans addObject:span];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_WIDTH]) {
            NvsCaptionOutlineWidthSpan *span = [NvsCaptionOutlineWidthSpan new];
            span.type = type;
            span.start = start;
            span.end = end;
            NSNumber *valueNumber = (NSNumber *)value;
            span.outlineWidth = [valueNumber floatValue];
            [applyCaptionSpans addObject:span];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_NORMAL_TEXT]) {
            NvsCaptionNormalTextSpan *normalSpan = [NvsCaptionNormalTextSpan new];
            normalSpan.type = NVS_SPAN_TYPE_NORMAL_TEXT;
            normalSpan.start = start;
            normalSpan.end = end;
            NSNumber *valueNumber = (NSNumber *)value;
            normalSpan.outlineWidth = [valueNumber floatValue];
            [applyCaptionSpans addObject:normalSpan];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_FONT_SIZE_RATIO]) {
            NvsCaptionFontSizeRatioSpan *fontSizeRatioSpan = [NvsCaptionFontSizeRatioSpan new];
            fontSizeRatioSpan.type = NVS_SPAN_TYPE_FONT_SIZE_RATIO;
            fontSizeRatioSpan.start = start;
            fontSizeRatioSpan.end = end;
            NSNumber *valueNumber = (NSNumber *)value;
            fontSizeRatioSpan.fontSizeRatio = [valueNumber floatValue];
            [applyCaptionSpans addObject:fontSizeRatioSpan];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_BODY_OPACITY]) {
            NvsCaptionBodyOpacitySpan *bodyOpacitySpan = [NvsCaptionBodyOpacitySpan new];
            bodyOpacitySpan.type = NVS_SPAN_TYPE_BODY_OPACITY;
            bodyOpacitySpan.start = start;
            bodyOpacitySpan.end = end;
            NSNumber *valueNumber = (NSNumber *)value;
            bodyOpacitySpan.bodyOpacity = [valueNumber floatValue];
            [applyCaptionSpans addObject:bodyOpacitySpan];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_OPACITY]) {
            NvsCaptionOutlineOpacitySpan *outlineOpacitySpan = [NvsCaptionOutlineOpacitySpan new];
            outlineOpacitySpan.type = NVS_SPAN_TYPE_OUTLINE_OPACITY;
            outlineOpacitySpan.start = start;
            outlineOpacitySpan.end = end;
            NSNumber *valueNumber = (NSNumber *)value;
            outlineOpacitySpan.outlineOpacity = [valueNumber floatValue];
            [applyCaptionSpans addObject:outlineOpacitySpan];
        }else if ([type isEqualToString:NVS_SPAN_TYPE_SHADOW_OPACITY]) {
            NvsCaptionShadowOpacitySpan *shadowOpacitySpan = [NvsCaptionShadowOpacitySpan new];
            shadowOpacitySpan.type = NVS_SPAN_TYPE_SHADOW_OPACITY;
            shadowOpacitySpan.start = start;
            shadowOpacitySpan.end = end;
            NSNumber *valueNumber = (NSNumber *)value;
            shadowOpacitySpan.shadowOpacity = [valueNumber floatValue];
            [applyCaptionSpans addObject:shadowOpacitySpan];
        }
    }
    [self.currentCaption setTextSpanList:applyCaptionSpans];
    
    
    NvCaptionInfoModel *info = self.captionInfo;
    NvCaptionSpan *captionInfo = info.textSpanArray.lastObject;
    if (captionInfo.start == start && captionInfo.end == end && [captionInfo.type isEqualToString:type]) {
        captionInfo.value = value;
    }else {
        NvCaptionSpan *spanInfo = [NvCaptionSpan new];
        spanInfo.type = type;
        spanInfo.start = start;
        spanInfo.end = end;
        spanInfo.value = value;
        [info.textSpanArray addObject:spanInfo];
    }
    
}

- (void)addNoneForTextSpanList:(NSString *)type {
    NSArray *spanArr = [self.currentCaption getTextSpanList];
    NSMutableArray *applyCaptionSpans = [NSMutableArray arrayWithArray:spanArr];
    ///[start end)
    NSInteger start = self.selectedRange.location;
    NSInteger end = self.selectedRange.location + self.selectedRange.length;
    NSObject *value;
    if ([type isEqualToString:NVS_SPAN_TYPE_COLOR]) {
        NvsCaptionColorSpan *span = [NvsCaptionColorSpan new];
        span.type = type;
        span.start = start;
        span.end = end;
        value = @"1,1,1,1";
        NSArray *colors = [(NSString *)value componentsSeparatedByString:@","];
        if (colors.count == 4) {
            span.r = [colors[0] floatValue];
            span.g = [colors[1] floatValue];
            span.b = [colors[2] floatValue];
        }
        [applyCaptionSpans addObject:span];
    }else if ([type isEqualToString:NVS_SPAN_TYPE_FONT_FAMILY]) {
        NvsCaptionFontFamilySpan *span = [NvsCaptionFontFamilySpan new];
        span.type = type;
        span.start = start;
        span.end = end;
        value = @"";
        span.fontFamily = (NSString *)value;
        [applyCaptionSpans addObject:span];
    }else if ([type isEqualToString:NVS_SPAN_TYPE_ITALIC]) {
        NvsCaptionItalicSpan *span = [NvsCaptionItalicSpan new];
        span.type = type;
        span.start = start;
        span.end = end;
        value = [NSNumber numberWithBool:NO];
        NSNumber *valueNumber = (NSNumber *)value;
        span.italic = [valueNumber boolValue];
        [applyCaptionSpans addObject:span];
    }else if ([type isEqualToString:NVS_SPAN_TYPE_UNDERLINE]) {
        NvsCaptionUnderlineSpan  *span = [NvsCaptionUnderlineSpan new];
        span.type = type;
        span.start = start;
        span.end = end;
        value = [NSNumber numberWithBool:NO];
        NSNumber *valueNumber = (NSNumber *)value;
        span.underline = [valueNumber boolValue];
        [applyCaptionSpans addObject:span];
    }else if ([type isEqualToString:NVS_SPAN_TYPE_OPACITY]) {
        NvsCaptionOpacitySpan *span = [NvsCaptionOpacitySpan new];
        span.type = type;
        span.start = start;
        span.end = end;
        value = [NSNumber numberWithFloat:0.f];
        NSNumber *valueNumber = (NSNumber *)value;
        span.opacity = [valueNumber floatValue];
        [applyCaptionSpans addObject:span];
    }else if ([type isEqualToString:NVS_SPAN_TYPE_RENDERERID]) {
        NvsCaptionNormalTextSpan *span = [NvsCaptionNormalTextSpan new];
        type = NVS_SPAN_TYPE_NORMAL_TEXT;
        span.type = type;
        span.start = start;
        span.end = end;
        value = [NSNumber numberWithFloat:0.f];
        NSNumber *valueNumber = (NSNumber *)value;
        span.outlineWidth = [valueNumber floatValue];
        [applyCaptionSpans addObject:span];
    }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_COLOR] || [type isEqualToString:NVS_SPAN_TYPE_OUTLINE_WIDTH]) {
        type = NVS_SPAN_TYPE_OUTLINE_WIDTH;
        NvsCaptionOutlineWidthSpan *span = [NvsCaptionOutlineWidthSpan new];
        span.type = type;
        span.start = start;
        span.end = end;
        value = [NSNumber numberWithFloat:0.f];
        NSNumber *valueNumber = (NSNumber *)value;
        span.outlineWidth = [valueNumber floatValue];
        [applyCaptionSpans addObject:span];
    }

    [self.currentCaption setTextSpanList:applyCaptionSpans];
    NvCaptionInfoModel *info = self.captionInfo;
    NvCaptionSpan *spanInfo = [NvCaptionSpan new];
    spanInfo.type = type;
    spanInfo.start = start;
    spanInfo.end = end;
    spanInfo.value = value;
    [info.textSpanArray addObject:spanInfo];
}

- (void)selectNoneForTextSpanList:(NSString *)type {
    NSArray *spanArr = [self.currentCaption getTextSpanList];
    NSMutableArray *applyCaptionSpans = [NSMutableArray arrayWithArray:spanArr];
    //change the range of spans with same type
    for (int i=0; i<applyCaptionSpans.count; i++) {
        NvsCaptionSpan *span = applyCaptionSpans[i];
        if ([span.type isEqualToString:type]) {
            NSRange spanRange = NSMakeRange(span.start, span.end - span.start);
            NSRange intersectionRange = NSIntersectionRange(spanRange, self.selectedRange);
            if (intersectionRange.length > 0) {
                if (NSEqualRanges(self.selectedRange, spanRange) || (self.selectedRange.location <= spanRange.location && self.selectedRange.length >= spanRange.length)) {
                    //span's range equal to or contained in the textview current selected range.
                    //you need remove the span from the span list.
                        [applyCaptionSpans removeObject:span];
                        i--;
                    
                }
                else if (NSEqualRanges(intersectionRange, self.selectedRange)) {
                    //span's range include all of the textview current selected range.
                    if (intersectionRange.location == spanRange.location) {
                        span.start = intersectionRange.location + intersectionRange.length;
                    }else if(intersectionRange.location + intersectionRange.length == spanRange.location + spanRange.length){
                        span.end = intersectionRange.location;
                    }else {
                        NSInteger start = intersectionRange.location + intersectionRange.length;
                        NSInteger end = span.end;
                        if ([type isEqualToString:NVS_SPAN_TYPE_COLOR]) {
                            NvsCaptionColorSpan *referSpan = (NvsCaptionColorSpan *)applyCaptionSpans[i];
                            NvsCaptionColorSpan *spanNew = [NvsCaptionColorSpan new];
                            spanNew.type = type;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.r = referSpan.r;
                            spanNew.g = referSpan.g;
                            spanNew.b = referSpan.b;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }else if ([type isEqualToString:NVS_SPAN_TYPE_FONT_FAMILY]) {
                            NvsCaptionFontFamilySpan *referSpan = (NvsCaptionFontFamilySpan *)applyCaptionSpans[i];
                            NvsCaptionFontFamilySpan *spanNew = [NvsCaptionFontFamilySpan new];
                            spanNew.type = type;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.fontFamily = referSpan.fontFamily;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }else if ([type isEqualToString:NVS_SPAN_TYPE_ITALIC]) {
                            NvsCaptionItalicSpan *referSpan = (NvsCaptionItalicSpan *)applyCaptionSpans[i];
                            NvsCaptionItalicSpan *spanNew = [NvsCaptionItalicSpan new];
                            spanNew.type = type;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.italic = referSpan.italic;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }else if ([type isEqualToString:NVS_SPAN_TYPE_UNDERLINE]) {
                            NvsCaptionUnderlineSpan *referSpan = (NvsCaptionUnderlineSpan *)applyCaptionSpans[i];
                            NvsCaptionUnderlineSpan *spanNew = [NvsCaptionUnderlineSpan new];
                            spanNew.type = type;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.underline = referSpan.underline;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }else if ([type isEqualToString:NVS_SPAN_TYPE_OPACITY]) {
                            NvsCaptionOpacitySpan *referSpan = (NvsCaptionOpacitySpan *)applyCaptionSpans[i];
                            NvsCaptionOpacitySpan *spanNew = [NvsCaptionOpacitySpan new];
                            spanNew.type = type;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.opacity = referSpan.opacity;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }else if ([type isEqualToString:NVS_SPAN_TYPE_RENDERERID]) {
                            NvsCaptionRendererIdSpan *referSpan = (NvsCaptionRendererIdSpan *)applyCaptionSpans[i];
                            NvsCaptionRendererIdSpan *spanNew = [NvsCaptionRendererIdSpan new];
                            spanNew.type = type;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.rendererId = referSpan.rendererId;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_COLOR]) {
                            NvsCaptionOutlineColorSpan *referSpan = (NvsCaptionOutlineColorSpan *)applyCaptionSpans[i];
                            NvsCaptionOutlineColorSpan *spanNew = [NvsCaptionOutlineColorSpan new];
                            spanNew.type = type;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.r = referSpan.r;
                            spanNew.g = referSpan.g;
                            spanNew.b = referSpan.b;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_WIDTH]) {
                            NvsCaptionOutlineWidthSpan *referSpan = (NvsCaptionOutlineWidthSpan *)applyCaptionSpans[i];
                            NvsCaptionOutlineWidthSpan *spanNew = [NvsCaptionOutlineWidthSpan new];
                            spanNew.type = type;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.outlineWidth = referSpan.outlineWidth;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }
                        else if ([type isEqualToString:NVS_SPAN_TYPE_NORMAL_TEXT]) {
                            NvsCaptionNormalTextSpan *referSpan = (NvsCaptionNormalTextSpan *)applyCaptionSpans[i];
                            NvsCaptionNormalTextSpan *spanNew = [NvsCaptionNormalTextSpan new];
                            spanNew.type = type;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.outlineWidth = referSpan.outlineWidth;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }else if ([type isEqualToString:NVS_SPAN_TYPE_BODY_OPACITY]) {
                            NvsCaptionBodyOpacitySpan *referSpan = (NvsCaptionBodyOpacitySpan *)applyCaptionSpans[i];
                            NvsCaptionBodyOpacitySpan *spanNew = [NvsCaptionBodyOpacitySpan new];
                            spanNew.type = type;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.bodyOpacity = referSpan.bodyOpacity;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }else if ([type isEqualToString:NVS_SPAN_TYPE_OUTLINE_OPACITY]) {
                            NvsCaptionOutlineOpacitySpan *referSpan = (NvsCaptionOutlineOpacitySpan *)applyCaptionSpans[i];
                            NvsCaptionOutlineOpacitySpan *spanNew = [NvsCaptionOutlineOpacitySpan new];
                            spanNew.type = NVS_SPAN_TYPE_OUTLINE_OPACITY;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.outlineOpacity = referSpan.outlineOpacity;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }else if ([type isEqualToString:NVS_SPAN_TYPE_SHADOW_OPACITY]) {
                            NvsCaptionShadowOpacitySpan *referSpan = (NvsCaptionShadowOpacitySpan *)applyCaptionSpans[i];
                            NvsCaptionShadowOpacitySpan *spanNew = [NvsCaptionShadowOpacitySpan new];
                            spanNew.type = NVS_SPAN_TYPE_SHADOW_OPACITY;
                            spanNew.start = start;
                            spanNew.end = end;
                            spanNew.shadowOpacity = referSpan.shadowOpacity;
                            [applyCaptionSpans insertObject:spanNew atIndex:i+1];
                        }
                        span.end = intersectionRange.location;
                    }
                }else {
                    //span's range include part of the textview current selected range.
                    //you need cut the current selected range out off the span's range.
                    if (intersectionRange.location == spanRange.location) {
                        span.start = intersectionRange.location + intersectionRange.length;
                    }else if(intersectionRange.location + intersectionRange.length == spanRange.location + spanRange.length){
                        span.end = intersectionRange.location;
                    }
                }
            }else if(self.selectedRange.length == 0) {
                [applyCaptionSpans removeObject:span];
                i--;
            }
            
        }
    }
    [self.currentCaption setTextSpanList:applyCaptionSpans];
    
    NvCaptionInfoModel *info = self.captionInfo;
    for (int i=0; i<info.textSpanArray.count; i++) {
        NvCaptionSpan *span = info.textSpanArray[i];
        if ([span.type isEqualToString:type]){
            NSRange spanRange = NSMakeRange(span.start, span.end - span.start);
            NSRange intersectionRange = NSIntersectionRange(spanRange, self.selectedRange);
            if (intersectionRange.length > 0) {
                if (NSEqualRanges(self.selectedRange, spanRange) || (self.selectedRange.location <= spanRange.location && self.selectedRange.length >= spanRange.length)) {
                    //span's range equal to or contained in the textview current selected range.
                    //you need remove the span from the span list.
                        [info.textSpanArray removeObject:span];
                        i--;
                }
                else if (NSEqualRanges(intersectionRange, self.selectedRange)) {
                    //span's range include all of the textview current selected range.
                    if (intersectionRange.location == spanRange.location) {
                        span.start = intersectionRange.location + intersectionRange.length;
                    }else if(intersectionRange.location + intersectionRange.length == spanRange.location + spanRange.length){
                        span.end = intersectionRange.location;
                    }else {
                        NSInteger start = intersectionRange.location + intersectionRange.length;
                        NSInteger end = span.end;
                        NvCaptionSpan *spanNew = [NvCaptionSpan new];
                        spanNew.start = start;
                        spanNew.end = end;
                        spanNew.type = span.type;
                        spanNew.value = span.value;
                        [info.textSpanArray insertObject:spanNew atIndex:i];
                        
                        span.end = intersectionRange.location;
                    }
                }else {
                    //span's range include part of the textview current selected range.
                    //you need cut the current selected range out off the span's range.
                    if (intersectionRange.location == spanRange.location) {
                        span.start = intersectionRange.location + intersectionRange.length;
                    }else if(intersectionRange.location + intersectionRange.length == spanRange.location + spanRange.length){
                        span.end = intersectionRange.location;
                    }
                }
            }else if(self.selectedRange.length == 0) {
                [info.textSpanArray removeObject:span];
                i--;
            }
            
        }
    }
}

- (void)cancelAllSelected {
    [self.captionRendererDataSource enumerateObjectsUsingBlock:^(NvCaptionRendererItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            obj.isSelect = true;
        } else {
            obj.isSelect = false;
        }
    }];
    if (self.captionRendererDataSource.count > 0) {
        [self.uiDelegate.rendererListView renderListWithItems:self.captionRendererDataSource];        
    }
    
    [self.uiDelegate.colorListView.dataSource enumerateObjectsUsingBlock:^(NvCaptionColorItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.isSelect = false;
    }];
    [self.uiDelegate.colorListView setDefaultDataSource:self.uiDelegate.colorListView.dataSource alpha:10];
    
    [self.uiDelegate.strokeListView.dataSource enumerateObjectsUsingBlock:^(NvCaptionStrokeItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            obj.isSelect = true;
        } else {
            obj.isSelect = false;
        }
    }];
    [self.uiDelegate.strokeListView setDefaultDataSource:self.uiDelegate.strokeListView.dataSource width:1 alpha:10];
    [self.uiDelegate.fontListView.dataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.lastSelect = NO;
        if (idx == 0) {
            obj.selected = true;
        } else {
            obj.selected = false;
        }
    }];
    [self.uiDelegate.fontListView setDefauleDataSource:self.uiDelegate.fontListView.dataSource];
    [self.uiDelegate.fontListView setDefaultFontBoldButton:false italic:false shadow:false underline:false];
    
}

@end
