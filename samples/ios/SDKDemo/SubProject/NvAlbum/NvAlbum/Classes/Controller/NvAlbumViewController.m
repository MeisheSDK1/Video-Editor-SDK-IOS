//
//  NvAlbumViewController.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/25.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvAlbumViewController.h"
#import "NvAllAssetCell.h"
#import "NvAlbumItem.h"
#import "NvAlbumCollectionView.h"
#import "NvFetchAlbum.h"
#import "NvAlbumUtils.h"
#import <Masonry/Masonry.h>
#import "NvAlbumToast.h"
#import "UIButton+NvButton.h"
#import "UIView+Dimension.h"
#import "UIColor+NvColor.h"
#import "NvAlbumProgressViewController.h"
#import "NvAlbumWebmViewController.h"
#import "NVDefineConfig.h"
#import <NvAlbum/PHAsset+NvAlbum.h>
#import "NvAlbumCategoryView.h"
#import "NvAlbumBottomSelectView.h"
@import PhotosUI;
@import Photos;

typedef void(^NvDownloadAsset)(PHAsset *);

@interface NvAlbumViewController ()<UIScrollViewDelegate,PHPhotoLibraryChangeObserver,NvAlbumWebmViewControllerDelegate,NvAlbumCategoryViewDelegate,NvAlbumBottomSelectViewDelegate> {
    UIView *bottomView;
    
    UIView *_bottomMattingView;
}

@property (nonatomic, strong) UIView *tabView;
@property (nonatomic, strong) UIButton *allButton;
@property (nonatomic, strong) UIButton *videoButton;
@property (nonatomic, strong) UIButton *imageButton;
@property (nonatomic, strong) UIButton *liveButton;
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NvAlbumCollectionView *albumCollectionView;
@property (nonatomic, strong) NvAlbumCollectionView *videoCollectionView;
@property (nonatomic, strong) NvAlbumCollectionView *imageCollectionView;
@property (nonatomic, strong) NvAlbumCollectionView *liveCollectionView;

@property (nonatomic, assign) NSInteger selectAssetCount;
@property (nonatomic, assign) NSInteger selectVideoAssetCount;
@property (nonatomic, assign) NSInteger selectImageAssetCount;
@property (nonatomic, assign) NSInteger selectLiveAssetCount;
@property (nonatomic, strong) UIImage *selectImage;
@property (nonatomic, strong) NvFetchAlbum *album;

@property (nonatomic, strong) NSMutableArray <PHAsset *>*selectAssetSource;
@property (nonatomic, strong) NSMutableArray <NSString *>*useOriginalAssetSource;
@property (nonatomic, assign) NSInteger selectIndex;

//底部按钮
@property (nonatomic, strong) UIButton *customButton;
@property (nonatomic, strong) UIButton *nextMattButton;
@property (nonatomic, strong) UIButton *cancelMattButton;

@property (nonatomic, strong) NSString *nextText;

@property (nonatomic, weak) NvAlbumProgressViewController *progress;
@property (nonatomic, assign) PHImageRequestID nv_requestId;
@property (nonatomic, assign) BOOL iCloudDownload;
@property (nonatomic, strong) UIButton *centerNavButton;
@property (nonatomic, strong) NSMutableArray <PHAssetCollection *>*albumCollectionArr;
@property (nonatomic, strong) PHAssetCollection *currentAlbumCollection;
@property (nonatomic, strong) NvAlbumCategoryView *albumCateView;
@property (nonatomic, strong) NvAlbumBottomSelectView *selectView; //只有当没有外界自定义按钮时才显示
@property (nonatomic, assign) CGFloat bottomViewHeight;
@property (nonatomic, assign) CGFloat usefulBottomVHeight;

@property (nonatomic, assign) BOOL enableSelectStrategy; // 外界是否开启了相册选中策略
@end

@implementation NvAlbumViewController

- (void)dealloc {
    NSLog(@"%s",__func__);
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusDenied || [PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusDenied) {
        
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.selectAssetSource = [NSMutableArray array];
        self.useOriginalAssetSource = [NSMutableArray array];
        self.outputSelectAssetSource = [NSMutableArray array];
        self.albumCollectionArr = [NSMutableArray array];
        self.mutableSelect = YES;
        self.maxSelectCount = 0;
        self.minSelectCount = 1;
        self.hiddenSelectAll = NO;
        self.alwaysShowCustomBottom = NO;
        self.usefulBottomVHeight = 44*SCREENSCALE;
        self.bottomViewHeight =  self.usefulBottomVHeight + INDICATOR;
        self.enableSelectStrategy = NO;
    }
    return self;
}

#pragma mark viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationView];
    self.iCloudDownload = NO;
    
    [self checkCustomViewHeight];
    [self checkSelectStrategyState];
    if (OpenWebmTestData) {
        self.rightItemStr = @"webm 测试";
    }
    if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
        
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        [self initSubViews];
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusDenied) {
        
        [self presentPermissions];
    } else if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusNotDetermined) {
        
        __weak typeof(self)weakSelf = self;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
                    
                    [weakSelf presentPermissions];
                } else {
                    
                    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:weakSelf];
                    [weakSelf initSubViews];
                }
            });
        }];
    }
    
   
}

- (void)presentPermissions {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NvLocalStringFromTableInBundle(@"album.Tips",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) message:NvLocalStringFromTableInBundle(@"album.TipPermission",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *skipAction = [UIAlertAction actionWithTitle:NvLocalStringFromTableInBundle(@"album.Know",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alertVC addAction:skipAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

// MARK: - set title
- (void)setTitleWithCount:(NSInteger)count {
    if (count == 0) {
        if (self.isOnlyImage) {
            if (self.isPhotoAlbumMode) {
                self.title = NvLocalStringFromTableInBundle(@"album.selectAssets",@"NvAlbum",[NSBundle bundleForClass:self.class],nil);
            }else{
                self.title = NvLocalStringFromTableInBundle(@"album.selectImage",@"NvAlbum",[NSBundle bundleForClass:self.class],nil);
            }
            
        } else if (self.isOnlyVideo) {
            self.title = NvLocalStringFromTableInBundle(@"album.selectVideo",@"NvAlbum",[NSBundle bundleForClass:self.class],nil);
        } else {
            self.title = NvLocalStringFromTableInBundle(@"album.selectContent",@"NvAlbum",[NSBundle bundleForClass:self.class],nil);
        }
    } else {
        if (!self.mutableSelect) {
            self.title = NvLocalStringFromTableInBundle(@"album.select",@"NvAlbum",[NSBundle bundleForClass:self.class],nil);
        } else {
            if (self.isPhotoAlbumMode) {
                self.title = NvLocalStringFromTableInBundle(@"album.selectAssets",@"NvAlbum",[NSBundle bundleForClass:self.class],nil);
            }else{
                self.title = [NSString stringWithFormat:NvLocalStringFromTableInBundle(@"album.selectNum",@"NvAlbum",[NSBundle bundleForClass:self.class],nil),(long)count];
            }
            
        }
    }
}

- (void)setNavigationView {
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    self.view.backgroundColor = [UIColor blackColor];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [NvAlbumUtils fontWithSize:16], NSFontAttributeName, nil]];

    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self leftNavigationBarItemView]];
    if (@available(iOS 26.0, *)) {
        backButtonItem.hidesSharedBackground = YES;
    }
    self.navigationItem.leftBarButtonItem = backButtonItem;
    self.navigationItem.titleView = [self centerNavigationBarView];
}

- (void)setRightItemStr:(NSString *)rightItemStr {
    _rightItemStr = rightItemStr;
    if ((_isPhotoAlbumMode && rightItemStr.length >0) || OpenWebmTestData) {
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightItemStr style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClicked)];
        [rightButtonItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[NvAlbumUtils fontWithSize:10], NSFontAttributeName, [UIColor nv_colorWithHexRGB:@"#FFFFFF"], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];

        if (@available(iOS 26.0, *)) {
            rightButtonItem.hidesSharedBackground = YES;
        }

        self.navigationItem.rightBarButtonItem = rightButtonItem;
    }
}

- (void)rightBtnClicked {
    if (OpenWebmTestData) {
        NvAlbumWebmViewController *vc = [NvAlbumWebmViewController new];
        vc.sourcePath = WebmDirectory;
        vc.delegate = self;
        [self.navigationController presentViewController:vc animated:YES completion:nil];
    }
}

- (UIView *)leftNavigationBarItemView {
    UIButton *backButton;
    backButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"icon_back")];
    backButton.frame = CGRectMake(0, 0, 30, 44);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15*SCREENSCALE, 0, 0);
    __weak typeof(self)weakSelf = self;
    [backButton nv_BtnClickHandler:^{
        if ([weakSelf.delegate respondsToSelector:@selector(nvAlbumViewControllerCancelClick:)]) {
            [weakSelf.delegate nvAlbumViewControllerCancelClick:weakSelf];
        } else {
            if (weakSelf.navigationController.viewControllers.count == 1) {
                [weakSelf dismissViewControllerAnimated:YES completion:NULL];
            } else {
                if (weakSelf.navigationController.topViewController != weakSelf) {
                    [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                } else {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
        }
    }];
    backButton.exclusiveTouch = YES;
    return backButton;
}

- (UIView *)centerNavigationBarView {
    self.centerNavButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.centerNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIFont *font = [UIFont fontWithName:@"PingFangSC-Semibold" size:16];
    if (font) {
        self.centerNavButton.titleLabel.font = font;
    } else {
        UIFont *font = [UIFont systemFontOfSize:16];
        self.centerNavButton.titleLabel.font = font;
    }
    [self.centerNavButton setImage:NvImageNamed(@"nv_album_center_up") forState:UIControlStateSelected];
    [self.centerNavButton setImage:NvImageNamed(@"nv_album_center_down") forState:UIControlStateNormal];
    
    self.centerNavButton.titleEdgeInsets = UIEdgeInsetsMake(0, -15*SCREENSCALE, 0, 15*SCREENSCALE);
    self.centerNavButton.imageEdgeInsets = UIEdgeInsetsMake(0, 100-15*SCREENSCALE, 0, -15*SCREENSCALE);
    self.centerNavButton.bounds = CGRectMake(0, 0, 100, 44);
    [self.centerNavButton addTarget:self action:@selector(centerNavButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.centerNavButton.exclusiveTouch = YES;
    return self.centerNavButton;
}

- (void)centerNavButtonClicked:(UIButton *)button {
    button.selected = !button.selected;
    BOOL show = button.selected;
    self.albumCateView.hidden = NO;
    CGFloat height = SCREENHEIGHT - NV_STATUSBARHEIGHT - 44  - INDICATOR;
    if (self.albumCateView.assetDataSource==nil || self.albumCateView.assetDataSource.count==0) {
        self.albumCateView.assetDataSource = self.albumCollectionArr;
    }
    if (show) {
        if(self.view.subviews.lastObject != self.albumCateView) {
            [self.view bringSubviewToFront:self.albumCateView];
        }
        [UIView animateWithDuration:0.25 animations:^{
            self.albumCateView.frame = CGRectMake(0, 0, SCREENWIDTH, height);
        }];
        
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.albumCateView.frame = CGRectMake(0, -SCREENHEIGHT, SCREENWIDTH, height);
        }];
    }
}

- (void)updateCenterNavigationView:(NSString *)title {
    [self.centerNavButton setTitle:title forState:UIControlStateNormal];
//    self.navigationItem.titleView = self.centerNavButton;
}



- (void)customSelectAssetButtonText:(NSString *)text {
    self.nextText = text;
    [self.customButton setTitle:self.nextText forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    //判断是否是下载icloud资源引起的资源变动
    // Check if icloud resource download is the cause of resource change
    if(self.iCloudDownload) {
        self.iCloudDownload = NO;
        return;
    }
    if(!self.albumCollectionView) {
        return;
    }
    
    PHFetchResultChangeDetails *changes = [changeInstance changeDetailsForFetchResult:self.albumCollectionView.assetDataSource];
    if (changes == nil) {
        return;
    }
    
    if (self.isViewLoaded && self.view.window) {
        //从设置里改变可见相册资源后，这里将所有已选资源全部改为未选，重新获取相册数据
        // After changing visible album assets from Settings, here change all selected assets to unselected and retrieve album data again
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger index = weakSelf.selectAssetSource.count;
            while (index > 0) {
                PHAsset *asset = weakSelf.selectAssetSource[0];
                [weakSelf removeAsset:asset];
                index = weakSelf.selectAssetSource.count;
            }
            [weakSelf updateAlbumAssets];
        });
    }
}

// MARK: - 分类点击Classified clicks
- (void)allContentsClick {
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.allButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    [self.videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.imageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.liveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.bottomLine.frame = CGRectMake(self.allButton.left, self.allButton.bottom, self.allButton.width, 3*SCREENSCALE);
    [self setTitleWithCount:self.selectAssetCount];
    [self.albumCollectionView reloadVisibleCellData];
}

- (void)videoClick {
    [self.scrollView setContentOffset:CGPointMake(SCREENWIDTH, 0) animated:YES];
    [self.allButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.videoButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    [self.imageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.liveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.bottomLine.frame = CGRectMake(self.allButton.right, self.allButton.bottom, self.allButton.width, 3*SCREENSCALE);
    [self setTitleWithCount:self.selectAssetCount];
    [self.videoCollectionView reloadVisibleCellData];
    if (self.videoCollectionView.assetDataSource.count > 0) {
        return;
    }
    [self fetchAssetsWithType:NvAlbumFetchTypeVideo];
}

- (void)imageClick {
    [self.scrollView setContentOffset:CGPointMake(2*SCREENWIDTH, 0) animated:YES];
    [self.allButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.imageButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    [self.liveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.bottomLine.frame = CGRectMake(self.videoButton.right, self.allButton.bottom, self.allButton.width, 3*SCREENSCALE);
    [self setTitleWithCount:self.selectAssetCount];
    [self.imageCollectionView reloadVisibleCellData];
    if (self.imageCollectionView.assetDataSource.count > 0) {
        return;
    }
    [self fetchAssetsWithType:NvAlbumFetchTypeImage];
}

- (void)livePhotoClick {
    [self.scrollView setContentOffset:CGPointMake(3*SCREENWIDTH, 0) animated:YES];
    [self.allButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.videoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.imageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.liveButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
    self.bottomLine.frame = CGRectMake(self.videoButton.right, self.allButton.bottom, self.allButton.width, 3*SCREENSCALE);
    [self setTitleWithCount:self.selectAssetCount];
    [self.liveCollectionView reloadVisibleCellData];
    if (self.liveCollectionView.assetDataSource.count > 0) {
        return;
    }
    [self fetchAssetsWithType:NvAlbumFetchTypeLivePhoto];
}

- (void)reloadData {
    [self.albumCollectionView reloadData];
    [self.videoCollectionView reloadData];
    [self.imageCollectionView reloadData];
    [self.liveCollectionView reloadData];
}

- (void)reloadVisibleData {
    [self.albumCollectionView reloadVisibleCellData];
    [self.videoCollectionView reloadVisibleCellData];
    [self.imageCollectionView reloadVisibleCellData];
    [self.liveCollectionView reloadVisibleCellData];
}

// MARK: - initView
- (void)initSubViews {
    if (self.isOnlyImage) {
        if (self.isPhotoAlbumMode) {
            self.title = NvLocalStringFromTableInBundle(@"album.selectAssets",@"NvAlbum",[NSBundle bundleForClass:self.class],nil);
        }else{
            self.title = NvLocalStringFromTableInBundle(@"album.selectImage",@"NvAlbum",[NSBundle bundleForClass:self.class],nil);
        }
        
    } else if (self.isOnlyVideo) {
        self.title = NvLocalStringFromTableInBundle(@"album.selectVideo",@"NvAlbum",[NSBundle bundleForClass:self.class],nil);
    } else {
        self.title = NvLocalStringFromTableInBundle(@"album.selectContent",@"NvAlbum",[NSBundle bundleForClass:self.class],nil);
    }
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    __weak typeof(self)weakSelf = self;
    self.tabView = [[UIView alloc] init];
    self.tabView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#363738"];
    [self.view addSubview:self.tabView];
    float tabViewHeight = 44*SCREENSCALE;
    if (self.isOnlyImage||self.isOnlyVideo) {
        tabViewHeight = 0;
    }
    self.tabView.frame = CGRectMake(0, 0, SCREENWIDTH, tabViewHeight);
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(0));
        make.left.right.equalTo(@0);
        make.height.equalTo(@(tabViewHeight));
    }];
    //如果是图片模式或者是视频模式不显示“所有内容”，“视频”，“图片”选项卡
    // Don't show "All", "video", or "Images" tabs if image mode or video mode
    if (!self.isOnlyImage && !self.isOnlyVideo) {
        self.allButton = [UIButton nv_buttonWithTitle:NvLocalStringFromTableInBundle(@"album.all",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:12];
        [self.tabView addSubview:self.allButton];
        self.allButton.frame = CGRectMake(0, 0, SCREENWIDTH/4.0, self.tabView.height);
        
        [self.allButton nv_BtnClickHandler:^{
            [weakSelf allContentsClick];
        }];
        
        self.videoButton = [UIButton nv_buttonWithTitle:NvLocalStringFromTableInBundle(@"album.video",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) textColor:[UIColor whiteColor] fontSize:12];
        self.videoButton.frame = CGRectMake(self.allButton.right, 0, SCREENWIDTH/4.0, self.tabView.height);
        [self.tabView addSubview:self.videoButton];
        
        [self.videoButton nv_BtnClickHandler:^{
            [weakSelf videoClick];
        }];
        
        self.imageButton = [UIButton nv_buttonWithTitle:NvLocalStringFromTableInBundle(@"album.image",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) textColor:[UIColor whiteColor] fontSize:12];
        self.imageButton.frame = CGRectMake(self.videoButton.right, 0, SCREENWIDTH/4.0, self.tabView.height);
        [self.tabView addSubview:self.imageButton];
        
        [self.imageButton nv_BtnClickHandler:^{
            [weakSelf imageClick];
        }];
        
        self.liveButton = [UIButton nv_buttonWithTitle:NvLocalStringFromTableInBundle(@"album.live",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) textColor:[UIColor whiteColor] fontSize:12];
        self.liveButton.frame = CGRectMake(self.imageButton.right, 0, SCREENWIDTH/4.0, self.tabView.height);
        [self.tabView addSubview:self.liveButton];
        
        [self.liveButton nv_BtnClickHandler:^{
            [weakSelf livePhotoClick];
        }];
        
        self.bottomLine = [UIView new];
        self.bottomLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        [self.tabView addSubview:self.bottomLine];
        self.bottomLine.frame = CGRectMake(self.allButton.left, self.allButton.bottom, self.allButton.width, 3*SCREENSCALE);
        
    }
    
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.frame = CGRectMake(0, self.tabView.bottom, SCREENWIDTH, SCREENHEIGHT - NV_STATUSBARHEIGHT - 44 - self.tabView.height - INDICATOR);
    [self resetContentSize];
    
    float collectionViewHeight = 0;
    if (self.isOnlyImage || self.isOnlyVideo) {
        collectionViewHeight = SCREENHEIGHT - NV_STATUSBARHEIGHT - 44;
    } else {
        collectionViewHeight = SCREENHEIGHT - NV_STATUSBARHEIGHT - 44 - 44*SCREENSCALE;
    }
    [self fetchAlbumAssets];
    if ([self.delegate respondsToSelector:@selector(nvAlbumViewControllerCustomBottomButton)]) {
        bottomView = [self.delegate nvAlbumViewControllerCustomBottomButton];
        if (bottomView) {
            [self.view addSubview:bottomView];
            bottomView.hidden = !self.alwaysShowCustomBottom;
            [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                
                make.left.right.mas_equalTo(0);
                make.height.mas_equalTo(self.bottomViewHeight);
                make.bottom.mas_equalTo(0);
            }];
            
            if (self.alwaysShowCustomBottom) {
                self.scrollView.frame = CGRectMake(0, self.tabView.bottom, SCREENWIDTH, self.view.height - (self.bottomViewHeight));
                [self resetContentSize];
                float collectionViewHeight = 0;
                if (self.isOnlyImage || self.isOnlyVideo) {
                    collectionViewHeight = SCREENHEIGHT - NV_STATUSBARHEIGHT - 44- self.usefulBottomVHeight;
                } else {
                    collectionViewHeight = SCREENHEIGHT - NV_STATUSBARHEIGHT - 44 - 44*SCREENSCALE - self.usefulBottomVHeight;
                }
                
                if (self.isOnlyImage) {
                    self.imageCollectionView.frame = CGRectMake(self.imageCollectionView.left, self.imageCollectionView.top, self.imageCollectionView.width, collectionViewHeight-INDICATOR);
                    self.imageCollectionView.selectAssetSource = self.selectAssetSource;
                    self.imageCollectionView.useOriginalAssetSource = self.useOriginalAssetSource;
                } else if (self.isOnlyVideo) {
                    self.videoCollectionView.frame = CGRectMake(self.videoCollectionView.left, self.videoCollectionView.top, self.videoCollectionView.width, collectionViewHeight-INDICATOR);
                    self.videoCollectionView.selectAssetSource = self.selectAssetSource;
                    self.videoCollectionView.useOriginalAssetSource = self.useOriginalAssetSource;
                } else {
                    self.albumCollectionView.frame = CGRectMake(self.albumCollectionView.left, self.albumCollectionView.top, self.albumCollectionView.width, collectionViewHeight-INDICATOR);
                    self.albumCollectionView.selectAssetSource = self.selectAssetSource;
                    self.albumCollectionView.useOriginalAssetSource = self.useOriginalAssetSource;
                    
                    self.videoCollectionView.frame = CGRectMake(self.videoCollectionView.left, self.videoCollectionView.top, self.videoCollectionView.width, collectionViewHeight-INDICATOR);
                    self.videoCollectionView.selectAssetSource = self.selectAssetSource;
                    self.videoCollectionView.useOriginalAssetSource = self.useOriginalAssetSource;
                    
                    self.imageCollectionView.frame = CGRectMake(self.imageCollectionView.left, self.imageCollectionView.top, self.imageCollectionView.width, collectionViewHeight-INDICATOR);
                    self.imageCollectionView.selectAssetSource = self.selectAssetSource;
                    self.imageCollectionView.useOriginalAssetSource = self.useOriginalAssetSource;
                    
                    self.liveCollectionView.frame = CGRectMake(self.liveCollectionView.left, self.liveCollectionView.top, self.liveCollectionView.width, collectionViewHeight-INDICATOR);
                    self.liveCollectionView.selectAssetSource = self.selectAssetSource;
                }
                
                
                if ([self.delegate respondsToSelector:@selector(nvAlbumViewControllerAdjustAlbumCollectionFrameAsCustomBottomViewHeightAtInitialization:)]) {
                    BOOL adjust = [self.delegate nvAlbumViewControllerAdjustAlbumCollectionFrameAsCustomBottomViewHeightAtInitialization:self];
                    if (adjust) {
                        [self adjustAlbumCollecitonsFrame];
                    }
                }
            }
        }
    }
    
    if (self.showMattingView && !bottomView) {
        bottomView = [UIView new];
        [self.view addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(self.bottomViewHeight);
            make.bottom.mas_equalTo(0);
        }];
        bottomView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#363738"];
        //如果被选择的个数大于最小限制值，则允许点击按钮
        // Allow the button to be clicked if the number of selected is greater than the minimum limit
        if (_selectIndex >= self.minSelectCount) {
            [self.customButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
        } else {//否则置灰按钮
            // Gray button otherwise
            [self.customButton setTitleColor:[UIColor nv_colorWithHexARGB:@"#FFA3A3A3"] forState:UIControlStateNormal];
        }
        
        if (self.nextText && ![self.nextText isEqualToString:@""]) {
            [self.customButton setTitle:self.nextText forState:UIControlStateNormal];
        }
        
        self.cancelMattButton.frame = CGRectMake(0, 0, SCREENWIDTH / 2.0, 49*SCREENSCALE);
        [self.cancelMattButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [bottomView addSubview:self.cancelMattButton];
        
        self.customButton.frame = CGRectMake(SCREENWIDTH / 2.0,0 , SCREENWIDTH / 2.0, 49*SCREENSCALE);
        [bottomView addSubview:self.customButton];
        __weak typeof(self)weakSelf = self;
        [self.customButton nv_BtnClickHandler:^{
            if (weakSelf.selectIndex >= weakSelf.minSelectCount) {
                if ([weakSelf.delegate respondsToSelector:@selector(nvAlbumViewController:selectAlbumAssets:)]) {
                    [weakSelf updateOutputSelectAssetSource];
                    [weakSelf.delegate nvAlbumViewController:weakSelf selectAlbumAssets:weakSelf.outputSelectAssetSource];
                }
            } else {
                if ([weakSelf.delegate respondsToSelector:@selector(nvAlbumViewController:selectAlbumAssetsUnderMinCountLimit:)]) {
                    [weakSelf updateOutputSelectAssetSource];
                    [weakSelf.delegate nvAlbumViewController:weakSelf selectAlbumAssetsUnderMinCountLimit:weakSelf.outputSelectAssetSource];
                }
            }
        }];
        
        [self.cancelMattButton nv_BtnClickHandler:^{
            if ([weakSelf.delegate respondsToSelector:@selector(nvAlbumViewCancelMattController:)]) {
                [weakSelf.delegate nvAlbumViewCancelMattController:weakSelf];
            }
        }];
    }
    [self.view addSubview:self.albumCateView];
    self.albumCateView.hidden = YES;
}

- (void)checkCustomViewHeight {
    if ([self.delegate respondsToSelector:@selector(nvAlbumViewControllerUsefulCustomBottomHeight)]) {
        self.usefulBottomVHeight = [self.delegate nvAlbumViewControllerUsefulCustomBottomHeight];
        self.bottomViewHeight =  self.usefulBottomVHeight + INDICATOR;
    }
}

- (void)adjustAlbumCollecitonsFrame {
    self.scrollView.frame = CGRectMake(0, self.tabView.bottom, SCREENWIDTH, SCREENHEIGHT - NV_STATUSBARHEIGHT - 44 - self.tabView.height - (self.bottomViewHeight));
    [self resetContentSize];
    float collectionViewHeight = 0;
    if (self.isOnlyImage || self.isOnlyVideo) {
        collectionViewHeight = SCREENHEIGHT - NV_STATUSBARHEIGHT - 44- self.usefulBottomVHeight;
    } else {
        collectionViewHeight = SCREENHEIGHT - NV_STATUSBARHEIGHT - 44 - 44*SCREENSCALE - self.usefulBottomVHeight;
    }
    
    if (self.isOnlyImage) {
        self.imageCollectionView.frame = CGRectMake(self.imageCollectionView.left, self.imageCollectionView.top, self.imageCollectionView.width, collectionViewHeight-INDICATOR);
    } else if (self.isOnlyVideo) {
        self.videoCollectionView.frame = CGRectMake(self.videoCollectionView.left, self.videoCollectionView.top, self.videoCollectionView.width, collectionViewHeight-INDICATOR);
    } else {
        self.albumCollectionView.frame = CGRectMake(self.albumCollectionView.left, self.albumCollectionView.top, self.albumCollectionView.width, collectionViewHeight-INDICATOR);
        self.videoCollectionView.frame = CGRectMake(self.videoCollectionView.left, self.videoCollectionView.top, self.videoCollectionView.width, collectionViewHeight-INDICATOR);
        self.imageCollectionView.frame = CGRectMake(self.imageCollectionView.left, self.imageCollectionView.top, self.imageCollectionView.width, collectionViewHeight-INDICATOR);
        self.liveCollectionView.frame = CGRectMake(self.liveCollectionView.left, self.liveCollectionView.top, self.liveCollectionView.width, collectionViewHeight-INDICATOR);
    }
}

- (void)resetContentSize {
    if (!self.isOnlyImage && !self.isOnlyVideo) {
        self.scrollView.contentSize = CGSizeMake(4*SCREENWIDTH, self.scrollView.height);
    } else {
        self.scrollView.contentSize = CGSizeMake(SCREENWIDTH, self.scrollView.height);
    }
}

//获取相册资源
// Get an album resource
- (void)fetchAlbumAssets {
    __weak typeof(self)weakSelf = self;
    self.album = [NvFetchAlbum new];
    [self fetchCollections:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf fetchAlbumAssetsInSpecificCollection];
        });
    }];
    
}

- (void)updateAlbumAssets {
    if( self.album != nil) {
        __weak typeof(self)weakSelf = self;

        [self fetchCollections:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self removeAllSubCollectionViewsInScrollView];

                [self fetchAlbumAssetsInSpecificCollection];
                [self allContentsClick];
                
            });
        }];
    }
}

- (void)fetchAlbumAssetsInSpecificCollection {

    __weak typeof(self)weakSelf = self;
    NvAlbumAssetType type;
    if (self.isOnlyImage) {
        type = NvAlbumAssetAllImage;
    } else if (self.isOnlyVideo) {
        type = NvAlbumAssetAllVideo;
    } else {
        type = NvAlbumAssetAll;
    }

    //图片
    // Image
    if (self.isOnlyImage) {
        self.imageCollectionView = [[NvAlbumCollectionView alloc] initWithFrame:CGRectZero withMediaType:NvAlbumAssetAllImage];
        self.imageCollectionView.mutableSelect = self.mutableSelect;
        self.imageCollectionView.hiddenSelectAll = self.hiddenSelectAll;
        [self.scrollView addSubview:self.imageCollectionView];
        self.imageCollectionView.delegate = self;
        self.imageCollectionView.frame = CGRectMake(0, 0, SCREENWIDTH, self.scrollView.height);
        self.imageCollectionView.selectAssetSource = self.selectAssetSource;
        self.imageCollectionView.useOriginalAssetSource = self.useOriginalAssetSource;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf fetchAssetsWithType:NvAlbumFetchTypeImage];
        });
    } else if (self.isOnlyVideo) {//视频video
        self.videoCollectionView = [[NvAlbumCollectionView alloc] initWithFrame:CGRectZero withMediaType:NvAlbumAssetAllVideo];
        self.videoCollectionView.mutableSelect = self.mutableSelect;
        self.videoCollectionView.hiddenSelectAll = self.hiddenSelectAll;
        [self.scrollView addSubview:self.videoCollectionView];
        self.videoCollectionView.delegate = self;
        self.videoCollectionView.frame = CGRectMake(0, 0, SCREENWIDTH, self.scrollView.height);
        self.videoCollectionView.selectAssetSource = self.selectAssetSource;
        self.videoCollectionView.useOriginalAssetSource = self.useOriginalAssetSource;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf fetchAssetsWithType:NvAlbumFetchTypeVideo];
        });
        
    } else {//所有 all
        self.albumCollectionView = [[NvAlbumCollectionView alloc] initWithFrame:CGRectZero withMediaType:type];
        self.albumCollectionView.mutableSelect = self.mutableSelect;
        self.albumCollectionView.hiddenSelectAll = self.hiddenSelectAll;
        [self.scrollView addSubview:self.albumCollectionView];
        self.albumCollectionView.delegate = self;
        self.albumCollectionView.frame = CGRectMake(0, 0, SCREENWIDTH, self.scrollView.height);
        self.albumCollectionView.selectAssetSource = self.selectAssetSource;
        self.albumCollectionView.useOriginalAssetSource = self.useOriginalAssetSource;
        self.videoCollectionView = [[NvAlbumCollectionView alloc] initWithFrame:CGRectZero withMediaType:NvAlbumAssetAllVideo];
        self.videoCollectionView.mutableSelect = self.mutableSelect;
        self.videoCollectionView.hiddenSelectAll = self.hiddenSelectAll;
        [self.scrollView addSubview:self.videoCollectionView];
        self.videoCollectionView.delegate = self;
        self.videoCollectionView.frame = CGRectMake(self.albumCollectionView.right, 0, SCREENWIDTH, self.scrollView.height);
        self.videoCollectionView.selectAssetSource = self.selectAssetSource;
        self.videoCollectionView.useOriginalAssetSource = self.useOriginalAssetSource;
        self.imageCollectionView = [[NvAlbumCollectionView alloc] initWithFrame:CGRectZero withMediaType:NvAlbumAssetAllImage];
        self.imageCollectionView.mutableSelect = self.mutableSelect;
        self.imageCollectionView.hiddenSelectAll = self.hiddenSelectAll;
        [self.scrollView addSubview:self.imageCollectionView];
        self.imageCollectionView.delegate = self;
        self.imageCollectionView.frame = CGRectMake(self.videoCollectionView.right, 0, SCREENWIDTH, self.scrollView.height);
        self.imageCollectionView.selectAssetSource = self.selectAssetSource;
        self.imageCollectionView.useOriginalAssetSource = self.useOriginalAssetSource;
        self.imageCollectionView.backgroundColor = [UIColor redColor];
        self.liveCollectionView = [[NvAlbumCollectionView alloc] initWithFrame:CGRectZero withMediaType:NvAlbumAssetAllImage];
        self.liveCollectionView.mutableSelect = self.mutableSelect;
        self.liveCollectionView.hiddenSelectAll = self.hiddenSelectAll;
        [self.scrollView addSubview:self.liveCollectionView];
        self.liveCollectionView.delegate = self;
        self.liveCollectionView.frame = CGRectMake(self.imageCollectionView.right, 0, SCREENWIDTH, self.scrollView.height);
        self.liveCollectionView.selectAssetSource = self.selectAssetSource;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf fetchAssetsWithType:NvAlbumFetchTypeAll];
        });
        
    }
}

- (void)fetchCollections:(void(^)(void))completion {
    __weak typeof(self)weakSelf = self;
    [self.album fetchAlbumCollections:^(NSMutableArray<PHAssetCollection *> *albumCollections) {
        NSMutableArray <PHAssetCollection *> *albumArr = albumCollections;
        weakSelf.albumCollectionArr = albumCollections;
        if (albumCollections != nil && albumCollections.count > 0) {
            weakSelf.currentAlbumCollection = albumCollections[0];
        }
        
        completion();
    }];

}

- (void)fetchAssetsWithType:(NvAlbumFetchType)fetchType {
    __weak typeof(self)weakSelf = self;
    [self.album fetchAlbum:fetchType assetCollection:self.currentAlbumCollection complete:^(NvAlbumFetchType type, NSMutableArray<PHAsset *> *fetchedArray) {
        if (type == NvAlbumFetchTypeAll) {
            weakSelf.albumCollectionView.assetDataSource = fetchedArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.albumCollectionView reloadData];
            });
        } else if (type == NvAlbumFetchTypeVideo) {
            weakSelf.videoCollectionView.assetDataSource = fetchedArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.videoCollectionView reloadData];
            });
        } else if (type == NvAlbumFetchTypeImage) {
            weakSelf.imageCollectionView.assetDataSource = fetchedArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.imageCollectionView reloadData];
            });
        } else if (type == NvAlbumFetchTypeLivePhoto) {
            weakSelf.liveCollectionView.assetDataSource = fetchedArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.liveCollectionView reloadData];
            });
        }
        
    }];
}

- (void)updateCurrentAlbumCollection:(PHAssetCollection *)currentAlbumCollection {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf updateCenterNavigationView:currentAlbumCollection.localizedTitle];
    });
}

- (UIButton *)customButton {
    if (!_customButton) {
        _customButton = [UIButton nv_buttonWithTitle:NvLocalStringFromTableInBundle(@"album.startmake",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:16];
    }
    return _customButton;
}

- (UIButton *)cancelMattButton {
    if (!_cancelMattButton) {
        _cancelMattButton = [UIButton nv_buttonWithTitle:NvLocalStringFromTableInBundle(@"album.cancelBackground",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] fontSize:16];
    }
    return _cancelMattButton;
}

- (void)addAsset:(PHAsset *)selectAsset removeContains:(BOOL)isRemoveContains {
    if ([self.selectAssetSource containsObject:selectAsset]) {
        if (isRemoveContains) {
            [self.selectAssetSource removeObject:selectAsset];
        }
    } else {
        [self.selectAssetSource addObject:selectAsset];
    }
    [self ascendingWithSelectAsset];
    self.selectIndex = self.selectAssetSource.count;
}

- (void)removeAsset:(PHAsset *)selectAsset {
    if ([self.selectAssetSource containsObject:selectAsset]) {
        [self.selectAssetSource removeObject:selectAsset];
    }
    
    [self ascendingWithSelectAsset];
    self.selectIndex = self.selectAssetSource.count;
}

// 重新排序被选择的asset
// Reorder the selected assets
- (void)ascendingWithSelectAsset {
    for (int i = 0; i<self.selectAssetSource.count; i++) {
        PHAsset *asset = self.selectAssetSource[i];
        if (asset.isShowLayer) {
            asset.number = i+1;
        }
    }
}

// MARK: UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ((*targetContentOffset).x/SCREENWIDTH == 0) {
        [self allContentsClick];
    } else if ((*targetContentOffset).x/SCREENWIDTH == 1) {
        [self videoClick];
    } else if ((*targetContentOffset).x/SCREENWIDTH == 3) {
        [self livePhotoClick];
    } else {
        [self imageClick];
    }
}


- (BOOL)checkAssetInICloud:(PHAsset *)albumAsset {
    if(!albumAsset)
        return NO;
    
    __block BOOL isInICloud = NO;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    @autoreleasepool {
        if (albumAsset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
            option.version = PHVideoRequestOptionsVersionCurrent;
            option.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
            [[PHImageManager defaultManager] requestAVAssetForVideo:albumAsset
                                                            options:option
                                                      resultHandler:^(AVAsset * avAsset, AVAudioMix * audioMix, NSDictionary * info) {
                                                          NSLog(@"%d", [[info objectForKey:PHImageResultIsInCloudKey] boolValue]);
                                                          if (avAsset == nil) {
                                                              isInICloud = YES;
                                                          } else {
                                                              isInICloud = NO;
                                                          }
                                                          dispatch_semaphore_signal(semaphore);
                                                      }];
        } else {
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.version = PHImageRequestOptionsVersionOriginal;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.synchronous = YES;
            [[PHImageManager defaultManager] requestImageDataForAsset:albumAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                if ([[info objectForKey:PHImageResultIsInCloudKey] boolValue] && !imageData) {
                    isInICloud = YES;
                }
                dispatch_semaphore_signal(semaphore);
            }];
        }
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    
    return isInICloud;
}

// MARK: 下载 download
- (void)downloadAssetFromiCloud:(PHAsset *)selectAsset complate:(NvDownloadAsset)complate {
    //资源在iCloud上
    //The resources are on iCloud
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NvLocalStringFromTableInBundle(@"album.assetFromiCloud",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                                                                             message:NvLocalStringFromTableInBundle(@"album.download",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert ];
    //添加取消到UIAlertController中
    //Add cancel to UIAlertController
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NvLocalStringFromTableInBundle(@"album.cancel",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) style:UIAlertActionStyleDefault handler:^ (UIAlertAction *action){
        selectAsset.isShowLayer = NO;
        if (complate) {
            complate(nil);
        }
    }];
    [alertController addAction:cancelAction];
    //添加确定到UIAlertController中
    //Add cancel to UIAlertController
    __weak typeof(self)weakSelf = self;
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NvLocalStringFromTableInBundle(@"album.ok",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) style:UIAlertActionStyleDefault handler:^ (UIAlertAction *action){
        NvAlbumProgressViewController *progressVC = [NvAlbumProgressViewController new];
        weakSelf.progress = progressVC;
        [weakSelf.progress setCancelBlock:^{
            selectAsset.isShowLayer = NO;
            if (complate) {
                complate(nil);
            }
            [[PHImageManager defaultManager] cancelImageRequest:weakSelf.nv_requestId];
            [weakSelf dismissViewControllerAnimated:YES completion:NULL];
        }];
        
        weakSelf.definesPresentationContext = YES;
        weakSelf.progress.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [weakSelf.navigationController presentViewController:progressVC animated:YES completion:NULL];
        if (selectAsset.mediaType == PHAssetMediaTypeVideo) {
            PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc]init];
            option.networkAccessAllowed = YES;
            option.version = PHVideoRequestOptionsVersionCurrent;
            option.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
            option.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
                NSLog(@"%f",progress);
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.iCloudDownload = YES;
                    weakSelf.progress.progress = progress;
                });
            };
            weakSelf.nv_requestId = [[PHImageManager defaultManager] requestAVAssetForVideo:selectAsset options:option resultHandler:^(AVAsset * _Nullable asset1, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (asset1) {
                        [NvAlbumToast showInfoWithMessage:NvLocalStringFromTableInBundle(@"album.finish",@"NvAlbum",[NSBundle bundleForClass:weakSelf.class],nil) inView:weakSelf.view];
                        if (complate) {
                            complate(selectAsset);
                        }
                    } else {
                        if (![info[PHImageCancelledKey] boolValue]) {//如果不是取消
                            // If not cancelled
                            [NvAlbumToast showInfoWithMessage:NvLocalStringFromTableInBundle(@"album.faild",@"NvAlbum",[NSBundle bundleForClass:weakSelf.class],nil) inView:weakSelf.view];
                        }
                        //点击cell的时候isShowLayer被设为yes，点击取消的时候要设为NO
                        // isShowLayer is set to yes when cell is clicked and NO when Cancel is clicked
                        selectAsset.isShowLayer = NO;
                        if (complate) {
                            complate(nil);
                        }
                    }
                    [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                });
            }];
        } else {
            PHImageRequestOptions *options = [PHImageRequestOptions new];
            options.resizeMode = PHImageRequestOptionsResizeModeFast;
            options.version = PHImageRequestOptionsVersionOriginal;
            options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            options.networkAccessAllowed = YES;
            options.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
                NSLog(@"%f",progress);
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.iCloudDownload = YES;
                    weakSelf.progress.progress = progress;
                });
            };
            weakSelf.nv_requestId = [[PHImageManager defaultManager] requestImageDataForAsset:selectAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (imageData) {
                        [NvAlbumToast showInfoWithMessage:NvLocalStringFromTableInBundle(@"album.finish",@"NvAlbum",[NSBundle bundleForClass:weakSelf.class],nil) inView:weakSelf.view];
                        if (complate) {
                            complate(selectAsset);
                        }
                    } else {
                        if (![info[PHImageCancelledKey] boolValue]) {//如果不是取消
                            // If not cancelled
                            [NvAlbumToast showInfoWithMessage:NvLocalStringFromTableInBundle(@"album.faild",@"NvAlbum",[NSBundle bundleForClass:weakSelf.class],nil) inView:weakSelf.view];
                        }
                        selectAsset.isShowLayer = NO;
                        if (complate) {
                            complate(nil);
                        }
                    }
                    [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                });
            }];
        }
    }];
    
    [alertController addAction:OKAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//下载全选资源
// Download all selected resources
- (void)downloadAssetsFromICloud:(NSArray <PHAsset *> *)selectAssets complete:(void(^)(BOOL isComplete))complete {
    //资源在iCloud上
    // Resources are on iCloud
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NvLocalStringFromTableInBundle(@"album.assetFromiCloud",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                                                                             message:NvLocalStringFromTableInBundle(@"album.download",@"NvAlbum",[NSBundle bundleForClass:self.class],nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert ];
    //添加取消到UIAlertController中
    // Add cancel to UIAlertController
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NvLocalStringFromTableInBundle(@"album.cancel",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) style:UIAlertActionStyleDefault handler:^ (UIAlertAction *action){
        
        if (complete) {
            complete(nil);
        }
    }];
    [alertController addAction:cancelAction];
    
    //添加确定到UIAlertController中
    // Add confirmation to UIAlertController
    __weak typeof(self)weakSelf = self;
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:NvLocalStringFromTableInBundle(@"album.ok",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) style:UIAlertActionStyleDefault handler:^ (UIAlertAction *action){
        //弹出弹框
        // Popup popup
        NvAlbumProgressViewController *progressVC = [NvAlbumProgressViewController new];
        weakSelf.progress = progressVC;
        [weakSelf.progress setCancelBlock:^{
            [[PHImageManager defaultManager] cancelImageRequest:weakSelf.nv_requestId];
            
            [weakSelf dismissViewControllerAnimated:YES completion:NULL];
        }];
        
        weakSelf.definesPresentationContext = YES;
        weakSelf.progress.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [weakSelf.navigationController presentViewController:progressVC animated:YES completion:NULL];
        [weakSelf requestAssetFromICloud:selectAssets index:0 complete:^(BOOL isComplete) {
            if (isComplete) {
                complete(YES);
            }
        }];
        
    }];
    
    [alertController addAction:OKAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

//网络请求
// Network request
- (void)requestAssetFromICloud:(NSArray <PHAsset *> *)selectAssets index:(NSInteger )index complete:(void(^)(BOOL isComplete))complete {
    PHAsset *selectAsset = selectAssets[index];
    __weak typeof(self)weakSelf = self;

    weakSelf.progress.titleStr = [NSString stringWithFormat:@"%@%ld",NvLocalStringFromTableInBundle(@"album.loadingIndex",@"NvAlbum",[NSBundle bundleForClass:weakSelf.class],nil),(long)index+1];
    if (selectAsset.mediaType == PHAssetMediaTypeVideo) {
        PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc]init];
        option.networkAccessAllowed = YES;
        option.version = PHVideoRequestOptionsVersionCurrent;
        option.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
        option.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
            NSLog(@"++%f",progress);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.iCloudDownload = YES;
                weakSelf.progress.progress = progress;
            });
        };
        weakSelf.nv_requestId = [[PHImageManager defaultManager] requestAVAssetForVideo:selectAsset options:option resultHandler:^(AVAsset * _Nullable asset1, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //下载成功
                // Download was successful
                if (asset1) {
                    if (index+1 <selectAssets.count) {
                        //循环未结束
                        // Loop does not end
                        [weakSelf requestAssetFromICloud:selectAssets index:index+1 complete:complete];
                    }else{
                        //循环已结束
                        // loop has ended
                        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                        complete(YES);
                    }
                } else {
                    //下载失败
                    // Download failed
                    if (![info[PHImageCancelledKey] boolValue]) {
                        [NvAlbumToast showInfoWithMessage:NvLocalStringFromTableInBundle(@"album.faild",@"NvAlbum",[NSBundle bundleForClass:weakSelf.class],nil) inView:weakSelf.view];
                        
                    }
                    [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                }
            });
        }];
    } else {
        PHImageRequestOptions *options = [PHImageRequestOptions new];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.version = PHImageRequestOptionsVersionOriginal;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.networkAccessAllowed = YES;
        options.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
            NSLog(@"——%f",progress);
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.iCloudDownload = YES;
                weakSelf.progress.progress = progress;
            });
        };
        weakSelf.nv_requestId = [[PHImageManager defaultManager] requestImageDataForAsset:selectAsset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //下载成功
                // Download was successful
                if (imageData) {
                    if (index+1 <selectAssets.count) {
                        //循环未结束
                        // Loop does not end
                        [weakSelf requestAssetFromICloud:selectAssets index:index+1 complete:complete];
                    }else{
                        //循环已结束
                        // loop has ended
                        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                        complete(YES);
                    }
                    
                } else {
                    //下载失败
                    // Download failed
                    if (![info[PHImageCancelledKey] boolValue]) {
                        [NvAlbumToast showInfoWithMessage:NvLocalStringFromTableInBundle(@"album.faild",@"NvAlbum",[NSBundle bundleForClass:weakSelf.class],nil) inView:weakSelf.view];
                    }
                    [weakSelf dismissViewControllerAnimated:YES completion:NULL];
                }
            });
        }];
    }
    
}

- (void)selectAsset:(PHAsset *)selectAsset {
    if (self.enableSelectStrategy) {
        [self didSelectAssetOnEnableSelectStrategy:selectAsset];
        return;
    }
    //如果不允许多选
    // If multiple selection is not allowed
    if (!self.mutableSelect) {
        if (![self.selectAssetSource containsObject:selectAsset]) {
            if (self.selectAssetSource.count != 0) {
                for (int i = 0; i < self.selectAssetSource.count; i++) {
                    PHAsset *asset = self.selectAssetSource[i];
                    asset.isShowLayer = NO;
                }
                [self.selectAssetSource removeAllObjects];
            }
            [self.selectAssetSource addObject:selectAsset];
        } else {
            [self.selectAssetSource removeObject:selectAsset];
        }
        
        self.selectIndex = self.selectAssetSource.count;
        
        [self reloadData];
        if ([self.delegate respondsToSelector:@selector(nvAlbumViewController:didSelectAlbumAssets:)]) {
            [self updateOutputSelectAssetSource];
            [self.delegate nvAlbumViewController:self didSelectAlbumAssets:self.outputSelectAssetSource];
        }
    } else {//如果允许多选
        //如果所选的内容不包含在已选择的里面，并且已选择的个数大于最大限制个数给出回调
        // Give a callback if the selected item is not included in the selected list and the number of selected items is greater than the Max limit
        if (![self.selectAssetSource containsObject:selectAsset] && self.selectAssetSource.count >= self.maxSelectCount && self.maxSelectCount!=0) {
            selectAsset.isShowLayer = NO;
            [self reloadData];
            if ([self.delegate respondsToSelector:@selector(nvAlbumViewController:selectAlbumAssetsOverMaxCountLimit:)]) {
                [self updateOutputSelectAssetSource];
                [self.delegate nvAlbumViewController:self selectAlbumAssetsOverMaxCountLimit:self.outputSelectAssetSource];
            }
        } else {
            
            if (self.isQuickSplicing) {
                NvAlbumAsset *item = [self convertPHAssetToAlbumAsset:selectAsset];
                if ([self.delegate respondsToSelector:@selector(nvAlbumViewSamemMaterialController:asset:index:isSelect:)] && [self.delegate nvAlbumViewSamemMaterialController:self asset:item index:self.selectAssetSource.count isSelect:[self.selectAssetSource containsObject:selectAsset] ? NO : YES]) {
                    [self addAsset:selectAsset removeContains:YES];

                    [self reloadData];
                }else{
                    selectAsset.isShowLayer = NO;
                    [self reloadData];
                    [NvAlbumToast showInfoWithMessage:NvLocalStringFromTableInBundle(@"album.cancelselect",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) inView:self.view];
                }
            }else{
                [self addAsset:selectAsset removeContains:YES];

                [self reloadData];
            }
        }
        if ([self.delegate respondsToSelector:@selector(nvAlbumViewController:didSelectAlbumAssets:)]) {
            [self updateOutputSelectAssetSource];
            [self.delegate nvAlbumViewController:self didSelectAlbumAssets:self.outputSelectAssetSource];
        }
    }
}

//从本地（包含已经从icloud 上下载好的asset）处理
// process locally (including assets already downloaded from icloud)
- (void)selectAssetFromLocal:(NSArray <PHAsset *> *)selectAssets {
    bool isContainsLivePhoto = NO;
    for (PHAsset *asset in selectAssets) {
        if (asset.isLivePhoto) {
            isContainsLivePhoto = true;
            break;
        }
    }
    if (isContainsLivePhoto) {
        // 导出livephoto到沙盒
        // Export livephoto to sandbox
        [NvAlbumToast showLoading];
        dispatch_group_t group = dispatch_group_create();
        for (PHAsset *asset in selectAssets) {
            if (asset.isLivePhoto) {
                __weak typeof(self)weakSelf = self;
                dispatch_group_enter(group);
                [self exportVideoFromAsset:asset defaultShowLoading:false completion:^(NSString * _Nullable videoPath) {
                    asset.albumVideoPath = videoPath;
                    dispatch_group_leave(group);
                }];
            }
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            [NvAlbumToast dismiss];
        });
    }
    for (PHAsset *asset in selectAssets) {
        [self addAsset:asset removeContains:NO];
    }

    [self reloadData];
    if ([self.delegate respondsToSelector:@selector(nvAlbumViewController:didSelectAlbumAssets:)]) {
        [self updateOutputSelectAssetSource];
        [self.delegate nvAlbumViewController:self didSelectAlbumAssets:self.outputSelectAssetSource];
    }
}

#pragma mark - 开启选中策略 / Enable Select Strategy

- (void)checkSelectStrategyState {
    if ([self.selectStrategy respondsToSelector:@selector(enableNvAlbumViewControllerSelectStrategy:)]) {
        self.enableSelectStrategy = [self.selectStrategy enableNvAlbumViewControllerSelectStrategy:self];
    }
}

- (void)didSelectAssetOnEnableSelectStrategy:(PHAsset *)asset {
    if ([self.selectStrategy respondsToSelector:@selector(nvAlbumViewController:selectAssetOnSelectStrategy:)]) {
        [self.selectStrategy nvAlbumViewController:self selectAssetOnSelectStrategy:asset];
    }
}


// MARK: - NvAlbumCollectionViewDelegate
//cell单独被选中
//cell individually selected
- (void)nvAlbumCollectionView:(NvAlbumCollectionView *)nvAlbumCollectionView selectAsset:(PHAsset *)selectAsset {
    if ([self checkAssetInICloud:selectAsset]) {
        __weak typeof(self)weakSelf = self;
        [self downloadAssetFromiCloud:selectAsset complate:^(PHAsset *select) {
            if (select) {
                if (selectAsset.isLivePhoto) {
                    [weakSelf exportVideoFromAsset:selectAsset completion:^(NSString * _Nullable videoPath) {
                        selectAsset.albumVideoPath = videoPath;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf selectAsset:selectAsset];
                        });
                    }];
                } else {
                    [weakSelf selectAsset:selectAsset];
                }
            }
        }];
    } else {
        if (selectAsset.isLivePhoto) {
            __weak typeof(self)weakSelf = self;
            [self exportVideoFromAsset:selectAsset completion:^(NSString * _Nullable videoPath) {
                selectAsset.albumVideoPath = videoPath;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf selectAsset:selectAsset];
                });
            }];
        } else {
            [self selectAsset:selectAsset];
        }
    }
}

- (void)exportVideoFromAsset:(PHAsset *)asset defaultShowLoading:(BOOL)defaultShowLoading completion:(void (^)(NSString * _Nullable videoPath))completion {
    NSArray<PHAssetResource *> *resources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *videoRes = nil;
    
    for (PHAssetResource *res in resources) {
        if (res.type == PHAssetResourceTypePairedVideo) {
            videoRes = res;
            break;
        }
    }
    
    if (!videoRes) {
        if (completion) completion(nil);
        return;
    }
    
    NSString *livePhotoDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/LivePhoto"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:livePhotoDir]) {
        [fm createDirectoryAtPath:livePhotoDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filename = [NSString stringWithFormat:@"%@_%@", [videoRes.assetLocalIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"], videoRes.originalFilename];
    NSString *path = [livePhotoDir stringByAppendingPathComponent:filename];
    if ([fm fileExistsAtPath:path]) {
        if (completion) {
            completion(path);
        }
        return;
    }

    PHAssetResourceRequestOptions *options = [[PHAssetResourceRequestOptions alloc] init];
    options.networkAccessAllowed = YES;
    if (defaultShowLoading) {
        [NvAlbumToast showLoading];
    }
    [[PHAssetResourceManager defaultManager] writeDataForAssetResource:videoRes
                                                                toFile:[NSURL fileURLWithPath:path]
                                                               options:options
                                                     completionHandler:^(NSError * _Nullable error) {
        if (defaultShowLoading) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [NvAlbumToast dismiss];
            });
        }
        if (error) {
            NSLog(@"视频导出失败：%@", error.localizedDescription);
            if (completion) completion(nil);
        } else {
            if (completion) completion(path);
        }
    }];
}

- (void)exportVideoFromAsset:(PHAsset *)asset completion:(void (^)(NSString * _Nullable videoPath))completion {
    [self exportVideoFromAsset:asset defaultShowLoading:true completion:completion];
}

//点击全选
//click select all
- (void)nvAlbumCollectionView:(NvAlbumCollectionView *)nvAlbumCollectionView selectAssets:(NSMutableArray <PHAsset *>*)selectAssets completionBlock:(void (^)(void))block{

}

//点击反全选
//deselect all
- (void)nvAlbumCollectionView:(NvAlbumCollectionView *)nvAlbumCollectionView deselectAssets:(NSMutableArray <PHAsset *>*)selectAssets {

}

#pragma mark - NvAlbumWebmViewControllerDelegate
- (void)nvAlbumWebmViewController:(NvAlbumWebmViewController *)webmViewController selectAssets:(NSMutableArray<PHAsset *> *)assets {
    NSMutableArray *selectPaths = [NSMutableArray array];
    NSString *path = webmViewController.sourcePath;
    for (PHAsset *asset in assets) {
        [selectPaths addObject:[path stringByAppendingPathComponent:asset.albumVideoPath]];
    }
    [webmViewController dismissViewControllerAnimated:NO completion:nil];
    
    if ([self.delegate respondsToSelector:@selector(nvAlbumViewController:selectWebmAlbumAssets:)]) {
        [self.delegate nvAlbumViewController:self selectWebmAlbumAssets:selectPaths];
    }
}

#pragma mark - update outputSelectAssetSource
- (void)updateOutputSelectAssetSource {
    [self.outputSelectAssetSource removeAllObjects];
    for(int i=0; i<self.selectAssetSource.count; i++) {
        PHAsset *asset = self.selectAssetSource[i];
        NvAlbumAsset *item = [self convertPHAssetToAlbumAsset:asset];
        item.useOriginalFile = [self.useOriginalAssetSource containsObject:asset.localIdentifier];
        [self.outputSelectAssetSource addObject:item];
    }
}

- (NvAlbumAsset *)convertPHAssetToAlbumAsset:(PHAsset *)asset {
    NvAlbumAsset *item = [NvAlbumAsset new];
    item.number = asset.number;
    item.albumVideoPath = asset.albumVideoPath;
    item.asset = asset;
    item.isLivePhoto = asset.isLivePhoto;
    return item;
}

#pragma mark - NvAlbumCategoryViewDelegate
- (void)nvAlbumCategoryView:(NvAlbumCategoryView *)albumView didSelectCellAtIndex:(NSUInteger)index {
    [self selectAlbumCategory:index];
}

- (void)selectAlbumCategory:(NSUInteger)index {
    if (index >= self.albumCollectionArr.count) {
        return;
    }
    if (self.currentAlbumCollection == self.albumCollectionArr[index]) {
        [self centerNavButtonClicked:self.centerNavButton];
        return;
    }
    self.currentAlbumCollection = self.albumCollectionArr[index];
    [self centerNavButtonClicked:self.centerNavButton];
    [self removeAllSubCollectionViewsInScrollView];
    [self fetchAlbumAssetsInSpecificCollection];
    CGFloat contentOffsetX = self.scrollView.contentOffset.x;
    int offsetIndex = contentOffsetX / SCREENWIDTH;
    if (offsetIndex == 0) {
        [self allContentsClick];
    } else if (offsetIndex == 1) {
        [self fetchAssetsWithType:NvAlbumFetchTypeVideo];
    } else if (offsetIndex == 3) {
        [self fetchAssetsWithType:NvAlbumFetchTypeLivePhoto];
    } else {
        [self fetchAssetsWithType:NvAlbumFetchTypeImage];
    }
}

- (void)removeAllSubCollectionViewsInScrollView {
    if (self.albumCollectionView) {
        [self.albumCollectionView removeFromSuperview];
        self.albumCollectionView = nil;
    }
    if (self.videoCollectionView) {
        [self.videoCollectionView removeFromSuperview];
        self.videoCollectionView = nil;
    }
    if (self.imageCollectionView) {
        [self.imageCollectionView removeFromSuperview];
        self.imageCollectionView = nil;
    }
    if (self.liveCollectionView) {
        [self.liveCollectionView removeFromSuperview];
        self.liveCollectionView = nil;
    }
}

#pragma mark - NvAlbumBottomSelectViewDelegate
- (void)nvAlbumBottomSelectView:(NvAlbumBottomSelectView *)view selectItem:(NSUInteger)index {
    if (index >= self.selectAssetSource.count) {
        return;
    }
    PHAsset *asset = self.selectAssetSource[index];
    [self selectAsset:asset];
}

#pragma mark - keep portrait
- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return  UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - setter
- (void)setCurrentAlbumCollection:(PHAssetCollection *)currentAlbumCollection {
    _currentAlbumCollection = currentAlbumCollection;
    [self updateCurrentAlbumCollection:currentAlbumCollection];
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    self.albumCateView.selectCount = _selectIndex;
    self.selectAssetCount = _selectIndex;
    [self setTitleWithCount:_selectIndex];
    self.selectView.assetDataSource = self.selectAssetSource;
    [self.selectView reloadData];
    //一直显示底部按钮
    // Always show the bottom button
    if (self.alwaysShowCustomBottom) {
        bottomView.hidden = NO;
        
    } else {
        if (_selectIndex > 0) {
            //显示开始制作按钮
            // Show the Make Start button
            if ([self.delegate respondsToSelector:@selector(nvAlbumViewControllerCustomBottomButton)] && bottomView != nil) {
                if (self.selectAssetSource.count != 0) {
                    bottomView.hidden = NO;
                    //如果被选择的个数大于最小限制值，则允许点击按钮
                    // Allow the button to be clicked if the number of selected is greater than the minimum limit
                    if (_selectIndex >= self.minSelectCount) {
                        UIColor *color = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
                        if (_selectView) {
                            color = [UIColor whiteColor];
                        }
                        [self.customButton setTitleColor:color forState:UIControlStateNormal];
                    } else {//否则置灰按钮
                        // Gray button otherwise
                        [self.customButton setTitleColor:[UIColor nv_colorWithHexARGB:@"#FFA3A3A3"] forState:UIControlStateNormal];
                    }
                }
            } else {
                self.usefulBottomVHeight = 137.5*SCREENSCALE;
                self.bottomViewHeight =  self.usefulBottomVHeight + INDICATOR;
                
                bottomView.hidden = NO;
                if (selectIndex >= self.minSelectCount) {
                    [self.customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                } else {//否则置灰按钮
                    // Gray button otherwise
                    [self.customButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFA3A3A3"] forState:UIControlStateNormal];
                }
                if (bottomView != nil) {
                    return;
                }
                
                bottomView = [UIView new];
                [self.view addSubview:bottomView];
                [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                        
                    make.left.right.mas_equalTo(0);
                    make.height.mas_equalTo(self.bottomViewHeight);
                    make.bottom.mas_equalTo(0);
                }];
                bottomView.backgroundColor = [UIColor whiteColor];
                //添加底部选中素材显示界面
                [bottomView addSubview:self.selectView];
                self.selectView.assetDataSource = self.selectAssetSource;
                //如果被选择的个数大于最小限制值，则允许点击按钮
                // Allow the button to be clicked if the number of selected is greater than the minimum limit
                if (_selectIndex >= self.minSelectCount) {
                    [self.customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                } else {//否则置灰按钮
                    // Gray button otherwise
                    [self.customButton setTitleColor:[UIColor nv_colorWithHexARGB:@"#FFA3A3A3"] forState:UIControlStateNormal];
                }
                
                if (self.nextText && ![self.nextText isEqualToString:@""]) {
                    [self.customButton setTitle:self.nextText forState:UIControlStateNormal];
                }
                self.customButton.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
                [self.customButton setTitle:NvLocalStringFromTableInBundle(@"album.nextStep",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) forState:UIControlStateNormal];
                [self.customButton setTitle:NvLocalStringFromTableInBundle(@"album.nextStep",@"NvAlbum",[NSBundle bundleForClass:self.class],nil) forState:UIControlStateSelected];
                [self.customButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.customButton.frame = CGRectMake(SCREENWIDTH - 66*SCREENSCALE - 12*SCREENSCALE, CGRectGetMaxY(self.selectView.frame), 66*SCREENSCALE, 25*SCREENSCALE);
                self.customButton.layer.cornerRadius = CGRectGetHeight(self.customButton.frame) / 2 ;
                self.customButton.layer.masksToBounds = YES;
                [bottomView addSubview:self.customButton];
                __weak typeof(self)weakSelf = self;
                [self.customButton nv_BtnClickHandler:^{
                    if (weakSelf.selectIndex >= weakSelf.minSelectCount) {
                        if ([weakSelf.delegate respondsToSelector:@selector(nvAlbumViewController:selectAlbumAssets:)]) {
                            [weakSelf updateOutputSelectAssetSource];
                            [weakSelf.delegate nvAlbumViewController:weakSelf selectAlbumAssets:weakSelf.outputSelectAssetSource];
                        }
                    } else {
                        if ([weakSelf.delegate respondsToSelector:@selector(nvAlbumViewController:selectAlbumAssetsUnderMinCountLimit:)]) {
                            [weakSelf updateOutputSelectAssetSource];
                            [weakSelf.delegate nvAlbumViewController:weakSelf selectAlbumAssetsUnderMinCountLimit:weakSelf.outputSelectAssetSource];
                        }
                    }
                }];
            }
            [self adjustAlbumCollecitonsFrame];
        } else {
            if (self.showMattingView) {
                bottomView.hidden = NO;
            }else{
                //隐藏开始制作按钮
                // Hide the start button
                bottomView.hidden = YES;
            }
            if (_selectIndex >= self.minSelectCount) {
                [self.customButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
            } else {//否则置灰按钮
                // Gray button otherwise
                [self.customButton setTitleColor:[UIColor nv_colorWithHexARGB:@"#FFA3A3A3"] forState:UIControlStateNormal];
            }
            self.scrollView.frame = CGRectMake(0, self.tabView.bottom, SCREENWIDTH, SCREENHEIGHT - NV_STATUSBARHEIGHT - 44);
            [self resetContentSize];
            float collectionViewHeight = 0;
            if (self.isOnlyImage || self.isOnlyVideo) {
                collectionViewHeight = SCREENHEIGHT - NV_STATUSBARHEIGHT - 44;
            } else {
                collectionViewHeight = SCREENHEIGHT - NV_STATUSBARHEIGHT - 44 - 44*SCREENSCALE;
            }
            
            if (self.isOnlyImage) {
                self.imageCollectionView.frame = CGRectMake(self.imageCollectionView.left, self.imageCollectionView.top, self.imageCollectionView.width, collectionViewHeight);
            } else if (self.isOnlyVideo) {
                self.videoCollectionView.frame = CGRectMake(self.videoCollectionView.left, self.videoCollectionView.top, self.videoCollectionView.width, collectionViewHeight);
            } else {
                self.albumCollectionView.frame = CGRectMake(self.albumCollectionView.left, self.albumCollectionView.top, self.albumCollectionView.width, collectionViewHeight);
                self.videoCollectionView.frame = CGRectMake(self.videoCollectionView.left, self.videoCollectionView.top, self.videoCollectionView.width, collectionViewHeight);
                self.imageCollectionView.frame = CGRectMake(self.imageCollectionView.left, self.imageCollectionView.top, self.imageCollectionView.width, collectionViewHeight);
                self.liveCollectionView.frame = CGRectMake(self.liveCollectionView.left, self.liveCollectionView.top, self.liveCollectionView.width, collectionViewHeight);
            }
        }
    }
}
#pragma mark - getter
- (NvAlbumCategoryView *)albumCateView {
    if (!_albumCateView) {
        _albumCateView = [[NvAlbumCategoryView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, self.view.height - NV_STATUSBARHEIGHT  - INDICATOR)];
        _albumCateView.delegate = self;
    }
    return _albumCateView;
}

- (NvAlbumBottomSelectView *)selectView {
    if (!_selectView) {
        _selectView = [[NvAlbumBottomSelectView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 94*SCREENSCALE)];
        _selectView.delegate = self;
        _selectView.backgroundColor = [UIColor whiteColor];
    }
    return _selectView;
}
@end
