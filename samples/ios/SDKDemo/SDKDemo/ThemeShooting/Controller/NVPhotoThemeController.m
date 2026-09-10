//
//  NVPhotoThemeController.m
//  ThemeShooting
//
//  Created by ms on 2020/7/15.
//  Copyright © 2020 ms. All rights reserved.
//

#import "NVPhotoThemeController.h"
#import "PhotoThemeCell.h"
#import "NVDescribeController.h"
#import "UIColor+NvColor.h"
#import "NVHeader.h"
#import "HttpClient.h"
#import <NvBaseCommon/NvToast.h>
#import "NvThemeShootModel.h"
#import <NvSDKCommon/NvHttpRequest.h>
#import <NvSDKCommon/NvBaseNavigationController.h>
#import "NvThemeShootPopView.h"
#import "SSZipArchive.h"
#import "YYModel.h"

#define NV_THEME_SHOOT_BASEPATH @"Documents/ThemeShoot"

@interface NVPhotoThemeController ()<UICollectionViewDelegate, UICollectionViewDataSource, NvHttpRequestDelegate>
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NvThemeShootModel *currentmModel;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *localDataArray;
@property (nonatomic, assign) BOOL netAvailable;
@property (nonatomic, strong) NvThemeShootPopView *popView;
@property (nonatomic, strong) PhotoThemeCell *downloadCell;

@end

static NSString *const PhotoThemeCellID = @"PhotoThemeCell";

@implementation NVPhotoThemeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    self.localDataArray = [NSMutableArray array];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barTintColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"], NSForegroundColorAttributeName, [NvUtils fontWithSize:16], NSFontAttributeName, nil]];
    
    
    self.navigationController.navigationBar.translucent = NO;

    self.title = NvLocalString(@"ThemeShooting", @"主题拍摄");
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1A1A1A"];
    
    [self initCollectionView];
    
    [self addLocalSource];
    [self requestData];
}

/**
 添加本地素材
 Add local material
 */
- (void)addLocalSource {
    NSString *memoPath = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"ThemeShoot"];
    [self addLocalAssetWithPath:memoPath];
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/LocalThemeShoot"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:docPath isDirectory:nil]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:docPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self addLocalAssetWithPath:docPath];
}


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
            if ([path.pathExtension isEqualToString:@"json"]) {
                NSString *jsonPath = [localPath stringByAppendingPathComponent:path];
                NSString *item = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
                NvThemeShootModel *infoModel= [NvThemeShootModel new];
                NvPackageInfoModel *pModel= [NvPackageInfoModel yy_modelWithJSON:item];
                infoModel.packageInfoModel = pModel;
                infoModel.isDownload = YES;
                infoModel.isLocal = YES;
                for (NvShotInfoModel *info in infoModel.packageInfoModel.shotInfos) {
                    if (!info.source || !info.source.length) {
                        [infoModel.packageInfoModel.realCaptureVideos addObject:info];
                    }
                }
                [self.localDataArray addObject:infoModel];
                break;
            }
            
        }

    }
}

/**
 处理下载后的数据
 Processing the downloaded data
 */
-(void)configDownloadInfo{

    for (NvThemeShootModel *model in self.dataArray) {
        NSString *memoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/ThemeShoot"];
        NSString *dstPath = [memoPath stringByAppendingPathComponent:model.uuid];
        NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dstPath error:nil];
        if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:nil] && contents.count) {
            model.isDownload = YES;
        }else{
            model.isDownload = NO;
        }
        
        for (NvShotInfoModel *info in model.packageInfoModel.shotInfos) {
            if (!info.source || !info.source.length) {
                [model.packageInfoModel.realCaptureVideos addObject:info];
            }
        }
    }
    
    for (NvThemeShootModel *model in self.localDataArray) {
        [self.dataArray insertObject:model atIndex:0];
    }
    
    [self.collectionView reloadData];
}

#pragma mark 生命周期
///Life cycle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

/**
 请求主题模板
 Request theme template
 */
-(void)requestData{
    [NvToast showLoading];
    [HttpClient GETNewAsset:NV_ASSET_REQUEST_URL param:@{@"type":@18,
                                                         @"page":@1,
                                                         @"pageSize":@100,
                                                         @"lang":[NvHttpRequest getCurrentLang]}
                    success:^(NSArray<NSDictionary *> *items) {
        
        [NvToast dismiss];
        for (NSDictionary *dict in items) {
            NvThemeShootModel *model = [[NvThemeShootModel alloc] init];
            model.coverUrl = dict[@"coverUrl"];
            model.uuid = dict[@"id"];
            model.videoUrl = dict[@"previewVideoUrl"];
            model.packageUrl = dict[@"packageUrl"];
            model.zipUrl = dict[@"zipUrl"];
            model.packageInfoModel = [NvPackageInfoModel yy_modelWithJSON:dict[@"infoJson"]];
            model.isDownload = NO;
            [self.dataArray addObject:model];
        }
        
        if (self.dataArray.count) {
            self.currentmModel = self.dataArray[0];
        }
        
        [self configDownloadInfo];
    } failure:^(NSError *error) {
        [NvToast showInfoWithMessage:NvLocalString(@"CheckNetwork", @"请检查网络是否连接")];
    }];
    
    
}

/**
 下载主题素材
 Find out if a material exists

 @param uuid 素材id
 material id
 */
- (void)downloadWithId:(NvThemeShootModel *)model {

    NSString *memoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/ThemeShoot/Download"];
    NSString *dstPath = [[memoPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:model.uuid];
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dstPath error:nil];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dstPath isDirectory:nil] && contents.count) {
        NVDescribeController *VC = [[NVDescribeController alloc] init];
        VC.model = self.currentmModel;
        
        NvBaseNavigationController *nav = [[NvBaseNavigationController alloc] initWithRootViewController:VC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        if (![[NSFileManager defaultManager] fileExistsAtPath:memoPath isDirectory:nil]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:memoPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [self downloadPackageWithUrl:model.zipUrl destinationUrl:memoPath downloadId:model.uuid];
    }
}


-(void)initCollectionView{
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - NV_STATUSBARHEIGHT - NV_NAV_BAR_HEIGHT) collectionViewLayout:self.flowLayout];
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerClass:[PhotoThemeCell class] forCellWithReuseIdentifier:PhotoThemeCellID];
    self.collectionView.contentInset = UIEdgeInsetsMake(15 * SCREENSCALE, 15 * SCREENSCALE, 0,  15* SCREENSCALE);
    [self.view addSubview:self.collectionView];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionView Delegate

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(self)weakSelf = self;
    PhotoThemeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoThemeCellID forIndexPath:indexPath];
    cell.downLoadBlock = ^(NvThemeShootModel * _Nonnull model, PhotoThemeCell *cell) {
        [weakSelf downloadWithId:model];
        weakSelf.downloadCell = cell;
    };
    cell.model = self.dataArray[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.currentmModel = self.dataArray[indexPath.item];
    [self downloadWithId:self.currentmModel];
    
}

#pragma mark - Lazy Load

-(UICollectionViewFlowLayout *)flowLayout{
    if (_flowLayout == nil){
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake((SCREENWIDTH - 45 * SCREENSCALE) / 2.0, (SCREENWIDTH - 45 * SCREENSCALE) / 2.0+36 *SCREENSCALE);
        _flowLayout.minimumInteritemSpacing = 5 * SCREENSCALE;
        _flowLayout.minimumLineSpacing = 15 * SCREENSCALE;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}

- (void)onCheckNetworkState:(BOOL)isNetAvailable {
    self.netAvailable = isNetAvailable;
    if (self.dataArray.count == 0) {
         [self requestData];
    }
}

///下载模版
///Download template
- (void)downloadPackageWithUrl:(NSString *)sourceUrl destinationUrl:(NSString *)destinationUrl downloadId:(NSString *)downloadId {
    NvHttpRequest *request = [NvHttpRequest sharedInstance];
    [request downloadAsset:sourceUrl destFileDir:destinationUrl withDelegate:self downloadID:downloadId];
    self.popView = [[NvThemeShootPopView alloc] init];
    self.popView.title = NvLocalString(@"Downloading", nil);
    [self.popView showWithDirection:NvThemeShootPopDirection_Center completion:nil];
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
    __weak typeof(self)weakSelf = self;
    NSString *memoPath = [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/ThemeShoot"];
    downloadFilePath = [downloadFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    [self.popView dismissCompletion:^{
        for (NvThemeShootModel *mo in weakSelf.dataArray) {
            if ([downloadID isEqualToString:mo.uuid]) {
                mo.isDownload = YES;
                break;
            }
        }
        [weakSelf.collectionView reloadData];
        [weakSelf uSSZipArchiveWithFilePath:downloadFilePath destinationPath:memoPath];
    }];
    
}

- (void)onDonwloadAssetFailed:(NSError *) error
             downloadFilePath:(NSString*)downloadFilePath
                   downloadID:(NSString*)downloadID {
    [self.popView dismissCompletion:nil];
    
}

/**
 解压缩素材
 decompression
 */
-(void)uSSZipArchiveWithFilePath:(NSString *)path destinationPath:(NSString *)destinationPath {
   BOOL isSuccess =  [SSZipArchive unzipFileAtPath:path toDestination:destinationPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {

    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        
        if (error) {
            NSLog(@"%@",[error description]);
        }else{
            ///删除下载的压缩包
            ///Delete the downloaded compressed package
            NSFileManager *manager = [NSFileManager defaultManager];
            BOOL result = [manager removeItemAtPath:path error:nil];
            if (result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.downloadCell.downLoadImageView.hidden = YES;
                });
            }
           
        }
    }];
    
    ///如果解压成功则获取解压后文件列表
    ///If the decompression is successful, the file list is displayed
    if (!isSuccess) {
    }
}

@end
