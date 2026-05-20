//
//  NvUrlVideoMaterialVC.m
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/2.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvUrlVideoMaterialVC.h"
#import <NvAlbum/NvAlbumSizeViewController.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvEditViewController.h"
#import "NvUrlInputTVCell.h"
#import "NvUrlInputViewController.h"
#import "NvUrlMaterialListViewController.h"
#import <JXPagingView/JXPagerView.h>
#import <JXCategoryView/JXCategoryView.h>
#import <JXCategoryView/JXCategoryTitleImageCell.h>
#import "AFNetworkReachabilityManager.h"

@interface NvUrlVideoMaterialVC () <JXCategoryListContainerViewDelegate, JXCategoryViewDelegate, NvUrlMaterialListViewControllerDelegate, NvUrlInputViewControllerDelegate>

///界面按钮
///Interface button
///关闭
///Shut down
@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UIButton *editButton;

@property (nonatomic, strong) JXCategoryTitleView *titleView;

@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;

@property (nonatomic, strong) NSMutableArray *listCategoryArray;

@property (nonatomic, strong) NvsStreamingContext *streamingContext;

@property (nonatomic, strong) NvUrlInputViewController *inputVc;

@property (nonatomic, strong) NvUrlMaterialListViewController *listVc;

@property (nonatomic, assign) NSInteger total;

@property (nonatomic, assign) BOOL tip;
@end

@implementation NvUrlVideoMaterialVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#181818"];
    
    self.streamingContext = [NvSDKUtils getSDKContext];
    [self addTopView];
    [self addContentView];
    [self updateTotal];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self addObservers];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)addObservers {
    
}

- (void)addTopView{
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:NvImageNamed(@"NvUrlEdit_back") forState:UIControlStateNormal];
    [self.backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(NV_STATUSBARHEIGHT);
        make.left.equalTo(self.view).offset(15 * SCREENSCALE);
        make.width.offset(30 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    
    NSMutableArray *titleCategoryArray = [NSMutableArray array];
    [titleCategoryArray addObject:NvLocalString(@"urlEditing_home_url", nil)];
    [titleCategoryArray addObject:NvLocalString(@"urlEditing_home_material", nil)];
    
    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(55 * SCREENSCALE);
        make.right.equalTo(self.view).offset(-55 * SCREENSCALE);
        make.centerY.equalTo(self.backBtn);
        make.height.offset(30*SCREENSCALE);
    }];
    
    self.titleView.titleColor = [UIColor nv_colorWithHexRGB:@"#888888"];
    self.titleView.titleSelectedColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    
    [self.titleView setDefaultSelectedIndex:0];
    self.titleView.titles = titleCategoryArray;
    [self.titleView reloadData];
}

- (void)addContentView{
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom).offset(20*SCREENSCALE);
        make.left.equalTo(self.view).offset(0 * SCREENSCALE);
        make.right.equalTo(self.view).offset(-0 * SCREENSCALE);
        make.bottom.equalTo(self.view);
    }];

    if (!self.isMusicEdit) {
        self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.editButton.titleLabel.font = [NvUtils regularFontWithSize:12];
        self.editButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5* SCREENSCALE, 0, 0);
        [self.editButton setImage:NvImageNamed(@"NvUrlEdit_homeIcon") forState:UIControlStateNormal];
        [self.editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        self.editButton.imageEdgeInsets = UIEdgeInsetsMake(0, 10* SCREENSCALE, 0, 0);
        [self.editButton addTarget:self action:@selector(editButtonClick) forControlEvents:UIControlEventTouchUpInside];
        self.editButton.layer.cornerRadius = 20*SCREENSCALE;
        [self.view addSubview:self.editButton];
        [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.listContainerView.mas_bottom).offset(-INDICATOR - 10*SCREENSCALE);
            make.centerX.equalTo(self.listContainerView);
            make.width.offset(150 * SCREENSCALE);
            make.height.offset(40 * SCREENSCALE);
        }];
        
        [self.view layoutIfNeeded];
        [self gradientView:self.editButton withColors:@[(id)[UIColor nv_colorWithHexRGB:@"#A5CFFF"].CGColor,(id)[UIColor nv_colorWithHexRGB:@"#63ABFF"].CGColor]];
    }
}

- (void)editButtonClick{
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable || [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_checkNetwork", nil)];
        return;
    }
    if (![self checkCorrectness]) {
        if (self.titleView.selectedIndex == 0) {
            [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_checkUrl", nil)];
        } else {
            [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_checkMaterial", nil)];
        }
        return;
    }
    if ([self.delegate respondsToSelector:@selector(selectVideo:)]) {
        [NvToast showLoading];
        __weak typeof(self)weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *videoPathArray = [self assemblingMaterials];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [NvToast dismiss];
                if (!videoPathArray) {
                    [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_importFailed", nil)];
                } else {
                    [weakSelf.delegate selectVideo:videoPathArray];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            });
        });
    } else {
        NvAlbumSizeViewController *sizeVC = [NvAlbumSizeViewController new];
        sizeVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self.navigationController presentViewController:sizeVC animated:NO completion:NULL];
        __weak typeof(self)weakSelf = self;
        [sizeVC selectSizeTypeBlock:^(int type) {
            [NvToast showLoading];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray *videoPathArray = [weakSelf assemblingMaterials];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NvToast dismiss];
                    if (!videoPathArray) {
                        [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_importFailed", nil)];
                    } else {
                        int afterTime = 0;
                        if (weakSelf.tip) {
                            [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_dataRateTip", nil)];
                            afterTime = 0.5;
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [[NSUserDefaults standardUserDefaults] setValue:@(true) forKey:@"urlEdit"];
                            NvEditViewController *vc  = [[NvEditViewController alloc]init];
                            vc.editMode = (NvEditMode)type;
                            vc.urlPath = videoPathArray;
                            vc.isFromAlbum = NO;
                            [weakSelf.navigationController pushViewController:vc animated:YES];
                        });
                    }
                });
            });
        }];
    }
}

#pragma mark - method
- (NSMutableArray *)assemblingMaterials{
    NSMutableArray *videoPathArray = [NSMutableArray array];

    NSMutableDictionary *audiodic = [NSMutableDictionary dictionary];
    NSMutableString *error = [NSMutableString string];
    NSMutableArray *urlArray = [NSMutableArray array];
    for (NvUrlInputMaterialModel *model in self.inputVc.dataArray) {
        if (model.urlString.length > 0) {
            [urlArray addObject:model.urlString];
            if (self.isMusicEdit) {
                [audiodic setValue:@(self.inputVc.trimIn) forKey:@"trimIn"];
                [audiodic setValue:@(self.inputVc.trimOut) forKey:@"trimOut"];
            }
        }
    }
    
    for (NvListMediaInfoModel *model in self.listVc.selectDataArray) {
        if (model.url.length > 0) {
            [urlArray addObject:model.url];
            if (self.isMusicEdit) {
                [audiodic setValue:@(self.listVc.trimIn) forKey:@"trimIn"];
                [audiodic setValue:@(self.listVc.trimOut) forKey:@"trimOut"];
            }
        }
    }
    
    for (NSString *path in urlArray) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:path forKey:@"url"];
        NvsAVFileInfo *info = [self.streamingContext getAVFileInfo:path extraFlag:0 withError:error];
        if (!info || error.length > 0) {
            videoPathArray = nil;
            break;
        }
        int64_t duration = 0;
        if (self.isMusicEdit) {
            [info getAudioStreamDuration:0];
            [dic setValuesForKeysWithDictionary:audiodic];
        } else {
            duration = [info getVideoStreamDuration:0];
            [dic setValue:@(duration) forKey:@"duration"];
        }
        
        if (info.dataRate > 10000000){
            self.tip = YES;
        }
        
        [videoPathArray addObject:dic];
    }
    
    return videoPathArray;
}

- (void)backBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)importBtnClick{
    if (![self checkCorrectness]) {
        [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_checkUrl", nil)];
        return;
    }
    [NvToast showLoading];
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *videoPathArray = [weakSelf assemblingMaterials];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NvToast dismiss];
            if (!videoPathArray) {
                [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_importFailed", nil)];
            } else {
                if ([weakSelf.delegate respondsToSelector:@selector(selectMusicItem:trimIn:trimOut:)]) {
                    NSDictionary *dict = videoPathArray.firstObject;
                    NSString *path = dict[@"url"];
                    int64_t trimIn = [dict[@"trimIn"] integerValue];
                    int64_t trimOut = [dict[@"trimOut"] integerValue];
                    
                    NvListMediaInfoModel *info = [[NvListMediaInfoModel alloc] init];
                    info.url = path;
                    [weakSelf.delegate selectMusicItem:info trimIn:trimIn trimOut:trimOut];
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            }
        });
    });
}

- (BOOL)checkCorrectness{
    BOOL state = false;
    for (NvUrlInputMaterialModel *model in self.inputVc.dataArray) {
        if (model.urlString.length > 0) {
            state = true;
            break;
        }
    }
    
    if (!state) {
        if (self.listVc.selectDataArray.count > 0 ) {
            state = true;
        }
    }
    
    return state;
}

- (void)updateTotal{
    NSInteger count = 0;
    for (NvUrlInputMaterialModel *model in self.inputVc.dataArray) {
        if (model.urlString.length > 0) {
            count++;
        }
    }
    self.total = count+self.listVc.selectDataArray.count;
    
    if (self.total > 0) {
        [self.editButton setTitle:[NSString stringWithFormat:@"%@(%ld)",NvLocalString(@"urlEditing_home_editUrl", nil),(long)self.total] forState:UIControlStateNormal];
    } else {
        [self.editButton setTitle:NvLocalString(@"urlEditing_home_editUrl", nil) forState:UIControlStateNormal];
    }
    
}

#pragma mark - NvUrlMaterialListViewControllerDelegate
- (void)changeSelectData {
    if (self.isMusicEdit) {
        [self.inputVc removeSelect];
    }
    [self updateTotal];
}

- (void)musicImport {
    NvUrlInputMaterialModel *model = self.inputVc.dataArray.firstObject;
    model.urlString = @"";
    [self importBtnClick];
}

- (void)musicInputImport {
    [self importBtnClick];
}

#pragma mark - NvUrlInputViewControllerDelegate
- (void)changeInputData {
    if (self.isMusicEdit) {
        [self.listVc removeSelect];
    }
    [self updateTotal];
}

-(void)hideEdit{
    self.editButton.hidden = [self.inputVc hideControl];
}

#pragma mark -- JXCategoryListContainerViewDelegate
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titleView.titles.count;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    if (index == 0) {
        self.inputVc = [[NvUrlInputViewController alloc] init];
        self.inputVc.delegate = self;
        self.inputVc.isMusicEdit = self.isMusicEdit;
        return self.inputVc;
    }
    self.listVc = [[NvUrlMaterialListViewController alloc] init];
    self.listVc.delegate = self;
    self.listVc.isMusicEdit = self.isMusicEdit;
    return self.listVc;
}

#pragma mark -- JXCategoryViewDelegate

- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    if (index == 0) {
        [self hideEdit];
    } else {
        self.editButton.hidden = NO;
    }
}

- (JXCategoryTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[JXCategoryTitleView alloc] init];
        _titleView.delegate = self;
        _titleView.titleColorGradientEnabled = YES;
        _titleView.averageCellSpacingEnabled = NO;
        _titleView.contentEdgeInsetLeft = 70*SCREENSCALE;
        _titleView.contentEdgeInsetRight = 70*SCREENSCALE;
        _titleView.titleFont = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _titleView.cellSpacing = 20*SCREENSCALE;
        _titleView.titleSelectedColor = [UIColor nv_colorWithHexString:@"#FFFFFF"];
        _titleView.titleColor = [UIColor nv_colorWithHexString:@"#646464"];
        _titleView.backgroundColor = [UIColor clearColor];
        _titleView.listContainer = self.listContainerView;
    }
    return _titleView;
}

- (JXCategoryListContainerView *)listContainerView {
    if (!_listContainerView) {
        _listContainerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
        _listContainerView.scrollView.scrollEnabled = NO;
    }
    return _listContainerView;
}

- (void)gradientView:(UIButton *)sender withColors:(NSArray *)colors{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height);
    gradientLayer.colors = colors;
    gradientLayer.locations = @[@(0.0f),@(1.0f)];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.masksToBounds = YES;
    gradientLayer.cornerRadius = 20 * SCREENSCALE;
    [sender.layer insertSublayer:gradientLayer atIndex:0];
}

@end
