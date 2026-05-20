//
//  NvEditMakeUpController.m
//  SDKDemo
//
//  Created by ms on 2021/10/13.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvEditMakeUpController.h"
#import <NvSDKCommon/NvLiveWindowPanelView.h>
#import <NvSDKCommon/NvAssetManager.h>
#import "NvsTimelineVideoFx.h"
#import "NvTimelineUtils.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvsVideoFx.h"
#import "NvMakeupModel.h"
#import "NvEditMakeUpView.h"
#import <NvSDKCommon/NvInitArScence.h>
#import "NvSDKMakeupUtils.h"
#import "NvMakeupToolManager.h"

@interface NvEditMakeUpController ()<NvLiveWindowPanelViewDelegate, NvEditMakeUpViewDelegate,NvMakeupToolManagerDelegate>
@property (nonatomic, strong) NvLiveWindowPanelView *liveWindowPanel;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
//已应用的全部美妆效果数据
// All applied Beauty makeup effect data
@property (nonatomic, strong) NvMakeupToolModel *currentMakeupTotalModel;
//美妆视图
//Beauty makeup view
@property (nonatomic, strong) NvEditMakeUpView *makeupView;
@property (nonatomic, strong) NvsTimelineVideoFx *currentFx;

@property (nonatomic, copy) NSString *colorCorrectId;
@property (nonatomic, strong) NvsTimelineVideoFx *colorCorrectFilter;
@property (nonatomic, strong) NvMakeupToolManager *makeupManager;
//此次进入美妆是否点击了妆容效果，包括点击“无”选项
// Whether you have clicked the makeup effect this time, including clicking the "None" option
@property (nonatomic, assign) BOOL appliedVariableMakeupThisTime;
@end

@implementation NvEditMakeUpController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"capture.makeup", @"美妆");
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.appliedVariableMakeupThisTime = NO;
    [self initARFace];
    [self addSubViews];
    [self initTimeline];
    self.makeupManager = [NvMakeupToolManager new];
    self.makeupManager.delegate = self;
    self.makeupManager.mode = NvMakeupModulerModeEdit;
    self.currentMakeupTotalModel =  [NvTimelineData sharedInstance].timelineMakeupModel;
}


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
    [_liveWindowPanel connectTimeline:_timeline];
    [self.liveWindowPanel hiddenVolumeButton];
    [self seekTimeline:0];
}


#pragma mark 连接预览窗口并且播放
///connect liveWindow
- (void)connectLiveWindow {
    [_liveWindowPanel connectTimeline:_timeline];
    [self seekTimeline:_liveWindowPanel.currentTime];
}

#pragma mark 添加子视图
///add subviews
- (void)addSubViews{
    self.liveWindowPanel = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    _liveWindowPanel.delegate = self;
    _liveWindowPanel.editMode = self.editMode;
    [self.view addSubview:_liveWindowPanel];

    UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finshBtn setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finshBtn addTarget:self action:@selector(finishClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finshBtn];
    [finshBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-12 * SCREENSCALE - INDICATOR);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.offset(25 * SCREENSCALE);
        make.height.offset(20 * SCREENSCALE);
    }];

    UIView *line = [[UIView alloc] init];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(finshBtn.mas_top).offset(- 12 * SCREENSCALE);
        make.width.offset(SCREENWIDTH);
        make.height.offset(0.5);
    }];

    self.makeupView = [[NvEditMakeUpView alloc] initWithFunctionUse:NvEditMakeUpFunctionEdit Frame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 280 * SCREENSCALE)];
    self.makeupView.backgroundColor = [UIColor clearColor];
    self.makeupView.delegate = self;
    [self.view addSubview:self.makeupView];
    [self.makeupView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line.mas_top).offset(0 * SCREENSCALE);
        make.right.mas_equalTo(self.view.mas_right);
        make.left.mas_equalTo(self.view.mas_left);
        make.top.mas_equalTo(self.liveWindowPanel.mas_bottom);
    }];
}

#pragma mark - NvEditMakeUpViewDelegate
- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView applyVariableMakeupEffect:(NSString *)path {
    self.appliedVariableMakeupThisTime = YES;
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    for (int i = 0; i<track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *fx = [NvSDKMakeupUtils getClipVideoFx:@"AR Scene" withClip:clip];
        if (!fx) {
            fx = [NvSDKMakeupUtils createClipVideoFx:@"AR Scene" withClip:clip];
            if (ARSCENE_MS || ARSCENE_MS_240) {
                [[fx getARSceneManipulate] setDetectionMode:NvsARSceneDetectionMode_SemiImage];
            }
            [fx setBooleanVal:@"Max Faces Respect Min" val:YES];
            
//            if(ARSCENE_MS_240){
//                // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//                [fx setBooleanVal:@"Use Face Extra Info" val:YES];
//            }
        }
        self.makeupManager.clip = clip;
        if (path.length > 0) {
            [self.makeupManager applyMakeupEffect:path arsceneFx:fx];
        }else{
            [self.makeupManager removeAllMakeupEffects:fx];
        }
    }
    
    //重置已应用美妆为本次点击的整妆效果
    //Reset the applied makeup to the full makeup effect of this click
    self.currentMakeupTotalModel = [self.makeupManager getEffectModel];
    [self seekTimeline];
}

- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView applySingleKindMakeupEffect:(NvMakeupEffectModel *)effectModel {
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    //模型转换 Model transformation
    NSMutableArray *transformArr = [NSMutableArray array];
    if(effectModel.makeup.count > 0){
        for (NvMakeupEffectContentModel *model in effectModel.makeup) {
            NvMakeupToolEffectModel *transformModel = [self transformToMakeupToolEffectModel:model makeupId:effectModel.makeupId];
            [transformArr addObject:transformModel];
        }
    }else if(effectModel){
        NvMakeupToolEffectModel *transformModel = [self transformToMakeupToolEffectModel:nil makeupId:effectModel.makeupId];
        [transformArr addObject:transformModel];
    }
    
    
    //应用特效 Applied special effect
    for (int i = 0; i<track.clipCount; i++) {
        NvsVideoClip *clip = [track getClipWithIndex:i];
        NvsVideoFx *fx = [NvSDKMakeupUtils getClipVideoFx:@"AR Scene" withClip:clip];
        if (!fx) {
            fx = [NvSDKMakeupUtils createClipVideoFx:@"AR Scene" withClip:clip];
            if (ARSCENE_MS || ARSCENE_MS_240) {
                [[fx getARSceneManipulate] setDetectionMode:NvsARSceneDetectionMode_SemiImage];
            }
            [fx setBooleanVal:@"Max Faces Respect Min" val:YES];
            BOOL highVersion = [NvInitArScence isHighVersionPhone];
            if(highVersion) {
                [fx setBooleanVal:@"AI Face Occlusion Enabled" val:YES];
            }
//            if(ARSCENE_MS_240){
//                // !!!: 设置后就会走检测， 不需要设置 3.12.0+
//                [fx setBooleanVal:@"Use Face Extra Info" val:YES];
//            }
        }
        [fx setStringVal:@"Makeup Compound Package Id" val:@""];
        for(NvMakeupToolEffectModel *transformModel in transformArr) {
            for(NvMakeupToolElementModel *element in transformModel.params) {
                [NvTimelineUtils applyMakeupToolElements:fx item:element packagePath:nil reset:NO];
            }
        }
        [fx setFloatVal:@"Makeup Intensity" val: transformArr.count > 0 ? 1 : 0];
    }
    
    if (self.currentMakeupTotalModel.effectContent.makeup > 0) {
        //已应用的美妆不为空 Applied beauty is not empty
        
        for(NvMakeupToolEffectModel *effect in transformArr) {
            BOOL contained = NO;
            NvMakeupToolEffectModel *toRemovedItem;
            for(NvMakeupToolEffectModel *containedEffect in self.currentMakeupTotalModel.effectContent.makeup) {
                if ([effect.type containsString:containedEffect.type]) {
                    contained = YES;
                    toRemovedItem = containedEffect;
                    break;
                }
            }
            if (contained && toRemovedItem) {
                [self.currentMakeupTotalModel.effectContent.makeup removeObject:toRemovedItem];
            }
        }
        [self.currentMakeupTotalModel.effectContent.makeup addObjectsFromArray:transformArr];
    } else {
        //尚未应用任何美妆 No beauty has been applied yet
        self.currentMakeupTotalModel.effectContent.makeup = [NSMutableArray arrayWithArray:transformArr];
    }
    [self seekTimeline];
}

- (void)nvEditMakeUpView:(NvEditMakeUpView *)makeupView forbiddenReplaceMakeupEffect:(NvMakeupEffectModel *)makeupModel {
    [self presentMakeupUnReplaceableAlertController];
}

- (NvMakeupToolModel *)nvEditMakeUpViewGetCurrentMakeupTotalModel:(NvEditMakeUpView *)makeupView {
    return self.currentMakeupTotalModel;
}

- (NvMakeupToolEffectModel *)transformToMakeupToolEffectModel:(NvMakeupEffectContentModel *)model makeupId:(NSString *)makeupId {
    if (model.makeupId.length > 0) {
        NSString *prefixStr = [@"Makeup " stringByAppendingString:model.makeupId];
        NvMakeupToolEffectModel *transformedModel = [NvMakeupToolEffectModel new];
        transformedModel.canReplace = model.canReplace;
        transformedModel.type = model.makeupId;
        NvMakeupToolElementStringModel *packageIdItem = [NvMakeupToolElementStringModel new];
        packageIdItem.type = @"string";
        packageIdItem.key = model.className;
        packageIdItem.value = model.uuid;
        
        NvMakeupToolElementFloatModel *intensityItem = [NvMakeupToolElementFloatModel new];
        intensityItem.type = @"float";
        intensityItem.key = [prefixStr stringByAppendingString:@" Intensity"];
        intensityItem.value = model.intensity;
        
        NvMakeupToolElementColorModel *colorItem = [NvMakeupToolElementColorModel new];
        colorItem.type = @"color";
        colorItem.key = [prefixStr stringByAppendingString:@" Color"];
        NvsColor color;
        if(model.color.length > 0){
            color = [self nvsColorWithValue:model.color];
        }else{
            color.r = 0;
            color.g = 0;
            color.b = 0;
            color.a = 0;
        }
        colorItem.r = color.r;
        colorItem.g = color.g;
        colorItem.b = color.b;
        colorItem.a = color.a;
        
        transformedModel.params = @[packageIdItem,intensityItem,colorItem];
        return transformedModel;
    }
    NSString *prefixStr = [@"Makeup " stringByAppendingString:makeupId];
    NvMakeupToolEffectModel *transformedModel = [NvMakeupToolEffectModel new];
    transformedModel.type = makeupId;
    NvMakeupToolElementStringModel *packageIdItem = [NvMakeupToolElementStringModel new];
    packageIdItem.type = @"string";
    packageIdItem.key = [prefixStr stringByAppendingString:@" Package Id"];
    packageIdItem.value = @"";
    
    NvMakeupToolElementFloatModel *intensityItem = [NvMakeupToolElementFloatModel new];
    intensityItem.type = @"float";
    intensityItem.key = [prefixStr stringByAppendingString:@" Intensity"];
    intensityItem.value = 0;
    
    NvMakeupToolElementColorModel *colorItem = [NvMakeupToolElementColorModel new];
    colorItem.type = @"color";
    colorItem.key = [prefixStr stringByAppendingString:@" Color"];

    colorItem.r = 0;
    colorItem.g = 0;
    colorItem.b = 0;
    colorItem.a = 0;
    
    transformedModel.params = @[packageIdItem,intensityItem,colorItem];
    return transformedModel;
}

// 定位某一时间戳的图像
- (void)seekTimeline {
    int flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster | NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    if (![self.streamingContext seekTimeline:self.timeline timestamp:currentTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag]) {
        NSLog(@"Failed to seek timeline!");
    }
}


- (NvsColor)nvsColorWithValue:(NSString *)value {
    NSArray *arr = [value componentsSeparatedByString:@","];
    NvsColor color;
    color.r = 0;
    color.g = 0;
    color.b = 0;
    color.a = 0;
    if (arr.count == 4) {
        color.r = [arr[0] floatValue];
        color.g = [arr[1] floatValue];
        color.b = [arr[2] floatValue];
        color.a = [arr[3] floatValue];
    }
    return color;
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

#pragma mark finishClick——完成按钮点击
///method of finish button
- (void)finishClick:(UIButton *)button {
    NSMutableArray *order = [[NvTimelineData sharedInstance] dataOrder];
    [NvTimelineData sharedInstance].timelineMakeupModel = self.currentMakeupTotalModel;
    if (self.appliedVariableMakeupThisTime) {
        [order removeObject:@"Makeup"];
        [order addObject:@"Makeup"];
        NvMakeupToolEffectContentModel *effectContent = self.currentMakeupTotalModel.effectContent;
        if(effectContent.beauty.count > 0 || effectContent.shape.count > 0 || effectContent.microShape.count > 0) {
            [order removeObject:@"Beauty"];
            [[NvTimelineData sharedInstance].beautyArr removeAllObjects];
            [[NvTimelineData sharedInstance].shapeArr removeAllObjects];
            [[NvTimelineData sharedInstance].microShapeArr removeAllObjects];
        }
    }
    [self.streamingContext removeTimeline:self.timeline];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NvLiveWindowPanelViewDelegate
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {

}

// 定位某一时间戳的图像
- (void)seekTimeline:(int64_t)postion {
    if (![_streamingContext seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster | NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
}

- (NvMakeupToolModel *)currentMakeupTotalModel {
    if (!_currentMakeupTotalModel) {
        _currentMakeupTotalModel = [NvMakeupToolModel new];
    }
    return _currentMakeupTotalModel;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
