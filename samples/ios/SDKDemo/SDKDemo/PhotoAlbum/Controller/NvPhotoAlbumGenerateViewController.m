//
//  NvPhotoAlbumGenerateViewController.m
//  SDKDemo
//
//  Created by MS on 2019/9/24.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvPhotoAlbumGenerateViewController.h"
#import <NvStreamingSdkCore/NvsStreamingContext.h>
#import "NvPhotoAlbumHelper.h"
#import "NvPhotoCompileViewController.h"
#import <NvSDKCommon/NvWeakTimer.h>
#import "NvPhotoAlbumLineProcessView.h"
#import "NvsVideoTrack.h"
#import "NvsVideoClip.h"
#import <NvSDKCommon/NvUtils.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvBaseCommon/UIColor+NvColor.h>
#import <Masonry/Masonry.h>

@interface NvPhotoAlbumGenerateViewController ()<NvPhotoCompileViewControllerDelegate,NvsStreamingContextDelegate>
@property(nonatomic, strong) NvsTimeline *timeline;
@property(nonatomic, strong) NvsLiveWindow *liveWindow;
@property(nonatomic, strong) NvsStreamingContext *streamingContext;
@property(nonatomic, strong) NvPhotoAlbumLineProcessView *progressSlider;
@property(nonatomic, strong) UIView *controlPanelView;
@property(nonatomic, strong) UIButton *playbackButton;
@property(nonatomic, strong) NvWeakTimer *timer;
@property(nonatomic, copy)   NSString *compileFilePath;
@property (nonatomic, strong) UIButton *compileButton;
@end

@implementation NvPhotoAlbumGenerateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [self prepareTimeline];
    [self addSubviews];
    [self setHiddenPanelTimer];
    [self.streamingContext connectTimeline:self.timeline withLiveWindow:self.liveWindow];
    [self seekTimeline];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLiveWindow:)];
    [self.liveWindow addGestureRecognizer:tap];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSString *documentsDirectory =[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/YJ"];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    NSEnumerator *enumrator = [contents objectEnumerator];
    NSString *filename;
    while ((filename = [enumrator nextObject])) {
        [[NSFileManager defaultManager] removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:filename] error:NULL];

    }
}

- (UIView *)rightNavigationBarItemView {
    self.compileButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Compile", @"生成") textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:16 image:nil];
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

- (void)seekTimeline {
    int flag = 0;
    int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
    flag = NvsStreamingEngineSeekFlag_ShowCaptionPoster | NvsStreamingEngineSeekFlag_ShowAnimatedStickerPoster|NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame;
    if (![self.streamingContext seekTimeline:self.timeline timestamp:currentTime videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:flag]) {
        NSLog(@"Failed to seek timeline!");
    }
    [self playbackInZeroTime];
}

- (void)playbackInZeroTime {
    if (![self.streamingContext playbackTimeline:self.timeline startTime:0 endTime:self.timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
        return;
    }
}

///利用中间层创建时间线
///create the timeline according template and assets selected
- (void)prepareTimeline{
    if (self.localPath) {
        NSString *basePath = self.localPath;
        NSString *filePath ;
        NSFileManager *myFileManager = [NSFileManager defaultManager];
        NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:basePath error:nil];
        if (dirArray.count <=0) {
            return;
        }
        NSDirectoryEnumerator *myDirectoryEnumerator = [myFileManager enumeratorAtPath:basePath];
        for (NSString *path in myDirectoryEnumerator.allObjects) {
            if ([path.pathExtension isEqualToString:@"msphotoalbum"]) {
                filePath = [basePath stringByAppendingPathComponent:path];
                break;
            }
        }
        if (filePath.length <= 0 || !filePath) {
            return;
        }
        NSString *uuid = [[self.localPath lastPathComponent] componentsSeparatedByString:@"."].firstObject;
        NSString *licPath = [basePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.lic",uuid]];
        self.streamingContext = [NvsStreamingContext sharedInstance];
        self.streamingContext.delegate = self;
        self.timeline = [NvPhotoAlbumHelper CreatePhotoAlbumTimelineWithFilePath:filePath licFile:licPath resourceDir:basePath replaceFiles:self.files];
    }
}

///创建模糊效果的timeline
///create the blur effect timeline
- (NvsTimeline *)createPhotoAlbumTimelineInAspectFillModeWithFilePath:(NSString *)filePath
                                 licFile:(NSString *)licFile
                             resourceDir:(NSString *)resourceDir
                            replaceFiles:(NSArray <NSString *>*)replaceFiles
                                captions:(NSArray <NSString *>*)captions {
    NSMutableArray *grabImgArr = [NSMutableArray array];
    NvsTimeline *grabImageTimeline = [self createGrabTimeline];
    if (self.files.count >0 && grabImageTimeline) {
        NvsVideoTrack *videoTrack = [grabImageTimeline appendVideoTrack];
        if (videoTrack) {
            for (NSString *imagePath in self.files) {
                NvsVideoClip *videoClip = [videoTrack appendClip:[imagePath stringByReplacingOccurrencesOfString:@"PHAsset://" withString:@""]];
                if (videoClip) {
                    [videoClip setImageMotionMode:NvsStreamingEngineImageClipMotionMode_LetterBoxZoomIn];
                    [videoClip setImageMotionAnimationEnabled:NO];
                    [videoClip setSourceBackgroundMode:NvsSourceBackgroundModeBlur];
                }
            }
            NSString *documentsDirectory =[NSHomeDirectory() stringByAppendingPathComponent:@"Documents/YJ"];
            if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDirectory isDirectory:nil]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            }
            for (int i=0; i<videoTrack.clipCount; i++) {
                [videoTrack setBuiltinTransition:i withName:@""];
                
                NvsVideoClip *clip = [videoTrack getClipWithIndex:i];
                NSString *path = clip.filePath;
                NvsAVFileInfo *avFileInfo = [[NvsStreamingContext sharedInstance] getAVFileInfo:[path stringByReplacingOccurrencesOfString:@"PHAsset://" withString:@""]];
                if (avFileInfo) {
                    NvsSize imageSize = [avFileInfo getVideoStreamDimension:0];
                    if (imageSize.width*16 == imageSize.height*9) {
                        if(![path containsString:@"PHAsset://"]){
                           NSString *tmpPath = [@"PHAsset://" stringByAppendingString:path];
                            path = tmpPath;
                        }
                        [grabImgArr addObject:path];
                        continue;
                    }
                }else{
                    NSLog(@"获取图片信息错误 Error obtaining picture information%@",path);
                }
                
                [[NvsStreamingContext sharedInstance] seekTimeline:grabImageTimeline timestamp:clip.inPoint videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize flags:NvsStreamingEngineSeekFlag_BuddyOriginHostVideoFrame];
                NvsRational proxyScale = {1, 1};
                UIImage *grabImage = [[NvsStreamingContext sharedInstance] grabImageFromTimeline:grabImageTimeline timestamp:clip.inPoint proxyScale:&proxyScale];
                NSString *dateStr = [NvUtils currentDateAndTime];
                NSString *toSavePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",dateStr]];
                
                BOOL result = [UIImagePNGRepresentation(grabImage) writeToFile:toSavePath atomically:YES];
                if (result) {
                    [grabImgArr addObject:toSavePath];
                }else{
                    
                }
            }
            
            if (grabImgArr.count == self.files.count) {
                self.timeline = [NvPhotoAlbumHelper CreatePhotoAlbumTimelineWithFilePath:filePath licFile:licFile resourceDir:resourceDir replaceFiles:grabImgArr captions:@[@"美摄科技",@"2020"]];
                return self.timeline;
            }
        }
    }
    return self.timeline;
}

- (NvsTimeline *)createGrabTimeline {
    NvsStreamingContext *context = [NvsStreamingContext sharedInstance];
    NvsVideoResolution videoEditRes;
    videoEditRes.imageWidth = 720;
    videoEditRes.imageHeight = 1280;
    videoEditRes.imagePAR = (NvsRational){1, 1};
    NvsRational videoFps = {25, 1};
    NvsAudioResolution audioEditRes;
    audioEditRes.sampleRate = 44100;
    audioEditRes.channelCount = 2;
    audioEditRes.sampleFormat = NvsAudSmpFmt_S16;
    NvsTimeline *timeline = [context createTimeline:&videoEditRes videoFps:&videoFps audioEditRes:&audioEditRes];
    return timeline;
}

- (void)addSubviews {
    self.progressSlider = [[NvPhotoAlbumLineProcessView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 3)];
    self.progressSlider.fillColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    self.progressSlider.defaultColor = [UIColor nv_colorWithHexARGB:@"#50FFFFFF"];
    [self.view addSubview:self.progressSlider];
    
    self.liveWindow = [[NvsLiveWindow alloc] initWithFrame:CGRectZero];
    self.liveWindow.fillMode = NvsLiveWindowFillModePreserveAspectFit;
    [self.view addSubview:self.liveWindow];
    [self.liveWindow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.progressSlider.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    self.controlPanelView = [[UIView alloc] init];
    self.controlPanelView.backgroundColor = [UIColor clearColor];
    [self.liveWindow addSubview:self.controlPanelView];
    [self.controlPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.liveWindow);
    }];
    
    self.playbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.playbackButton.backgroundColor = [UIColor clearColor];
    [self.playbackButton addTarget:self action:@selector(playbackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.playbackButton setImage:[UIImage imageNamed:@"NvPhotoAlbum_pause"] forState:UIControlStateNormal];
    [self.playbackButton setImage:[UIImage imageNamed:@"NvPhotoAlbum_play"] forState:UIControlStateSelected];
    [self.controlPanelView addSubview:self.playbackButton];
    [self.playbackButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.controlPanelView.mas_centerY);
        make.centerX.equalTo(self.controlPanelView.mas_centerX);
        make.width.mas_equalTo(50*SCREENSCALE);
        make.height.mas_equalTo(50*SCREENSCALE);
    }];
}

- (void)leftNavButtonClick:(UIButton *)button {
    
    NVWeakSelf
    [UIAlertController presentAlertFromVC:self
                                    title:NvLocalString(@"Abandon Achievements", @"是否放弃已有效果?")
                                  message:nil
                        buttonTitleColors:@[[UIColor nv_colorWithHexRGB:@"#4A90E2"],[UIColor nv_colorWithHexRGB:@"#333333"]]
                        cancelButtonTitle:NvLocalString(@"Cancel", @"取消")
                         otherButtonTitle:NvLocalString(@"Sure", @"确定")
                       cancelButtonAction:nil
                        otherButtonAction:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf.streamingContext stop];
        [weakSelf.streamingContext clearCachedResources:NO];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)rightBtnClicked {
    self.playbackButton.selected = YES;
    self.compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvPhotoCompileViewController *compileViewController = [NvPhotoCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:_timeline outputPath:_compileFilePath];
}

- (void)setFiles:(NSMutableArray *)files {
    _files = files;
}

#pragma mark - tapLiveWindow
- (void)tapLiveWindow:(UITapGestureRecognizer *)tap {
    [self playEORPause];
}

- (void)playbackButtonClicked:(UIButton *)sender {
    [self playEORPause];
}

- (void)playEORPause {
    self.playbackButton.selected = !self.playbackButton.selected;
    if (self.streamingContext.getStreamingEngineState != NvsStreamingEngineState_Playback) {
        int64_t currentTime = [self.streamingContext getTimelineCurrentPosition:self.timeline];
        
        [self.streamingContext playbackTimeline:self.timeline startTime:currentTime endTime:self.timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame];
        
    } else {
        [self.streamingContext stop];
    }
    
    if(_controlPanelView.hidden){
        [self showControllPanel];
    }else{
        [self setHiddenPanelTimer];
    }
}

- (void)showControllPanel {
    _controlPanelView.hidden = NO;
    [self setHiddenPanelTimer];
}

- (void)hideControlPanel:(NSTimer *)timer {
    if (!_controlPanelView.hidden)
        _controlPanelView.hidden = YES;
}

- (void)setHiddenPanelTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NvWeakTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hideControlPanel:) userInfo:nil repeats:NO dispatchQueue:dispatch_get_main_queue()];
}
#pragma mark - NvsStreamingContextDelegate
- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    self.playbackButton.selected = NO;
    if(_controlPanelView.hidden){
        [self showControllPanel];
    }else{
        [self setHiddenPanelTimer];
    }
    [self playbackInZeroTime];
}

- (void)didPlaybackStopped:(NvsTimeline *)timeline {
    self.playbackButton.selected = YES;
}

- (void)didPlaybackTimelinePosition:(NvsTimeline *)timeline position:(int64_t)position {
    self.progressSlider.processValue =(float)position / timeline.duration;
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
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

#pragma mark 添加通知
///Add notification
- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification*)notification {
    [self.streamingContext stop];
    
}

- (void)applicationBecomeActive:(NSNotification*)notification {
    if (![self.streamingContext playbackTimeline:self.timeline startTime:[self.streamingContext getTimelineCurrentPosition:self.timeline] endTime:self.timeline.duration videoSizeMode:NvsVideoPreviewSizeModeLiveWindowSize preload:YES flags:NvsStreamingEnginePlaybackFlag_BuddyOriginHostVideoFrame]) {
        return;
    }
    self.playbackButton.selected = NO;
}

@end
