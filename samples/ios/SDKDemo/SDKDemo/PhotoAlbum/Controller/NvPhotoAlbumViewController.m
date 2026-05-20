//
//  NvPhotoAlbumViewController.m
//  SDKDemo
//
//  Created by MS on 2019/9/24.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvPhotoAlbumViewController.h"
#import "NvPhotoAlbumFlowLayout.h"
#import "NvPhotoAlbumCollectionViewCell.h"
#import "NvAlbumViewController.h"
#import "NvPhotoAlbumGenerateViewController.h"
#import "NvPhotoAlbumPlayerView.h"
#import "NvPhotoAlbumModel.h"
#import <NvSDKCommon/NvHttpRequest.h>
#import "NSObject+YYModel.h"
#import "SSZipArchive.h"
#import "NvPhotoAlbumTemplateView.h"
#import <NvBaseCommon/UIColor+NvColor.h>
#import <NvSDKCommon/NvUtils.h>
#import <Masonry/Masonry.h>
#import <NvSDKCommon/NvAsset.h>
#import "AFNetworkReachabilityManager.h"

@interface NvPhotoAlbumViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,NvPhotoAlbumCollectionViewFlowLayoutDelegate,NvAlbumViewControllerDelegate,UIScrollViewDelegate,NvPhotoAlbumCollectionViewCellDelegate,NvHttpRequestDelegate,SSZipArchiveDelegate>
@property(nonatomic, strong) UICollectionView *photoCollectionView;
///模版label
///Template label
@property(nonatomic, strong) UILabel *templateLabel;
///附加信息label（x张照片最佳）
///Additional Information label (Best for x photos)
@property(nonatomic, strong) UILabel *subInfoLabel;
///当前模版index及总模版数label
///Current template index and total template label
@property(nonatomic, strong) UILabel *indexLabel;
///使用按钮
///Use button
@property(nonatomic, strong) UIButton *confirmButton;
@property(nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic, strong) AVAsset *asset;
@property(nonatomic, strong) AVPlayerItem *playerItem;
@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) NvPhotoAlbumCollectionViewCell *currentCell;
@property(nonatomic, strong) NvPhotoAlbumPlayerView *playerView;
@property(nonatomic, strong) NvPhotoAlbumTemplateView *popView;
@property(nonatomic, strong) NvPhotoAlbumModel *currentModel;
@property(nonatomic, strong) NvPhotoAlbumInfoModel *currentInfoModel;
@property(nonatomic, assign) NSInteger currentIndex;
@end

@implementation NvPhotoAlbumViewController {

    BOOL isDismiss;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"], NSForegroundColorAttributeName, [NvUtils fontWithSize:16], NSFontAttributeName, nil]];
    self.title = NvLocalString(@"PhotoAlbum", @"照片影集");
    self.dataSource = [NSMutableArray array];
    [self addSubviews];
    self.currentIndex = 0;
    [self addLocalSource];
    [self getPhotoAlbumList];
    
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown || [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [NvToast showInfoWithMessage:NvLocalString(@"CheckNetwork", @"Please check whether the network connection")];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self addObserver];
    if (self.playerItem) {
        [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    }
    [super viewWillAppear:animated];
    isDismiss = NO;
    
    NvPhotoAlbumFlowLayout* layout = (NvPhotoAlbumFlowLayout*)self.photoCollectionView.collectionViewLayout;
    if (self.photoCollectionView.contentOffset.x != layout.targetPoint.x) {
        [self.photoCollectionView setContentOffset:CGPointMake(layout.targetPoint.x, 0)];
        CGPoint pInView = [self.photoCollectionView.superview convertPoint:self.photoCollectionView.center toView:self.photoCollectionView];
        NSIndexPath *indexPathNow = [self.photoCollectionView indexPathForItemAtPoint:pInView];
        [self collectioViewScrollToIndex:indexPathNow.row];
        [self scrollViewDidEndDecelerating:self.photoCollectionView];
    }else{
        if (self.player && self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
            [self.player play];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    isDismiss = YES;
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addSubviews {
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    self.templateLabel = [[UILabel alloc] init];
    self.templateLabel.font = [UIFont systemFontOfSize:16.f*SCREENSCALE];
    self.templateLabel.textColor = [UIColor whiteColor];
    self.templateLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.templateLabel];
    [self.templateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(14.f*SCREENSCALEHEIGHT);
        make.left.equalTo(self.view).offset(KScale6s(10));
        make.right.equalTo(self.view).offset(-KScale6s(10));
        make.height.mas_equalTo(20.f*SCREENSCALEHEIGHT);
    }];
    
    self.subInfoLabel = [[UILabel alloc] init];
    self.subInfoLabel.font = [UIFont systemFontOfSize:11];
    self.subInfoLabel.textColor = [UIColor whiteColor];
    self.subInfoLabel.textAlignment = NSTextAlignmentCenter;
    self.subInfoLabel.numberOfLines = 2;
    [self.view addSubview:self.subInfoLabel];
    [self.subInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.templateLabel.mas_bottom).offset(1);
        make.left.equalTo(self.view).offset(KScale6s(10));
        make.right.equalTo(self.view).offset(-KScale6s(10));
        make.height.mas_lessThanOrEqualTo(14.f*SCREENSCALEHEIGHT);
    }];
    
    [self.view addSubview:self.photoCollectionView];
    [self.photoCollectionView registerClass:[NvPhotoAlbumCollectionViewCell class] forCellWithReuseIdentifier:@"CellId"];
    [self.photoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.subInfoLabel.mas_bottom).offset(16*SCREENSCALEHEIGHT);
        make.height.mas_equalTo(223*SCREENSCALE*16.0/9);
        make.left.right.equalTo(self.view);
    }];
    
    self.indexLabel = [[UILabel alloc] init];
    self.indexLabel.font = [UIFont systemFontOfSize:15];
    self.indexLabel.textAlignment = NSTextAlignmentCenter;
    self.indexLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:self.indexLabel];
    [self.indexLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.photoCollectionView.mas_bottom).offset(15.f*SCREENSCALEHEIGHT);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(20.f*SCREENSCALEHEIGHT);
    }];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton.layer.cornerRadius = 15*SCREENSCALE;
    self.confirmButton.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    [self.confirmButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [self.confirmButton setTitle:NvLocalString(@"Use", @"使用") forState:UIControlStateNormal];
    [self.confirmButton addTarget:self action:@selector(confirmButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.confirmButton];
    self.confirmButton.enabled = NO;
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.indexLabel.mas_bottom).offset(15*SCREENSCALEHEIGHT);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.width.mas_equalTo(120*SCREENSCALEHEIGHT);
        make.height.mas_equalTo(30*SCREENSCALE);
    }];
}

- (void)leftNavButtonClick:(UIButton *)button {
    [self.player pause];
    self.player = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - getter & setter
- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
}

- (void)configWithCurrentIndex:(NSInteger)index {
    if (self.dataSource.count >0) {
        self.currentModel = self.dataSource[index];
        self.currentInfoModel = [NvPhotoAlbumInfoModel yy_modelWithJSON:self.currentModel.packageInfo];
        self.templateLabel.text = self.currentInfoModel.photosAlbumName;
        self.subInfoLabel.text = self.currentInfoModel.photosAlbumTips;
        self.indexLabel.text = [NSString stringWithFormat:@"%ld/%lu",(long)index+1,(unsigned long)self.dataSource.count];
    }
}

#pragma mark - 按钮方法
///使用按钮点击
///the click method of confirm button
- (void)confirmButtonClicked:(UIButton *)button {
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown || [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable) {
        [NvToast showInfoWithMessage:NvLocalString(@"CheckNetwork", @"Please check whether the network connection")];
        return;
    }
    if (self.currentModel.isLocalAsset) {
        [self selectAlbum];
        return;
    }
    NSString *memoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/PhotoAlbum/Download"];
    NSString *dstPath = [[memoPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:self.currentModel.uuid];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:nil]) {
        [self selectAlbum];
    }else{
        if (![[NSFileManager defaultManager] fileExistsAtPath:memoPath isDirectory:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:memoPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [self downloadPackageWithUrl:self.currentModel.packageUrl destinationUrl:memoPath downloadId:self.currentModel.uuid];
    }
    

}

- (void)selectAlbum {
    [self.player pause];
    NvAlbumViewController *album = [[NvAlbumViewController alloc] init];
    album.isOnlyImage = YES;
    album.hiddenSelectAll = YES;
    album.delegate = self;
    album.isPhotoAlbumMode = YES;
    album.rightItemStr = self.currentInfoModel.photosAlbumTips;
    album.maxSelectCount = [self.currentInfoModel.photosAlbumReplaceMax integerValue];
    album.minSelectCount = [self.currentInfoModel.photosAlbumReplaceMin integerValue];
    [self.navigationController pushViewController:album animated:YES];
}

#pragma mark - 网络请求
///get list online
- (void)getPhotoAlbumList {
    [NvHttpRequest RequestPhotoAlbumMaterialListWithPage:1 pageSize:100 completionBlock:^(id respondData){
        NSDictionary *dic = (NSDictionary *)respondData;
        NSArray *arr = dic[@"data"][@"elements"];
        for (int i=0; i<arr.count; i++) {
            NSDictionary *item = arr[i];
            NvAsset *asset = [NvAsset yy_modelWithJSON:item];
            NvPhotoAlbumModel *model = [[NvPhotoAlbumModel alloc] init];
            model.coverUrl = asset.coverUrl;
            model.uuid = asset.uuid;
            model.videoUrl = asset.previewVideoUrl;
            model.packageUrl = asset.zipUrl;
            model.packageInfo = asset.infoJson.yy_modelToJSONString;
            [self.dataSource addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photoCollectionView reloadData];
            if (self.currentIndex == 0) {
                [self replaceAVPlayerItem];
                [self configWithCurrentIndex:self.currentIndex];
                self.confirmButton.enabled = YES;
            }
        });
       
    } failureBlock:^(NSError *error){
        
    }];
}

-(NvPhotoAlbumInfoModel *)getLocalJsonWithUUid:(NSString *)uuid{
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSString *memoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/PhotoAlbum"];
    NSString *dstPath = [memoPath stringByAppendingPathComponent:uuid];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:nil]) {
        NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:dstPath error:nil];
        if (dirArray.count <=0) {
            return nil;
        }
        for (NSString *dirPath in dirArray) {
            if ([dirPath.pathExtension isEqualToString:@"json"]) {
                NSString *jsonPath = [dstPath stringByAppendingPathComponent:dirPath];
                NSString *item = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
                NvPhotoAlbumInfoModel *infoModel= [NvPhotoAlbumInfoModel yy_modelWithJSON:item];
                return infoModel;
               
            }
        }
    }
    return nil;
}

///获取本地模版列表
///get list in local
- (void)addLocalSource {
    NSString *memoPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"PhotoAlbumAsset"];
    [self addLocalAssetWithPath:memoPath];
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/PhotoAlbumAsset"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:docPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self addLocalAssetWithPath:docPath];
}

///根据路径添加模版信息
///add local asset by given path
- (void)addLocalAssetWithPath:(NSString *)memoPath {
    NSFileManager *myFileManager = [NSFileManager defaultManager];
    NSArray * dirArray = [myFileManager contentsOfDirectoryAtPath:memoPath error:nil];
    if (dirArray.count <=0) {
        return;
    }
    NSLog(@"%@",dirArray);
    for (NSString *dirPath in dirArray) {
        NSString *localPath = [memoPath stringByAppendingPathComponent:dirPath];
        NSDirectoryEnumerator *myDirectoryEnumerator = [myFileManager enumeratorAtPath:localPath];
        for (NSString *path in myDirectoryEnumerator.allObjects) {
            if ([path isEqualToString:@"info.json"]) {
                NSString *jsonPath = [localPath stringByAppendingPathComponent:path];
                NSString *item = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
                NvPhotoAlbumInfoModel *infoModel= [NvPhotoAlbumInfoModel yy_modelWithJSON:item];
                NvPhotoAlbumModel *model = [NvPhotoAlbumModel new];
                model.packageInfo = item;
                model.uuid = dirPath;
                model.isLocalAsset = YES;
                model.videoUrl = [localPath stringByAppendingPathComponent:infoModel.photosAlbumCoverVideo];
                model.coverUrl = [localPath stringByAppendingPathComponent:infoModel.photosAlbumCoverImage];
                model.localPath = localPath;
                [self.dataSource addObject:model];
                break;
            }
            
        }
    }
}

///下载模版
///download package online
- (void)downloadPackageWithUrl:(NSString *)sourceUrl destinationUrl:(NSString *)destinationUrl downloadId:(NSString *)downloadId {
    NvHttpRequest *request = [NvHttpRequest sharedInstance];
    [request downloadAsset:sourceUrl destFileDir:destinationUrl withDelegate:self downloadID:downloadId];
    self.popView = [[NvPhotoAlbumTemplateView alloc] init];
    self.popView.title = NvLocalString(@"Downloading", nil);
    [self.popView showWithDirection:NvPopDirection_Center completion:nil];
    [self.player pause];
}

#pragma mark - 切换播放源
///replace the player item
- (void)replaceAVPlayerItem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    self.currentCell = (NvPhotoAlbumCollectionViewCell *)[self.photoCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0]];
    
    NvPhotoAlbumModel *model;
    if(self.currentIndex >= 0 && self.currentIndex < self.dataSource.count){
        model = self.dataSource[self.currentIndex];
    }
    NSURL *url = [NSURL URLWithString:model.videoUrl];
    if (self.playerItem) {
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }
    NSString *memoPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/PhotoAlbum"] stringByAppendingPathComponent:model.uuid];
    if (model.isLocalAsset) {
        memoPath = model.localPath;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:memoPath]) {
        NSDirectoryEnumerator *myDirectoryEnumerator = [manager enumeratorAtPath:memoPath];
        
        BOOL isDir = NO;
        BOOL isExist = NO;
        for (NSString *path in myDirectoryEnumerator.allObjects) {
            if ([path isEqualToString:@"cover.mp4"]) {

                NSString *coverPath = [NSString stringWithFormat:@"%@/%@", memoPath, path];
                isExist = [manager fileExistsAtPath:coverPath isDirectory:&isDir];
                if (isExist && !isDir) {
                    url = [NSURL fileURLWithPath:coverPath];
                    break;
                }
            }
        }
    }
    
    AVPlayerItem *avItem = [AVPlayerItem playerItemWithURL:url];
    if (!self.player) {
        self.player = [AVPlayer playerWithPlayerItem:avItem];
        self.playerView.player = self.player;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                       error:nil];
    }else{
        [self.player replaceCurrentItemWithPlayerItem:avItem];
    }
    self.playerItem = avItem;
    [self.playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    self.player.muted = NO;
}

- (void)seekToStart:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.player pause];
        AVPlayerItem *item = [notification object];
        [item seekToTime:kCMTimeZero completionHandler:nil];
        [self.player play];
    });
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                [(AVPlayerLayer *)[self.playerView layer] setVideoGravity:AVLayerVideoGravityResizeAspect];
                [self.currentCell addSubview:self.playerView];
                [self.currentCell bringSubviewToFront:self.playerView];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(seekToStart:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
                [self.player play];
            }
        });
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NvPhotoAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellId" forIndexPath:indexPath];
    cell.delegate = self;
    cell.model = self.dataSource[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

#pragma mark - NvPhotoAlbumCollectionViewFlowLayoutDelegate
- (void)collectioViewScrollToIndex:(NSInteger)index {
    self.currentIndex = index;
    [self configWithCurrentIndex:self.currentIndex];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.player pause];
    self.confirmButton.enabled = NO;
    if (self.playerView) {
        [self.playerView removeFromSuperview];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!isDismiss) {
        [self replaceAVPlayerItem];
    }
    self.confirmButton.enabled = YES;
    
}

#pragma mark - NvPhotoAlbumCollectionViewCellDelegate
- (void)photoAlbumCollectionCell:(NvPhotoAlbumCollectionViewCell *)cell didUpdateModel:(NvPhotoAlbumModel *)model {
    NSInteger index = [self.dataSource indexOfObject:model];
    if (index == self.currentIndex && index==0 && !self.currentCell) {
        [cell addSubview:self.playerView];
    }
}


#pragma mark - NvHttpRequestDelegate
- (void)onDonwloadAssetProgress:(int32_t)progress
                     downloadID:(NSString*)downloadID {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.popView.progressValue = progress;
    });
    
}

- (void)onDonwloadAssetSuccess:(BOOL) isSuccess
              downloadFilePath:(NSString*)downloadFilePath
                    downloadID:(NSString*)downloadID {

    NSString *memoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/PhotoAlbum"];
    downloadFilePath = [downloadFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    [self.popView dismissCompletion:^{
        [self uSSZipArchiveWithFilePath:downloadFilePath destinationPath:memoPath];
    }];
    
}

- (void)onDonwloadAssetFailed:(NSError *) error
             downloadFilePath:(NSString*)downloadFilePath
                   downloadID:(NSString*)downloadID {
    [self.popView dismissCompletion:nil];
    
}

-(void)uSSZipArchiveWithFilePath:(NSString *)path destinationPath:(NSString *)destinationPath {
   BOOL isSuccess =  [SSZipArchive unzipFileAtPath:path toDestination:destinationPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {

    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        
        if (error) {

        }else{
            ///删除下载的压缩包
            ///Delete the downloaded compressed package
            NSFileManager *manager = [NSFileManager defaultManager];
            BOOL result = [manager removeItemAtPath:path error:nil];
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   [self selectAlbum];
                });
            }
           
        }
    }];
    
    ///如果解压成功则获取解压后文件列表
    ///If the decompression is successful, the file list is displayed
    if (!isSuccess) {
        
    }
    
}

#pragma mark - NvAlbumViewControllerDelegate
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    [self.player pause];
    NvPhotoAlbumGenerateViewController *vc = [NvPhotoAlbumGenerateViewController new];
    __block NSMutableArray *pathFiles = [NSMutableArray array];
    for (int i=0; i<assets.count; i++) {
        NvAlbumAsset *albumAsset = assets[i];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        @autoreleasepool {
            if (albumAsset.asset.mediaType == PHAssetMediaTypeImage) {
               
                PHImageRequestOptions *options = [PHImageRequestOptions new];
                options.version = PHImageRequestOptionsVersionOriginal;
                options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
                options.synchronous = YES;
                [[PHImageManager defaultManager] requestImageDataForAsset:albumAsset.asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    NSString *filePath = [@"PHAsset://" stringByAppendingString:albumAsset.asset.localIdentifier] ;
                    [pathFiles addObject:filePath];
                    dispatch_semaphore_signal(semaphore);
                }];
            }
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }

    }

    NSString *memoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/PhotoAlbum"];
    if (self.currentModel.isLocalAsset) {
        memoPath = [self.currentModel.localPath stringByDeletingLastPathComponent];
    }
    vc.files = pathFiles;
    vc.localPath = [memoPath stringByAppendingPathComponent:self.currentModel.uuid];
    vc.title = self.currentInfoModel.photosAlbumName;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - lazyload
- (UICollectionView *)photoCollectionView {
    if (!_photoCollectionView) {
        NvPhotoAlbumFlowLayout *flow = [[NvPhotoAlbumFlowLayout alloc] init];
        flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flow.itemSize = CGSizeMake(223*SCREENSCALE, 223*SCREENSCALE*16.0/9);
        flow.minimumLineSpacing = 0*SCREENSCALE;
        flow.needAlpha = YES;
        flow.delegate = self;
        CGFloat oneX = SCREENWIDTH / 2 - 223*SCREENSCALE/2;
        flow.sectionInset = UIEdgeInsetsMake(0, oneX, 0, oneX);
        
        _photoCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREENSCALE, 223*SCREENSCALE*16.0/9) collectionViewLayout:flow];
        _photoCollectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        _photoCollectionView.delegate = self;
        _photoCollectionView.dataSource = self;
        _photoCollectionView.showsHorizontalScrollIndicator = NO;
    }
    return _photoCollectionView;
}

- (NvPhotoAlbumPlayerView *)playerView {
    if (!_playerView) {
        _playerView = [[NvPhotoAlbumPlayerView alloc] initWithFrame:CGRectMake(0, 0, 223*SCREENSCALE, 223*SCREENSCALE*16.0/9)];
    }
    return _playerView;
}

#pragma mark 添加通知
///Add notification
- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)applicationWillResignActive:(NSNotification*)notification {
    [self.player pause];
}

- (void)applicationBecomeActive:(NSNotification*)notification {
    [self.player play];
}

@end
