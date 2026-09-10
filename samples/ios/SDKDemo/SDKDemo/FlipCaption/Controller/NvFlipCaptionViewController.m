//
//  NvFlipCaptionViewController.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFlipCaptionViewController.h"
#import <NvSDKCommon/NvCompileViewController.h>
#import "NvFlipCaptionListViewController.h"
#import "NvTimelineUtils.h"
#import "NvFlipCaptionColor.h"
#import "NvFlipCaptionFontView.h"
#import "NvFlipCaptionModel.h"
#import "NvJokeCaptionConvertor.h"
#import "NvsTimelineVideoFx.h"
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvSDKUtils.h>

@interface NvFlipCaptionViewController ()<NvCompileViewControllerDelegate, NvLiveWindowPanelViewDelegate,NvAssetManagerDelegate>

@property (nonatomic, strong) NSString *compileFilePath;
@property (nonatomic, strong) UIButton *captionButton,*colorButton,*fontButton;
@property (nonatomic, strong) UILabel *captionLabel,*colorLabel,*fontLabel;
@property (nonatomic, strong) NvFlipCaptionColor *colorView;
@property (nonatomic, strong) NvFlipCaptionFontView *fontView;
@property (nonatomic, strong) NSMutableArray <NvFlipCaptionModel *>*dataSource;
@property (nonatomic, strong) NvsTimelineVideoFx* fx;
@property (nonatomic, strong) NSString *fontPath;
@property (nonatomic, strong) NvCaptionFontItem *currentModel;

@property (nonatomic, strong) NvAssetManager *assetManager;
@property (nonatomic, strong) NSMutableArray <NvCaptionFontItem *>*fontDataSource;
///是否有字体列表
///Whether there is a font list
@property (nonatomic, assign) BOOL isHaveList;
@property (nonatomic, strong) UIButton *compileButton;
@end

@implementation NvFlipCaptionViewController {
    NvJokeCaptionConvertor *convertor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.liveWindowPanel.liveWindow.hdrDisplayMode = NvsLiveWindowHDRDisplayMode_SDR;
    
    // Do any additional setup after loading the view.
    self.title = NvLocalString(@"FlipCaption", @"翻转字幕");
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];

    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    self.liveWindowPanel.delegate = self;
    [self.liveWindowPanel hiddenVolumeButton];
    [self initTimeline:self.editMode];
    [self seekTimeline:0];
    [self addSubView];
    [self loadLrcModel];
    convertor = [[NvJokeCaptionConvertor alloc] init];
    ///通过歌词list初始化数据
    ///Initialize the data with the lyrics list
    NSMutableArray* list = [[NSMutableArray alloc] init];
    [self.dataSource enumerateObjectsUsingBlock:^(NvFlipCaptionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *text = [NSString stringWithFormat:@"%@%@",obj.timeStr,obj.text];
        [list addObject:text];
    }];
    [convertor setupJokeFxDadaWithList:list livewindow:self.liveWindowPanel.liveWindow timeline:self.timeline];
    [self buildJokeFx:self.dataSource];
    
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
    [self.assetManager searchLocalAssets:ASSET_FONT];
    //本地
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"fontPackage" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_FONT bundlePath:fontPath];
    //网络
    [self.assetManager downloadRemoteAssetsInfo:ASSET_FONT categoryId:0 page:1 pageSize:20 kind:NV_KIND_ID_ALL modular:NvAssetModularAll ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NvSDKUtils getSdkVersion]];
    [self configFontDataSource];
}

- (void)loadLrcModel {
    self.dataSource = [NSMutableArray array];
    NSString *lrcPath = [[[NSBundle mainBundle] pathForResource:@"music" ofType:@"bundle"] stringByAppendingPathComponent:@"春江花月夜.lrc"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:lrcPath]) {
        
        NSError *error = nil;
        NSString* content = [NSString stringWithContentsOfFile:lrcPath encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            
            DebugLog(@"Error reading file: %@", error.localizedDescription);
        }else{
            
            content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
        NSArray *lrcArray = [content componentsSeparatedByString:@"\n"];
        [lrcArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NvFlipCaptionModel *model = [NvFlipCaptionModel new];
            NSArray *textArr = [obj componentsSeparatedByString:@"]"];
            model.timeStr = [NSString stringWithFormat:@"%@%@",textArr.firstObject,@"]"];
            model.text = [textArr.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self.dataSource addObject:model];
        }];
    }
}

- (void)buildJokeFx:(NSMutableArray <NvFlipCaptionModel *>*)dataSource {
    [self.timeline removeTimelineVideoFx:self.fx];
    
    if (self.fontPath && ![self.fontPath isEqualToString:@""]) {
        NSString* fontFamily = [self.streamingContext registerFontByFilePath:self.fontPath];
        [convertor setFont:fontFamily];
    }else{
        [convertor setFont:@"none"];
    }
    
    [dataSource enumerateObjectsUsingBlock:^(NvFlipCaptionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.colorString) {
            NSArray *colors = [NvUtils rgbWithColor:[UIColor nv_colorWithHexARGB:obj.colorString]];
            [self->convertor setFontColorSingleLine:(int)idx color:[NSString stringWithFormat:@"%d,%d,%d,%d",(int)[colors[0] integerValue],(int)[colors[1] integerValue],(int)[colors[2] integerValue],(int)[colors[3] integerValue]]];
        }
    }];

    NSString* fxDesc = [convertor buildJokeFxDesc];
    
    self.fx = [self.timeline addBuiltinTimelineVideoFx:0 duration:self.timeline.duration videoFxName:@"Storyboard"];
    [self.fx setStringVal:@"Description String" val:fxDesc];
    [self.fx setBooleanVal:@"Is Caption" val:true];
}

///添加数据
///Add data
- (void)initTimeline:(NvEditMode)model {
    self.editMode = model;
    self.timeline = [NvTimelineUtils createTimelineOrdinary:model];
    
    __block BOOL isshowToast = NO;
    __weak typeof(self)weakSelf = self;
    [self.assets enumerateObjectsUsingBlock:^(NvAlbumAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [weakSelf appendClip:obj ForTrack:[weakSelf.timeline getVideoTrackByIndex:0] containiCloud:&isshowToast];
    }];
    
    if (isshowToast) {
        
        [UIAlertController presentAlertFromVC:self
                                        title:NvLocalString(@"Tips", @"提示")
                                      message:NvLocalString(@"album.iClould", @"所选资源在iCloud中")
                            buttonTitleColors:nil
                            cancelButtonTitle:nil
                             otherButtonTitle:NvLocalString(@"Know", @"知道了")
                           cancelButtonAction:nil
                            otherButtonAction:nil];
    }
}

- (void)appendClip:(NvAlbumAsset *)obj ForTrack:(NvsVideoTrack *)track containiCloud:(BOOL *)contain {
    if (obj.asset.mediaType == PHAssetMediaTypeVideo) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        __block NSString *localIdentifier = nil;
        [[PHImageManager defaultManager] requestAVAssetForVideo:obj.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            if (asset && [asset isKindOfClass:[AVURLAsset class]]) {
                localIdentifier = obj.asset.localIdentifier;
            } else {
                *contain = YES;
            }
            
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        if (localIdentifier) {
            [track appendClip:localIdentifier];
        }
    } else if (obj.isLivePhoto) {
        [track appendClip:obj.albumVideoPath];
    }
}


- (void)leftNavButtonClick:(UIButton *)button {
    [self.streamingContext stop];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (UIView *)rightNavigationBarItemView {
    self.compileButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Compile", @"生成") textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:16 image:nil];
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

///生成按钮
///Generate button
- (void)rightBtnClicked {
    _compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compileTimeline:self.timeline outputPath:_compileFilePath];
}

- (void)addSubView {
    self.colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.colorButton setImage:NvImageNamed(@"NvFlipCaptionColor") forState:UIControlStateNormal];
    [self.view addSubview:self.colorButton];
    [self.colorButton addTarget:self action:@selector(colorButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.colorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.height.equalTo(@(49*SCREENSCALE));
        make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-46*SCREENSCALE);
    }];
    
    self.colorLabel = [[UILabel alloc] init];
    self.colorLabel.text = NvLocalString(@"FlipCaption.color", @"颜色");
    self.colorLabel.textAlignment = NSTextAlignmentCenter;
    self.colorLabel.textColor = [UIColor whiteColor];
    self.colorLabel.alpha = 0.8;
    self.colorLabel.numberOfLines = 2;
    self.colorLabel.font = [NvUtils regularFontWithSize:12];
    [self.view addSubview:self.colorLabel];
    [self.colorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.colorButton.mas_bottom).offset(18*SCREENSCALE);
        make.centerX.equalTo(self.colorButton);
        make.width.mas_lessThanOrEqualTo(KScale6s(50));
    }];
    self.captionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.captionButton setImage:NvImageNamed(@"NvFlipCaption") forState:UIControlStateNormal];
    [self.view addSubview:self.captionButton];
    [self.captionButton addTarget:self action:@selector(captionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.captionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.width.height.equalTo(self.colorButton);
        make.right.equalTo(self.colorButton.mas_left).offset(-30*SCREENSCALE);
    }];
    self.captionLabel = [[UILabel alloc] init];
    self.captionLabel.textAlignment = NSTextAlignmentCenter;
    self.captionLabel.text = NvLocalString(@"FlipCaption.caption", @"字幕");
    self.captionLabel.textColor = [UIColor whiteColor];
    self.captionLabel.alpha = 0.8;
    self.captionLabel.numberOfLines = 2;
    self.captionLabel.font = [NvUtils regularFontWithSize:12];
    [self.view addSubview:self.captionLabel];
    [self.captionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.captionButton.mas_bottom).offset(16*SCREENSCALE);
        make.centerX.equalTo(self.captionButton);
        make.width.mas_lessThanOrEqualTo(KScale6s(50));
    }];
    
    self.fontButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.fontButton setImage:NvImageNamed(@"NvFlipCaptionFont") forState:UIControlStateNormal];
    [self.view addSubview:self.fontButton];
    [self.fontButton addTarget:self action:@selector(fontButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.fontButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.width.height.equalTo(self.colorButton);
        make.left.equalTo(self.colorButton.mas_right).offset(30*SCREENSCALE);
    }];
    self.fontLabel = [[UILabel alloc] init];
    self.fontLabel.textAlignment = NSTextAlignmentCenter;
    self.fontLabel.text = NvLocalString(@"FlipCaption.font", @"字体");
    self.fontLabel.textColor = [UIColor whiteColor];
    self.fontLabel.alpha = 0.8;
    self.fontLabel.numberOfLines = 2;
    self.fontLabel.font = [NvUtils regularFontWithSize:12];
    [self.view addSubview:self.fontLabel];
    [self.fontLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(self.fontButton.mas_bottom).offset(16*SCREENSCALE);
        make.centerX.equalTo(self.fontButton);
        make.width.mas_lessThanOrEqualTo(KScale6s(50));
    }];
    
    self.fontView = [NvFlipCaptionFontView new];
    self.fontView.delegate = self;
    [self.view addSubview:self.fontView];
    [self.fontView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(self.view.mas_bottom);
    }];
}

- (void)colorButtonClick:(UIButton *)button {
    self.colorView = [NvFlipCaptionColor new];
    self.colorView.delegate = self;
    [self.view addSubview:self.colorView];
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(self.view.mas_bottom);
    }];
    [self.view layoutIfNeeded];
    [self.colorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)captionButtonClick:(UIButton *)button {
    [self.streamingContext stop];
    NvFlipCaptionListViewController *captionList = [NvFlipCaptionListViewController new];
    captionList.delegate = self;
    captionList.dataSource = [[NSMutableArray alloc] initWithArray:self.dataSource copyItems:YES];
    [self.navigationController pushViewController:captionList animated:YES];
}

- (void)fontButtonClick:(UIButton *)button {
    [self.fontView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
    if (self.fontPath && ![self.fontPath isEqualToString:@""]) {
        [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.packagePath isEqualToString:self.fontPath]) {
                obj.selected = YES;
            } else {
                obj.selected = NO;
            }
        }];
        self.fontView.dataSource = self.fontDataSource;
    }
    if (!self.isHaveList) {
        ///第一次没有请求到数据
        ///No data was requested the first time
        [self.assetManager downloadRemoteAssetsInfo:ASSET_FONT categoryId:0 page:1 pageSize:20 kind:NV_KIND_ID_ALL modular:NvAssetModularAll ratioFlag:1 ratio:AspectRatio_All sdkVerskon:[NvSDKUtils getSdkVersion]];
    }
}

- (void)didPlaybackEOF:(NvsTimeline *)timeline {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self seekTimeline:0];
        [self.liveWindowPanel playAtTime:0];
    });
}

#pragma mark - NvFlipCaptionListViewControllerDelegate
- (void)flipCaptionListViewController:(NvFlipCaptionListViewController *)flipCaptionListViewController editCaptionDataSource:(NSMutableArray *)dataSource {
    self.dataSource = dataSource;
    NSMutableArray *arr = [NSMutableArray array];
    [self.dataSource enumerateObjectsUsingBlock:^(NvFlipCaptionModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableDictionary *lrcDic = [NSMutableDictionary dictionary];
        NSString *result = [[obj.timeStr stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSArray *timeComponent = [result componentsSeparatedByString:@":"];
        NSLog(@"%@",timeComponent.firstObject);
        NSArray *array = [timeComponent.lastObject componentsSeparatedByString:@"."];
        NSString* min =timeComponent[0];
        NSString* sec =array[0];
        NSString* mill =[array[1] stringByAppendingString:@"0"];
        NSLog(@"%@%@%@",min, sec, mill);
        long time = [self getLongTime:min sec:sec mill:mill];
        [lrcDic setObject:obj.text forKey:@(time)];
        [arr addObject:lrcDic];
    }];
    [convertor updateTextList:arr];
    [self buildJokeFx:self.dataSource];
    [self seekTimeline:0];
}

- (long)getLongTime:(NSString*)min sec:(NSString*)sec mill:(NSString*)mill {
    int m = [min intValue];
    int s = [sec intValue];
    int ms = [mill intValue];
    
    if(s >= 60) {
    }
    long time = m*60*1000 + s*1000 + ms;
    return time;
}


#pragma mark - ColorViewDelegate
- (void)flipCaptionColor:(NvFlipCaptionColor *)colorView didSelectItem:(NvCaptionColorItem *)item {
    [self.dataSource enumerateObjectsUsingBlock:^(NvFlipCaptionModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.colorString = item.colorString;
    }];
    [self buildJokeFx:self.dataSource];
    [self seekTimeline:0];
}

- (void)flipCaptionColor:(NvFlipCaptionColor *)colorView okClickItem:(NvCaptionColorItem *)item {
    [self.colorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(self.view.mas_bottom);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        [colorView removeFromSuperview];
    }];
}

- (void)selectItem:(NvCaptionFontItem *)item {
    [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = NO;
    }];
    item.selected = YES;
    self.fontView.dataSource = self.fontDataSource;
}

#pragma mark - ColorViewDelegate
- (void)flipCaptionFont:(NvFlipCaptionFontView *)fontView didSelectItem:(NvCaptionFontItem *)item {
    self.currentModel = item;
    if ([item.displayName isEqualToString:@"无"] ||
        [item.displayName isEqualToString:NvLocalString(@"None", @"无")]) {
        [self selectItem:item];
        self.fontPath = nil;
        [self buildJokeFx:self.dataSource];
        [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
        return;
    }
    if (item.packagePath) {
        [self selectItem:item];
        self.fontPath = item.packagePath;
        [self buildJokeFx:self.dataSource];
        [self seekTimeline:[self.streamingContext getTimelineCurrentPosition:self.timeline]];
    } else {
        [self.assetManager downloadAsset:item.packageId];
    }
}
- (void)flipCaptionFont:(NvFlipCaptionFontView *)fontView okClickItem:(NvCaptionFontItem *)item {
    [self.fontView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.top.equalTo(self.view.mas_bottom);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)compileFinished:(BOOL)needDelete {
    self.streamingContext.delegate = self.liveWindowPanel;
    self.liveWindowPanel.delegate = self;
    NVWeakSelf
    if (needDelete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:weakSelf.compileFilePath error:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(weakSelf.compileFilePath, weakSelf, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

//保存相册的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    
}

#pragma mark - NvAssetManagerDelegate
- (void)onRemoteAssetsChanged:(BOOL)hasNext {
    self.isHaveList = YES;
    [self configFontDataSource];
}

-(void)configFontDataSource{
    
    self.fontDataSource = [NSMutableArray array];
    NSArray *useArray = [self.assetManager getUsableAssets:ASSET_FONT aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
    NSArray *array = [self.assetManager getRemoteAssets:ASSET_FONT aspectRatio:AspectRatio_All categoryId:NV_CATEGORY_ID_ALL kindId:NV_KIND_ID_ALL];
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
        item.showName = NO;
        item.selected = NO;
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
        [useArray enumerateObjectsUsingBlock:^(NvAsset *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.uuid isEqualToString:asset.uuid]) {
                item.packagePath = asset.localDirPath;
                item.state = Finish;
            }
        }];
        [self.fontDataSource addObject:item];
    }
    self.fontView.dataSource = self.fontDataSource;
}

- (void)onGetRemoteAssetsFailed {
    [NvToast showErrorWithMessage:NvLocalString(@"CheckNetwork", @"请检查网络是否连接")];
    self.isHaveList = NO;
}

- (void)onDownloadAssetProgress:(NSString *)uuid
                       progress:(int)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.fontView updateProgress:progress/100.0 uuid:uuid];        
    });
}

- (void)onDonwloadAssetFailed:(NSString *)uuid {
    dispatch_async(dispatch_get_main_queue(), ^{
        [NvToast showErrorWithMessage:NvLocalString(@"downloadFaild", @"下载失败！")];
        [self.fontView downloadFailduuid:uuid];
    });
}

- (void)onDonwloadAssetSuccess:(NSString *)uuid {
    [self.fontDataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.packageId isEqualToString:uuid]) {
            obj.state = Finish;
            obj.packagePath = [NSString stringWithFormat:@"%@%@/%@",NSHomeDirectory(),NV_ASSET_DOWNLOAD_PATH_FONT,obj.packageNetPath.lastPathComponent];
        }
    }];
    self.fontView.dataSource = self.fontDataSource;
    if ([self.currentModel.packageId isEqualToString:uuid]) {
        [self selectItem:self.currentModel];
        self.fontPath = self.currentModel.packagePath;
        [self buildJokeFx:self.dataSource];
        [self seekTimeline:0];
    }
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
