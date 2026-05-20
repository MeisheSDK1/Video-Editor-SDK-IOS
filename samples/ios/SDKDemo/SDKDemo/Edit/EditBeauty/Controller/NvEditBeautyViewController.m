//
//  NvEditBeautyViewController.m
//  SDKDemo
//
//  Created by Meishe on 2022/11/15.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvEditBeautyViewController.h"
#import <NvSDKCommon/NvLiveWindowPanelView.h>
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvInitArScence.h>
#import "NvTimelineUtils.h"
#import "NvEditBeautyView.h"
#import "NvCaptureDataUtils.h"
#import "NvBeautyModelTranslator.h"

@interface NvEditBeautyViewController ()<NvLiveWindowPanelViewDelegate,NvEditBeautyViewDelegate>
@property (nonatomic, strong) NvLiveWindowPanelView *liveWindowPanel;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) NvEditBeautyView *beautyView;
@property (nonatomic, strong) NSString *colorCorrectId;
@property (nonatomic, assign) BOOL containAI;
@property (nonatomic, assign) BOOL connectedLiveWindow;
@property (nonatomic, strong) NvBeautyModelTranslator *modelTranslator;
@property (nonatomic, strong) NSMutableArray *appliedBeautyEffects;
@property (nonatomic, strong) NSMutableArray *appliedShapeEffects;
@property (nonatomic, strong) NSMutableArray *appliedMicroShapeEffects;
@end

@implementation NvEditBeautyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"capture.beauty", @"美颜");
    self.containAI = NO;
    self.connectedLiveWindow = NO;
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.modelTranslator = [NvBeautyModelTranslator new];
    self.colorCorrectId = [NvTimelineUtils installColorCorrectFilter];
    self.appliedBeautyEffects = [NSMutableArray array];
    self.appliedShapeEffects = [NSMutableArray array];
    self.appliedMicroShapeEffects = [NSMutableArray array];
    [self initARFace];
    [self initTimeline];
    [self addSubViews];
    [self configBeautyCategoryDatas];
    [self configShapeCategoryDatas];
    if (self.containAI) {
        [self configMicroShapeCategoryDatas];
    }
    [self refreshBeautyViewAccordingToTimelineData];
    [self connectLiveWindow];
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self connectLiveWindow];
}

#pragma mark 创建timline
///init timeline
- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimeline:self.editMode];
    [NvTimelineUtils recreateTimeline:self.timeline];
    NvTimelineData *timelineData = [NvTimelineData sharedInstance];
    [NvTimelineUtils resetTimeline:self.timeline beautyEffect:timelineData.beautyArr shapeEffect:timelineData.shapeArr microShapeEffect:timelineData.microShapeArr];
}


#pragma mark 连接预览窗口并且播放
///connect liveWindow
- (void)connectLiveWindow {
    [_liveWindowPanel connectTimeline:_timeline];
    self.connectedLiveWindow = YES;
    [self seekTimeline:_liveWindowPanel.currentTime];
}

#pragma mark 定位某一时间戳的图像
- (void)seekTimeline:(int64_t)timestamp {
    if (!self.connectedLiveWindow) {
        return;
    }
    int flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster | NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame ;
    [NvTimelineUtils seekTimeline:self.timeline timestamp:timestamp flags:flag];
}

#pragma mark 初始化人脸授权
/*
 初始化人脸授权
 Initialize face authorization
 */
- (void)initARFace {
    if (![NvInitArScence getInitArFace]) {
        if (ARSCENE_MS){
            [NvInitArScence initARFace:NvFaceMode_106];
        }else if (ARSCENE_MS_240){
            [NvInitArScence initARFace:NvFaceMode_240];
        }
    }
    if ([NvInitArScence getInitArFace]) {
        self.containAI = YES;
    }
}

#pragma mark 添加子视图
///add subviews
- (void)addSubViews {
    self.liveWindowPanel = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    _liveWindowPanel.delegate = self;
    _liveWindowPanel.editMode = self.editMode;
    [_liveWindowPanel hiddenVolumeButton];
    [self.view addSubview:_liveWindowPanel];
    self.beautyView = [[NvEditBeautyView alloc] initWithContainAI:self.containAI];
    self.beautyView.delegate = self;
    [self.view addSubview:self.beautyView];
    self.beautyView.backgroundColor = [UIColor clearColor];
    [self.beautyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(self.liveWindowPanel.mas_bottom);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];
}

- (BOOL)containMatte {
    BOOL matte = YES;
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    if (track.clipCount > 0) {
        NvsVideoClip *clip = [track getClipWithIndex:0];
        NvsVideoFx *fx = [NvSDKUtils getClipVideoFx:@"AR Scene" withClip:clip];
        if (!fx) {
            fx = [NvSDKUtils createClipVideoFx:@"AR Scene" withClip:clip];
            if (ARSCENE_MS || ARSCENE_MS_240) {
                [[fx getARSceneManipulate] setDetectionMode:NvsARSceneDetectionMode_SemiImage];
            }
            BOOL highVersion = [NvInitArScence isHighVersionPhone];
            if(highVersion) {
                [fx setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
            }
            [fx setBooleanVal:@"Max Faces Respect Min" val:YES];
//            if(ARSCENE_MS_240){
//                // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//                [fx setBooleanVal:@"Use Face Extra Info" val:YES];
//            }
            [fx setBooleanVal:@"Beauty Effect" val:YES];
            [fx setBooleanVal:@"Beauty Shape" val:YES];
            [fx setBooleanVal:@"Face Mesh Internal Enabled" val:YES];
            [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
        }
        NvsARSceneManipulate * manipulate = [fx getARSceneManipulate];
        matte = [manipulate isFunctionAvailable:NvsToBeCheckedFunctionType_Matte];
    }
    return matte;
}

- (void)configBeautyCategoryDatas {
    NSMutableArray *beautyArray = [NSMutableArray array];
    BOOL matte = [self containMatte];
    NSArray *beautyNameArr = [NvCaptureDataUtils getBeautifulSkinTitleArray:matte];
    NSArray *beautyCoverImgArr = [NvCaptureDataUtils getBeautifulSkinCoverArray:matte];
    NSArray *beautyCoverSelectedImgArr = [NvCaptureDataUtils getBeautifulSkinCoverSelectedArray:matte];
    NSArray *beautyFxNameArr = [NvCaptureDataUtils getBeautifulSkinFxNameArray:matte isContentAI:self.containAI];

    for (int i = 0; i < beautyNameArr.count; i++) {
        NvBeautyTypeModel *beautyModel = [NvBeautyTypeModel new];
        beautyModel.name = beautyNameArr[i];
        beautyModel.coverImage = beautyCoverImgArr[i];
        beautyModel.selectedCoverImg = beautyCoverSelectedImgArr[i];
        if ([beautyModel.name isEqualToString:NvLocalString(@"Whiten mode B", @"美白B")]){
            beautyModel.switchSelected = YES;
        }else if ([beautyModel.name isEqualToString:NvLocalString(@"Shiny", @"去油光")]){
            beautyModel.extValue = 0.44;
        }else if([beautyModel.name isEqualToString:NvLocalString(@"Color correction", @"校色")]){
            beautyModel.uuid = self.colorCorrectId;
        }
        beautyModel.isOperation = YES;
        beautyModel.isBeauty = YES;
        beautyModel.type = 0;
        beautyModel.fxName = beautyFxNameArr[i];
        beautyModel.canReplace = YES;
        [beautyArray addObject:beautyModel];
    }
    [self.beautyView configData:beautyArray category:NvEditBeautyCategoryBeauty showTemporaryData:NO];
}

- (void)applyNonEffectBeautyData {
    NSMutableArray *nonEffectData = [self beautyCategoryData];
    [self.beautyView applyEffects:nonEffectData category:NvEditBeautyCategoryBeauty];
}

- (NSMutableArray *)beautyCategoryData {
    NSMutableArray *beautyArray = [NSMutableArray array];
    BOOL matte = YES;
    NSArray *beautyNameArr = [NvCaptureDataUtils getBeautifulSkinTitleArray:matte];
    NSArray *beautyCoverImgArr = [NvCaptureDataUtils getBeautifulSkinCoverArray:matte];
    NSArray *beautyCoverSelectedImgArr = [NvCaptureDataUtils getBeautifulSkinCoverSelectedArray:matte];
    NSArray *beautyFxNameArr = [NvCaptureDataUtils getBeautifulSkinFxNameArray:matte isContentAI:self.containAI];

    for (int i = 0; i < beautyNameArr.count; i++) {
        NvBeautyTypeModel *beautyModel = [NvBeautyTypeModel new];
        beautyModel.name = beautyNameArr[i];
        beautyModel.coverImage = beautyCoverImgArr[i];
        beautyModel.selectedCoverImg = beautyCoverSelectedImgArr[i];
        if ([beautyModel.name isEqualToString:NvLocalString(@"Whiten mode B", @"美白B")]){
            beautyModel.switchSelected = YES;
        }
        beautyModel.isOperation = YES;
        beautyModel.isBeauty = YES;
        beautyModel.type = 0;
        beautyModel.fxName = beautyFxNameArr[i];
        beautyModel.canReplace = YES;
        [beautyArray addObject:beautyModel];
    }
    return beautyArray;
}

- (void)configShapeCategoryDatas {
    NSMutableArray *shapeArr = [self shapeCategoryData];
    [self.beautyView configData:shapeArr category:NvEditBeautyCategoryShape showTemporaryData:NO];
}

- (NSMutableArray *)shapeCategoryData {
    NSArray *shapeTitleArr = [NvCaptureDataUtils getShapeTitleArray:self.containAI];
    NSArray *shapeCoverArr = [NvCaptureDataUtils getShapeCoverArray:self.containAI];
    NSArray *shapeSelectedCoverArr = [NvCaptureDataUtils getShapeSelectedCoverArray:self.containAI];
    NSArray *fxNameArr = [NvCaptureDataUtils getShapeFxNameArray];
    NSArray *degreeNameArr = [NvCaptureDataUtils getShapeDegreeNameArray:self.containAI];
    NSMutableArray *packagePathArr = [NvCaptureDataUtils getShapePackagePaths];
    NSMutableArray *shapeArr = [NSMutableArray array];
    for (int i = 0; i < shapeTitleArr.count; i++) {
        NvBeautyTypeModel *model = [NvBeautyTypeModel new];
        model.name = shapeTitleArr[i];
        model.coverImage = shapeCoverArr[i];
        model.selectedCoverImg = shapeSelectedCoverArr[i];
        model.selected = NO;
        model.isOperation = YES;
        model.isBeauty = NO;
        model.type = 1;
        model.degreeName = degreeNameArr[i];
        model.value = 0;
        model.canReplace = YES;
        if (self.containAI) {
            model.fxName = fxNameArr[i];
            model.packageUrl = packagePathArr[i];
            NvsAssetPackageType assetType = NvsAssetPackageType_FaceMesh;
            if ([model.packageUrl.pathExtension containsString:@"warp"]) {
                assetType = NvsAssetPackageType_Warp;
            }
            if (model.packageUrl.length > 0) {
                NSString * licensePath = [NSString convertFilePathToNewPath:model.packageUrl WithExtension:@"lic"];
                model.uuid = [NvSDKUtils installAssetPackage:model.packageUrl license:licensePath assetType:assetType];
            }
            
        }
        [shapeArr addObject:model];
    }
    
    for (NSMutableDictionary *dict in [NvCaptureDataUtils getShapeTestData]) {
        NvBeautyTypeModel *model = [NvBeautyTypeModel yy_modelWithDictionary:dict];
        if (model) {
            
            NSString * licensePath = [NSString convertFilePathToNewPath:model.packageUrl WithExtension:@"lic"];
            if ([model.packageUrl containsString:@"warp"]) {
                [NvSDKUtils reInstallAssetPackage:model.packageUrl license:licensePath assetType:NvsAssetPackageType_Warp];
            }else if ([model.packageUrl containsString:@"facemesh"]) {
                [NvSDKUtils reInstallAssetPackage:model.packageUrl license:licensePath assetType:NvsAssetPackageType_FaceMesh];
            }
            
            [shapeArr insertObject:model atIndex:0];
        }
    }
    
    return shapeArr;
}

- (void)configMicroShapeCategoryDatas {
    NSMutableArray *shapeArr = [self microShapeCategoryData];
    [self.beautyView configData:shapeArr category:NvEditBeautyCategoryMicroShape showTemporaryData:NO];
}

- (NSMutableArray *)microShapeCategoryData {
    NSArray *microShapeTitleArr = [NvCaptureDataUtils getMicroShapeTitleArray];
    NSArray *microShapeCoverArr = [NvCaptureDataUtils getMicroShapeCoverArray];
    NSArray *microShapeSelectedCoverArr = [NvCaptureDataUtils getMicroShapeSelectedCoverArray];
    NSArray *fxNameArr = [NvCaptureDataUtils getMicroShapeFxNameArray];
    NSArray *degreeNameArr = [NvCaptureDataUtils getMicroShapeDegreeNameArray];
    NSMutableArray *packagePathArr = [NvCaptureDataUtils getMicroShapePackagePaths];
    NSMutableArray *shapeArr = [NSMutableArray array];
    for (int i = 0; i < microShapeTitleArr.count; i++) {
        NvBeautyTypeModel *model = [NvBeautyTypeModel new];
        model.name = microShapeTitleArr[i];
        model.coverImage = microShapeCoverArr[i];
        model.selectedCoverImg = microShapeSelectedCoverArr[i];
        model.selected = NO;
        model.isOperation = YES;
        model.isBeauty = NO;
        model.type = 1;
        model.degreeName = degreeNameArr[i];
        model.value = 0;
        model.canReplace = YES;
        if (self.containAI) {
            model.fxName = fxNameArr[i];
            model.packageUrl = packagePathArr[i];
            NvsAssetPackageType assetType = NvsAssetPackageType_FaceMesh;
            if ([model.packageUrl.pathExtension containsString:@"warp"]) {
                assetType = NvsAssetPackageType_Warp;
            }
            if (model.packageUrl.length > 0) {
                NSString * licensePath = [NSString convertFilePathToNewPath:model.packageUrl WithExtension:@"lic"];
                model.uuid = [NvSDKUtils installAssetPackage:model.packageUrl license:licensePath assetType:assetType];
            }
            
        }
        [shapeArr addObject:model];
    }
    
    for (NSMutableDictionary *dict in [NvCaptureDataUtils getMicroShapeTestData]) {
        NvBeautyTypeModel *model = [NvBeautyTypeModel yy_modelWithDictionary:dict];
        if (model) {
            NSString * licensePath = [NSString convertFilePathToNewPath:model.packageUrl WithExtension:@"lic"];
            if ([model.packageUrl containsString:@"warp"]) {
                [NvSDKUtils reInstallAssetPackage:model.packageUrl license:licensePath assetType:NvsAssetPackageType_Warp];
            }else if ([model.packageUrl containsString:@"facemesh"]) {
                [NvSDKUtils reInstallAssetPackage:model.packageUrl license:licensePath assetType:NvsAssetPackageType_FaceMesh];
            }
            
            [shapeArr insertObject:model atIndex:0];
        }
    }
    return shapeArr;
}

//根据timelinedata 中数据恢复界面
//Data recovery interface according to timelinedata
- (void)refreshBeautyViewAccordingToTimelineData {
    NvTimelineData *data = [NvTimelineData sharedInstance];
    NSMutableArray *beautyEffects= data.beautyArr;
    NSMutableArray *shapeEffects= data.shapeArr;
    NSMutableArray *microShapeEffects= data.microShapeArr;
    NvMakeupToolEffectContentModel *makeupEffectContent = data.timelineMakeupModel.effectContent;
    if (beautyEffects.count > 0 || shapeEffects.count > 0 || microShapeEffects.count > 0 || makeupEffectContent.beauty.count > 0 || makeupEffectContent.shape.count > 0 || makeupEffectContent.microShape.count > 0) {
        
        if (makeupEffectContent.beauty.count > 0 || makeupEffectContent.shape.count > 0 || makeupEffectContent.microShape.count > 0) {
            //存在美妆数据 There is beauty data
            
            NSMutableArray *beautyArr = [self beautyCategoryData];
            NSMutableArray *transBeautyArr = [self.modelTranslator translateBeautyModelWithMakeupEffect:data.timelineMakeupModel referenceArr:beautyArr];
            
            NSMutableArray *shapeArr = [self shapeCategoryData];
            NSMutableArray *transShapeArr = [self.modelTranslator translateShapeModelWithMakeupEffect:data.timelineMakeupModel referenceArr:shapeArr];
            
            NSMutableArray *microShapeArr = [self microShapeCategoryData];
            NSMutableArray *transMicroShapeArr = [self.modelTranslator translateMicroShapeModelWithMakeupEffect:data.timelineMakeupModel referenceArr:microShapeArr];
            
            [self.beautyView configData:transBeautyArr category:NvEditBeautyCategoryBeauty showTemporaryData:YES];
            [self.beautyView configData:transShapeArr category:NvEditBeautyCategoryShape showTemporaryData:YES];
            [self.beautyView configData:transMicroShapeArr category:NvEditBeautyCategoryMicroShape showTemporaryData:YES];
        }
        if (beautyEffects.count > 0 || shapeEffects.count > 0 || microShapeEffects.count > 0) {
            //存在美颜数据 There is beauty data
            BOOL beautyValueable = [self checkValueableData:beautyEffects];
            BOOL shapeValueable = [self checkValueableData:shapeEffects];
            BOOL microShapeValueable = [self checkValueableData:microShapeEffects];
            if (beautyValueable) {
                [self.beautyView configData:beautyEffects category:NvEditBeautyCategoryBeauty showTemporaryData:YES];
                self.appliedBeautyEffects = [[NSMutableArray alloc] initWithArray:beautyEffects copyItems:YES];
            }else {
                [self.beautyView changeSwitchState:NvEditBeautyCategoryBeauty isOpen:NO];
            }
            if (shapeValueable) {
                [self.beautyView configData:shapeEffects category:NvEditBeautyCategoryShape showTemporaryData:YES];
                self.appliedShapeEffects = [[NSMutableArray alloc] initWithArray:shapeEffects copyItems:YES];
            }else {
                [self.beautyView changeSwitchState:NvEditBeautyCategoryShape isOpen:NO];
            }
            if (microShapeValueable) {
                [self.beautyView configData:microShapeEffects category:NvEditBeautyCategoryMicroShape showTemporaryData:YES];
                self.appliedMicroShapeEffects = [[NSMutableArray alloc] initWithArray:microShapeEffects copyItems:YES];
            }else {
                [self.beautyView changeSwitchState:NvEditBeautyCategoryMicroShape isOpen:NO];
            }

        }
    }
    else {
        [self.beautyView changeSwitchState:NvEditBeautyCategoryBeauty isOpen:NO];
        [self.beautyView changeSwitchState:NvEditBeautyCategoryShape isOpen:NO];
        [self.beautyView changeSwitchState:NvEditBeautyCategoryMicroShape isOpen:NO];
    }
    
}

#pragma mark - NvEditBeautyViewDelegate
- (void)nvEditBeautyViewFinishedButtonClicked:(NvEditBeautyView *)beautyView {
    NvTimelineData *data = [NvTimelineData sharedInstance];
    NSMutableArray *order = [data dataOrder];
    [order removeObject:@"Beauty"];
    [order addObject:@"Beauty"];
    [self checkAndHandleBeautyStrengthModel];
    for (NvBeautyTypeModel *model in self.appliedBeautyEffects) {
        model.isOperation = self.beautyView.beautySwitchOpen;
    }
    for (NvBeautyTypeModel *model in self.appliedShapeEffects) {
        model.isOperation = self.beautyView.shapeSwitchOpen;
    }
    for (NvBeautyTypeModel *model in self.appliedMicroShapeEffects) {
        model.isOperation = self.beautyView.microShapeSwitchOpen;
    }
    data.beautyArr = [[NSMutableArray alloc] initWithArray:self.appliedBeautyEffects copyItems:YES];
    data.shapeArr = [[NSMutableArray alloc] initWithArray:self.appliedShapeEffects copyItems:YES];
    data.microShapeArr = [[NSMutableArray alloc] initWithArray:self.appliedMicroShapeEffects copyItems:YES];
    [self.streamingContext removeTimeline:self.timeline];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nvEditBeautyView:(NvEditBeautyView *)beautyView category:(NvEditBeautyCategory)category applyModel:(NvBeautyTypeModel *)model {
    [self checkAndHandleEffectData:model category:category];
    if (category == NvEditBeautyCategoryBeauty && [model.fxName isEqualToString:@"ColorCorrect"]) {
        [self applyColorCorrectFilter:model];
    }else{
        [self applyEffect:self.timeline category:category model:model];
    }
    
    [self seekTimeline:_liveWindowPanel.currentTime];
}

- (void)nvEditBeautyView:(NvEditBeautyView *)beautyView forbiddenReplaceCategory:(NvEditBeautyCategory)category model:(NvBeautyTypeModel *)model {
    [self presentMakeupUnReplaceableAlertController];
}

- (void)presentMakeupUnReplaceableAlertController {
    
    [UIAlertController presentAlertFromVC:self
                                    title:nil
                                  message:NvLocalString(@"forbidden to modify this item", @"此整妆不支持修改此项")
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Sure", @"确定")
                       cancelButtonAction:nil
                        otherButtonAction:nil];

}

- (void)checkAndHandleEffectData:(NvBeautyTypeModel *)model category:(NvEditBeautyCategory)category {
    NSMutableArray *effectArr;
    
    if (category == NvEditBeautyCategoryBeauty) {
        effectArr = self.appliedBeautyEffects;
    }else if (category == NvEditBeautyCategoryShape) {
        effectArr = self.appliedShapeEffects;
    }else if (category == NvEditBeautyCategoryMicroShape) {
        effectArr = self.appliedMicroShapeEffects;
    }
    [self checkAndHandleEffectData:model efffectArr:effectArr];
}

- (void)checkAndHandleEffectData:(NvBeautyTypeModel *)model efffectArr:(NSMutableArray *)effectArr {
    if (!effectArr) {
        return;
    }
    if (!(model.fxName.length > 0 || model.degreeName.length > 0) || [model.fxName caseInsensitiveCompare:@"none"] == NSOrderedSame) {
        return;
    }
    if ([model.name containsString:NvLocalString(@"Strength", @"磨皮")] && model.value == 0) {
        return;
    }
    
    BOOL containModel = NO;
    for(NvBeautyTypeModel *item in effectArr) {
        if ((item.fxName.length > 0 && [item.fxName isEqualToString:model.fxName]) || (item.degreeName.length > 0 && [item.degreeName isEqualToString:model.degreeName])) {
            containModel = YES;
            item.value = model.value;
            item.uuid = model.uuid;
            item.extValue = model.extValue;
            item.switchSelected = model.switchSelected;
            item.degreeName = model.degreeName;
            item.canReplace = model.canReplace;
            break;
        }
    }
    if (!containModel) {
        NvBeautyTypeModel *item = [NvBeautyTypeModel new];
        item.value = model.value;
        item.uuid = model.uuid;
        item.extValue = model.extValue;
        item.switchSelected = model.switchSelected;
        item.fxName = model.fxName;
        item.degreeName = model.degreeName;
        item.name = model.name;
        item.type = model.type;
        item.canReplace = model.canReplace;
        [effectArr addObject:item];
    }
}

- (void)checkAndHandleBeautyStrengthModel {
    BOOL containBeautyStrength = NO;
    for(NvBeautyTypeModel *model in self.appliedBeautyEffects) {
        if([model.name containsString:NvLocalString(@"Strength", @"磨皮")]) {
            containBeautyStrength = YES;
            break;
        }
    }
    if (!containBeautyStrength) {
        NvBeautyTypeModel *model = [NvBeautyTypeModel new];
        model.fxName = @"Advanced Beauty Type Zero";
        model.name = NvLocalString(@"Strength Mode 2", @"磨皮2");
        model.value = 0;
        model.canReplace = YES;
        [self.appliedBeautyEffects addObject:model];
    }
}

- (void)applyEffect:(NvsTimeline *)timeline category:(NvEditBeautyCategory)category model:(NvBeautyTypeModel *)model {
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    for (int i=0; i<track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *fx = [NvSDKUtils getClipVideoFx:@"AR Scene" withClip:clip];
        if (!fx) {
            fx = [NvSDKUtils createClipVideoFx:@"AR Scene" withClip:clip];
            if (ARSCENE_MS || ARSCENE_MS_240) {
                [[fx getARSceneManipulate] setDetectionMode:NvsARSceneDetectionMode_SemiImage];
            }
            BOOL highVersion = [NvInitArScence isHighVersionPhone];
            if(highVersion) {
                [fx setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
            }
            [fx setBooleanVal:@"Max Faces Respect Min" val:YES];
//            if(ARSCENE_MS_240){
//                // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//                [fx setBooleanVal:@"Use Face Extra Info" val:YES];
//            }
            
        }
        [fx setBooleanVal:@"Beauty Effect" val:YES];
        [fx setBooleanVal:@"Beauty Shape" val:YES];
        [fx setBooleanVal:@"Face Mesh Internal Enabled" val:YES];
        [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
        [self applyFx:fx category:category model:model];
    }
}

- (void)applyFx:(NvsFx *)fx category:(NvEditBeautyCategory)category model:(NvBeautyTypeModel *)model {
    if (!fx || !(model.fxName.length > 0 || model.degreeName.length > 0) || [model.fxName caseInsensitiveCompare:@"none"] == NSOrderedSame) {
        return;
    }
    
    if (category == NvEditBeautyCategoryBeauty) {
        //美颜 beauty
        if ([model.fxName isEqualToString:@"Default Sharpen Enabled"]) {
            BOOL value = model.switchSelected;
            [fx setBooleanVal:model.fxName val:value];
        }else if ([model.fxName isEqualToString:@"Advanced Beauty Type Zero"]) {
            [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [fx setIntVal:@"Advanced Beauty Type" val:0];
            [fx setFloatVal:@"Beauty Strength" val:0];
            [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
            
        }else if ([model.fxName isEqualToString:@"Advanced Beauty Type One"]) {
            [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [fx setIntVal:@"Advanced Beauty Type" val:1];
            [fx setFloatVal:@"Beauty Strength" val:0];
            [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
            
        }else if ([model.fxName isEqualToString:@"Advanced Beauty Type Two"]) {
            [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [fx setIntVal:@"Advanced Beauty Type" val:2];
            [fx setFloatVal:@"Beauty Strength" val:0];
            [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
            
        }else if ([model.fxName isEqualToString:@"Advanced Beauty Type Three"]) {
            [fx setBooleanVal:@"Advanced Beauty Enable" val:YES];
            [fx setIntVal:@"Advanced Beauty Type" val:3];
            [fx setFloatVal:@"Beauty Strength" val:0];
            [fx setFloatVal:@"Advanced Beauty Intensity" val:model.value];
            
        }else if ([model.fxName isEqualToString:@"Beauty Strength"]){
            [fx setFloatVal:@"Advanced Beauty Intensity" val:0];
            [fx setFloatVal:model.fxName val:model.value];
        }else if ([model.fxName isEqualToString:@"Shiny"]){
            [fx setFloatVal:@"Advanced Beauty Matte Intensity" val:model.value];
            [fx setFloatVal:@"Advanced Beauty Matte Fill Radius" val:3+model.extValue*27];
        }else if ([model.fxName isEqualToString:@"Beauty Whitening"]){
            [self applyBeauty:fx lutWhiten:model.switchSelected];
            [fx setFloatVal:model.fxName val:model.value];
        }
        else if(![model.fxName containsString:@"Advanced Beauty Type"] && ![model.fxName isEqualToString:@""] && ![model.fxName isEqualToString:@"Beauty Strength"] && ![model.fxName isEqualToString:@"none"]){
            [fx setFloatVal:model.fxName val:model.value];
        }
    }else if (category == NvEditBeautyCategoryShape || category == NvEditBeautyCategoryMicroShape) {
        if (model.fxName.length > 0) {
            [fx setStringVal:model.fxName val:model.uuid];
        }
        if (model.degreeName.length > 0) {
            [fx setFloatVal:model.degreeName val:model.value];
        }
    }
}

- (void)applyColorCorrectFilter:(NvBeautyTypeModel *)model {
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    for (int i=0; i<track.clipCount; i++) {
        BOOL containTargetFx = NO;
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *targetFx;
        for (int j = 0; j < clip.fxCount; j++) {
            NvsVideoFx *fx = [clip getFxWithIndex:j];
            if ([fx.bultinVideoFxName isEqualToString:model.uuid] || [fx.videoFxPackageId isEqualToString:model.uuid]) {
                containTargetFx = YES;
                targetFx = fx;
                break;
            }
        }
        if (model.switchSelected) {
            if (!containTargetFx) {
                targetFx = [clip appendPackagedFx:model.uuid];
            }
            [targetFx setFilterIntensity:model.value];
        }else if (targetFx.bultinVideoFxName.length > 0 || targetFx.videoFxPackageId.length > 0){
            [clip removeFx:targetFx.index];
        }
    }
}

//切换美白 Switching whitening
- (void)applyBeauty:(NvsFx *)fx lutWhiten:(BOOL)isLutWhiten {
    NSString *imagePath;
    if (isLutWhiten) {
        /*
         轻言美白(模式B)
         Whitening (mode B)
         */
        NSString *path = [[NSBundle mainBundle] pathForResource:@"whitenLut" ofType:@"bundle"];
        imagePath = [path stringByAppendingPathComponent:@"WhiteB.mslut"];
        
    }else{
        /*
         美白(模式A)
         Whitening (mode A)
         */
        imagePath = @"";
        
    }
    [fx setStringVal:@"Whitening Lut File" val:imagePath];
    [fx setBooleanVal:@"Whitening Lut Enabled" val:isLutWhiten];
}

- (BOOL)checkValueableData:(NSMutableArray <NvBeautyTypeModel *>*)data {
    return data.firstObject.isOperation;
}

#pragma mark - NvLiveWindowPanelViewDelegate
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {

}
@end
