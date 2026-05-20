//
//  NvEditViewController.m
//  SDKDemo
//
//  Created by meishe01 on 2018/5/25.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvEditViewController.h"
#import "NVHeader.h"
#import <NvSDKCommon/NvLiveWindowPanelView.h>
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import "NvEditCaptionViewController.h"
#import "NvFeatureItem.h"
#import "NvFeatureCollectionViewCell.h"
#import <NvSDKCommon/NvCompileViewController.h>
#import "NvEditMaterialViewController.h"
#import "NvEditThemeViewController.h"
#import "NvEditFilterViewController.h"
#import "NvEditStickerViewController.h"
#import "NvTimelineData.h"
#import "NvTimelineUtils.h"
#import "NvTransitionViewController.h"
#import "NvEditMusicViewController.h"
#import "NvOriginSoundView.h"
#import "NvsAudioClip.h"
#import "NvTipTransitionViewController.h"
#import "NvRecordViewController.h"
#import "NvEditCompoundCaptionViewController.h"
#import "NvEditBackgroundViewController.h"
#import "NvEditWatemarkVC.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import "YYModel.h"
#import "NvsVideoFx.h"
#import "NvAssetManager.h"
#import "NvsMakeupEffectInfo.h"
#import "NvEditAnimationController.h"
#import "NvMaskViewController.h"
#import "NvEditMakeUpController.h"
#import "NvEditBeautyViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <NvSDKCommon/NvInitArScence.h>
#import "NvLivePhotoViewController.h"

@interface NvEditViewController () <UICollectionViewDataSource, UICollectionViewDelegate, NvCompileViewControllerDelegate, NvLiveWindowPanelViewDelegate,NvEditThemeViewControllerDelegate> {
    NvsStreamingContext *_streamingContext;
    NvLiveWindowPanelView *_liveWindowPanelView;
    NvsTimeline *_timeline;
    UICollectionView *_featureCollectionView;
    NSMutableArray *_featureDataSource;
    NSString *_compileFilePath;
    NvTimelineData *timelineData;
    NvOriginSoundView *_originSoundView;
    UIView *_rightBtnBGView;
    UIButton *_generateVideoButton;
    UIButton *_generateImageButton;
    UIButton *_generateLiveButton;
}

@end

@implementation NvEditViewController


- (void)dealloc {
    NSLog(@"%s",__func__);
    if (_isFromAlbum) {
        [timelineData clear];
        [_streamingContext stop];
        NSLog(@"%d",[_streamingContext getStreamingEngineState]);
        [_streamingContext clearCachedResources:NO];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"EditVideo", @"视频编辑");
    _streamingContext = [NvSDKUtils getSDKContext];
    [_streamingContext setDefaultCaptionFade:NO];
    [self registerFontAssets];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:NvLocalString(@"Compile", @"生成") style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClicked)];
    [rightButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NvUtils fontWithSize:16], NSFontAttributeName, [UIColor nv_colorWithHexRGB:@"#4A90E2"], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItem = rightButtonItem;
    [self addSubViews];
    [self initTimeline];
    [self initTimelineData];
    [self configAudioSession];
}


/**
 需要改动子类需要重写这个方法
 You need to change the subclass you need to override this method
 @return 需要显示的返回按钮
 The back button that needs to be displayed
 */
- (UIView *)leftNavigationBarItemView {
    UIButton *backButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:15 image:[UIImage imageNamed:@"icon_back"]];
    backButton.frame = CGRectMake(0, 0, 30, 44);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREENSCALE, 0, 0);
    __weak typeof(self)weakSelf = self;
    [backButton nv_BtnClickHandler:^{
        [weakSelf backMethod];
    }];
    return backButton;
}

- (void)backMethod {
    [_streamingContext stop];
    [[NvTimelineData sharedInstance] clear];
    [NvTimelineUtils removeTimeline:_timeline];
    [_streamingContext clearCachedResources:NO];
    if (self.isFromAlbum) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)initTimelineData {
    timelineData = [NvTimelineData sharedInstance];
    if (self.selectPath.count != 0) {
        NSString *cafFiles = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/otherfiles"];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:cafFiles]) {
            [fm createDirectoryAtPath:cafFiles withIntermediateDirectories:true attributes:nil error:nil];
        }
        NSArray *contents = [fm contentsOfDirectoryAtPath:cafFiles error:nil];
        [contents enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *filePath = [cafFiles stringByAppendingPathComponent:obj];
            [self.selectPath addObject:filePath];
        }];
        NSLog(@"self.selectPath==%@",self.selectPath);
        for (NSString *path in self.selectPath) {
            NvEditDataModel *editData = NvEditDataModel.new;
            if ([path hasSuffix:@".png"]) {
                editData.isImage = YES;
                editData.trimOut = 4 * NV_TIME_BASE;
                editData.localIdentifier = path;
                editData.thumImage = [UIImage imageWithContentsOfFile:path];
                editData.isFromAlbum = NO;
                editData.isPhotoAlbum = NO;
                editData.hasMotion = NO;
                editData.isDefault = YES;
                editData.isArea = NO;
                editData.motionMode = NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn;
            }else{
                NvsAVFileInfo *fileInfo = [_streamingContext getAVFileInfo:path];
                int64_t duration = fileInfo.duration;
                editData.trimOut = duration;
                editData.isImage = NO;
                editData.thumImage = [self getImage:path];
                editData.isFromAlbum = NO;
                editData.videoPath = path;
            }
            editData.trimIn = 0;
            editData.duration = editData.trimOut;
            [timelineData.editDataArray addObject:editData];
            
            NvTimeFilterInfoModel *filterInfo = [NvTimeFilterInfoModel new];
            [[[NvTimelineData sharedInstance] videoFxDataArray] addObject:filterInfo];
            
            NvTransitionInfoModel *info = NvTransitionInfoModel.new;
            [[[NvTimelineData sharedInstance] transitionDataArray] addObject:info];
        }
        
        if (self.musicInfo){
            [[[NvTimelineData sharedInstance] musicDataArray] addObject:self.musicInfo];
            [NvTimelineUtils resetMusicTrack:_timeline musicDataArray:[[NvTimelineData sharedInstance] musicDataArray]];
        }
        
    }else if (self.urlPath.count != 0) {
        for (NSDictionary *dict in self.urlPath) {
            NSString *path = dict[@"url"];
            int64_t duration = [dict[@"duration"] integerValue];
            
            NvEditDataModel *editData = NvEditDataModel.new;
            if ([path hasSuffix:@".png"]) {
                editData.isImage = YES;
                editData.trimOut = duration;
                editData.localIdentifier = path;
                editData.thumImage = [UIImage imageWithContentsOfFile:path];
                editData.isFromAlbum = NO;
                editData.isPhotoAlbum = NO;
                editData.hasMotion = NO;
                editData.isDefault = YES;
                editData.isArea = NO;
                editData.motionMode = NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn;
            }else{
                editData.trimOut = duration;
                editData.isImage = NO;
                editData.thumImage = [self getImage:path];
                editData.isFromAlbum = NO;
                editData.videoPath = path;
            }
            editData.trimIn = 0;
            editData.duration = editData.trimOut;
            [timelineData.editDataArray addObject:editData];
            
            NvTimeFilterInfoModel *filterInfo = [NvTimeFilterInfoModel new];
            [[[NvTimelineData sharedInstance] videoFxDataArray] addObject:filterInfo];
            
            NvTransitionInfoModel *info = NvTransitionInfoModel.new;
            [[[NvTimelineData sharedInstance] transitionDataArray] addObject:info];
        }
    }else {
            for (NvAlbumAsset *asset in self.selectAssets) {
                NSString *videoPath = asset.asset.localIdentifier;
                if (asset.useOriginalFile) {
                    videoPath = [NSString stringWithFormat:@"meicam://url=%@?original_file=1", videoPath];
                }
                if (asset.asset.mediaType == PHAssetMediaTypeVideo || (asset.asset.mediaType == PHAssetMediaTypeImage && asset.asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive)) {
                    NvEditDataModel *editData = NvEditDataModel.new;
                    editData.isFromAlbum = YES;
                    editData.asset = asset.asset;
                    
                    editData.videoPath = videoPath;
                    editData.isImage = NO;
                    editData.trimIn = 0;
                    NvsAVFileInfo *fileInfo = [_streamingContext getAVFileInfo:videoPath];
                    editData.trimOut =fileInfo.duration;
                    editData.duration = editData.trimOut;
                    if ((asset.isLivePhoto)) {
                        NvsAVFileInfo *fileInfo = [self->_streamingContext getAVFileInfo:asset.albumVideoPath];
                        NSLog(@"时长：%lld",fileInfo.duration);
                        editData.videoPath = asset.albumVideoPath;
                        editData.trimOut = fileInfo.duration;
                        editData.duration = editData.trimOut;
                        UIImage *image = [self thumbnailImageForVideoAtURL:[NSURL fileURLWithPath:asset.albumVideoPath] atTime:kCMTimeZero];
                        editData.thumImage = image;
                    } else {
                        [[PHImageManager defaultManager] requestImageForAsset:asset.asset targetSize:CGSizeMake(77.0*SCREENSCALE, 50.0*SCREENSCALE) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                            editData.thumImage = result;
                        }];
                    }
                    [timelineData.editDataArray addObject:editData];
                    
                    NvTimeFilterInfoModel *filterInfo = [NvTimeFilterInfoModel new];
                    [[[NvTimelineData sharedInstance] videoFxDataArray] addObject:filterInfo];
                    
                    NvTransitionInfoModel *info = NvTransitionInfoModel.new;
                    [[[NvTimelineData sharedInstance] transitionDataArray] addObject:info];
                } else if (asset.asset.mediaType == PHAssetMediaTypeImage) {
                    NvEditDataModel *editData = NvEditDataModel.new;
                    editData.isFromAlbum = YES;
                    editData.localIdentifier = asset.albumVideoPath.length > 0 ? asset.albumVideoPath : videoPath;
                    editData.videoPath = asset.asset.localIdentifier;
                    
                    if ([self isWebPAsset:asset.asset] || [self isGifPAsset:asset.asset]) {
                        NvsAVFileInfo *fileInfo = [_streamingContext getAVFileInfo:editData.localIdentifier];
                        int64_t duration = fileInfo.duration;
                        editData.isImage = NO;
                        editData.thumImage = [self getImage:editData.localIdentifier];
                        editData.videoPath = editData.localIdentifier;
                        editData.trimOut = duration == 0 ? 4000000 : duration;
                    } else {
                        editData.isImage = YES;
                        editData.trimOut = 4*NV_TIME_BASE;
                    }

                    editData.trimIn = 0;
                    editData.isPhotoAlbum = YES;
                    editData.duration = editData.trimOut;
                    editData.hasMotion = NO;
                    editData.isDefault = YES;
                    editData.isArea = NO;
                    editData.motionMode = NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn;
                    [[PHImageManager defaultManager] requestImageForAsset:asset.asset targetSize:CGSizeMake(77.0*SCREENSCALE, 50.0*SCREENSCALE) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                           editData.thumImage = result;
                    }];
                    [timelineData.editDataArray addObject:editData];
                    
                    NvTimeFilterInfoModel *filterInfo = [NvTimeFilterInfoModel new];
                    [[[NvTimelineData sharedInstance] videoFxDataArray] addObject:filterInfo];
                    
                    NvTransitionInfoModel *info = NvTransitionInfoModel.new;
                    [[[NvTimelineData sharedInstance] transitionDataArray] addObject:info];
                }
            }
    }
}

- (UIImage *)thumbnailImageForVideoAtURL:(NSURL *)videoURL atTime:(CMTime)time {
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];

    imageGenerator.appliesPreferredTrackTransform = YES; // 保持视频方向
    imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeCleanAperture;

    NSError *error = nil;
    CMTime actualTime;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];

    if (error) {
        NSLog(@"生成缩略图失败: %@", error.localizedDescription);
        return nil;
    }

    UIImage *thumbnail = [[UIImage alloc] initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return thumbnail;
}

- (BOOL)isWebPAsset:(PHAsset *)asset {
    NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:asset];
    for (PHAssetResource *resource in resources) {
        NSString *uti = resource.uniformTypeIdentifier;
        CFStringRef mimeType = UTTypeCopyPreferredTagWithClass((__bridge CFStringRef _Nonnull)(uti), kUTTagClassMIMEType);
        if (mimeType != NULL) {
            NSString *mimeTypeString = (__bridge_transfer NSString *)mimeType;
            if ([mimeTypeString isEqualToString:@"image/webp"]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)isGifPAsset:(PHAsset *)asset {
    NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:asset];
    for (PHAssetResource *resource in resources) {
        NSString *uti = resource.uniformTypeIdentifier;
        CFStringRef mimeType = UTTypeCopyPreferredTagWithClass((__bridge CFStringRef _Nonnull)(uti), kUTTagClassMIMEType);
        if (mimeType != NULL) {
            NSString *mimeTypeString = (__bridge_transfer NSString *)mimeType;
            if ([mimeTypeString isEqualToString:@"image/gif"]) {
                return YES;
            }
        }
    }
    return NO;
}

-(UIImage *)getImage:(NSString *)videoURL{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return thumb;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [NvTimelineUtils recreateTimeline:_timeline];
    [_liveWindowPanelView showControllPanel];
    [self connectTimeline];
}

- (void)connectLiveWindow {
    if (!_timeline) {
        return;
    }
    
    [_liveWindowPanelView connectTimeline:_timeline];
    [self seekTimeline:_liveWindowPanelView.currentTime];
}

- (void)addSubViews {
    _liveWindowPanelView = [[NvLiveWindowPanelView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.width)];
    _liveWindowPanelView.editMode = self.editMode;
    _liveWindowPanelView.delegate = self;
    [self.view addSubview:_liveWindowPanelView];
    _featureDataSource = [[NSMutableArray alloc] init];
    NSArray *featureNameArray = @[NvLocalString(@"Edit", @"编辑"), NvLocalString(@"Filter", @"滤镜"), NvLocalString(@"Sticker", @"贴纸"),NvLocalString(@"Animation", @"动画"),NvLocalString(@"Mask", @"蒙版"), NvLocalString(@"Caption", @"字幕"),NvLocalString(@"CompoundCaption", @"组合字幕"),NvLocalString(@"Background" ,@"背景"), NvLocalString(@"WaterMark", @"水印"), NvLocalString(@"Transition", @"转场"), NvLocalString(@"Music", @"音乐"), NvLocalString(@"Dubbing", @"配音"),NvLocalString(@"capture.beauty", @"美颜"), NvLocalString(@"capture.makeup", @"美妆")];
    NSArray *featureImageArray = @[@"NvEdit", @"NvEditFilter", @"NvEditSticker",@"NVEditAnimation",@"NvMaskIcon", @"NvEditCaption",@"NvEditCompoundCaption",@"NvEditBackground", @"NvEditWatermark", @"NvEditTransition", @"NvEditMusic", @"NvEditRecord", @"edit_beauty_image", @"edit_make_up_image"];
    for (int i = 0; i < featureNameArray.count; i++) {
        NvFeatureItem *item = [NvFeatureItem new];
        item.name = featureNameArray[i];
        item.image = featureImageArray[i];
        [_featureDataSource addObject:item];
    }
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(73 * SCREENSCALE, 86 * SCREENSCALE);
    layout.minimumLineSpacing = 3 * SCREENSCALE;
    if (![NvUtils currentLanguagesIsChinese]) {
        layout.minimumLineSpacing = 23 * SCREENSCALE;
    }
    layout.minimumInteritemSpacing = 0;
    _featureCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.view.height - INDICATOR - 203 * SCREENSCALE, self.view.width, 86 * SCREENSCALE) collectionViewLayout:layout];
    _featureCollectionView.delegate = self;
    _featureCollectionView.dataSource = self;
    _featureCollectionView.backgroundColor = [UIColor clearColor];
    _featureCollectionView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_featureCollectionView];
    [_featureCollectionView registerClass:[NvFeatureCollectionViewCell class] forCellWithReuseIdentifier:@"NvFeatureCollectionViewCell"];
    
    _originSoundView = [[NvOriginSoundView alloc] initWithFrame:CGRectMake(0, _liveWindowPanelView.bottom, _liveWindowPanelView.width, self.view.height-_liveWindowPanelView.bottom-NV_STATUSBARHEIGHT-NV_NAV_BAR_HEIGHT)];
    _originSoundView.delegate = self;
    [self.view addSubview:_originSoundView];
    float height = self.view.height-_liveWindowPanelView.bottom-NV_STATUSBARHEIGHT-NV_NAV_BAR_HEIGHT;
    [_originSoundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.and.left.and.right.equalTo(self.view);
        make.height.equalTo(@(height));
    }];
    _originSoundView.hidden = YES;
    float origin = 1,music = 1,dubbing = 1;
    NvsVideoTrack *videoTrack = [_timeline getVideoTrackByIndex:0];
    [videoTrack getVolumeGain:&origin rightVolumeGain:&origin];
    NvsAudioTrack *audioTrack = [_timeline getAudioTrackByIndex:0];
    [audioTrack getVolumeGain:&music rightVolumeGain:&music];
    NvsAudioTrack *dubbingTrack = [_timeline getAudioTrackByIndex:NV_DUBBING_SOUND_TRACK];
    [dubbingTrack getVolumeGain:&dubbing rightVolumeGain:&dubbing];
    [_originSoundView setOriginSound:origin musicSound:music dubbing:dubbing];
    
    _rightBtnBGView = [[UIView alloc] init];
    _rightBtnBGView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_rightBtnBGView];
    
    [_rightBtnBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(5*SCREENSCALE);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view.mas_top).offset(5*SCREENSCALE);
        }
        make.right.equalTo(self.view.mas_right).offset(-5*SCREENSCALE);
//        make.width.mas_equalTo(100*SCREENSCALE);
//        make.height.mas_equalTo(60*SCREENSCALE);
    }];
    
    CGFloat itemHeight = itemHeight = 30*SCREENSCALE;
    _generateVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtnBGView addSubview:_generateVideoButton];
    [_generateVideoButton addTarget:self action:@selector(generateVideoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_generateVideoButton setTitle:NvLocalString(@"Compile Video" , @"生成视频") forState:UIControlStateNormal];
    _generateVideoButton.titleLabel.font = [UIFont systemFontOfSize:11*SCREENSCALE];
    _generateVideoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_generateVideoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_rightBtnBGView.mas_top).offset(1*SCREENSCALE);
        make.height.mas_equalTo(itemHeight-2*SCREENSCALE);
        make.left.equalTo(self->_rightBtnBGView.mas_left);
        make.right.equalTo(self->_rightBtnBGView.mas_right);
    }];
    
    _generateImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtnBGView addSubview:_generateImageButton];
    [_generateImageButton addTarget:self action:@selector(generateImgBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_generateImageButton setTitle:NvLocalString(@"Compile Image" , @"生成图片") forState:UIControlStateNormal];
    _generateImageButton.titleLabel.font = [UIFont systemFontOfSize:11*SCREENSCALE];
    _generateImageButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_generateImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_generateVideoButton.mas_bottom).offset(1*SCREENSCALE);
        make.height.mas_equalTo(itemHeight-2*SCREENSCALE);
        make.left.equalTo(self->_rightBtnBGView.mas_left);
        make.right.equalTo(self->_rightBtnBGView.mas_right);
    }];
    
    _generateLiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightBtnBGView addSubview:_generateLiveButton];
    [_generateLiveButton addTarget:self action:@selector(generateLivePhotoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_generateLiveButton setTitle:NvLocalString(@"Compile LivePhoto" , @"生成实况") forState:UIControlStateNormal];
    _generateLiveButton.titleLabel.font = [UIFont systemFontOfSize:11*SCREENSCALE];
    _generateLiveButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [_generateLiveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self->_generateImageButton.mas_bottom).offset(1*SCREENSCALE);
        make.height.mas_equalTo(itemHeight-2*SCREENSCALE);
        make.left.equalTo(self->_rightBtnBGView.mas_left).offset(5);
        make.right.equalTo(self->_rightBtnBGView.mas_right).offset(-5);
        make.bottom.equalTo(self->_rightBtnBGView.mas_bottom);
    }];
    _rightBtnBGView.hidden = YES;
}

- (void)initTimeline {
    _timeline = [NvTimelineUtils createTimeline:self.editMode];
    if (!_timeline) {
        return;
    }
}

- (void)connectTimeline {
    [_liveWindowPanelView connectTimeline:_timeline];
    _liveWindowPanelView.currentTime = 0;
    [self seekTimeline:0];
}

- (void)configAudioSession{
    NSError* error = nil;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDuckOthers |
     AVAudioSessionCategoryOptionAllowBluetooth
                                           error:&error];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

///定位某一时间戳的图像
///seekTimeline
- (void)seekTimeline:(int64_t)postion {
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    if (OResolutionNum.intValue >= 2160) {
        NvsRational rational = {1,4};
        if (![_streamingContext seekTimeline:_timeline timestamp:postion proxyScale:&rational flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame|NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame]) {
            NSLog(@"定位时间线失败！Failed to seek timeline!");
        }
    }else {
        if (![_streamingContext seekTimeline:_timeline timestamp:postion videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame|NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame]){
            NSLog(@"定位时间线失败！Failed to seek timeline!");
        }
    }
}

- (void)rightBtnClicked {
    _rightBtnBGView.hidden = !_rightBtnBGView.hidden;
}

- (void)generateVideoBtnClicked {
    _rightBtnBGView.hidden = YES;
    _compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.isHDRSetUp = YES;
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [NvTimelineUtils resetAllClipManipulatesTracking:_timeline];
    [compileViewController compileTimeline:_timeline outputPath:_compileFilePath];
}

- (void)generateImgBtnClicked {
    _rightBtnBGView.hidden = YES;
    int64_t timestamp = [_streamingContext getTimelineCurrentPosition:_timeline];
    NvsRational proxyScale = {1, 1};
    UIImage *image = [_streamingContext grabImageFromTimeline:_timeline timestamp:timestamp proxyScale:&proxyScale flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [NvToast showInfoWithMessage:NvLocalString(@"storage", @"请检查手机存储空间")];
    } else {
        [NvToast showInfoWithMessage:NvLocalString(@"Save Succecs!", @"保存成功!")];
    }
}

- (void)generateLivePhotoBtnClicked {
    _rightBtnBGView.hidden = YES;
    NvLivePhotoViewController *livePhotoVC = [[NvLivePhotoViewController alloc] init];
    livePhotoVC.editMode = self.editMode;
    livePhotoVC.timeline = _timeline;
    [self.navigationController pushViewController:livePhotoVC animated:true];
}

- (void)registerFontAssets {
    NvAssetManager *assetManager = [NvAssetManager sharedInstance];
    [assetManager searchLocalAssets:ASSET_FONT];
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"fontPackage" ofType:@"bundle"];
    [assetManager searchReservedAssets:ASSET_FONT bundlePath:fontPath];
    ///获取字体
    ///Get font
    NSArray *fontArr = [assetManager getUsableAssets:ASSET_FONT aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    for (int j = 0;j < fontArr.count;j++) {
        NvAsset *asset = fontArr[j];
        [_streamingContext registerFontByFilePath:asset.bundledLocalDirPath ? asset.bundledLocalDirPath : asset.localDirPath];
    }
}

#pragma mark - NvLiveWindowPanelViewDelegate
- (void)volumnClicked {
    _originSoundView.hidden = NO;
}

#pragma mark - NvOriginSoundViewDelegate
- (void)applyClick:(NvOriginSoundView *)originSoundView {
    originSoundView.hidden = YES;
}

- (void)originSoundView:(NvOriginSoundView *)originSoundView originSound:(float)originSound {
    ///视频数据结构的修改
    ///Modification of video data structure
    NSMutableArray<NvEditDataModel *> *editDataArray = timelineData.editDataArray;
    for (int i = 0; i < editDataArray.count; i++) {
        NvEditDataModel *model = editDataArray[i];
        model.volume = originSound;
        NvsVideoClip *clip = [NvTimelineUtils getTimelineVideoClip:_timeline clipInfo:model];
        [clip setVolumeGain:originSound rightVolumeGain:originSound];
    }
}

- (void)originSoundView:(NvOriginSoundView *)originSoundView musicSound:(float)musicSound {
    ///外加音乐的数据
    ///Plus the music data
    for (NvMusicInfoModel *musicInfo in timelineData.musicDataArray) {
        musicInfo.volume = musicSound;
    }
    
    NvThemeInfoModel *themeInfo = [[NvTimelineData sharedInstance] themeInfo];
    themeInfo.volume = musicSound;
    
    ///如果音乐存在，主题音乐音量为0，调整音乐轨道片段的音量
    ///If the music is present and the theme music volume is 0, adjust the volume of the music track fragment
    ///如果音乐不存在，设置主题音乐的音量
    ///If the music does not exist, set the volume of the theme music
    if (timelineData.musicDataArray.count > 0) {
        NvsAudioTrack *audioTrack = [_timeline getAudioTrackByIndex:NV_MUSIC_SOUND_TRACK];
        for (int i = 0; i < audioTrack.clipCount; i++) {
            NvsAudioClip *clip = [audioTrack getClipWithIndex:i];
            [clip setVolumeGain:musicSound rightVolumeGain:musicSound];
        }
    } else {
        [_timeline setThemeMusicVolumeGain:musicSound rightVolumeGain:musicSound];
    }
}

- (void)originSoundView:(NvOriginSoundView *)originSoundView dubbing:(float)dubbing {
    NvsAudioTrack *audioTrack = [_timeline getAudioTrackByIndex:NV_DUBBING_SOUND_TRACK];
    [audioTrack setVolumeGain:dubbing rightVolumeGain:dubbing];
    timelineData.dubbingModel.volume = dubbing;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _featureDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvFeatureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvFeatureCollectionViewCell" forIndexPath:indexPath];
    [cell renderCellWithItem:_featureDataSource[indexPath.row]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [_streamingContext stop];
    NvFeatureItem *item = _featureDataSource[indexPath.row];
    if (indexPath.item == 0){
        NvEditMaterialViewController *vc = [[NvEditMaterialViewController alloc]init];
        vc.editMode = self.editMode;
        vc.liveWindow = _liveWindowPanelView.liveWindow;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.item == 1){
        NvEditFilterViewController *vc = [[NvEditFilterViewController alloc]init];
        vc.editMode = self.editMode;
        vc.title = item.name;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.item == 2){
        NvEditStickerViewController *vc = [[NvEditStickerViewController alloc]init];
        vc.editMode = self.editMode;
        vc.title = item.name;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.item == 3){
        ///动画
        ///animation
        NvEditAnimationController *animationVC = [NvEditAnimationController new];
        animationVC.editMode = self.editMode;
        animationVC.editDataArray = [NvTimelineData sharedInstance].editDataArray;
        [self.navigationController pushViewController:animationVC animated:YES];
    }else if (indexPath.item == 4){
        ///蒙版
        ///mask
        NvMaskViewController *maskVC = [NvMaskViewController new];
        maskVC.editMode = self.editMode;
        maskVC.editDataArray = [NvTimelineData sharedInstance].editDataArray;
        [self.navigationController pushViewController:maskVC animated:YES];
        
    }else if (indexPath.item == 5){
        NvEditCaptionViewController *captionVC = [NvEditCaptionViewController new];
        captionVC.editMode = self.editMode;
        [self.navigationController pushViewController:captionVC animated:YES];
    }else if (indexPath.item == 6){
        NvEditCompoundCaptionViewController *record = [NvEditCompoundCaptionViewController new];
        record.editMode = self.editMode;
        [self.navigationController pushViewController:record animated:YES];
    }else if (indexPath.item == 7){
        NvEditBackgroundViewController *background = [NvEditBackgroundViewController new];
        background.editDataArray = [NvTimelineData sharedInstance].editDataArray;
        background.editMode = self.editMode;
        [self.navigationController pushViewController:background animated:YES];
    }
    else if (indexPath.item == 8){
        NvEditWatemarkVC *vc = [[NvEditWatemarkVC alloc]init];
        vc.editMode = self.editMode;
        vc.title = item.name;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.item == 9){
        if (timelineData.editDataArray.count>=2) {
            NvTransitionViewController *transition = [NvTransitionViewController new];
            transition.timeline = _timeline;
            transition.editMode = self.editMode;
            [self.navigationController pushViewController:transition animated:YES];
        } else {
            NvTipTransitionViewController *tip = [NvTipTransitionViewController new];
            tip.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:tip animated:NO completion:NULL];
        }
    }else if (indexPath.item == 10){
        NvEditMusicViewController *editMusic = [NvEditMusicViewController new];
        editMusic.editMode = self.editMode;
        [self.navigationController pushViewController:editMusic animated:YES];
    }else if (indexPath.item == 11){
        NvRecordViewController *record = [NvRecordViewController new];
        record.editMode = self.editMode;
        [self.navigationController pushViewController:record animated:YES];
    }else if (indexPath.item == 12){
        NvEditBeautyViewController *VC = [NvEditBeautyViewController new];
        VC.editMode = self.editMode;
        [self.navigationController pushViewController:VC animated:YES];
    }else if (indexPath.item == 13){
        NvEditMakeUpController *VC = [NvEditMakeUpController new];
        VC.editMode = self.editMode;
        [self.navigationController pushViewController:VC animated:YES];
    }
    
}

#pragma mark tipView按钮点击事件
///tipView button click event
- (void)knowClick:(UIButton *)sender{
    [sender.superview.superview removeFromSuperview];
}

///保存相册的回调
///Save the album callback
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"保存成功！ Save successfully!");

}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    [self connectLiveWindow];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

