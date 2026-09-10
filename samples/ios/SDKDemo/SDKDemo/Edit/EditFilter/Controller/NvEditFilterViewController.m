//
//  NvEditFilterViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditFilterViewController.h"
#import <NvSDKCommon/NvLiveWindowPanelView.h>
#import <NvSDKCommon/NvAssetManager.h>
#import "NvsTimelineVideoFx.h"
#import "NvTimelineUtils.h"
#import "NvMoreFilterViewController.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvEditFilterView.h"
#import "NvCaptureFilterModel.h"
#import "NvsVideoFx.h"
#import "NvFilterDataSource.h"
#import "NvAdjustFxParamView.h"
#import <NvSDKCommon/NvInitArScence.h>

@interface NvEditFilterViewController ()<NvCaptureFilterViewDelegate,NvLiveWindowPanelViewDelegate,NvAdjustFxParamViewDelegate>

@property (nonatomic, strong) NvLiveWindowPanelView *liveWindowPanel;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;

@property (nonatomic, strong) NvAssetManager *assetManager;
///当前滤镜
///Current filter
@property (nonatomic, strong) NvsTimelineVideoFx *currentFx;
///当前model，用于保存到数据结构，和展示的NvCaptureFilterModel不一样
///The current model, which is used to save to the data structure, is different from the NvCaptureFilterModel shown
@property (nonatomic, strong) NvTimeFilterInfoModel *currentInfoModel;
///滤镜视图
///Filter view
@property (nonatomic, strong) NvFilterView  *filterView;
@property (nonatomic, strong) NvAdjustFxParamView *filterPrmView;
@property (nonatomic, assign) BOOL userChanged;
@end

@implementation NvEditFilterViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"Filter", @"滤镜");
    self.streamingContext = [NvSDKUtils getSDKContext];
    [self addSubViews];
    [self initTimeline];
    
    ///为了预览效果，删除当前主题
    ///To preview the effect, delete the current theme
    [self.timeline removeCurrentTheme];
    self.userChanged = NO;
    self.assetManager = [NvAssetManager sharedInstance];
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"filter" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_FILTER bundlePath:itemPath];
    [self.assetManager searchLocalAssets:ASSET_FILTER];
    
    ///已有的滤镜效果，在数组中找到该model设置选中
    ///With the existing filter effect, find the model Settings in the array and select them
    self.currentInfoModel = [NvTimelineData sharedInstance].timelineFilter ;
    if (self.currentInfoModel) {
        if (![self.currentInfoModel.name isEqualToString:@"无"]) {
            [self reloadDataWithSelectedModel];
        }
    }else{
        self.currentInfoModel = [[NvTimeFilterInfoModel alloc]init];
    }
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.assetManager setAssetInfoToUserDefaults:ASSET_FILTER];
    [self connectLiveWindow];
    if (self.filterView) {
        [self.filterView reloadData];
        [self reloadDataWithSelectedModel];
    }
}

- (void)reloadDataWithSelectedModel{
    [self.filterView reloadDataWithSelectedModel:self.currentInfoModel];
    self.filterView.strengthLabel.text = [NSString stringWithFormat:@"%@ %.f", NvLocalString(@"fxStrength", @"强度"),self.currentInfoModel.strength*100];
    if (self.currentInfoModel.categoryId == 2 && (self.currentInfoModel.kindId == 8||self.currentInfoModel.kindId == 9)){
        self.filterView.strengthSlider.hidden = YES;
        self.filterView.strengthLabel.hidden =  YES;
    }
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
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ///耗时操作放在这里
        NvFilterDataSource* dataSource = [[NvFilterDataSource alloc] initWithAspectRatio:AspectRatio_All];
        dispatch_async(dispatch_get_main_queue(), ^{
            ///回到主线程进行UI操作
            ///The time-consuming operations go here
            self.filterView = [[NvFilterView alloc] initWithDataSource:dataSource];
            self.filterView.delegate = self;
            [self.view addSubview:self.filterView];
            CGRect frame = self.filterView.frame;
            frame.origin.y = SCREENHEIGHT -93 * SCREENSCALE - INDICATOR - frame.size.height;
            self.filterView.frame = frame;
            [self.filterView backColor:UIColor.clearColor];
            
            if (!self.filterView.strengthLabel) {
                self.filterView.strengthSlider.maximumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
                self.filterView.strengthSlider.minimumTrackTintColor = [UIColor whiteColor];

                [self.filterView.strengthSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.filterView.topView.mas_centerY);
                    make.left.equalTo(self.filterView.mas_left).offset(110*SCREENSCALE);
                    make.right.equalTo(self.filterView.mas_right).offset(-45*SCREENSCALE);
                }];
                
                self.filterView.strengthLabel = [[UILabel alloc] init];
                self.filterView.strengthLabel.backgroundColor = [UIColor clearColor];
                self.filterView.strengthLabel.font = [UIFont systemFontOfSize:12*SCREENSCALE];
                self.filterView.strengthLabel.textColor = [UIColor whiteColor];
                self.filterView.strengthLabel.textAlignment = NSTextAlignmentCenter;
                self.filterView.strengthLabel.numberOfLines = 2;
                [self.filterView.topView addSubview:self.filterView.strengthLabel];
                [self.filterView.strengthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.equalTo(self.filterView.strengthSlider.mas_centerY);
                    make.left.equalTo(self.filterView.mas_left).offset(10*SCREENSCALE);
                    make.right.equalTo(self.filterView.strengthSlider.mas_left).offset(-10*SCREENSCALE);
                }];
            }
            
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
            
            CGFloat y = CGRectGetMaxY(self->_liveWindowPanel.frame) + 4*SCREENSCALE;
            CGRect sliderRect = [self.filterView convertRect:self.filterView.strengthSlider.frame toView:self.view];
            CGFloat height =  CGRectGetMaxY(sliderRect) - y;
            self.filterPrmView = [[NvAdjustFxParamView alloc] initWithFrame:CGRectMake(0, y, SCREENWIDTH, height) fxParams:nil translation:nil];
            self.filterPrmView.backgroundColor = self.view.backgroundColor;
            self.filterPrmView.delegate = self;
            self.filterPrmView.hidden = YES;
            [self.view addSubview:self.filterPrmView];
            
            [self reloadDataWithSelectedModel];
        });
    });

}

- (void)checkAssetExpValueList:(NvTimeFilterInfoModel *)model type:(NvsAssetPackageType)type {
    NvsAssetPackageManager *assetPackageManager = self.streamingContext.assetPackageManager;
    NSArray <NvsExpressionParam *>* expArr = [assetPackageManager getExpValueList:model.name type:type];
    NSDictionary<NSString*, NSString*>* translation = [assetPackageManager getTranslationMap:model.name type:type];
    if (type == NvsAssetPackageType_VideoFx) {
        self.filterPrmView.hidden = expArr.count > 0 ? NO : YES;
        self.filterView.strengthSlider.hidden = !self.filterPrmView.hidden;
        self.filterView.strengthLabel.hidden = self.filterView.strengthSlider.hidden;
        if(expArr.count > 0){
            CGFloat y = CGRectGetMaxY(self->_liveWindowPanel.frame) + 4*SCREENSCALE;
            CGRect sliderRect = [self.filterView convertRect:self.filterView.strengthSlider.frame toView:self.view];
            CGFloat height =  CGRectGetMaxY(sliderRect) - y;
            self.filterPrmView.frame = CGRectMake(0, y, SCREENWIDTH, height);
            [self.filterPrmView updateFxParams:expArr translation:translation];
        }
    }
    
}

#pragma mark finishClick——完成按钮点击
///method of finish button
- (void)finishClick:(UIButton *)button {
    if (self.userChanged) {
        NSMutableArray *order = [[NvTimelineData sharedInstance] dataOrder];
        [order removeObject:@"Theme"];
        [order removeObject:@"Filter"];
        [order addObject:@"Theme"];
        [order addObject:@"Filter"];
    }
    
    [NvTimelineData sharedInstance].timelineFilter = self.currentInfoModel;
    [self.streamingContext removeTimeline:self.timeline];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - NvLiveWindowPanelViewDelegate
- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {

}

#pragma mark - NvCaptureFilterViewDelegate
- (void)NvCaptureFilterView:(NvCaptureFilterView *)view withFilterModel:(NvBaseModel *)model{
    //    BOOL isHasDetection = [self.streamingContext.assetPackageManager hasDetectionInAssetPackage:filterModel.packageId type:NvsAssetPackageType_VideoFx];
    //    if (isHasDetection){
            if (![NvInitArScence getInitArFace]) {
                if (ARSCENE_MS){
                    [NvInitArScence initARFace:NvFaceMode_106];
                }else if (ARSCENE_MS_240){
                    [NvInitArScence initARFace:NvFaceMode_240];
                }
            }
    //    }
    
    NvCaptureFilterModel *filterModel = (NvCaptureFilterModel *)model;
    self.currentInfoModel.grayscale = filterModel.grayscale;
    self.currentInfoModel.strokeOnly = filterModel.strokeOnly;
    self.currentInfoModel.strength = 1;
    self.filterView.strengthLabel.text = [NSString stringWithFormat:@"%@ %.f", NvLocalString(@"fxStrength", @"强度"),self.currentInfoModel.strength*100];
    if (![model.displayName isEqualToString:NvLocalString(@"None", @"无")]) {
        
        self.currentInfoModel.name = model.builtinName ? model.builtinName : model.packageId;
    }else{
        
        self.currentInfoModel.name = NvLocalString(@"None", @"无");
    }

    self.currentInfoModel.strokeOnly = filterModel.strokeOnly;
    self.currentInfoModel.grayscale = filterModel.grayscale;
    self.currentInfoModel.categoryId = filterModel.categoryId;
    self.currentInfoModel.kindId = filterModel.kindId;
    [self checkAssetExpValueList:self.currentInfoModel type:NvsAssetPackageType_VideoFx];
    [NvTimelineUtils resetTimelineFilter:self.timeline filterData:self.currentInfoModel];
    self.currentFx = [self.timeline getFirstTimelineVideoFx];
    self.userChanged = YES;
    if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
        [self.liveWindowPanel playBackStart:[self.streamingContext getTimelineCurrentPosition:self.timeline] end:_timeline.duration];
    }
    
    if (filterModel.categoryId == 2 && (filterModel.kindId == 8||filterModel.kindId == 9)){
        self.filterView.strengthSlider.hidden = YES;
        self.filterView.strengthLabel.hidden =  YES;
    }
}

- (void)NvCaptureFilterView:(NvCaptureFilterView *)view sliderValueChanged:(UISlider *)slider{
    self.currentInfoModel.strength = slider.value;
    self.filterView.strengthLabel.text = [NSString stringWithFormat:@"%@ %.f", NvLocalString(@"fxStrength", @"强度"),slider.value*100];
    NvsTimelineVideoFx *firstFx = [self.timeline getFirstTimelineVideoFx];
    [firstFx setFilterIntensity:self.currentInfoModel.strength];
    self.userChanged = YES;
    if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
        [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    }

}

- (void)NvCaptureFilterView:(NvCaptureFilterView *)view moreClick:(UIButton *)sender{
    NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
    vc.editModel = self.editMode;
    vc.type = ASSET_FILTER;
    vc.categoryId = 2;
    vc.kind = NV_KIND_ID_ALL;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NvAdjustFxParamViewDelegate
- (void)nvAdjustFxParamView:(NvAdjustFxParamView *)view valueChanged:(nonnull NSArray<NvAjustFxParamModel *> *)models {
    if (view == self.filterPrmView) {
        for(NvAjustFxParamModel *model in models) {
            if (model.type == NvAjustFxParamCategoryColor) {
                NvsColor color;
                color.r = model.r;
                color.g = model.g;
                color.b = model.b;
                color.a = model.a;
                [self.currentFx setColorExprVar:model.name varValue:&color];
            }
            else if (model.type == NvAjustFxParamCategoryInt || model.type == NvAjustFxParamCategoryFloat) {
                [self.currentFx setExprVar:model.name varValue:model.currentValue];
            }
        }
        self.userChanged = YES;
        self.currentInfoModel.expModels = [NSMutableArray arrayWithArray:models];
    }
}

- (void)nvAdjustFxParamView:(NvAdjustFxParamView *)view endChange:(NSArray<NvAjustFxParamModel *> *)models {
    if (view == self.filterPrmView) {
        [NvTimelineUtils resetTimelineFilter:self.timeline filterData:self.currentInfoModel];
        self.currentFx = [self.timeline getFirstTimelineVideoFx];
        for(NvAjustFxParamModel *model in models) {
            if (model.type == NvAjustFxParamCategoryColor) {
                NvsColor color;
                color.r = model.r;
                color.g = model.g;
                color.b = model.b;
                color.a = model.a;
                [self.currentFx setColorExprVar:model.name varValue:&color];
            }
            else if (model.type == NvAjustFxParamCategoryInt || model.type == NvAjustFxParamCategoryFloat) {
                [self.currentFx setExprVar:model.name varValue:model.currentValue];
            }
        }
        self.userChanged = YES;
        self.currentInfoModel.expModels = [NSMutableArray arrayWithArray:models];
        if (self.streamingContext.getStreamingEngineState == NvsStreamingEngineState_Playback) {
            [self.streamingContext stop];
        }
        [self.liveWindowPanel playBackStart:0 end:_timeline.duration];
    }
}

// 定位某一时间戳的图像
- (void)seekTimeline:(int64_t)postion {
    if (![_streamingContext seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
