//
//  NvThemeShootingEditVC.m
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/3.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvThemeShootingEditVC.h"
#import <NvSDKCommon/NvLiveWindowPanelView.h>
#import <NvSDKCommon/NvCompileViewController.h>
#import "NvStreamingSdkCore.h"

#import <NvSDKCommon/NvSDKUtils.h>
#import "UIImage+YYWebImage.h"
#import "NvTimelineUtils.h"
#import "YYModel.h"

#import "NvThemeShootItemModel.h"
#import "NvThemeShootCVCell.h"
#import "NvThemeSOperationView.h"
#import "NvCaptureFilterModel.h"
#import "NvCompoundCaptionModel.h"
#import "NvInputCaptionVC.h"

@interface NvThemeShootingEditVC ()<NvLiveWindowPanelViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,NvThemeSOperationViewDelegate,NvInputCaptionVCDelegate,NvCompileViewControllerDelegate>

@property (nonatomic, strong) NvsStreamingContext *streamingContext;

@property (nonatomic, strong) NvLiveWindowPanelView *liveWindow;

@property (nonatomic, strong) NvsTimeline *timeline;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NvThemeSOperationView *operationView;

@property (nonatomic, strong) NvThemeShootItemModel *currentItemModel;

@property (nonatomic, strong) NSString *compileFilePath;

@end

@implementation NvThemeShootingEditVC

-(void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    self.streamingContext = [NvSDKUtils getSDKContext];
    self.streamingContext.delegate = nil;
    
    [self createTimeline];
    [self configData];
    [self configAddHeaderAndCredits];
    
    [self addExportBtn];
    [self addMainView];
    
    [self.liveWindow playAtTime:0];
    [self.collectionView reloadData];
}

#pragma mark 生命周期
///Life cycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    [self.liveWindow playAtTime:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
}

- (UIView *)leftNavigationBarItemView {
    UIButton *backButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:15 image:[UIImage imageNamed:@"icon_back"]];
    backButton.frame = CGRectMake(0, 0, 30, 44);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREENSCALE, 0, 0);
    __weak typeof(self)weakSelf = self;
    __weak typeof(_timeline)weakTimeline = _timeline;
    [backButton nv_BtnClickHandler:^{
        [weakSelf.streamingContext stop];
        [NvTimelineUtils removeTimeline:weakTimeline];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    return backButton;
}

#pragma mark 添加导入按钮
///Add import button
- (void)addExportBtn{
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [rightBtn setTitle:NvLocalString(@"Export", @"导出") forState:UIControlStateNormal];
    [rightBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14*SCREENSCALE];
    [rightBtn addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.exclusiveTouch = YES;
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50*SCREENSCALE, 27*SCREENSCALE)];
    rightView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    rightBtn.frame = CGRectMake(0, 0, 50*SCREENSCALE, 27*SCREENSCALE);
    [rightView addSubview:rightBtn];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightView];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
}

#pragma mark - rightBtnClicked
- (void)rightBtnClicked{
    self.compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:_timeline outputPath:_compileFilePath];
}

#pragma mark 添加主视图
///Add master view
- (void)addMainView{
    self.liveWindow = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, NV_STATUSBARHEIGHT + NV_NAV_BAR_HEIGHT, self.view.width, self.view.width)];
    self.liveWindow.editMode = self.editMode;
    self.liveWindow.liveWindow.hdrDisplayMode = NvsLiveWindowHDRDisplayMode_SDR;
    self.liveWindow.delegate = self;
    [self.liveWindow hiddenVolumeButton];
    [self.view addSubview:self.liveWindow];
    
    [self connectTimeline];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(66 * SCREENSCALE, 100*SCREENSCALE);
    layout.minimumLineSpacing = 10*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 15*SCREENSCALE, 0, 15*SCREENSCALE);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[NvThemeShootCVCell class] forCellWithReuseIdentifier:@"NvThemeShootCVCell"];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.liveWindow.mas_bottom).offset(88 * SCREENSCALE);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.offset(105 * SCREENSCALE);
    }];
    

    self.operationView = [[NvThemeSOperationView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.liveWindow.frame), SCREENWIDTH, SCREENHEIGHT -  self.liveWindow.height - NV_NAV_BAR_HEIGHT - NV_STATUSBARHEIGHT)];
    self.operationView.hidden = YES;
    self.operationView.delegate = self;
    [self.view addSubview:self.operationView];
    [self.operationView configFilterArray:AspectRatio_9v16];
    [self.operationView configFilter:@"" withValue:0];
}

#pragma mark 创建timeline
///Create timeline
- (void)createTimeline{
    self.timeline = [NvTimelineUtils createTimelineOrdinary:self.editMode];
    if (!self.timeline) {
        return;
    }
}

- (NvsVideoFx *)getTransform2DWithClip:(NvsVideoClip *)clip {
    for(int i = 0;i<clip.fxCount;i++) {
        NvsVideoFx *fx = [clip getFxWithIndex:i];
        if ([fx.bultinVideoFxName isEqualToString:@"Transform 2D"] && fx.videoFxType == NvsVideoFxType_Builtin) {
            return fx;
        }
    }
    return nil;
}


/**
 给timeline填充数据
 Fill the timeline with data
 */
- (void)configData{
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    
    for (int i = 0; i<self.currentModel.shotInfos.count; i++) {
        NvShotInfoModel *model = self.currentModel.shotInfos[i];
        
        model.shotStart = self.timeline.duration;
        
        NvsVideoClip *clip = nil;
        
        if (model.speed) {
            int64_t trimin = 0;
            int64_t trimOut = 0;
            int64_t oriDuration = 0;
            int64_t tempDuration = 0;
            
            for (int j = 0; j < model.speed.count; j++) {
                NvSpeedModel *speedModel = model.speed[j];
                
                oriDuration = (speedModel.end - speedModel.start)*(speedModel.speed0+speedModel.speed1)/2.0;
                
                trimin = tempDuration;
                trimOut = trimin+oriDuration;
                
                speedModel.start = trimin;
                speedModel.end = trimOut;
                
                tempDuration = speedModel.end;

            }
            
            
            for (int j = 0; j < model.speed.count; j++) {
                NvSpeedModel *speedModel = model.speed[j];
                clip = [videoTrack appendClip:model.sourcePath trimIn:speedModel.start trimOut:speedModel.end];
                if (self.needRotate) {
                    [clip setExtraVideoRotation:NvsExtraVideoRotation_270];
                }
                [clip changeVariableSpeed:speedModel.speed0 endSpeed:speedModel.speed1 keepAudioPitch:YES];
                model.transIndex = clip.index;
             }
        }else{
            clip = [videoTrack appendClip:model.sourcePath trimIn:0 trimOut:model.duration];
            if (self.needRotate) {
                [clip setExtraVideoRotation:NvsExtraVideoRotation_270];
            }
            model.transIndex = clip.index;
            
        }
        
        model.duration = self.timeline.duration;
    }
    
    for (int i = 0; i < videoTrack.clipCount; i++) {
        [videoTrack setBuiltinTransition:i withName:@""];
        [videoTrack setPackagedTransition:i withPackageId:@""];
    }
    
    for (int i = 0; i < self.currentModel.shotInfos.count; i++) {
        NvThemeShootItemModel *itemModel = [[NvThemeShootItemModel alloc]init];
        NvShotInfoModel *model = self.currentModel.shotInfos[i];
        itemModel.shotModel = model;
        
        if (model.trans && model.trans.length != 0) {
            if (![videoTrack setBuiltinTransition:model.transIndex withName:model.trans]) {
                [videoTrack setPackagedTransition:model.transIndex withPackageId:model.trans];
            }
        }else{
            [videoTrack setBuiltinTransition:model.transIndex withName:@""];
            [videoTrack setPackagedTransition:model.transIndex withPackageId:@""];
        }
        
        NvsTimelineCompoundCaption *caption = nil;
        if (model.compoundCaption && model.compoundCaption.length != 0) {
            caption =[self.timeline addCompoundCaption:model.shotStart duration:model.duration compoundCaptionPackageId:model.compoundCaption];
        }
        
        itemModel.compoundCaption = caption;
        itemModel.displayName = [NSString stringWithFormat:@"%@%d",NvLocalString(@"Clip", @"片段"),i + 1];
        itemModel.coverImage = [self.streamingContext grabImageFromTimeline:self.timeline timestamp:model.shotStart+1*NV_TIME_BASE proxyScale:nil];
        itemModel.type = 2;
        
        [self.dataArray addObject:itemModel];
    }
    
    NvsAudioTrack *audioTrack = [self.timeline getAudioTrackByIndex:0];
    
    int64_t audioDuration = audioTrack.duration;
    if ([self checkString:self.currentModel.music]) {
        [videoTrack setVolumeGain:0 rightVolumeGain:0];
        while (audioDuration < self.currentModel.musicDuration) {
            [audioTrack addClip:[self.dirPath stringByAppendingPathComponent:self.currentModel.music] inPoint:audioDuration trimIn:0 trimOut:videoTrack.duration];
            audioDuration = audioTrack.duration;
        }
        
        if (self.currentModel.needControlMusic) {
            NvsAudioClip *lastAudioClip = [audioTrack getClipWithIndex:audioTrack.clipCount -1];
            lastAudioClip.fadeOutDuration = self.currentModel.musicFadingTime;
        }
    }

    NvsTimelineVideoFx *fx = [self.timeline addPackagedTimelineVideoFx:0 duration:self.timeline.duration videoFxPackageId:self.currentModel.timelineFilter];
    [fx setFilterIntensity:1.0f];
}

/**
 添加片头片尾
 Add titles and endings
 */
- (void)configAddHeaderAndCredits{
    
    NvsTimelineVideoFx *titleFilter = nil;
    NvsTimelineCompoundCaption *caption = nil;
    NvsTimelineVideoFx *endFilter = nil;
    NvsTimelineCompoundCaption *endCaption = nil;
    if ([self checkString:self.currentModel.titleFilter]) {
        titleFilter = [self.timeline addPackagedTimelineVideoFx:0 duration:self.currentModel.titleFilterDuration videoFxPackageId:self.currentModel.titleFilter];
    }

    if ([self checkString:self.currentModel.titleCaption]){
        caption = [self.timeline addCompoundCaption:0 duration:self.currentModel.titleCaptionDuration compoundCaptionPackageId:self.currentModel.titleCaption];
    }
    
    if ([self checkString:self.currentModel.endingCaption]){
        endCaption = [self.timeline addCompoundCaption:self.timeline.duration - self.currentModel.endingCaptionDuration duration:self.currentModel.endingCaptionDuration compoundCaptionPackageId:self.currentModel.endingCaption];
    }
    if ([self checkString:self.currentModel.endingFilter]){
        endFilter = [self.timeline addPackagedTimelineVideoFx:self.timeline.duration - self.currentModel.endingFilterLen duration:self.currentModel.endingFilterLen videoFxPackageId:self.currentModel.endingFilter];
        [self.timeline enableRenderOrderByZValue:YES];
        [endFilter setZValue:5000];
    }

    
    if (titleFilter || caption) {
        NvThemeShootItemModel *firstModel = [[NvThemeShootItemModel alloc]init];
        firstModel.coverImage = [UIImage imageWithContentsOfFile:self.currentModel.titleCover];
        firstModel.filterVideoFx = titleFilter;
        firstModel.compoundCaption = caption;
        firstModel.displayName = NvLocalString(@"Title", @"片头");
        firstModel.type = 0;
        firstModel.shotModel = [[NvShotInfoModel alloc]init];
        firstModel.shotModel.shotStart = 0;
        firstModel.shotModel.duration = self.currentModel.titleFilterDuration;
        [self.dataArray insertObject:firstModel atIndex:0];
    }
    
    if (endFilter || endCaption) {
        NvThemeShootItemModel *endModel = [[NvThemeShootItemModel alloc]init];
        endModel.coverImage = [UIImage imageWithContentsOfFile:self.currentModel.endingCover];;
        endModel.filterVideoFx = endFilter;
        endModel.compoundCaption = endCaption;
        endModel.displayName = NvLocalString(@"Credits", @"片尾");
        endModel.type = 1;
        endModel.shotModel = [[NvShotInfoModel alloc]init];
        endModel.shotModel.shotStart = self.timeline.duration - self.currentModel.endingFilterLen;
        endModel.shotModel.duration = self.currentModel.endingFilterLen;
        [self.dataArray addObject:endModel];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvThemeShootCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvThemeShootCVCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.dataArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvThemeShootItemModel *model in self.dataArray) {
        model.selected = NO;
    }
    self.currentItemModel = self.dataArray[indexPath.item];
    self.currentItemModel.selected = YES;
    
    [collectionView reloadData];
    
    BOOL push = YES;
    switch (self.currentItemModel.type) {
        case 0:
            if ([self checkString:self.currentModel.titleFilter] && [self checkString:self.currentModel.titleCaption]) {
                [self.operationView configFilter:YES withCaption:YES];
            }else if ([self checkString:self.currentModel.titleCaption]){
                [self.operationView configFilter:NO withCaption:YES];
            }else if ([self checkString:self.currentModel.titleFilter]){
                [self.operationView configFilter:YES withCaption:NO];
            }else{
                push = NO;
            }
            break;
        case 1:
            if ([self checkString:self.currentModel.endingFilter]){
                [self.operationView configFilter:YES withCaption:NO];
            }else{
                push = NO;
            }
            break;
        case 2:
            if ([self checkString:self.currentItemModel.shotModel.compoundCaption] && [self checkString:self.currentItemModel.shotModel.filter]) {
                [self.operationView configFilter:YES withCaption:YES];
            }else if ([self checkString:self.currentItemModel.shotModel.compoundCaption]){
                [self.operationView configFilter:NO withCaption:YES];
            }else{
                [self.operationView configFilter:YES withCaption:NO];
            }
            break;
        default:
            break;
    }
    
    if (!push) {
        return;
    }
    
    [self.operationView configTitle:self.currentItemModel.displayName];
    
    if (self.currentItemModel.filterVideoFx) {
        [self.operationView configFilter:self.currentItemModel.filterVideoFx.timelineVideoFxPackageId withValue:self.currentItemModel.filterVideoFx.getFilterIntensity];
    }else{
        [self.operationView configFilter:@"" withValue:0];
    }
    
    if (self.currentItemModel.compoundCaption) {
        NSMutableArray *tempArray = [NSMutableArray array];
        for (int i = 0; i < self.currentItemModel.compoundCaption.captionCount; i++) {
            NvCompoundCaptionModel *tempModel = [[NvCompoundCaptionModel alloc]init];
            tempModel.showName = [self.currentItemModel.compoundCaption getText:i];
            [tempArray addObject:tempModel];
        }
        [self.operationView configCaptionArray:tempArray];
    }
    
    self.operationView.hidden = NO;
    
    [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    [self.liveWindow playAtTime:self.currentItemModel.shotModel.shotStart];
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    [self.liveWindow connectTimeline:self.timeline];
    [self seekTimeline:self.liveWindow.currentTime];
    if (needDelete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:self->_compileFilePath error:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(self->_compileFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
}

#pragma mark NvThemeSOperationViewDelegate
- (void)themeSOperationView:(NvThemeSOperationView *)themeSOperationView withModel:(NvCaptureFilterModel *)filterModel{
    if (self.currentItemModel.filterVideoFx){
        [self.timeline removeTimelineVideoFx:self.currentItemModel.filterVideoFx];
    }
    self.currentItemModel.filterVideoFx = nil;
    if (filterModel.packageId && filterModel.packageId.length != 0) {
        self.currentItemModel.filterVideoFx = [self.timeline addPackagedTimelineVideoFx:self.currentItemModel.shotModel.shotStart duration:self.currentItemModel.shotModel.duration videoFxPackageId:filterModel.packageId];
    }else if (filterModel.builtinName && filterModel.builtinName.length != 0) {
        self.currentItemModel.filterVideoFx = [self.timeline addBuiltinTimelineVideoFx:self.currentItemModel.shotModel.shotStart duration:self.currentItemModel.shotModel.duration videoFxName:filterModel.builtinName];
    }
    [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    [self.liveWindow playAtTime:self.currentItemModel.shotModel.shotStart];
}

- (void)themeSOperationView:(NvThemeSOperationView *)themeSOperationView withValue:(CGFloat)value{
    [self.currentItemModel.filterVideoFx setFilterIntensity:value];
}

- (void)themeSOperationView:(NvThemeSOperationView *)themeSOperationView withCaption:(NSString *)caption{
    NvInputCaptionVC *vc = [[NvInputCaptionVC alloc]init];
    vc.text = caption;
    vc.delegate = self;
    vc.index = themeSOperationView.index;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark NvInputCaptionVCDelegate
- (void)inputCaptionVC:(NvInputCaptionVC *)vc saveText:(NSString *)text{
    [self.currentItemModel.compoundCaption setText:vc.index text:text];
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < self.currentItemModel.compoundCaption.captionCount; i++) {
        NvCompoundCaptionModel *tempModel = [[NvCompoundCaptionModel alloc]init];
        tempModel.showName = [self.currentItemModel.compoundCaption getText:i];
        [tempArray addObject:tempModel];
    }
    [self.operationView configCaptionArray:tempArray];
}

#pragma mark 连接livewindow
///Connect to livewindow
- (void)connectTimeline {
    [self.liveWindow connectTimeline:self.timeline];
    self.liveWindow.currentTime = 0;
    [self seekTimeline:0];
}

#pragma mark 定位某一时间戳的图像
///seekTimeline
- (void)seekTimeline:(int64_t)postion {
    if (![self.streamingContext seekTimeline:self.timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame]){
    }
}

#pragma mark 检查字符串的有效性
///Check the validity of the string
- (BOOL)checkString:(NSString *)string{
    if (string && string.length != 0) {
        return YES;
    }
    return NO;
}

@end
