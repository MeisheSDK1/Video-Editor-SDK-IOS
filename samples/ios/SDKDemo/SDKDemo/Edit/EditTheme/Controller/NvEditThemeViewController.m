//
//  NvEditThemeViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/6/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvEditThemeViewController.h"
#import <NvSDKCommon/NvLiveWindowPanelView.h>
#import "NvMoreFilterViewController.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvAsset.h>
#import "NvTimelineData.h"
#import "NvTimelineUtils.h"
#import "NvsTimelineCaption.h"
#import "NvRectView.h"
#import "NvCaptionDialog.h"
#import "NvCaptureFilterView.h"
#import "NvEditThemeModel.h"
#import <NvSDKCommon/NvSDKUtils.h>

@interface NvEditThemeViewController ()<NvAssetManagerDelegate, NvLiveWindowPanelViewDelegate, NvCaptureFilterViewDelegate>

@property (nonatomic, strong) NvLiveWindowPanelView *liveWindowPanel;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;

@property (nonatomic, strong) NvAssetManager *assetManager;
///存储选择的音乐
///Store the selected music
@property (nonatomic, strong) NSMutableArray<NvMusicInfoModel *> *musicDataArray;
@property (nonatomic, strong) NvThemeInfoModel *themeInfo;

@property (nonatomic, strong) NvRectView *rectView;
@property (nonatomic, strong) NvCaptionDialog *changeDialog;
@property (nonatomic, strong) NvsTimelineCaption *currentCaption;

///主题视图
///Topic view
@property (nonatomic, strong) NvCaptureFilterView  *themeView;
///主题数组
///Topic array
@property (nonatomic, strong) NSMutableArray *themeDataSource;

@property (nonatomic, assign) BOOL originHaveTitle,originHaveTrailer;

@end

@implementation NvEditThemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.themeDataSource = [NSMutableArray array];
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.musicDataArray = [NSMutableArray arrayWithArray: [[NvTimelineData sharedInstance] musicDataArray]];
    
    [self addSubViews];
    [self initTimeline];
    [_liveWindowPanel connectTimeline:_timeline];
    [self seekTimeline:0];
    
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *firstClip = [videoTrack getClipWithIndex:0];
    NvsVideoClip *lastClip = [videoTrack getClipWithIndex:videoTrack.clipCount];
    if (firstClip.roleInTheme == NvsRoleInThemeTitle) {
        self.originHaveTitle = YES;
    }
    
    if (lastClip.roleInTheme == NvsRoleInThemeTrailer) {
        self.originHaveTrailer = YES;
    }
    
    ///配置数据
    ///config data
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
    
    NvEditThemeModel *item = [NvEditThemeModel new];
    item.coverName = @"NvsFilterNone";
    item.displayName = NvLocalString(@"None", nil);
    item.selected = NO;
    [self.themeDataSource addObject:item];
    ///查找本地资源包
    ///search theme asset package from local
    NSString *itemPath = [[NSBundle mainBundle] pathForResource:@"theme" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_THEME bundlePath:itemPath];
    [self.assetManager searchLocalAssets:ASSET_THEME];
    
    [self getDefaultData];
}

- (UIView *)leftNavigationBarItemView {
    return [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.assetManager setAssetInfoToUserDefaults:ASSET_THEME];
    [self connectLiveWindow];
    [self getDefaultData];
}

///获取默认数据
///Get default data
- (void)getDefaultData {
    NSString *themeId = [self.timeline getCurrentThemeId];
    AspectRatio ratio;
    switch (self.editMode) {
        case NvEditMode16v9:
            ratio = AspectRatio_16v9;
            break;
        case NvEditMode1v1:
            ratio = AspectRatio_1v1;
            break;
        case NvEditMode9v16:
            ratio = AspectRatio_9v16;
            break;
        case NvEditMode3v4:
            ratio = AspectRatio_3v4;
            break;
        case NvEditMode4v3:
            ratio = AspectRatio_4v3;
            break;
        case NvEditMode18v9:
            ratio = AspectRatio_18v9;
            break;
        case NvEditMode9v18:
            ratio = AspectRatio_9v18;
            break;
        case NvEditMode21v9:
            ratio = AspectRatio_21v9;
            break;
        case NvEditMode9v21:
            ratio = AspectRatio_9v21;
            break;
        case NvEditMode7v6:
            ratio = AspectRatio_7v6;
            break;
        case NvEditMode6v7:
            ratio = AspectRatio_6v7;
            break;
        default:
            ratio = AspectRatio_All;
            break;
    }
    ///将本地资源与工程中的预置资源拼在一起
    ///Combine local resources with pre-built resources in the project
    NSArray *array = [self.assetManager getUsableAssets:ASSET_THEME aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    for (NvAsset *asset in array) {
        if ([self isFilterExist:asset.uuid]){
            continue;
        }
        if ([asset isReserved]) {
            NvEditThemeModel *item = [NvEditThemeModel new];
            item.coverName = asset.coverUrl;
            [self initReservedAssetName:asset];
            if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
                item.displayName = asset.displayNamezhCN;
                    }else{
                        item.displayName = asset.displayName;
                    }
            item.packageId = asset.uuid;
            if ([item.packageId isEqualToString:themeId]) {
                item.selected = YES;
            } else {
                item.selected = NO;
            }
            [self.themeDataSource insertObject:item atIndex:1];
        }
    }
    for (NvAsset *asset in array) {
        if ([self isFilterExist:asset.uuid]){
            continue;
        }
        if (![asset isReserved]) {
            NvEditThemeModel *item = [NvEditThemeModel new];
            item.coverName = asset.coverUrl;
            [self initReservedAssetName:asset];
            if ([NvUtils currentLanguagesIsChinese] && asset.displayNamezhCN){
                item.displayName = asset.displayNamezhCN;
                    }else{
                        item.displayName = asset.displayName;
                    }
            item.packageId = asset.uuid;
            if ([item.packageId isEqualToString:themeId]) {
                item.selected = YES;
            } else {
                item.selected = NO;
            }
            [self.themeDataSource insertObject:item atIndex:1];
        }
    }
    
    [self.themeView configDataSource:self.themeDataSource];
}
//给内置资源包配置名字
//Configure the name of the built-in resource bundle
- (void)initReservedAssetName:(NvAsset *)asset {
    if ([asset isReserved]) {
        if ([asset.uuid isEqualToString:@"924EDA33-8FDF-435B-9DDE-414F9D07CB84"]) {
            asset.displayName = NvLocalString(@"Simple square", nil) ;
        }
        if ([asset.uuid isEqualToString:@"97489A20-5143-4923-9A3D-0F57ED030366"]) {
            asset.displayName = NvLocalString(@"New Year 2019", nil) ;
        }
    }
}

#pragma mark 查找数组中是否存在该数据，选择性添加到数组中
//Find if the data exists in the array and optionally add it to the array
- (BOOL)isFilterExist:(NSString *)uuid {
    for (NvEditThemeModel *item in self.themeDataSource) {
        if ([item.packageId isEqualToString:uuid])
            return YES;
    }
    return NO;
}

#pragma mark - 初始化timeline
/*
 根据数据初始化timeline
 Initialize Timeline based on the data
 */
- (void)initTimeline {
    self.timeline = [NvTimelineUtils createTimeline:self.editMode];
    [NvTimelineUtils recreateTimeline:self.timeline];
    self.themeInfo = [[NvTimelineData sharedInstance].themeInfo copy];
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubViews{
    self.liveWindowPanel = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    _liveWindowPanel.editMode = self.editMode;
    _liveWindowPanel.delegate = self;
    [self.liveWindowPanel hiddenVolumeButton];
    [self.view addSubview:_liveWindowPanel];
    
    self.rectView = [[NvRectView alloc] initWithFrame:self.liveWindowPanel.bounds type:NV_CAPTION];
    [self.rectView hiddenAllImage];
    self.rectView.delegate = self;
    [self.rectView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapScreen)]];
    [self.liveWindowPanel.liveWindow addSubview:self.rectView];
    [self.liveWindowPanel.controlPanelView bringSubviewToFront:self.liveWindowPanel];
    
    UIButton *finshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [finshBtn setImage:NvImageNamed(@"Nvcheck - material") forState:UIControlStateNormal];
    [finshBtn addTarget:self action:@selector(finshClick:) forControlEvents:UIControlEventTouchUpInside];
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
    
    self.themeView = [[NvCaptureFilterView alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, 100 * SCREENSCALE) HaveTopView:NO WithTopViewHeight:0 withMore:YES withlayout:nil];
    self.themeView.delegate = self;
    [self.themeView backColor:self.view.backgroundColor];
    [self.view addSubview:self.themeView];
    [self.themeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(line.mas_top);
        make.width.offset(SCREENWIDTH);
        make.height.offset(100 * SCREENSCALE);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.textColor = UIColor.whiteColor;
    label.alpha = 0.6;
    label.font = [NvUtils regularFontWithSize:12];
    label.text = NvLocalString(@"Edit text", @"片头处暂停可以修改文字");
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.themeView.mas_top);
        make.left.equalTo(self.view.mas_left).offset(13 * SCREENSCALE);
    }];
}

#pragma mark 拦截屏幕响应事件，不允许删除，必须保留
///Block screen response events, not allowed to delete, must be reserved
- (void)singleTapScreen {
    
}

- (void)connectLiveWindow {
    [_liveWindowPanel connectTimeline:_timeline];
    [self seekTimeline:_liveWindowPanel.currentTime];
}
     
- (void)finshClick:(UIButton *)sender{
    
    NvTimelineData *data = [NvTimelineData sharedInstance];
    data.themeInfo = self.themeInfo;
    NSMutableArray *order = [[NvTimelineData sharedInstance] dataOrder];
    [order removeObject:@"Theme"];
    [order removeObject:@"Filter"];
    [order addObject:@"Theme"];
    [order addObject:@"Filter"];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
       NvsVideoClip *firstClip = [videoTrack getClipWithIndex:0];
       NvsVideoClip *lastClip = [videoTrack getClipWithIndex:videoTrack.clipCount];
       //主题的片头和片尾会让视频轨道多出来一个转场，需要判断原来有没有，原来有现在没有需要删掉，原来没有现在有需要加上
       //The Title and Trailer of the theme will add an extra transition to the video track. It is necessary to judge whether there is one in the original, whether it needs to be deleted or not, and whether there is one in the original and now it needs to be added
       if (firstClip.roleInTheme == NvsRoleInThemeTitle) {
           if (!self.originHaveTitle) {
               //add
               NvTransitionInfoModel *info = [NvTransitionInfoModel new];
               info.builtinName = nil;
               info.packageId = @"theme";
               [[[NvTimelineData sharedInstance] transitionDataArray] insertObject:info atIndex:0];
           }
       } else {
           if (self.originHaveTitle) {
               //delete
               [[[NvTimelineData sharedInstance] transitionDataArray] removeObjectAtIndex:0];
           }
       }
       
       if (lastClip.roleInTheme == NvsRoleInThemeTrailer) {
           if (!self.originHaveTrailer) {
               //add
               NvTransitionInfoModel *info = [NvTransitionInfoModel new];
               info.builtinName = nil;
               info.packageId = @"theme";
               [[[NvTimelineData sharedInstance] transitionDataArray] addObject:info];
           }
       } else {
          if (self.originHaveTrailer) {
              //delete
              [[[NvTimelineData sharedInstance] transitionDataArray] removeLastObject];
          }
       }
       
    [self.streamingContext removeTimeline:self.timeline];
    [self.navigationController popViewControllerAnimated:YES];
}

// 定位某一时间戳的图像 seek video frame
- (void)seekTimeline:(int64_t)postion {
    if (![_streamingContext seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame])
        NSLog(@"定位时间线失败！Failed to seek timeline!");
}

///更新字幕框的位置
///Update the location of the subtitle box
- (void)updateCaptionView: (NvsTimelineCaption*) caption {
    NSArray *array = [caption getBoundingRectangleVertices];
    NSValue *leftTopValue = array[0];
    NSValue *leftBottomValue = array[1];
    NSValue *rightBottomValue = array[2];
    NSValue *rightTopValue = array[3];
    CGPoint topLeftCorner = [leftTopValue CGPointValue];
    CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
    CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
    CGPoint rightTopCorner = [rightTopValue CGPointValue];
    
    topLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:topLeftCorner];
    rightBottomCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightBottomCorner];
    bottomLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:bottomLeftCorner];
    rightTopCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightTopCorner];
    
    [self.rectView setPoints:@[[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:topLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:bottomLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightBottomCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightTopCorner toView:self.rectView]]]];
    if ([caption getTextAlignment] == NvsTextAlignmentLeft) {
        [self.rectView setTextAlign:NvLeft];
    } else if ([caption getTextAlignment] == NvsTextAlignmentCenter) {
        [self.rectView setTextAlign:NvCenter];
    } else if ([caption getTextAlignment] == NvsTextAlignmentRight) {
        [self.rectView setTextAlign:NvRight];
    }
    
    [_streamingContext seekTimeline:self.timeline timestamp:[_streamingContext getTimelineCurrentPosition:self.timeline] videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
}

- (void)sliderValueChanged:(float)value {
    ino64_t currentTime = self.timeline.duration*value;
    [_streamingContext seekTimeline:self.timeline timestamp:currentTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
    NSArray *captionarray = [self.timeline getCaptionsByTimelinePosition:[_streamingContext getTimelineCurrentPosition:self.timeline]];
    NvsTimelineCaption *caption = [self removeThemeCaption:captionarray].firstObject;
    self.currentCaption = caption;
    [self updateCaptionView:self.currentCaption];
}

- (void)didStreamingEngineStateChanged:(NvsStreamingEngineState)state {
    if (state == NvsStreamingEngineState_Playback) {
        self.rectView.hidden = YES;
    } else {
        NSArray *captionarray = [self.timeline getCaptionsByTimelinePosition:[_streamingContext getTimelineCurrentPosition:self.timeline]];
        NvsTimelineCaption *caption = [self removeThemeCaption:captionarray].firstObject;
        self.currentCaption = caption;
        if (self.currentCaption) {
            self.rectView.hidden = NO;
        }
        [self updateCaptionView:caption];
    }
}

- (void)rectView:(NvRectView *)rectView touchBeganPoint:(CGPoint)point {
    NSArray *captionarray = [self.timeline getCaptionsByTimelinePosition:[_streamingContext getTimelineCurrentPosition:self.timeline]];
    NvsTimelineCaption *caption = [self removeThemeCaption:captionarray].firstObject;
    self.currentCaption = caption;
    if (self.currentCaption) {
        NSArray *array = [caption getBoundingRectangleVertices];
        NSValue *leftTopValue = array[0];
        NSValue *leftBottomValue = array[1];
        NSValue *rightBottomValue = array[2];
        NSValue *rightTopValue = array[3];
        CGPoint topLeftCorner = [leftTopValue CGPointValue];
        CGPoint bottomLeftCorner = [leftBottomValue CGPointValue];
        CGPoint rightBottomCorner = [rightBottomValue CGPointValue];
        CGPoint rightTopCorner = [rightTopValue CGPointValue];
        
        topLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:topLeftCorner];
        rightBottomCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightBottomCorner];
        bottomLeftCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:bottomLeftCorner];
        rightTopCorner = [self.liveWindowPanel.liveWindow mapCanonicalToView:rightTopCorner];
        
        CGMutablePathRef pathRef=CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, NULL, topLeftCorner.x, topLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, bottomLeftCorner.x, bottomLeftCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightBottomCorner.x, rightBottomCorner.y);
        CGPathAddLineToPoint(pathRef, NULL, rightTopCorner.x, rightTopCorner.y);
        CGPathCloseSubpath(pathRef);
        bool isIn = CGPathContainsPoint(pathRef, nil, point, false);
        CGPathRelease(pathRef);
        if(isIn){
            [self.rectView setPoints:@[[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:topLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:bottomLeftCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightBottomCorner toView:self.rectView]],[NSValue valueWithCGPoint:[self.liveWindowPanel.liveWindow convertPoint:rightTopCorner toView:self.rectView]]]];
            self.changeDialog = [[[NSBundle mainBundle] loadNibNamed:@"CaptionDialog" owner:self options:nil] firstObject];
            [self.changeDialog setCaptionText:[caption getText]];
            [self.view addSubview:self.changeDialog];
            self.changeDialog.delegate = self;
            [self.changeDialog mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.top.equalTo(@(80*SCREENSCALE));
                make.width.equalTo(@(320*SCREENSCALE));
                make.height.equalTo(@(180*SCREENSCALE));
            }];
            [self.streamingContext stop];
        } else {
            if (self.liveWindowPanel.controlPanelView.hidden == YES) {
                [self.liveWindowPanel showControllPanel];
            } else {
                [self.liveWindowPanel playAtTime:[_streamingContext getTimelineCurrentPosition:self.timeline]];
            }
        }
    } else {
        if (self.liveWindowPanel.controlPanelView.hidden == YES) {
            [self.liveWindowPanel showControllPanel];
        } else {
            [self.liveWindowPanel playAtTime:[_streamingContext getTimelineCurrentPosition:self.timeline]];
        }
    }
}

// MARK: NvCaptionDialogDelegate
- (void)captionDialog:(NvCaptionDialog *)captionDialog clickButtonIndex:(NSInteger)index {
    //添加字幕页面修改字幕
    //Add caption page to modify caption
    if (self.changeDialog == captionDialog) {
        if (index == 0) {
            NSString* text = [captionDialog getCaptionText];
            self.themeInfo.isChange = YES;
            [self.timeline setThemeTitleCaptionText:text];
            self.themeInfo.themeString = text;
            [self.timeline applyTheme:self.themeInfo.themeName];
            NvTimelineData *timelineData = [NvTimelineData sharedInstance];
            
            [NvTimelineUtils resetCaption:self.timeline captionDataArray:timelineData.captionDataArray];
            [_streamingContext seekTimeline:self.timeline timestamp:[_streamingContext getTimelineCurrentPosition:self.timeline] videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
            [self updateCaptionView:self.currentCaption];
        } else {
            [self updateCaptionView:self.currentCaption];
        }
        [self.changeDialog removeFromSuperview];
        self.changeDialog = nil;
    }
}

#pragma mark - NvCaptureFilterViewDelegate
- (void)NvCaptureFilterView:(NvCaptureFilterView *)view withFilterModel:(NvBaseModel *)model{
    self.themeInfo = NvThemeInfoModel.new;
    self.themeInfo.themeName = model.packageId;
    NvTimelineData *timelineData = [NvTimelineData sharedInstance];
    timelineData.themeInfo = self.themeInfo;
    
    NSMutableArray *musicData;
    if (model.packageId) {
        musicData = NSMutableArray.new;
    } else {
        self.themeInfo = nil;
        musicData = [NSMutableArray arrayWithArray:self.musicDataArray];
    }
    [[NvTimelineData sharedInstance] setMusicDataArray:musicData];
    [NvTimelineUtils resetMusicTrack:self.timeline musicDataArray:musicData];
    
    [NvTimelineUtils resetTheme:self.timeline themeInfo:self.themeInfo];
    [self addThemeText];
    
    [NvTimelineUtils resetVideoFx:self.timeline videoFxDataArray:timelineData.videoFxDataArray timelineData:timelineData];
    [NvTimelineUtils resetTimelineFilter:self.timeline filterData:timelineData.timelineFilter];
    [NvTimelineUtils resetVideoFx:self.timeline timelineFilterArray:timelineData.timelineFilterArray];
    [NvTimelineUtils resetKeyframesFilter:self.timeline timelineData:timelineData];
    
    [NvTimelineUtils resetCaption:self.timeline captionDataArray:timelineData.captionDataArray];
    
    //更改播放器的总时间
    //Change the total time of the player
    [_liveWindowPanel connectTimeline:_timeline];
    [self.liveWindowPanel playAtTime:0];
}

- (void)NvCaptureFilterView:(NvCaptureFilterView *)view moreClick:(UIButton *)sender{
    NvMoreFilterViewController *vc = [[NvMoreFilterViewController alloc]init];
    vc.editModel = self.editMode;
    vc.type = ASSET_THEME;
    vc.categoryId = 0;
    vc.kind = 0;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 给主题model添加主题字幕信息
///Add theme subtitle information to the theme model
- (void)addThemeText{
    NvsTimelineCaption* caption = [self.timeline getFirstCaption];
    while (caption) {
        if (caption.category == NvsThemeCategory && caption.roleInTheme != NvsRoleInThemeGeneral) {
            NSLog(@"%d,%d,%@",caption.category,caption.roleInTheme,caption.getText);
            self.themeInfo.themeString = [caption getText];
            self.themeInfo.thenmeRoleInTheme = caption.roleInTheme;
            if (!self.themeInfo.isChange) {
                self.themeInfo.themeString = NvLocalString(@"Default subject caption", @"美摄-记录美好生活");
                [self.timeline setThemeTitleCaptionText:self.themeInfo.themeString];
                [self.timeline applyTheme:self.themeInfo.themeName];
            }
            
            break;
        }else{
   
        }
        caption = [self.timeline getNextCaption:caption];
    }
}

- (void)removeAllThemeCaption {
    NSMutableArray *themeArray = [NSMutableArray array];
    for (NvCaptionInfoModel *captionModel in [[NvTimelineData sharedInstance] captionDataArray]) {
        if (captionModel.category == NvsThemeCategory && captionModel.roleInTheme == NvsRoleInThemeGeneral) {
            [themeArray addObject:captionModel];
        }
    }
    [[[NvTimelineData sharedInstance] captionDataArray] removeObjectsInArray:themeArray];
}

#pragma mark NvAssetManagerDelegate
///安装完成的回调
///A callback after the installation is complete
- (void)onFinishAssetPackageInstallation:(NSString *)uuid {
    NSLog(@"-------%@",uuid);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCurrentCaption:(NvsTimelineCaption *)currentCaption{
    if (currentCaption.category == NvsThemeCategory && currentCaption.roleInTheme != NvsRoleInThemeGeneral) {
        _currentCaption = currentCaption;
    }else{
        _currentCaption = nil;
    }
}

/// 从所有的caption中过滤出主题中带的字幕
/// Filter out the caption in the theme from all Captions
- (NSArray *)removeThemeCaption:(NSArray *)captionArray {
    NSMutableArray *array = [NSMutableArray array];
    [captionArray enumerateObjectsUsingBlock:^(NvsTimelineCaption*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.category == NvsThemeCategory && obj.roleInTheme != NvsRoleInThemeGeneral) {
            [array addObject:obj];
        } else {
            
        }
    }];
    return [array copy];
}

@end
