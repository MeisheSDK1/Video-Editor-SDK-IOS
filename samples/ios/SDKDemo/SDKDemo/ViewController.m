//
//  ViewController.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "ViewController.h"
#import "NvSetUpViewController.h"
#import <NvAlbum/NvAlbumViewController.h>
#import "NvCaptureViewController.h"
#import "NvEditViewController.h"
#import "NvEditMaterialViewController.h"
#import <NvAlbum/NvAlbumSizeViewController.h>
#import "NvParCaptureViewController.h"
#import <NvStreamingSdkCore/NvsStreamingContext.h>
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvHomeCViewCell.h"
#import "NvFeedbackViewController.h"
#import "CollectionLoopView.h"
#import <NvBaseCommon/HttpClient.h>
#import "NvWebViewController.h"
#import "NvPrivateAlertView.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NvToast.h>
#import <NvSDKCommon/NvUtils.h>
#import <NvSDKCommon/NvHttpRequest.h>
#import <NvSDKCommon/NvInitArScence.h>
#import <NvBaseCommon/NvModuleManager.h>
#import <NvTemplate/NvTemplate-Swift.h>
#import "AFNetworkReachabilityManager.h"
#import <NSObject+YYModel.h>
//键盘类
#import <IQKeyboardManager/IQKeyboardManager.h>
@import MediaPlayer;

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) NvAssetManager *assetManager;
//反馈按钮,Feedback button
@property (nonatomic, strong) UIButton *feedbackBtn;
//设置按钮,Set button
@property (nonatomic, strong) UIButton *setUpBtn;
//视频拍摄按钮,Video shoot button
@property (nonatomic, strong) UIButton *shootingBtn;
//视频编辑按钮,Video edit button
@property (nonatomic, strong) UIButton *editorBtn;

//scrollView视图数据，存放的是NvHomeArrayModel，结构：一个CollectionView，一个数组NvHomeModel
//scrollView view data, store is NvHomeArrayModel, structure: a CollectionView, an array NvHomeModel
@property (nonatomic, strong) NSMutableArray *dataSource;
//滚动视图，每一页放一个CollectionView
// Scroll view, put a CollectionView for each page
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIPageControl *pageControl;

//自定义相册底部按钮
// Customize the button at the bottom of the album
@property (nonatomic, weak) UIButton *custumButton;

@property (nonatomic, weak) NvAlbumViewController *albumViewController;
@property (nonatomic, strong) NvsStreamingContext *streamingContext;
@property (nonatomic, strong) CollectionLoopView *loopView;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, assign) CGFloat cellSpacing;

@end

@implementation ViewController {
    MPRemoteCommandCenter *commandCenter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.streamingContext = [NvSDKUtils getSDKContext];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    NSNumber *num = NV_UserInfo(@"NvRecordResolution");
    if (num==nil) {
        [[NSUserDefaults standardUserDefaults] setValue:@1080 forKey:@"NvRecordResolution"];
        [[NSUserDefaults standardUserDefaults] setValue:@1080 forKey:@"NvCompileResolution"];
        [[NSUserDefaults standardUserDefaults] setValue:@0 forKey:@"NvBackgroudBlurFilled"];
        [[NSUserDefaults standardUserDefaults] setValue:@(15 * NV_TIME_BASE) forKey:@"NvCompileBitrate"];
        [[NSUserDefaults standardUserDefaults] setValue:@1 forKey:@"NvLiveWindowModel"];
        [[NSUserDefaults standardUserDefaults] setValue:@1 forKey:@"NvResolutionConfiguration"];
        [[NSUserDefaults standardUserDefaults] setValue:@1 forKey:@"NvExportConfiguration"];
        [[NSUserDefaults standardUserDefaults] setValue:@0 forKey:@"NvHEVCModel"];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:0] forKey:@"NvTestNumMaterial"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self addSubViews];
    [self configDataSource];
    [self installPackage];
    [self createLocalMaterialFolder];
    [self installPIPPackage];
    [self installParticlePackage];
    NSString *itemPath = [[[NSBundle mainBundle] pathForResource:@"sticker" ofType:@"bundle"] stringByAppendingPathComponent:@"custom"];
    [self.assetManager searchReservedAssets:ASSET_CUSTOM_ANIMATED_STICKER bundlePath:itemPath];
    //创建目录，清除一些资源
    // Create a directory and clear some resources
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *pathArray = @[VIDEO_PATH(@"Recordmp3"),VIDEO_PATH(@"Record"),VIDEO_PATH(@"Particle"),VIDEO_PATH(@"Virtual"),VIDEO_PATH(@"Boomerang"),WATEMARK_PATH,CONVERTPATH];
    for (NSString *path in pathArray) {
        if (![fm fileExistsAtPath:path]) {
            [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        } else {
            [fm removeItemAtPath:path error:nil];
            [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    //美型测试包放置路径，只创建文件夹，不清除
    // Beauty package test package path do not only create, do not clear
    pathArray = @[Beauty_Type_Path,Beauty_Microshaping_Path,VIDEO_PATH(@"testedit")];
    for (NSString *path in pathArray) {
        if (![fm fileExistsAtPath:path]) {
            [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    
    /// 服务协议
    /// Service agreement
    [self checkPrivate];
    NSString *licenseDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/license"];
    if (![fm fileExistsAtPath:licenseDir]) {
        NSError *error;
        [fm createDirectoryAtPath:licenseDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.loopView startTimer];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.loopView stopTimer];
}

#pragma mark - 创建本地素材文件夹，方便设计人员测试素材
//Create a local materials folder for designers to test materials
- (void)createLocalMaterialFolder{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *pathArray = @[@"props",@"filter",@"stickers",@"compoundCaption",@"BeautyTemplate"];
    for (NSString *path in pathArray) {
        NSString *newPath = [VIDEO_PATH(@"LocalAssets") stringByAppendingPathComponent:path];
        if (![fm fileExistsAtPath:newPath]) {
            [fm createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
}

//为短视频demo安装package
// Install the package for the video demo
- (void)installPackage {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"shortVideoInstall"] boolValue]) {
        return;
    }
    BOOL isInstall = YES;
    NSString *packagePath = [[NSBundle mainBundle] pathForResource:@"shortVideoPackage" ofType:@"bundle"];
    NSString *jsonPath = [packagePath stringByAppendingPathComponent:@"fx.json"];
    NSString *jsontext = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    NSData *data =[jsontext dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    for (int i = 0; i < array.count-1; i++) {
        NSDictionary *dic = array[i];
        NSString *path = [packagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",dic[@"fxFileName"]]];
        NSString *license = [NSString convertFilePathToNewPath:path WithExtension:@"lic"];
        NvsAssetPackageManagerError error = [self.streamingContext.assetPackageManager installAssetPackage:path license:license type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:[NSMutableString string]];
        if (error == NvsAssetPackageManagerError_NoError || error == NvsAssetPackageManagerError_AlreadyInstalled || error == NvsAssetPackageManagerError_WorkingInProgress) {
            
        } else {
            isInstall = NO;
        }
    }
    
    [userDefault setObject:@(isInstall) forKey:@"shortVideoInstall"];
}

#pragma mark 为画中画安装package
//Install package for picture-in-picture
- (void)installPIPPackage {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([[userDefault objectForKey:@"PIPInstall"] boolValue]) {
        return;
    }
    BOOL isInstall = YES;
    
    NSString *packagePath = [[NSBundle mainBundle] pathForResource:@"PIPPackage" ofType:@"bundle"];
    NSString *jsonPath = [packagePath stringByAppendingPathComponent:@"pipFileInfo.json"];
    NSString *jsontext = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
    NSData *data =[jsontext dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array =[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    for (int i = 0; i < array.count; i++) {
        
        NSDictionary *dic = array[i];
        NSString *path = [packagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",dic[@"fileDirName"],dic[@"pipPackageName1"]]];
        NSString *path1 = [packagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",dic[@"fileDirName"],dic[@"pipPackageName2"]]];
        
        NSString *license = [NSString convertFilePathToNewPath:path WithExtension:@"lic"];;
        NSString *license1 = [NSString convertFilePathToNewPath:path1 WithExtension:@"lic"];
        
        NvsAssetPackageManagerError error = [self.streamingContext.assetPackageManager installAssetPackage:path license:license type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:[NSMutableString string]];
        if (error == NvsAssetPackageManagerError_NoError || error == NvsAssetPackageManagerError_AlreadyInstalled || error == NvsAssetPackageManagerError_WorkingInProgress) {
        } else {
            isInstall = NO;
        }
        
        NvsAssetPackageManagerError error1 = [self.streamingContext.assetPackageManager installAssetPackage:path1 license:license1 type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:[NSMutableString string]];
        if (error1 == NvsAssetPackageManagerError_NoError || error1 == NvsAssetPackageManagerError_AlreadyInstalled || error1 == NvsAssetPackageManagerError_WorkingInProgress) {
        } else {
            isInstall = NO;
        }
    }
    //安装沙盒package
    // Install the sandbox package
    NSString *jsonPath2 = [PIPPACKAGE_PATH stringByAppendingPathComponent:@"pipFileInfo.json"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:PIPPACKAGE_PATH]) {
        [fm createDirectoryAtPath:PIPPACKAGE_PATH withIntermediateDirectories:YES attributes:nil error:nil];
        [fm copyItemAtPath:jsonPath toPath:jsonPath2 error:nil];
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:jsonPath2];
        [fh truncateFileAtOffset:0];
        [fh writeData:[@"[]" dataUsingEncoding:NSUTF8StringEncoding]];
        [fh closeFile];
    }
    
    NSString *jsontext2 = [NSString stringWithContentsOfFile:jsonPath2 encoding:NSUTF8StringEncoding error:nil];
    NSData *data2 =[jsontext2 dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array2 =[NSJSONSerialization JSONObjectWithData:data2 options:0 error:nil];
    for (int i = 0; i < array2.count; i++) {
        
        NSDictionary *dic = array2[i];
        NSString *path = [PIPPACKAGE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",dic[@"fileDirName"],dic[@"pipPackageName1"]]];
        NSString *path1 = [PIPPACKAGE_PATH stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",dic[@"fileDirName"],dic[@"pipPackageName2"]]];
        
        NSString *license = [NSString convertFilePathToNewPath:path WithExtension:@"lic"];
        NSString *license1 = [NSString convertFilePathToNewPath:path1 WithExtension:@"lic"];
        
        NvsAssetPackageManagerError error = [self.streamingContext.assetPackageManager installAssetPackage:path license:license type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:[NSMutableString string]];
        if (error == NvsAssetPackageManagerError_NoError || error == NvsAssetPackageManagerError_AlreadyInstalled || error == NvsAssetPackageManagerError_WorkingInProgress) {
            
        } else {
            isInstall = NO;
        }
        
        NvsAssetPackageManagerError error1 = [self.streamingContext.assetPackageManager installAssetPackage:path1 license:license1 type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:[NSMutableString string]];
        if (error1 == NvsAssetPackageManagerError_NoError || error1 == NvsAssetPackageManagerError_AlreadyInstalled || error1 == NvsAssetPackageManagerError_WorkingInProgress) {
            
        } else {
            isInstall = NO;
        }
    }
    
    [userDefault setObject:@(isInstall) forKey:@"PIPInstall"];
}

#pragma mark 为粒子demo安装package
//Install the package for the particle demo
- (void)installParticlePackage {
    self.assetManager = [NvAssetManager sharedInstance];
    NSString *packagePath = [[NSBundle mainBundle] pathForResource:@"ParticlePackage" ofType:@"bundle"];
    [self.assetManager searchReservedAssets:ASSET_PARTICLE bundlePath:packagePath];
}

#pragma mark 敬请期待提示视图
//Stay tuned for the prompt view
- (void)tipView{
    
    [UIAlertController presentAlertFromVC:self
                                    title:NvLocalString(@"Stay tuned", @"敬请期待！")
                                  message:NvLocalString(@"contactbusiness", @"可移步官网联系商务人员")
                        buttonTitleColors:nil
                        cancelButtonTitle:nil
                         otherButtonTitle:NvLocalString(@"Know", @"知道了")
                       cancelButtonAction:nil
                        otherButtonAction:nil];
}

#pragma mark 添加子视图
//Add subview
- (void)addSubViews{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.feedbackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.feedbackBtn setImage:NvImageNamed(@"NvHomeFeedback") forState:UIControlStateNormal];
    [self.feedbackBtn addTarget:self action:@selector(feedbackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.setUpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.setUpBtn setImage:NvImageNamed(@"NvSetting") forState:UIControlStateNormal];
    [self.setUpBtn addTarget:self action:@selector(btnClickevent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *logoImageView = [[UIImageView alloc]init];
    logoImageView.image = NvImageNamed(@"NvHomeBgLogo");
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview:self.setUpBtn];
    [self.view addSubview:self.feedbackBtn];
    [self.view addSubview:logoImageView];
    
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(17 * SCREENSCALE + NV_STATUSBARHEIGHT);
        make.left.equalTo(self.view.mas_left).offset(17 * SCREENSCALE);
        make.width.offset(56 * SCREENSCALE);
        make.height.offset(26 * SCREENSCALE);
    }];
    
    [self.setUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(logoImageView);
        make.right.equalTo(self.view.mas_right).offset(-13 * SCREENSCALE);
    }];
    
    [self.feedbackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.setUpBtn.mas_centerY);
        make.right.equalTo(self.setUpBtn.mas_left).offset(-20 * SCREENSCALE);
    }];
    UIImageView *imageView = [UIImageView new];
    imageView.image = NvImageNamed(@"NvWaveImage");
    [self.view addSubview:imageView];
    UIView *bottomView = [[UIView alloc] init];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    
    self.shootingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.shootingBtn setImage:NvImageNamed(@"NvHomeCapture") forState:UIControlStateNormal];
    [self.shootingBtn setImage:NvImageNamed(@"NvHomeCapture") forState:UIControlStateHighlighted];
    [self.shootingBtn addTarget:self action:@selector(shootingBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shootingBtn];
    [self.shootingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(14 * SCREENSCALE);
        make.width.offset(157 * SCREENSCALE);
        make.height.offset(97 * SCREENSCALE);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-63*SCREENSCALE);
        } else {
            make.bottom.equalTo(self.view.mas_bottom).offset(-63*SCREENSCALE);
        }
    }];
    
    self.editorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editorBtn setImage:NvImageNamed(@"NvHomeEdit") forState:UIControlStateNormal];
    [self.editorBtn setImage:NvImageNamed(@"NvHomeEdit") forState:UIControlStateHighlighted];
    [self.editorBtn addTarget:self action:@selector(editorBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.editorBtn];
    [self.editorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view.mas_right).offset(-14 * SCREENSCALE);
        make.width.offset(157 * SCREENSCALE);
        make.height.offset(97 * SCREENSCALE);
        make.bottom.equalTo(self.shootingBtn.mas_bottom);
    }];
    
    UILabel *shootingLabel = [[UILabel alloc]init];
    shootingLabel.text = NvLocalString(@"ShootVideo", @"视频拍摄");
    shootingLabel.textColor = UIColor.whiteColor;
    shootingLabel.font = [NvUtils regularFontWithSize:15];
    [self.shootingBtn addSubview:shootingLabel];
    [shootingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.shootingBtn.mas_bottom).offset(-16 * SCREENSCALE);
        make.centerX.equalTo(self.shootingBtn.mas_centerX);
    }];
    
    UILabel *editLabel = [[UILabel alloc]init];
    editLabel.text = NvLocalString(@"EditVideo", @"视频编辑");
    editLabel.textColor = UIColor.whiteColor;
    editLabel.font = [NvUtils regularFontWithSize:15];
    [self.editorBtn addSubview:editLabel];
    [editLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.editorBtn.mas_bottom).offset(-16 * SCREENSCALE);
        make.centerX.equalTo(self.editorBtn.mas_centerX);
    }];
    
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    UILabel *sdkLabel = [[UILabel alloc]init];
    sdkLabel.textColor = [UIColor nv_colorWithHexARGB:@"#FF333333"];
    sdkLabel.font = [NvUtils regularFontWithSize:14];
    sdkLabel.text = [NSString stringWithFormat:@"V %d.%d.%d",large,minor,revision];
    [self.view addSubview:sdkLabel];
    [sdkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(self.view.mas_bottom);
        }
    }];
    
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.shootingBtn.mas_top).offset(-68*SCREENSCALE);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.offset(176 * SCREENSCALE);
    }];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView.mas_top).offset(-20*SCREENSCALE);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view);
    }];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.currentPageIndicatorTintColor = [UIColor nv_colorWithHexARGB:@"#55000000"];
    self.pageControl.pageIndicatorTintColor = [UIColor nv_colorWithHexARGB:@"#0F000000"];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.enabled = NO;
    [self.view addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView.mas_bottom).offset(10 * SCREENSCALE);
        make.centerX.equalTo(self.view.mas_centerX);
        if(@available(iOS 14.0, *)){
            
        }else{
            make.width.offset(20 * SCREENSCALE);
        }
        make.height.offset(10 * SCREENSCALE);
    }];
    [self.view layoutIfNeeded];
    self.loopView = [[CollectionLoopView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, self.scrollView.top-20*SCREENSCALE)];
    self.loopView.delegate = self;
    [self.view addSubview:self.loopView];
    [self.view sendSubviewToBack:self.loopView];
    self.loopView.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    
    // 开始监测 Start monitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWWAN || [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusReachableViaWiFi) {
        [self requestData];
    }else{
        // 网络状态改变的回调 Callbacks of network state changes
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:{
                    [self requestData];
                }
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:{
                    [self requestData];
                }
                default:{

                }
                break;
            }
        }];
    }


    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(bottomView.mas_top).offset(1*SCREENSCALE);
        make.left.right.equalTo(@0);
        make.height.equalTo(@(56*SCREENSCALE));
    }];
}

- (void)requestData{
    __weak typeof(self)weakSelf = self;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *listAdvertisement = [userDefaults objectForKey:@"listAdvertisement"];
    NSArray *defaultAdList = [NSArray yy_modelArrayWithClass:NvLoopViewModel.class json:listAdvertisement];
    weakSelf.loopView.contents = defaultAdList;
    [HttpClient request:NvGet url:[NV_API_HOST stringByAppendingPathComponent:@"app/listAdvertisement"] param:@{} completionHandler:^(NSURLResponse *response, id  _Nullable responseObject, NSError * _Nullable error) {
        int rval = [[responseObject objectForKey:@"code"] intValue];
        if (rval == 1) {
            
            NSArray *array = [responseObject objectForKey:@"data"];
            NSArray *adList = [NSArray yy_modelArrayWithClass:NvLoopViewModel.class json:array];
            weakSelf.loopView.contents = adList;
        } else {
            
            if (defaultAdList.count == 0) {
                [NvToast showInfoWithMessage:NvLocalString(@"CheckNetwork", @"请检查网络是否连接")];
            } else {
                weakSelf.loopView.contents = defaultAdList;
            }
        }
    }];
}

- (void)collectionLoopView:(CollectionLoopView *)collectionLoopView didSelectIndex:(unsigned int)index {
    NSString *urlString;
    if ([NvUtils currentLanguagesIsChinese]) {
        urlString = ((NvLoopViewModel *)(collectionLoopView.contents[index])).advertisementUrl;
    } else {
        urlString = ((NvLoopViewModel *)(collectionLoopView.contents[index])).advertisementUrlEn;
    }
    NvWebViewController *webVC = [NvWebViewController new];
    webVC.urlString = urlString;
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark feedbackBtnClick——反馈按钮点击
//Feedback button click
- (void)feedbackBtnClick:(UIButton *)sender{
    NvFeedbackViewController *vc = [[NvFeedbackViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark shootingBtnClick——视频拍摄按钮点击
//Click the video shooting button
- (void)shootingBtnClick:(UIButton *)sender{
    NvCaptureViewController *vc = [[NvCaptureViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark editorBtnClick——视频编辑按钮点击
//Click the video Edit button
- (void)editorBtnClick:(UIButton *)sender{
    [[NSUserDefaults standardUserDefaults] setValue:@(false) forKey:@"urlEdit"];
    NvAlbumViewController *vc = [NvAlbumViewController new];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 给拍摄、编辑配置颜色渐变效果
//Configure color gradients for shooting and editing
- (void)gradientView:(UIButton *)sender withColors:(NSArray *)colors{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height);
    gradientLayer.colors = colors;
    gradientLayer.locations = @[@(0.0f),@(1.0f)];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.masksToBounds = YES;
    gradientLayer.cornerRadius = 10 * SCREENSCALE;
    [sender.layer addSublayer:gradientLayer];
}

#pragma mark 配置数据
//Configuration data
- (void)configDataSource{
    
    [NvTemplateModule registerModule];
    [[NvModuleManager sharedInstance] generateRegistedModules];
    
    self.dataSource = [NSMutableArray array];
    NSArray *moduleArray = [[NvModuleManager sharedInstance] allModules];

    int page = ceil(moduleArray.count / 8.0);
    for (int i = 0; i < page; i++) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.itemSize = CGSizeMake(58*SCREENSCALE, 82*SCREENSCALE);
        layout.minimumInteritemSpacing= 36*SCREENSCALE;
        layout.minimumLineSpacing = 12*SCREENSCALE;
        layout.sectionInset = UIEdgeInsetsMake(0, 15*SCREENSCALE, 0, 15*SCREENSCALE);
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(i * SCREENWIDTH, 0, SCREENWIDTH, 176 * SCREENSCALE) collectionViewLayout:layout];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsVerticalScrollIndicator = NO; // 去掉滚动条
        [collectionView registerClass:[NvHomeCViewCell class] forCellWithReuseIdentifier:@"NvHomeCViewCell"];
        [self.scrollView addSubview:collectionView];
        
        NvHomeArrayModel *model = [NvHomeArrayModel new];
        model.array = [NSMutableArray array];
        model.collectionView = collectionView;
        int index = i*8;
        for (int j = index; j < moduleArray.count; j++) {
            NvModule *module = moduleArray[j];
            NvHomeModel *model_1 = [NvHomeModel new];
            model_1.name = [module moduleTitle];
            model_1.coverImage = [module moduleCover];
            model_1.moduleName = NSStringFromClass([module class]);
            [model.array addObject:model_1];
            index++;
            if (index % 8 == 0) break;
        }
        [self.dataSource addObject:model];
        [collectionView reloadData];
    }
    self.scrollView.contentSize = CGSizeMake(page * SCREENWIDTH, 171 * SCREENSCALE);
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = page;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    for (NvHomeArrayModel *model in self.dataSource) {
        if ([model.collectionView isEqual:collectionView]) {
            return model.array.count;
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvHomeArrayModel *model in self.dataSource) {
        if ([model.collectionView isEqual:collectionView]) {
            NvHomeCViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvHomeCViewCell" forIndexPath:indexPath];
            [cell renderCellWithItem:model.array[indexPath.item]];
            return cell;
        }
    }
    return [UICollectionViewCell new];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 3) {
        [self initARFace];
    }
    NSArray *moduleArray = [[NvModuleManager sharedInstance] allModules];
    NvModule *module = moduleArray[self.pageControl.currentPage * 8 + indexPath.item];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.navigationController forKey:kCurrentNavigationControllerKey];
    [[NvModuleManager sharedInstance] performPushTargetWithName:NSStringFromClass([module class]) params:params];
}

#pragma mark 初始化人脸授权
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

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewWith:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollViewWith:scrollView];
    }
}
//判断当前页面，给当前model赋值
// Determine the current page and assign a value to the current model
- (void)scrollViewWith:(UIScrollView *)scrollView {
    NSUInteger page = scrollView.contentOffset.x / SCREENWIDTH;
    self.pageControl.currentPage = page;
}

#pragma mark btnClickevent——设置按钮点击
//Set button click
- (void)btnClickevent:(UIButton *)btn{
    NvSetUpViewController *vc = [[NvSetUpViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark 相册回调
//Album callback
- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
    NvAlbumSizeViewController *sizeVC = [NvAlbumSizeViewController new];
    sizeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    ViewController *rootVc = (ViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVc presentViewController:sizeVC animated:NO completion:NULL];
    __weak typeof(self)weakSelf = self;
    for (NvAlbumAsset *albumAsset in assets) {
        PHAsset *asset = albumAsset.asset;

        NSArray *resourceList = [PHAssetResource assetResourcesForAsset:asset];
        [resourceList enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PHAssetResource *resource = obj;
            if ([resource.originalFilename.pathExtension caseInsensitiveCompare:@"gif"] == NSOrderedSame) {
                NSString *gifDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/GIF"];
                NSFileManager *fm = [NSFileManager defaultManager];
                if (![fm fileExistsAtPath:gifDir]) {
                    [fm createDirectoryAtPath:gifDir withIntermediateDirectories:true attributes:nil error:nil];
                }
                NSString *path = [gifDir stringByAppendingPathComponent:resource.originalFilename];
                
                NSURL *outputURL = [NSURL fileURLWithPath:path];
                if (![fm fileExistsAtPath:path]) {
                    PHAssetResourceManager *manager = [PHAssetResourceManager defaultManager];
                    PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];
                    options.networkAccessAllowed = YES;
                    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                    [manager writeDataForAssetResource:resource toFile:outputURL options:options completionHandler:^(NSError * _Nullable error) {
                        albumAsset.albumVideoPath = path;
                        dispatch_semaphore_signal(sem);
                    }];
                    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)));
                }else {
                    albumAsset.albumVideoPath = path;
                }
          
            }
            if ([resource.originalFilename.pathExtension caseInsensitiveCompare:@"webp"] == NSOrderedSame) {
                NSString *webpDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Webp"];
                NSFileManager *fm = [NSFileManager defaultManager];
                if (![fm fileExistsAtPath:webpDir]) {
                    [fm createDirectoryAtPath:webpDir withIntermediateDirectories:true attributes:nil error:nil];
                }
                NSString *path = [webpDir stringByAppendingPathComponent:resource.originalFilename];
                
                NSURL *outputURL = [NSURL fileURLWithPath:path];
                if (![fm fileExistsAtPath:path]) {
                    PHAssetResourceManager *manager = [PHAssetResourceManager defaultManager];
                    PHAssetResourceRequestOptions *options = [PHAssetResourceRequestOptions new];
                    options.networkAccessAllowed = YES;
                    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
                    [manager writeDataForAssetResource:resource toFile:outputURL options:options completionHandler:^(NSError * _Nullable error) {
                        albumAsset.albumVideoPath = path;
                        dispatch_semaphore_signal(sem);
                    }];
                    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)));
                }else {
                    albumAsset.albumVideoPath = path;
                }
          
            }
        }];
    }

    [sizeVC selectSizeTypeBlock:^(int type) {
        NvEditViewController *vc = [[NvEditViewController alloc] init];
        vc.selectAssets = assets;
        vc.editMode = (NvEditMode)type;
        vc.isFromAlbum = YES;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectAlbumAssetsOverMaxCountLimit:(NSMutableArray <NvAlbumAsset *>*)assets {
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController didSelectAlbumAssets:(NSMutableArray <NvAlbumAsset *>*)assets {
}

- (void)nvAlbumViewController:(NvAlbumViewController *)albumViewController selectWebmAlbumAssets:(NSMutableArray <NSString *>*)assets {
    NvAlbumSizeViewController *sizeVC = [NvAlbumSizeViewController new];
    sizeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    ViewController *rootVc = (ViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    [rootVc presentViewController:sizeVC animated:NO completion:NULL];
    __weak typeof(self)weakSelf = self;
    [sizeVC selectSizeTypeBlock:^(int type) {
        NvEditViewController *vc = [[NvEditViewController alloc] init];
        vc.selectPath = assets;
        vc.editMode = (NvEditMode)type;
        vc.isFromAlbum = NO;
        [weakSelf.navigationController pushViewController:vc animated:YES];
    }];
}

- (UIView *)nvAlbumViewControllerCustomBottomButton {
    return nil;
}

- (void)checkPrivate{
    
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"PrivateAlert"] boolValue]) {
        
        [NvPrivateAlertView nv_fadeIn:self.view eventHandle:^(Response response) {
            NSString *url = @"";
            switch (response) {
                case kPrivate:
                    url = @"https://vsapi.meishesdk.com/app/privacy/privacy-policy.html";
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PrivateAlert"];
                    break;
                case kService:
                    url = @"https://vsapi.meishesdk.com/app/privacy/service-agreement.html";
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PrivateAlert"];
                    break;
                case kAgree:
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"PrivateAlert"];
                    break;
                case kIgnore:
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"PrivateAlert"];
                    break;
                default:
                    break;
            }
            if (url.length > 0) {
                NvWebViewController *vc = [[NvWebViewController alloc] init];
                vc.urlString = url;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
