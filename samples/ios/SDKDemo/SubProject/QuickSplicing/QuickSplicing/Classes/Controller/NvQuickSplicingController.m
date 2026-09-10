//
//  NvQuickSplicingController.m
//  AFNetworking
//
//  Created by ms on 2022/1/12.
//

#import "NvQuickSplicingController.h"
#import "NVDefineConfig.h"
#import "NvCompileViewController.h"
#import "UIColor+NvColor.h"
#import <Masonry/Masonry.h>
#import "NvStreamingSdkCore.h"
#import "NvUtils.h"
#import "NvSDKUtils.h"
#import "JLLewReorderableLayout.h"
#import "NvQuickSplicingCollectionViewCell.h"
#import <NvAlbum/NvAlbumViewController.h>
#import "NvFilePassThroughViewController.h"

@interface NvQuickSplicingController ()<NvLiveWindowPanelViewDelegate,NvCompileViewControllerDelegate,LewReorderableLayoutDelegate,LewReorderableLayoutDataSource,NvFilePassThroughViewControllerDelegate>


@property (nonatomic, strong) NSString *compileFilePath;

@property (nonatomic, assign) BOOL isCredits;

@property (nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, assign) NSInteger index;

@property (nonatomic, assign) NvsSize size;
///编码方式
///Encoding mode
@property (nonatomic, assign) NvsVideoCodecType type;
///画质等级
///Picture quality grade
@property (nonatomic, assign) int codecProfile;
///编码等级
///Coding level
@property (nonatomic, assign) int codecLevel;
///旋转角度
///Angle of rotation
@property (nonatomic, assign) NvsVideoRotation rotation;
///颜色变换曲线
///Color transformation curve
@property (nonatomic, assign) NvsVideoColorTransfer colorTransfer;
///音频数量
///Audio quantity
@property (nonatomic, assign) int audioCount;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *deleteLabe;
@property (nonatomic, strong) UIButton *filePassthroughBtn;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) NSMutableArray <NvAlbumAsset *> *selectAssets;
@property (nonatomic, assign) NvEditMode editMode;
@property (nonatomic, strong) UIButton *compileButton;
@end

@implementation NvQuickSplicingController

- (instancetype)initWithAssets:(NSArray <NvAlbumAsset *> *)assets editMode:(NvEditMode)editMode {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.editMode = editMode;
        self.selectAssets = assets;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.liveWindowPanel.liveWindow.hdrDisplayMode = NvsLiveWindowHDRDisplayMode_SDR;
    
    self.title = NvLocalStringFromTable([self class], @"Quick splicing", @"快速拼接");
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self rightNavigationBarItemView]];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(templateSelectionCallback:) name:@"toPackagingTemplateViewController" object:nil];
    
    self.liveWindowPanel.delegate = self;
    [self.liveWindowPanel hiddenVolumeButton];
    [self initTimeline];
    [self seekTimeline:0];
    [self addSubView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self connectLiveWindow];
    if (self.selectAssets.count > 0) {
        NvsAVFileInfo *fileInfo = [[NvsStreamingContext sharedInstance] getAVFileInfoExtra:self.selectAssets[0].albumVideoPath extraFlag:NvsAVFileinfoExtra_AVPixelFormat];
        self.size = [fileInfo getVideoStreamDimension:0];
        self.type = [fileInfo getVideoStreamCodecType:0];
        self.codecProfile = [fileInfo getVideoCodecProfile:0];
        self.codecLevel = [fileInfo getVideoCodecLevel:0];
        self.rotation = [fileInfo getVideoStreamRotation:0];
        self.colorTransfer = [fileInfo getVideoStreamColorTranfer:0];
        self.audioCount = [fileInfo getAudioStreamChannelCount:0];
    }
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self seekTimeline];
}

- (UIView *)rightNavigationBarItemView {
    
    self.compileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.compileButton setTitle:NvLocalString(@"Compile", @"生成") forState:UIControlStateNormal];
    [self.compileButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
    if (font) {
        self.compileButton.titleLabel.font = font;
    } else {
        UIFont *font = [UIFont systemFontOfSize:16];
        self.compileButton.titleLabel.font = font;
    }
    self.compileButton.frame = CGRectMake(0, 0, 30, 44);
    self.compileButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15*SCREENSCALE);
    [self.compileButton addTarget:self action:@selector(rightBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.compileButton.exclusiveTouch = YES;
    return self.compileButton;
}

-(void)setSelectAssets:(NSMutableArray<NvAlbumAsset *> *)selectAssets{
    _selectAssets = selectAssets;
    for (NvAlbumAsset *asset in _selectAssets) {
        asset.isSelected = NO;
    }
}

- (void)leftNavButtonClick:(UIButton *)button{
    [self.streamingContext stop];
    [self.streamingContext clearCachedResources:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 创建timeline
/*
 创建timeline
 Create timeline
 */
- (void)initTimeline{
    self.timeline = [NvSDKUtils createTimeline:self.editMode];
    __weak typeof(self)weakSelf = self;
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    PHImageManager *manager = [PHImageManager defaultManager];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:VIDEO_PATH(@"AlbumVideo")]) {
        [fileManager createDirectoryAtPath:VIDEO_PATH(@"AlbumVideo") withIntermediateDirectories:YES attributes:nil error:nil];
    }
    if (![fileManager fileExistsAtPath:VIDEO_PATH(@"Compile")]) {
        [fileManager createDirectoryAtPath:VIDEO_PATH(@"Compile") withIntermediateDirectories:YES attributes:nil error:nil];
    }

    [self.selectAssets enumerateObjectsUsingBlock:^(NvAlbumAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.useOriginalFile) {
            obj.albumVideoPath = [NSString stringWithFormat:@"meicam://url=%@?original_file=1", obj.asset.localIdentifier];
        } else {
            obj.albumVideoPath = obj.asset.localIdentifier;
        }
        [[weakSelf.timeline getVideoTrackByIndex:0] appendClip:obj.albumVideoPath];
    }];

}

- (void)recreateTimeline {
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    [track removeAllClips];
    [self.selectAssets enumerateObjectsUsingBlock:^(NvAlbumAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.trimOut == 0) {
            ///trimOut初始化默认值为0,所以当为0的时候说明没有改变trimIn trimOut,全时域添加
            ///The initial default value of trimOut is 0, so when it is 0, it means that there is no change trimIn trimOut, add in the whole time domain
            NvsVideoClip * clip = [track appendClip:obj.albumVideoPath];
            if (!clip) {
                NSLog(@"添加clip失败!!! Failed to add clip");
            }
        }else{
            NvsVideoClip * clip = [track appendClip:obj.albumVideoPath trimIn:obj.trimIn trimOut:obj.trimOut];
            if (!clip) {
                NSLog(@"添加clip失败!!! Failed to add clip");
            }
        }
    }];
    NSInteger count = track.clipCount;
    NSLog(@"clip count :%d",count);
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubView{
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    self.bottomView.alpha = 0.3;
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view).offset(0);
        make.height.mas_equalTo(75.0 * SCREENSCALE);
    }];
    
    self.deleteLabe = [UILabel new];
    self.deleteLabe.textColor = UIColor.whiteColor;
    self.deleteLabe.font = [NvBaseUtils fontWithSize:10 * SCREENSCALE];
    self.deleteLabe.backgroundColor = [UIColor clearColor];
    self.deleteLabe.textAlignment = NSTextAlignmentCenter;
    self.deleteLabe.text = NvLocalStringFromTable([self class], @"Drag here to delete", @"拖动到此处删除");
    [self.bottomView addSubview:self.deleteLabe];
    [self.deleteLabe mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
        make.top.mas_equalTo(self.bottomView.mas_top).offset(15.0f *SCREENSCALE);
        make.height.mas_equalTo(12.0 * SCREENSCALE);
        make.width.mas_equalTo(80.0 * SCREENSCALE);
    }];
    self.bottomView.hidden = YES;
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.liveWindowPanel.mas_bottom).offset(50.0 * SCREENSCALE);
        make.left.right.mas_equalTo(self.view).offset(0);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(0);
        
    }];
    [_collectionView layoutIfNeeded];
    _collectionView.contentInset = UIEdgeInsetsMake(20, 20 , _collectionView.bounds.size.height - 200.0, 0);
    
    [self.collectionView reloadData];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView.collectionViewLayout invalidateLayout];
    } completion:nil];
    
    self.filePassthroughBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:self.filePassthroughBtn];
    [self.filePassthroughBtn setBackgroundColor:[UIColor whiteColor]];
    [self.filePassthroughBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.filePassthroughBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    [self.filePassthroughBtn setTitle:NvLocalStringFromTable([self class], @"Range Selection", @"区间选取") forState:UIControlStateNormal];
    self.filePassthroughBtn.font = [UIFont systemFontOfSize:14.f * SCREENSCALE];
    [self.filePassthroughBtn addTarget:self action:@selector(filePassthroughBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.filePassthroughBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.collectionView.mas_top).offset(-5.0 * SCREENSCALE);
        make.right.equalTo(self.view.mas_right).offset(-20.0 * SCREENSCALE);
        make.height.mas_equalTo(30.0 * SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(150.0 * SCREENSCALE);
    }];
    self.filePassthroughBtn.hidden = YES;
}

- (void)connectLiveWindow {
    if (!self.timeline) {
        return;
    }
    
    [self.liveWindowPanel connectTimeline:self.timeline];
    [self seekTimeline:self.liveWindowPanel.currentTime];
}

- (void)filePassthroughBtnClicked:(UIButton *)sender {
    NvsVideoTrack *track = [self.timeline getVideoTrackByIndex:0];
    NvsVideoClip *clip = [track getClipWithIndex:self.selectedIndex];
    NvsPSTimelineEditorInfo *info = [NvsPSTimelineEditorInfo new];
    info.trimIn = clip.trimIn;
    info.trimOut = clip.trimOut;
    info.inPoint = 0;
    info.outPoint = [self getAssetDuration:clip.filePath];
    info.mediaFilePath = clip.filePath;
    info.stillImageHint = NO;
    NvFilePassThroughViewController *vc = [NvFilePassThroughViewController new];
    vc.info = info;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:NO];
}

- (int64_t)getAssetDuration:(NSString *)assetPath {
    NvsAVFileInfo *avInfo = [self.streamingContext getAVFileInfo:assetPath];
    return avInfo.duration;
}
#pragma mark - 生成
/*
 生成
 composite
 */
- (void)rightBtnClicked{
    self.compileFilePath = [VIDEO_PATH(@"Compile") stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", [NvUtils currentDateAndTime]]];
    NvCompileViewController *compileViewController = [NvCompileViewController new];
    compileViewController.delegate = self;
    compileViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:compileViewController animated:NO completion:nil];
    [compileViewController compilePassthroughTimeline:self.timeline outputPath:self.compileFilePath];
}

#pragma mark - NvCompileViewControllerDelegate
- (void)compileFinished:(BOOL)needDelete {
    [self connectLiveWindow];
    if (needDelete) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            [[NSFileManager defaultManager] removeItemAtPath:self.compileFilePath error:nil];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:NO completion:nil];
            UISaveVideoAtPathToSavedPhotosAlbum(self.compileFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        });
    }
}

///保存相册的回调
///Save the album callback
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalString(@"Save video to album failed" , @"保存视频到相册失败") message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NvLocalString(@"Know", @"知道了") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

        }];

        [alertVC addAction:cancelAction];
        self.presentedViewController.definesPresentationContext = true; 
        [self presentViewController:alertVC animated:YES completion:nil];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
    }
    
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        JLLewReorderableLayout *layout = [[JLLewReorderableLayout alloc]init];
        layout.delegate = self;
        layout.dataSource = self;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(90*SCREENSCALE, 70*SCREENSCALE);
        layout.minimumLineSpacing = 0*SCREENSCALE;
        _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        
        [_collectionView registerClass:[NvQuickSplicingCollectionViewCell class] forCellWithReuseIdentifier:@"NvQuickSplicingCollectionViewCellID"];
    }
    return _collectionView;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectAssets.count == 1) {
        return NO;
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didDeleteItemAtIndexPath:(NSIndexPath *)indexPath{
    self.bottomView.hidden = YES;
    [self.selectAssets removeObjectAtIndex:indexPath.item];
    for (int i = 0; i < self.selectAssets.count; i ++) {
        NvAlbumAsset *asset = self.selectAssets[i];
        asset.number = i + 1;
    }
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        [self.collectionView.collectionViewLayout invalidateLayout];
    } completion:^(BOOL finished) {
        self.filePassthroughBtn.hidden = YES;
        [self.collectionView reloadData];
        NSLock *lock = [[NSLock alloc]init];
        NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
        [lock lock];
        if (videoTrack.clipCount > indexPath.item){
            NvsVideoClip *clip = [videoTrack getClipWithIndex:indexPath.item];
            [videoTrack removeClip:clip.index keepSpace:NO];
        }
        [lock unlock];
        [self connectLiveWindow];
        [self seekTimeline:0];
    }];
}


- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout didBeginDraggingItemAtIndexPath:(NSIndexPath *)indexPath{
    self.bottomView.hidden = NO;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout willEndDraggingItemAtIndexPath:(NSIndexPath *)indexPath{
    self.bottomView.hidden = YES;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.selectAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NvQuickSplicingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvQuickSplicingCollectionViewCellID" forIndexPath:indexPath];
    cell.asset = self.selectAssets[indexPath.item];
    cell.index = indexPath.item;
    __weak typeof(self)weakSelf = self;
    cell.addAssetBlock = ^(NSInteger index) {
        weakSelf.index = index;
        NvAlbumViewController *albumVC = [NvAlbumViewController new];
        albumVC.delegate = self;
        albumVC.mutableSelect = YES;
        albumVC.isOnlyVideo = YES;
        albumVC.hiddenSelectAll = YES;
        albumVC.isQuickSplicing = YES;
        [weakSelf.navigationController pushViewController:albumVC animated:YES];
    };
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    for (NvAlbumAsset *asset in self.selectAssets) {
        asset.isSelected = NO;
    }
    NvAlbumAsset *asset = self.selectAssets[indexPath.item];
    asset.isSelected = YES;
    self.selectedIndex = indexPath.item;
    self.filePassthroughBtn.hidden = NO;
    [collectionView reloadData];
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath didMoveToIndexPath:(NSIndexPath *)toIndexPath{
    NvAlbumAsset *asset0 = self.selectAssets[fromIndexPath.item];
    [self.selectAssets removeObjectAtIndex:fromIndexPath.item];
    [self.selectAssets insertObject:asset0 atIndex:toIndexPath.item];
    for (int i = 0; i < self.selectAssets.count; i ++) {
        NvAlbumAsset *asset = self.selectAssets[i];
        asset.number = i + 1;
    }
    [self.collectionView reloadData];
    NSLock *lock = [[NSLock alloc]init];
    NvsVideoTrack *videoTrack = [self.timeline getVideoTrackByIndex:0];
    [lock lock];
    if (videoTrack.clipCount >= fromIndexPath.item && videoTrack.clipCount >= toIndexPath.item) {
        [videoTrack moveClip:fromIndexPath.item destClipIndex:toIndexPath.item];
    }
    [lock unlock];
    [self seekTimeline:0];
}

#pragma mark - NvFilePassThroughViewControllerDelegate
- (void)filePassThroughViewController:(NvFilePassThroughViewController *)controller info:(NvsPSTimelineEditorInfo *)info {
    NvAlbumAsset *selectAsset = self.selectAssets[self.selectedIndex];
    selectAsset.trimIn = info.trimIn;
    selectAsset.trimOut = info.trimOut;
    [self recreateTimeline];
    [self seekTimeline:0];
}

#pragma mark - NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    
    [albumViewController.navigationController popViewControllerAnimated:YES];
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    PHImageManager *manager = [PHImageManager defaultManager];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [assets enumerateObjectsUsingBlock:^(NvAlbumAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.albumVideoPath = obj.asset.localIdentifier;
    }];
    __block NSInteger index = self.index;
    for (int i = 0;i < assets.count; i++) {
        NvAlbumAsset *asset = assets[i];
        [self.selectAssets insertObject:asset atIndex:index];
        NSLog(@"%@",asset.asset.localIdentifier);
        [[self.timeline getVideoTrackByIndex:0] insertClip:asset.albumVideoPath clipIndex:index];
        index++;
    }
    for (int i = 0; i < self.selectAssets.count; i ++) {
        NvAlbumAsset *asset = self.selectAssets[i];
        asset.number = i + 1;
    }
    [self.collectionView reloadData];
    [self seekTimeline:0];
}

- (BOOL)nvAlbumViewSamemMaterialController:(NvAlbumViewController *)albumViewController asset:(NvAlbumAsset *)asset index: (NSUInteger)index isSelect:(BOOL)select{

    if (!select) {
        return YES;
    }
    
    NvsAVFileInfo *fileInfo = [[NvsStreamingContext sharedInstance] getAVFileInfoExtra:asset.asset.localIdentifier extraFlag:NvsAVFileinfoExtra_AVPixelFormat];
    NvsSize size = [fileInfo getVideoStreamDimension:0];
    NvsVideoCodecType type = [fileInfo getVideoStreamCodecType:0];
    int codecProfile = [fileInfo getVideoCodecProfile:0];
    int codecLevel = [fileInfo getVideoCodecLevel:0];
    NvsVideoRotation rotation = [fileInfo getVideoStreamRotation:0];
    NvsVideoColorTransfer colorTransfer = [fileInfo getVideoStreamColorTranfer:0];
    int audio = [fileInfo getAudioStreamChannelCount:0];
    /*Note:
     * if you set the NvsStreamingEngineCompileFlag_OnlyVideo when you called
     "- (BOOL)compilePassthroughTimeline: outputFilePath: compileConfigurations: flags:" api, you should make sure the audiochannel of first track equal to the first asset you selected.
     eg:[fileInfo getAudioStreamChannelCount:0]
     */
    if (self.size.width == size.width && self.size.height == size.height
        && self.type == type && self.codecProfile == codecProfile && self.codecLevel == codecLevel && self.rotation == rotation && self.colorTransfer == colorTransfer && self.audioCount == audio) {
        return YES;
    }else{
        return NO;
    }
}

@end
