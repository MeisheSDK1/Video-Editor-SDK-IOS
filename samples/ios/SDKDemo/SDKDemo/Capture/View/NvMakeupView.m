//
//  NvMakeupView.m
//  SDKDemo
//
//  Created by MS on 2020/7/16.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvMakeupView.h"
#import "NvMakeupModel.h"
#import "NvMakeupCell.h"
#import "YWISOSlider.h"
#import "NvCustomColorControl.h"
#import "NVHeader.h"
#import <NvSDKCommon/NvHttpRequest.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import <CQMenuTabView.h>
#import "AFNetworkReachabilityManager.h"
#import "NvBeautySliderView.h"
#import "NvMakeupToolModel.h"
#import "NvMakeupToolDataManager.h"
#import "MJRefresh.h"
#import "BLItemSlider.h"

@interface NvMakeupView ()<UICollectionViewDelegate,UICollectionViewDataSource,YWISOSliderDelegate,NvCustomColorControlDelegate,NvAssetManagerDelegate,NvHttpRequestDelegate,BLItemSliderDelegate>

@property (nonatomic, strong) UIView *topView;       //上半部分视图 Top half view
@property (nonatomic, strong) UIView *bottomView;    //下半部分视图 Bottom half view
@property (nonatomic, strong) UICollectionView *makeupCollectionView;
@property (nonatomic, strong) CQMenuTabView *tabView;
@property (nonatomic, strong) YWISOSlider *makeupSlider;   //程度slider Degree slider
@property (nonatomic, assign) BOOL makeupSliderShow;  //当前是否显示了makeupSlider Whether makeupSlider is currently displayed
@property (nonatomic, strong) NvBeautySliderView *editMakeupSlider;   //程度slider Degree slider
@property (nonatomic, strong) NvCustomColorControl *customSlider; //自定义颜色选择器 Custom color picker
@property (nonatomic, copy) NSArray *makeupArr; //美妆界面数据 Beauty interface data
@property (nonatomic, strong) NvMakeupLevelModel *currentMakeupLevelModel; //当前美妆层级对应model The current makeup level corresponds to model
@property (nonatomic, strong) NSMutableDictionary *makeupLastValues; //保存美妆slider的value Save the value of the beauty slider
@property (nonatomic, assign) NSInteger makeupLastIndex; //保存美妆slider的key Save the key for Beauty slider
@property (nonatomic, strong) NSString *makeupLastKey; //保存美妆slider的key Save the key for Beauty slider
@property (nonatomic, strong) NvMakeupToolModel *currentMakeupVariableModel; //当前界面选中具体整妆model Select a makeup model on the current screen
@property (nonatomic, strong) NvMakeupContentModel *currentMakeupCustomModel; //当前界面选中具体单妆model Select the specific makeup model on the current screen
@property (nonatomic, strong) NSMutableArray *buttonArrs;

/// 是否已经应用整体美妆 Whether or not you have applied your overall makeup
@property (nonatomic, assign) BOOL isApplicationMakeup;

@property (nonatomic, assign) NSInteger indexPath;

@property (nonatomic, strong) UILabel *makeupInfoView; //美妆信息显示界面（选中颜色及不透明度） Beauty information display interface (select color and opacity)
@property (nonatomic, assign) CGFloat makeupInfoAlpha; //美妆信息透明度 Beauty information transparency
@property (nonatomic, strong) NSString *makeupInfoColorValue; //美妆信息选中颜色 Beauty Information Select color
@property (nonatomic, assign) NSInteger selectedTagIndex;
@property (nonatomic, strong) NSArray *tagArr;
@property (nonatomic, strong) NSMutableArray <NvMakeupModel *>*singleMakeupModelArr;
@property (nonatomic, strong) NvMakeupCellModel *selectedCellModel;
@property (nonatomic, assign) int currentCategory;
@property (nonatomic, assign) int currentKind;
@property (nonatomic, strong) NSMutableArray *installPaths;
@property (nonatomic, strong) NSMutableArray *installedMakups;
@property (nonatomic, assign) BOOL hasQueryKind;
@property (nonatomic, assign) BOOL hasNetwork;
@property (nonatomic, assign) NvMakeupFunctionMode functionUse;
@property (nonatomic, strong) NvMakeupToolDataManager *dataManager;
///整妆程度调节滑杆
///Complete makeup level adjustment slider
@property (nonatomic, strong) BLItemSlider *makeupVariableSlider;
@property (nonatomic, strong) UIView *makeupFilterView;
@property (nonatomic, assign) BOOL changeFilterValue;
@end
@implementation NvMakeupView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.dataManager = [[NvMakeupToolDataManager alloc] init];
        self.functionUse = NvMakeupFunctionModeCapture;
        [self configMakeupData];
        [self addSubviews];
        [self getTagData];
        [self monitorReachabilityStatus];
    }
    return self;
}

-(void)setEditColor{
    self.bottomView.backgroundColor = [UIColor clearColor];
}

- (void)configMakeupData {
    self.installPaths = [NSMutableArray array];
    self.installedMakups = [NSMutableArray array];
    self.singleMakeupModelArr = [NSMutableArray array];
}

- (void)addVariableDatas {
    if (self.dataManager.varialbeMakeupModel.contents.count <= 0) {
        __weak typeof(self)weakSelf = self;
        [self.dataManager getAllVariableMakeupData:^{
            weakSelf.tabView.hidden = NO;
            weakSelf.currentMakeupLevelModel = weakSelf.dataManager.varialbeMakeupModel;
            [weakSelf setMakeupTopViewState];
            [weakSelf.makeupCollectionView reloadData];
        }];
    }else{
        self.tabView.hidden = NO;
        self.currentMakeupLevelModel = self.dataManager.varialbeMakeupModel;
        [self setMakeupTopViewState];
        [self.makeupCollectionView reloadData];
    }
}

- (void)hiddenMakeupSlider {
    self.makeupSliderShow = !self.makeupSlider.hidden;
    self.makeupSlider.hidden = YES;
}

- (void)showMakeupSliderInCondition {
    if (self.makeupSliderShow) {
        self.makeupSlider.hidden = NO;
    }
}

//监测网络状态的方法 Methods for monitoring network status
- (void)monitorReachabilityStatus
{
    // 开始监测 Start monitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    // 网络状态改变的回调 Callbacks of network state changes
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:{
                    self.hasNetwork = YES;
                }
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:{
                    self.hasNetwork = YES;
                }
                    
                    break;
                case AFNetworkReachabilityStatusNotReachable:{
                    self.hasNetwork = NO;
                }
                    break;
                case AFNetworkReachabilityStatusUnknown:{
                    self.hasNetwork = NO;
                }
                    break;
                default:{
                    
                }
                    break;
            }
        [self addVariableDatas];
    }];
}

#pragma mark - 获取分类数据 Get classified data
- (void)getTagData {
    __weak typeof(self)weakSelf = self;
    [self.dataManager getTagData:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf refreshTagView];
        });
    }];
}

- (void)refreshTagView {
    NSMutableArray *titleArr = [NSMutableArray array];
    for (NvMakeupModel *model in self.dataManager.kindArr) {
        NSString *title = [NvUtils currentLanguagesIsChinese] ? model.displayNameZhCn : model.displayName;
        [titleArr addObject:title];
    }
    self.tabView.titles = [NSArray arrayWithArray:titleArr];
}

- (NSMutableArray *)getKindArr {
    NSMutableArray *titleArr = [NSMutableArray array];
    for (int i=1;i<self.dataManager.kindArr.count;i++) {
        NvMakeupLevelModel *model = self.dataManager.kindArr[i];
        NSString *title = model.displayName;
        title = [title stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        title = [title stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [titleArr addObject:[self firstCharacter:title]];
    }
    return titleArr;
}

- (NSString *)firstCharacter:(NSString *)dealString {
    NSString *resultString = dealString;
    if (dealString.length > 0) {
        resultString = [dealString stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[dealString substringToIndex:1] capitalizedString]];
    }
    return resultString;
}

- (void)resetSingleEffectStateAfterSelectVariableEffect {
    NvMakeupToolModel *makeupModel;
    if ([self.selectedCellModel.makeup isKindOfClass:[NvMakeupToolModel class]]) {
        makeupModel = (NvMakeupToolModel *)self.selectedCellModel.makeup;
    }
    
    NSArray <NvMakeupToolEffectModel *>*makeupArr = makeupModel.effectContent.makeup;
    if (makeupArr.count > 0 && self.selectedTagIndex > 0){
        NvMakeupLevelModel *levelModel = self.dataManager.kindArr[self.selectedTagIndex];
        [self resetContentModelUnselected:levelModel];
        for (NvMakeupToolEffectModel *effect in makeupArr) {
            for(NvMakeupToolElementStringModel *element in effect.params) {
                if ([element.type caseInsensitiveCompare:@"string"] == NSOrderedSame && [element.key containsString:@"Package Id"]) {
                    NSString *uuid = element.value;
                    for (NvMakeupCellModel *cellModel in levelModel.contents) {
                        NvMakeupContentModel *contentModel = (NvMakeupContentModel *)cellModel.makeup;
                        if (contentModel.effectContent.makeup.count > 0) {
                            
                            if ([contentModel.effectContent.makeup[0].uuid isEqualToString:uuid]) {
                                cellModel.selected = YES;
                                break;
                            }
                            
                        }
                    }
                }
            }
            
        }
        
    }
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubviews {
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = UIColor.clearColor;
    
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = self.functionUse == NvMakeupFunctionModeEdit ?  [UIColor clearColor] : [UIColor whiteColor];
    
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.equalTo(self.mas_width);
        make.height.offset(444 * SCREENSCALE);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.mas_width);
    }];
    
    [self addTabView];
    self.tabView.hidden = YES;
    
    [self.bottomView addSubview:self.makeupCollectionView];
    [self.makeupCollectionView registerClass:[NvMakeupCell class] forCellWithReuseIdentifier:@"NvMakeupCell"];
    [self.makeupCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tabView.mas_bottom).offset(10 * SCREENSCALE);
        make.left.equalTo(self.bottomView.mas_left);
        make.right.equalTo(self.bottomView.mas_right);
        make.height.offset(80 * SCREENSCALE);
    }];

    __weak typeof(self)weakSelf = self;
    MJRefreshNormalTrailer *trailer = [MJRefreshNormalTrailer trailerWithRefreshingBlock:^{
        __block NvMakeupLevelModel *model = weakSelf.dataManager.kindArr[weakSelf.selectedTagIndex];
        model.requestPageNum++;
        if(weakSelf.selectedTagIndex > 0){
            [weakSelf.dataManager getDetailMakeupKindNetworkData:model.materialType kind:model.kind page:model.requestPageNum pageSize:10 completeBlock:^(int responsePageSize) {
                [weakSelf.makeupCollectionView.mj_trailer endRefreshing];
                [weakSelf.makeupCollectionView reloadData];
            } failureBlock:^{
                model.requestPageNum--;
                [weakSelf.makeupCollectionView.mj_trailer endRefreshing];
            }];
        }else {
            [weakSelf.dataManager getVariableMakeupNetworkData:model.requestPageNum pageSize:10 completeBlock:^(int responsePageSize) {
                [weakSelf.makeupCollectionView.mj_trailer endRefreshing];
                [weakSelf.makeupCollectionView reloadData];
            } failureBlock:^{
                model.requestPageNum--;
                [weakSelf.makeupCollectionView.mj_trailer endRefreshing];
            }];
        }
    }];
    trailer.arrowView.hidden = YES;
    trailer.stateLabel.text = @"";
    [trailer setTitle:NvLocalString(@"RefreshTrailerIdleText", @"滑动查看") forState:MJRefreshStateIdle];
    [trailer setTitle:NvLocalString(@"RefreshTrailerPullingText", @"释放查看") forState:MJRefreshStatePulling];
    [trailer setTitle:NvLocalString(@"RefreshTrailerPullingText", @"释放查看") forState:MJRefreshStateRefreshing];

    self.makeupCollectionView.mj_trailer = trailer;
    [self addColorView];
    [self addMakeupFilterView];
}

- (void)addMakeupFilterView{
    self.makeupFilterView = [[UIView alloc] init];
    self.makeupFilterView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#EDEDED"];
    [self addSubview:self.makeupFilterView];
    [self.makeupFilterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15*SCREENSCALE);
        make.bottom.equalTo(self.bottomView.mas_top).offset(-10*SCREENSCALE);
        make.height.mas_equalTo(25*SCREENSCALE);
    }];
    self.makeupFilterView.layer.cornerRadius = 12.5*SCREENSCALE;
    self.makeupFilterView.layer.masksToBounds = YES;
    
    UIButton *makeupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    makeupButton.tag = 1000;
    makeupButton.selected = YES;
    makeupButton.layer.cornerRadius = 10*SCREENSCALE;
    makeupButton.layer.masksToBounds = YES;
    makeupButton.backgroundColor = UIColor.whiteColor;
    makeupButton.titleLabel.font = [UIFont systemFontOfSize:10];
    [makeupButton setContentEdgeInsets:UIEdgeInsetsMake(0, KScale6s(5), 0, KScale6s(5))];
    [makeupButton setTitle:NvLocalString(@"make up show", @"妆容") forState:UIControlStateNormal];
    [makeupButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#888888"] forState:UIControlStateNormal];
    [makeupButton setTitleColor:UIColor.blackColor forState:UIControlStateSelected];
    [makeupButton addTarget:self action:@selector(makeupFilterButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.makeupFilterView addSubview:makeupButton];
    
    [makeupButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.makeupFilterView.mas_left).offset(KScale6s(3));
        make.centerY.equalTo(self.makeupFilterView.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(KScale6s(32));
        make.height.mas_equalTo(KScale6s(20));
    }];
    
    UIButton *filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    filterButton.tag = 1001;
    filterButton.layer.cornerRadius = 10*SCREENSCALE;
    filterButton.layer.masksToBounds = YES;
    filterButton.backgroundColor = UIColor.clearColor;
    filterButton.titleLabel.font = [UIFont systemFontOfSize:10];
    [filterButton setContentEdgeInsets:UIEdgeInsetsMake(0, KScale6s(3), 0, KScale6s(3))];
    [filterButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#888888"] forState:UIControlStateNormal];
    [filterButton setTitleColor:UIColor.blackColor forState:UIControlStateSelected];
    [filterButton addTarget:self action:@selector(makeupFilterButton:) forControlEvents:UIControlEventTouchUpInside];
    [filterButton setTitle:NvLocalString(@"Filter", @"滤镜") forState:UIControlStateNormal];
    [self.makeupFilterView addSubview:filterButton];
    
    [filterButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.makeupFilterView.mas_right).offset(-3*SCREENSCALE);
        make.centerY.equalTo(self.makeupFilterView.mas_centerY);
        make.width.mas_greaterThanOrEqualTo(KScale6s(32));
        make.left.equalTo(makeupButton.mas_right).offset(0);
        make.height.offset(KScale6s(20));
    }];
    
    self.makeupVariableSlider = [[BLItemSlider alloc] initWithFrame:CGRectMake(0, 0, 300*SCREENSCALE, 20*SCREENSCALE)];
    self.makeupVariableSlider.delegate = self;
    self.makeupVariableSlider.maximumTrackTintColor = [UIColor whiteColor];
    self.makeupVariableSlider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#80FFFFFF"];
    self.makeupVariableSlider.thumbTintColor = [UIColor whiteColor];
    self.makeupVariableSlider.thumbSeletedTintColor = [UIColor whiteColor];
    self.makeupVariableSlider.minValue = 0;
    self.makeupVariableSlider.maxValue = 1;
    [self.makeupVariableSlider modifyStylevalueLabel];
    [self addSubview:self.makeupVariableSlider];
    [self.makeupVariableSlider adsorb:YES adsorbValue:1.0];
    [self.makeupVariableSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.makeupFilterView.mas_right).offset(10*SCREENSCALE);
        make.centerY.equalTo(self.makeupFilterView.mas_centerY);
        make.width.offset(218*SCREENSCALE);
        make.height.offset(20*SCREENSCALE);
    }];
    
    self.makeupVariableSlider.hidden = YES;
    self.makeupFilterView.hidden = self.makeupVariableSlider.hidden;
}

#pragma mark - 添加颜色选择器
/*
 添加颜色选择器
 Add color picker
 */
- (void)addColorView {
    /*
     添加默认颜色button 及自定义颜色选择button
     Add default color button and custom color selection button
     */
    self.buttonArrs = [NSMutableArray array];
    CGFloat xValue = self.frame.size.width - 45*SCREENSCALE;
    CGFloat topViewHeight =444 * SCREENSCALE;
    for(int i=0;i<4;i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        if (i==0) {
            [button setBackgroundImage:[UIImage imageNamed:@"Nv_custom_colorSelected"] forState:UIControlStateNormal];
        }else{
            button.backgroundColor = [UIColor blackColor];
        }
        button.tag = i;
        button.frame =CGRectMake(xValue,topViewHeight - 35*SCREENSCALE*(i+1) - 7.5*SCREENSCALE*(i+1) - 7*SCREENSCALE*i, 35*SCREENSCALE, 35*SCREENSCALE);
        button.layer.cornerRadius = 17.5*SCREENSCALE;
        [button addTarget:self action:@selector(colorButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:button];
        [self.buttonArrs addObject:button];
    }
    
    /*
     添加颜色slider
     Add color slider
     */
    self.makeupSlider = [[YWISOSlider alloc] initWithFrame:CGRectMake(xValue, 0, 30*SCREENSCALE, topViewHeight - 35*SCREENSCALE*4 - 7.5*SCREENSCALE*4 - 7*SCREENSCALE*3 - 17*SCREENSCALE)];
    self.makeupSlider.delegate = self;
    self.makeupSlider.minimumTrackTintColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    self.makeupSlider.thumbImage = NvImageNamed(@"NvSliderIcon");
    self.makeupSlider.maximumValue = 100;
    self.makeupSlider.minimumValue = 0;
    self.makeupSlider.closerIndicator = YES;
    [self.topView addSubview:self.makeupSlider];
    
    /*
     自定义颜色slider
     Custom color slider
     */
    CGFloat sep = 83*SCREENSCALE;
    CGFloat sliderY = topViewHeight - 12*SCREENSCALE - 31*SCREENSCALE;
    self.customSlider = [[NvCustomColorControl alloc] initWithFrame:CGRectMake(sep, sliderY, SCREENWIDTH - 2*sep, 31*SCREENSCALE) withColors:@[(id)UIColor.redColor.CGColor,(id)UIColor.magentaColor.CGColor,(id)UIColor.blueColor.CGColor,(id)UIColor.cyanColor.CGColor,(id)UIColor.greenColor.CGColor,(id)UIColor.yellowColor.CGColor,(id)UIColor.redColor.CGColor]];
    self.customSlider.delegate = self;
    [self.topView addSubview:self.customSlider];

    /*
     添加美妆头部信息展示界面（选中颜色及不透明度）
     Add beauty head information display interface (select color and opacity)
     */
    CGFloat infoViewWidth = 224.5*SCREENSCALE;
    self.makeupInfoView = [[UILabel alloc] initWithFrame:CGRectMake((SCREENWIDTH - infoViewWidth)/2, sliderY - 25*SCREENSCALE - 16*SCREENSCALE, infoViewWidth, 25*SCREENSCALE)];
    self.makeupInfoView.backgroundColor = [UIColor whiteColor];
    self.makeupInfoView.alpha = 0.2;
    self.makeupInfoView.textAlignment = NSTextAlignmentCenter;
    self.makeupInfoView.font = [UIFont systemFontOfSize:12.f*SCREENSCALE];
    self.makeupInfoView.text = [NSString stringWithFormat:@"%@:%.f%%     %@:%@",NvLocalString(@"Opacity", nil),50.0,NvLocalString(@"Color value", nil),@"#FFFFFFF"];
    self.makeupInfoView.layer.cornerRadius = 4*SCREENSCALE;
    self.makeupInfoView.layer.masksToBounds = YES;
    [self.topView addSubview:self.makeupInfoView];
    self.topView.hidden = YES;
}

- (void)hiddenColorRelatedViews:(BOOL)hidden {
    for (UIButton *button in self.buttonArrs) {
        button.hidden = hidden;
    }
    self.customSlider.hidden = hidden;
    self.makeupInfoView.hidden = hidden;
}

- (void)addTabView {
    self.tabView = [[CQMenuTabView alloc] initWithFrame:CGRectMake(15*SCREENSCALE, 5*SCREENSCALE, SCREENWIDTH-30*SCREENSCALE, 25*SCREENSCALE)];
    self.tabView.layer.masksToBounds = YES;
    self.tabView.titleFont = [UIFont systemFontOfSize:12*SCREENSCALE];
    self.tabView.normaTitleColor = [UIColor nv_colorWithHexString:@"#888888"];
    self.tabView.didSelctTitleColor = [UIColor nv_colorWithHexString:@"#1C1C1C"];
    self.tabView.showCursor = YES;
    self.tabView.normaTitleColor = self.functionUse == NvMakeupFunctionModeEdit ?  [UIColor whiteColor] : [UIColor blackColor];
    self.tabView.cursorStyle = CQTabCursorUnderneath;
    self.tabView.layoutStyle = CQTabWrapContent;
    self.tabView.cursorView.backgroundColor = [UIColor nv_colorWithHexString:@"#3A3A3A"];
    self.tabView.cursorWidth = 12*SCREENSCALE;
    self.tabView.speaceWidth = 15.0*SCREENSCALE;
    __weak typeof(self)weakSelf = self;
    self.tabView.didTapItemAtIndexBlock = ^(UIView *view, NSInteger index) {
        [weakSelf selectTab:index];
    };
    [self.bottomView addSubview:self.tabView];
    
}

#pragma mark - 选中tabView 选项 Select the tabView option
- (void)selectTab:(NSInteger)index {
    self.makeupVariableSlider.hidden = YES;
    self.makeupFilterView.hidden = self.makeupVariableSlider.hidden;
    self.selectedTagIndex = index;
    
    self.makeupLastKey = [NSString stringWithFormat:@"%ld", (long)index];
    NvMakeupLevelModel *levelModel = self.dataManager.kindArr[index];
    self.currentMakeupLevelModel = levelModel;
    if(index > 0) {
        //单妆 monomakeup
        __weak typeof(self)weakSelf = self;
        if (!(levelModel.contents.count>0)) {
            [self.dataManager getDetailMakeupKindData:levelModel completeBlock:^{
                [weakSelf resetSingleEffectStateAfterSelectVariableEffect];
                [weakSelf.makeupCollectionView reloadData];
                
                if (weakSelf.currentMakeupLevelModel.contents.count > 0) {
                    for (NvMakeupCellModel *model in weakSelf.currentMakeupLevelModel.contents) {
                        if (model.selected) {
                            weakSelf.currentMakeupCustomModel = (NvMakeupContentModel *)model.makeup;
                            break;
                        }
                    }
                }
                //配置topView Configuring topView
                [weakSelf setMakeupTopViewState];
            }];
        } else {
            if (weakSelf.currentMakeupLevelModel.contents.count > 0) {
                for (NvMakeupCellModel *model in weakSelf.currentMakeupLevelModel.contents) {
                    if (model.selected) {
                        weakSelf.currentMakeupCustomModel = (NvMakeupContentModel *)model.makeup;
                        break;
                    }
                }
            }
            [self.makeupCollectionView reloadData];
            [weakSelf setMakeupTopViewState];
        }
    }else {
        //整妆 Complete makeup
        [self resetSingleEffectStateAfterSelectVariableEffect];
        [self.makeupCollectionView reloadData];
        self.currentMakeupCustomModel = nil;
        //配置topView Configuring topView
        [self setMakeupTopViewState];
        if (self.currentMakeupVariableModel && index == 0){
            self.makeupVariableSlider.hidden = NO;
            self.makeupFilterView.hidden = self.makeupVariableSlider.hidden;
        }
    }
}

- (void)setMakeupTopViewState {
    if (self.currentMakeupLevelModel.contents.count > 0) {
        NvMakeupCellModel *targetModel = self.currentMakeupLevelModel.contents[0];
        for (NvMakeupCellModel *model in self.currentMakeupLevelModel.contents) {
            if (model.selected) {
                targetModel = model;
                break;
            }
        }
        [self resetMakeupSelectedState:targetModel];
    }else{
        [self resetMakeupSelectedState:nil];
    }
}

#pragma mark - 根据选中数据重置topview
/*
 根据选中数据重置topview
 Reset topview according to selected data
 
 @param makeupContentModel 美妆model makeup model
 */
- (void)configTopView:(NvMakeupContentModel *)makeupContentModel {
    if (makeupContentModel.effectContent.makeup.count > 0) {
        self.makeupSlider.value = makeupContentModel.effectContent.makeup[0].intensity*100;
        self.makeupSlider.tagLabel.text = [NSString stringWithFormat:@"%.f",self.makeupSlider.value];
        [self.makeupLastValues removeObjectForKey:self.makeupLastKey];
        if (makeupContentModel.hasSelectedCustomColor) {
           self.customSlider.hidden = NO;
           self.customSlider.endPoint = CGPointMake(makeupContentModel.xValue, 0);
        }else{
            [self.customSlider setDefaultMode];
            self.customSlider.hidden = YES;
        }
            
        [self setColorButtonsStateWithModel:makeupContentModel];
        
        
        if (makeupContentModel.effectContent.makeup[0].color.length > 0) {
            NvsColor color = [self nvsColorWithValue:makeupContentModel.effectContent.makeup[0].color];
            self.makeupInfoColorValue = [NvUtils colorStringInRGBAModeWithRGB:color];
        }else{
            self.makeupInfoColorValue = @"";
        }
        
        self.makeupInfoAlpha = self.makeupSlider.value;
    }
}

#pragma mark - 根据选中数据修改按钮状态
/*
 根据选中数据修改按钮状态
 Modify the button state according to the selected data
 
 @param makeupContentModel 美妆model makeup model
 */
- (void)setColorButtonsStateWithModel:(NvMakeupContentModel *)model {
    [self setCustomColorButtonSelected:model.hasSelectedCustomColor];
    if (model.effectContent.makeup.count <=0 || !model.effectContent.makeup) {
        return;
    }
    for (int i=0; i<model.effectContent.makeup[0].makeupRecommendColors.count; i++) {
        UIButton *button = self.buttonArrs[i+1];
        if (i<3) {
            button.backgroundColor = [self colorWithValue:model.effectContent.makeup[0].makeupRecommendColors[i].makeupColor];
        }
        
    }
    if (!model.hasSelectedCustomColor && model.selectedButtonIndex > 0) {
        UIButton *button = self.buttonArrs[model.selectedButtonIndex];
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1.5*SCREENSCALE;
    }
}

#pragma mark - 根据数据设置自定义颜色按钮状态
/*
 根据数据设置自定义颜色按钮状态
 Set custom color button state according to data
 
 @param isSelected yes表示选中，no表示没有选中
 */
- (void)setCustomColorButtonSelected:(BOOL)isSelected {
    for (UIButton *btn in self.buttonArrs) {
        btn.layer.borderWidth = 0;
        btn.layer.borderColor = [UIColor clearColor].CGColor;
    }
    UIButton *button = self.buttonArrs[0];
    if (isSelected) {
        [button setBackgroundImage:nil forState:UIControlStateNormal];
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1.5*SCREENSCALE;
    }else{
        [button setBackgroundImage:[UIImage imageNamed:@"Nv_custom_colorSelected"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        button.layer.borderWidth = 0;
        button.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

#pragma mark - 设置美妆界面的透明度
/*
 设置美妆界面的透明度
 Set the transparency of the beauty interface
 
 */
- (void)setupMakeupInfoView {
    if([self.makeupInfoColorValue containsString:@"00000000"] || !self.makeupInfoColorValue || [self.makeupInfoColorValue isEqualToString:@""]){
        self.makeupInfoView.text =[NSString stringWithFormat:@"%@:%.f",NvLocalString(@"Opacity", nil),self.makeupInfoAlpha];
    }else{
        self.makeupInfoView.text =[NSString stringWithFormat:@"%@:%.f%%     %@:%@",NvLocalString(@"Opacity", nil),self.makeupInfoAlpha,NvLocalString(@"Color value", nil),self.makeupInfoColorValue];
    }
}

#pragma mark - 根据参数，转换成UIColor
/*
 根据参数，转换成UIColor
 According to the parameters, convert to UIColor
 
 @param value 传入的RGBA字符串
 Incoming RGBA string
 
 return UIColor。
 */
- (UIColor *)colorWithValue:(NSString *)value {
    NSArray *arr = [value componentsSeparatedByString:@","];
    UIColor *color;
    if (arr.count == 4) {
        color = [UIColor colorWithRed:[arr[0] floatValue] green:[arr[1] floatValue] blue:[arr[2] floatValue] alpha:[arr[3] floatValue]];
    }
    return color;
}

#pragma mark - 颜色按钮点击方法
/*
 颜色按钮点击方法
 Color button click method
 
 @param button button
 */
- (void)colorButtonClicked:(UIButton *)button {
    self.currentMakeupCustomModel.hasSelectedCustomColor = NO;
    [self selectButtonWithIndex:button.tag];
    if(button.tag == 0) {
        /*
         自定义颜色
         Custom color
         */
        if (self.customSlider.hidden == YES) {
            self.customSlider.hidden = NO;
            self.currentMakeupCustomModel.hasSelectedCustomColor = YES;
            [self configTopView:self.currentMakeupCustomModel];
        }
        
    }else {
        [self.customSlider setDefaultMode];
        self.customSlider.hidden = YES;
        [self selectColorButtonForMakeup:button.tag -1];
    }
}

#pragma mark - 根据参数，修改选中的按钮状态
/*
 根据参数，修改选中的按钮状态
 According to the parameters, modify the selected button state
 
 @param index index
 */
- (void)selectButtonWithIndex:(NSInteger)index {
    for (UIButton *btn in self.buttonArrs) {
        btn.layer.borderWidth = 0;
        btn.layer.borderColor = [UIColor clearColor].CGColor;
    }
    UIButton *button = self.buttonArrs[index];
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 1.5*SCREENSCALE;
}

#pragma mark - 根据参数，修改选中的按钮状态
/*
 根据参数，修改选中的按钮状态
 According to the parameters, modify the selected button state
 
 @param index index
 */
- (void)selectColorButtonForMakeup:(NSInteger)index {
    self.currentMakeupCustomModel.selectedButtonIndex = index+1;
    [self configTopView:self.currentMakeupCustomModel];
    if (self.currentMakeupCustomModel.effectContent.makeup[0].makeupRecommendColors.count > index) {
        self.currentMakeupCustomModel.selectedColorStr = self.currentMakeupCustomModel.effectContent.makeup[0].makeupRecommendColors[index].makeupColor;
        NvsColor color = [self nvsColorWithValue:self.currentMakeupCustomModel.effectContent.makeup[0].makeupRecommendColors[index].makeupColor];
        self.makeupInfoColorValue = [NvUtils colorStringInRGBAModeWithRGB:color];
        self.currentMakeupCustomModel.effectContent.makeup[0].color = [NSString stringWithFormat:@"%f,%f,%f,%f", color.r,color.g,color.b,color.a];
        [self applyMakeupPackage:self.currentMakeupCustomModel.effectContent];
        
    }
}

#pragma mark - 预处理单独妆容数据（如：口红等）
/*
 预处理单独妆容数据（如：口红等）
 Preprocess individual makeup data (eg: lipstick, etc.)
 
 @param model 美妆数据 makeup data
 */
- (void)prepareSingleMakeupData:(NvMakeupModel *)model {
    for (NSString *path in model.addContentFile) {
        NSString *tmpFile = [NvMakeupBundlePath stringByAppendingPathComponent:path];
        
        NSData *tmpData = [[NSData alloc] initWithContentsOfFile:tmpFile];
        NSString *tmpStr = [NSJSONSerialization JSONObjectWithData:tmpData options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingFragmentsAllowed|NSJSONReadingAllowFragments error:nil];
        NvMakeupModel *tmpModel = [NvMakeupModel yy_modelWithJSON:tmpStr];
        NSString *resourcePath= [path stringByDeletingLastPathComponent];
        
        /*
         设置路径
         Set path
         */
        if (tmpModel.contents.count > 0) {
            for (NvMakeupContentModel *contentModel in tmpModel.contents) {
                contentModel.resourceDir = [NvMakeupBundlePath stringByAppendingPathComponent:resourcePath];
                [self setRandomLableColor:contentModel];
                contentModel.coverImage = [NvMakeupBundlePath stringByAppendingPathComponent:[resourcePath stringByAppendingPathComponent:contentModel.coverImage]];
            }
        } 
        [model.contents addObjectsFromArray:tmpModel.contents];
    }
    for(int i=0; i<model.contents.count; i++) {
        NvMakeupContentModel *contentModel = model.contents[i];
        if (i == 0 || i == 1) {
            /*
             返回按钮背景颜色为红色
             Back button background color is red
             */
            if(i == 0){
               contentModel.bgColorStr = @"#FF8E8EFF";
            }
            [self setTranslucentLableColor:contentModel];
        }
        contentModel.conLevel = model.contentLevel;
        contentModel.textColorStr = @"#FFFFFFFF";
    }
}


#pragma mark - 根据参数把RGBA颜色值转化成字符串并且赋值
/*
 根据参数把RGBA颜色值转化成字符串并且赋值
 Convert the RGB color value into a string according to the parameter and assign it
 
 @param model 美妆数据 makeup data
 */
- (void)setTranslucentLableColor:(NvMakeupContentModel *)model {
    NvsColor lightWhiteColor;
    lightWhiteColor.r = 1;
    lightWhiteColor.g = 1;
    lightWhiteColor.b = 1;
    lightWhiteColor.a = 0.5;
    model.labelColorStr = [NvUtils colorStringInRGBAModeWithRGB:lightWhiteColor];
}

#pragma mark - 根据参数把随机的颜色值转化成字符串并且赋值
/*
 根据参数把随机的颜色值转化成字符串并且赋值
 According to the parameters, the random color value is converted into a string and assigned
 
 @param model 美妆数据 makeup data
 */
- (void)setRandomLableColor:(NvMakeupContentModel *)model {
    model.labelColorStr = [NvUtils randomColorInColorArr:self.dataManager.labelColorArr];
}

#pragma mark - 点击美妆collectionView
/*
 点击美妆collectionView
 Click on beauty collectionView
 
 @param indexPath 下标 index
 */
- (void)selectMakeupCollectionViewWithIndex:(NSIndexPath *)indexPath
{
    __weak typeof(self)weakSelf = self;
    NvMakeupCellModel *cellModel = self.currentMakeupLevelModel.contents[indexPath.item];
    [self resetContentModelUnselected:self.currentMakeupLevelModel];
    cellModel.selected= YES;
    NvMakeupToolModel *downloadModel;
    //variable YES整装,NO单装
    BOOL variable = YES;
    if (self.selectedTagIndex > 0) {
        //单妆 monomakeup
        variable = NO;
        NvMakeupContentModel *tmpModel = (NvMakeupContentModel *)cellModel.makeup;
        self.currentMakeupCustomModel = tmpModel;
        downloadModel = [NvMakeupToolModel new];
        downloadModel.packagePath = tmpModel.packagePath;
        downloadModel.zipUrl = tmpModel.zipUrl;
        downloadModel.packageFileName = tmpModel.packageUrl;
    }else {
        
        self.currentMakeupVariableModel.currentValue = self.currentMakeupVariableModel.defaultValue;
        self.currentMakeupVariableModel.filterCurrentValue = self.currentMakeupVariableModel.filterDefaultValue;
        self.currentMakeupCustomModel = nil;
        NvMakeupToolModel * makeupModel = (NvMakeupToolModel *)cellModel.makeup;
        makeupModel.zipUrl = makeupModel.packagePath;
        self.currentMakeupVariableModel = makeupModel;
        downloadModel = makeupModel;
    }
    self.selectedCellModel = cellModel;
    
    if (cellModel.state == NODownload){
        cellModel.state = Downloading;
    }
    [self.dataManager downloadAndProcessMakeupPackage:downloadModel variable:variable completeBlock:^{
        
        cellModel.state = Finish;
        if(variable && [self.delegate respondsToSelector:@selector(nvMakeupView:applyVariableMakeupEffect:)]) {
            if(!downloadModel.packagePath || downloadModel.packagePath.length == 0) {
                [self setAllCategoriesSingleMakeupUnSelected];
            }
            [self.delegate nvMakeupView:self applyVariableMakeupEffect:downloadModel.packagePath];
        }else if(!variable && [self.delegate respondsToSelector:@selector(nvMakeupView:applySingleKindMakeupEffect:)]){
            [self.delegate nvMakeupView:self applySingleKindMakeupEffect:self.currentMakeupCustomModel.effectContent];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!variable && self.currentMakeupCustomModel.effectContent.makeup.count > 0 && self.currentMakeupCustomModel.effectContent.makeup[0].makeupRecommendColors.count > 0) {
                [weakSelf hiddenColorRelatedViews:NO];
            }else{
                if (downloadModel && variable) {
                    self.makeupVariableSlider.value = self.currentMakeupVariableModel.defaultValue;
                    self.changeFilterValue = NO;
                    self.makeupVariableSlider.hidden = NO;
                }else{
                    self.makeupVariableSlider.hidden = YES;
                }
                self.makeupFilterView.hidden = self.makeupVariableSlider.hidden;
                [weakSelf hiddenColorRelatedViews:YES];
            }
            [weakSelf resetMakeupSelectedState:cellModel];
            [weakSelf.makeupCollectionView reloadData];
        });
    }];
}

- (void)setAllCategoriesSingleMakeupUnSelected {
    if(self.dataManager.kindArr.count <= 1) {
        return;
    }
    for (int i=1; i<self.dataManager.kindArr.count; i++) {
        NvMakeupLevelModel *levelModel = self.dataManager.kindArr[i];
        [self resetContentModelUnselected:levelModel];
    }
   
}

#pragma mark - 美妆强度改变
/*
 美妆强度改变
 Beauty intensity changes
 
 @param value 效果值 Effect value
 */
- (void)makeupItensityChanged:(float)value {
    if (self.currentMakeupCustomModel.effectContent.makeup.count > 0) {
        self.currentMakeupCustomModel.effectContent.makeup[0].intensity = value/100;
        self.makeupInfoAlpha = value;
        [self applyMakeupPackage:self.currentMakeupCustomModel.effectContent];
    }
}

#pragma mark - 应用美妆效果 Apply beauty effects

- (void)applyMakeupPackage:(NvMakeupEffectModel *)effectModel {
    NSString *makeupId = effectModel.makeup[0].makeupId;
    BOOL canReplace = [self canReplace:makeupId appliedMakeupEffect:self.currentMakeupVariableModel];
    if (!canReplace) {
        if([self.delegate respondsToSelector:@selector(nvMakeupView:forbiddenReplaceMakeupEffect:)]) {
            [self.delegate nvMakeupView:self forbiddenReplaceMakeupEffect:effectModel];
        }
        return;
    }
    
    if([self.delegate respondsToSelector:@selector(nvMakeupView:applySingleKindMakeupEffect:)]){
        [self.delegate nvMakeupView:self applySingleKindMakeupEffect:effectModel];
    }

}

#pragma mark - 根据参数，转换成NvsColor
/*
 根据参数，转换成NvsColor
 According to the parameters, convert to NvsColor
 
 @param value 传入的RGBA字符串
 Incoming RGBA string
 
 return NvsColor。
 */
- (NvsColor)nvsColorWithValue:(NSString *)value {
    NSArray *arr = [value componentsSeparatedByString:@","];
    NvsColor color;
    color.r = 0;
    color.g = 0;
    color.b = 0;
    color.a = 0;
    if (arr.count == 4) {
        color.r = [arr[0] floatValue];
        color.g = [arr[1] floatValue];
        color.b = [arr[2] floatValue];
        color.a = [arr[3] floatValue];
    }
    return color;
}

#pragma mark - 根据参数，转换成字符串颜色值
/*
 根据参数，转换成字符串颜色值
 According to the parameters, converted into a string color value
 
 @param r 颜色值 Color value
 @param g 颜色值 Color value
 @param b 颜色值 Color value
 @param a 透明度 alpha
 
 return 返回字符串的颜色值。Returns the color value of the string.
 */
- (NSString *)getColorStringWithR:(CGFloat)r G:(CGFloat)g B:(CGFloat)b A:(CGFloat)a {
    /*
     取值范围0～1
     Value range 0～1
     */
    NSString *colorStr = [[NSString alloc] initWithFormat:@"%f,%f,%f,%f",r,g,b,a];
    return colorStr;
}

#pragma mark - 重置美妆的选中状态
/*
 重置美妆的选中状态
 Reset the selected state of beauty
 
 @param makeupContentModel 美妆数据 makeup data
 */
- (void)resetMakeupSelectedState:(NvMakeupCellModel *)makeupContentModel {
    if ([makeupContentModel.displayName isEqualToString:NvLocalString(@"None", @"无")] ||
        [makeupContentModel.displayName isEqualToString:NvLocalString(@"Custom", @"自定义")] ||
        [makeupContentModel.displayNameZhCn isEqualToString:@"无"] ||
        [makeupContentModel.displayNameZhCn isEqualToString:@"自定义"] ||
        [makeupContentModel.displayNameZhCn isEqualToString:@"美妆"]||
        self.selectedTagIndex == 0 ||
        !makeupContentModel) {
        
        self.topView.hidden = YES;
    }else{
        
        self.topView.hidden = NO;
        if ([makeupContentModel.makeup isKindOfClass:[NvMakeupContentModel class]]) {
            NvMakeupContentModel *customMakeup = (NvMakeupContentModel *)makeupContentModel.makeup;
            if (customMakeup.effectContent.makeup.count > 0 && customMakeup.effectContent.makeup[0].color.length > 0) {
                NvsColor color = [self nvsColorWithValue: customMakeup.effectContent.makeup[0].color];
                self.makeupInfoColorValue = [NvUtils colorStringInRGBAModeWithRGB:color];
            }else{
                self.makeupInfoColorValue = @"";
            }
            
            [self configTopView:customMakeup];
        }
        
    }
}

#pragma mark - 将美妆model中的contentModel选中状态全部设为NO
/*
 将美妆model中的contentModel选中状态全部设为NO
 Set the selected state of the contentModel in the beauty model to NO
 
 @param makeupModel 美妆数据 makeup data
 */
- (void)resetContentModelUnselected:(NvMakeupLevelModel *)makeupModel {
    for (NvMakeupCellModel * contentModel in makeupModel.contents) {
        contentModel.selected = NO;
    }
}

#pragma mark YWISOSliderDelegate
- (void)YWISOSliderValueChanged:(YWISOSlider *)slider {
    if(slider == self.makeupSlider){
        slider.tagLabel.hidden = NO;
        slider.tagLabel.text = [NSString stringWithFormat:@"%.f",slider.value];
    }
    [self makeupItensityChanged:slider.value];
}
#pragma mark - BLItemSliderDelegate
-(void)itemSlider:(BLItemSlider*)slider valueChanged:(float)value{
    if([self.delegate respondsToSelector:@selector(nvMakeupView:changeVariableMakeup:with:)]) {
        if(self.changeFilterValue){
            self.currentMakeupVariableModel.filterCurrentValue = slider.value;
            [self.delegate nvMakeupView:self changeVariableMakeup:self.currentMakeupVariableModel.filterCurrentValue with:YES];
        }else{
            self.currentMakeupVariableModel.currentValue = slider.value;
            [self.delegate nvMakeupView:self changeVariableMakeup:self.currentMakeupVariableModel.currentValue with:NO];
        }
    }
}

#pragma mark - makeupFilterButton
-(void)makeupFilterButton:(UIButton *)sender{
    self.changeFilterValue = sender.tag == 1001?YES:NO;
    
    if(self.changeFilterValue){
        self.makeupVariableSlider.value = self.currentMakeupVariableModel.filterCurrentValue;
    }else{
        self.makeupVariableSlider.value = self.currentMakeupVariableModel.currentValue;
    }
    
}

#pragma mark NvCustomColorControlDelegate
- (void)colorControl:(NvCustomColorControl *)colorView R:(CGFloat)r G:(CGFloat)g B:(CGFloat)b alpha:(CGFloat)alpha point:(CGPoint)point {
    UIColor *buttonColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
    UIButton *button = self.buttonArrs[0];
    [button setBackgroundImage:nil forState:UIControlStateNormal];
    button.backgroundColor = buttonColor;
    
    self.currentMakeupCustomModel.xValue = point.x;
    CGFloat rValue = r/255.0f;
    CGFloat gValue = g/255.0f;
    CGFloat bValue = b/255.0f;
    self.currentMakeupCustomModel.selectedColorStr = [self getColorStringWithR:rValue G:gValue B:bValue A:alpha];
    NvsColor color ;
    color.r = rValue;
    color.g = gValue;
    color.b = bValue;
    color.a = alpha;
    self.makeupInfoColorValue = [NvUtils colorStringInRGBAModeWithRGB:color];
    self.currentMakeupCustomModel.effectContent.makeup[0].color = [NSString stringWithFormat:@"%f,%f,%f,%f", rValue,gValue,bValue,alpha];
    [self applyMakeupPackage:self.currentMakeupCustomModel.effectContent];
}

- (NSArray <NvMakeupContentModel *>*)getSelectedSingleElements {
    NSMutableArray *arr = [NSMutableArray array];
    if (self.dataManager.kindArr.count > 1) {
        for (int i=1; i<self.dataManager.kindArr.count; i++) {
            NvMakeupLevelModel *levelModel = self.dataManager.kindArr[i];
            for (NvMakeupCellModel *cellModel in levelModel.contents) {
                if (cellModel.selected) {
                    NvMakeupContentModel *contentModel = (NvMakeupContentModel *)cellModel.makeup;
                    [arr addObject:contentModel];
                    break;
                }
            }
        }
    }
    return arr;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentMakeupLevelModel.contents.count;
 
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvMakeupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvMakeupCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.currentMakeupLevelModel.contents[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.makeupVariableSlider.hidden = YES;
    self.makeupFilterView.hidden = self.makeupVariableSlider.hidden;
    if (self.selectedTagIndex > 0) {
        //选择单妆时，判断是否可点击（根据已选整妆中该单妆项是否限制为不可替换来判断）
        // When selecting a single makeup, judge whether it can be clicked (according to whether the single makeup item in the selected makeup is limited to be irreplaceable).
        NvMakeupCellModel *selectModel = self.currentMakeupLevelModel.contents[indexPath.item];
        NvMakeupContentModel *contentModel = (NvMakeupContentModel *)selectModel.makeup;
        NSString *fxName = contentModel.effectContent.makeupId.length > 0 ? contentModel.effectContent.makeupId : contentModel.effectContent.makeup[0].makeupId;
        
        BOOL canReplace = [self canReplace:fxName appliedMakeupEffect:self.currentMakeupVariableModel];
        if (!canReplace) {
            if([self.delegate respondsToSelector:@selector(nvMakeupView:forbiddenReplaceMakeupEffect:)]) {
                [self.delegate nvMakeupView:self forbiddenReplaceMakeupEffect:contentModel.effectContent];
            }
            return;
        }
    }
    
    for (NvMakeupCellModel *model in self.currentMakeupLevelModel.contents) {
        model.selected = NO;
    }
    if(indexPath.item > 0) {
        NvMakeupCellModel *selectModel = self.currentMakeupLevelModel.contents[indexPath.item];
        selectModel.selected = YES;
    }
    
    self.isApplicationMakeup = NO;
    
    [self selectMakeupCollectionViewWithIndex:indexPath];
    [collectionView reloadData];
}

- (BOOL)canReplace:(NSString *)makeupId appliedMakeupEffect:(NvMakeupToolModel *)effectModel {
    BOOL canReplace = YES;
    for (NvMakeupToolEffectModel *model in effectModel.effectContent.makeup) {
        if ([model.type containsString:makeupId] && !(model.canReplace)) {
            canReplace = NO;
            break;
        }
    }
    return canReplace;
}

#pragma mark - hitTest
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect visibleRect = CGRectMake(0, 414 * SCREENSCALE, self.frame.size.width, self.frame.size.height);
    if (CGRectContainsPoint(visibleRect, point)) {
        return [super hitTest:point withEvent:event];
    }
    CGFloat xValue = self.frame.size.width - 45*SCREENSCALE;
    CGFloat topViewHeight =444 * SCREENSCALE;
    CGRect rightTopFrame = CGRectMake(xValue, 0, 45*SCREENSCALE, topViewHeight);
    CGRect colorSliderFrame = CGRectMake(82.5*SCREENSCALE, topViewHeight - 40*SCREENSCALE, SCREENHEIGHT - 165*SCREENHEIGHT, 40*SCREENHEIGHT);
    if (CGRectContainsPoint(rightTopFrame, point) || CGRectContainsPoint(colorSliderFrame, point)) {
        return [super hitTest:point withEvent:event];
    }
    return nil;
}

#pragma mark - get && set
- (UICollectionView *)makeupCollectionView {
    if (!_makeupCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(50*SCREENSCALE, 75*SCREENSCALE);
        layout.minimumLineSpacing =5*SCREENSCALE ;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 15*SCREENSCALE, 0, 0*SCREENSCALE);
        _makeupCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
        _makeupCollectionView.delegate = self;
        _makeupCollectionView.dataSource = self;
        _makeupCollectionView.backgroundColor = [UIColor clearColor];
        _makeupCollectionView.showsHorizontalScrollIndicator = NO;
    }
    return _makeupCollectionView;
}

- (NSMutableDictionary *)makeupLastValues {
    if (!_makeupLastValues) {
        _makeupLastValues = @{}.mutableCopy;
    }
    return _makeupLastValues;
}

- (void)setSelectedTagIndex:(NSInteger)selectedTagIndex {
    _selectedTagIndex = selectedTagIndex;
    self.dataManager.selectedTagIndex = selectedTagIndex;
}

- (void)setChangeFilterValue:(BOOL)changeFilterValue{
    _changeFilterValue = changeFilterValue;
    
    for (UIButton *btn in self.makeupFilterView.subviews) {
        btn.selected = NO;
        btn.backgroundColor = UIColor.clearColor;
    }
    
    UIButton *btn = (UIButton *)[self.makeupFilterView viewWithTag:1000];
    if(changeFilterValue){
        btn = (UIButton *)[self.makeupFilterView viewWithTag:1001];
    }
    btn.selected = YES;
    btn.backgroundColor = UIColor.whiteColor;
}

#pragma mark - 设置美妆信息界面透明度值
/*
 设置美妆信息界面透明度值
 Set the transparency value of the beauty information interface
 
 @param makeupInfoAlpha 透明度值 Alpha
 
 */
- (void)setMakeupInfoAlpha:(CGFloat)makeupInfoAlpha {
    _makeupInfoAlpha = makeupInfoAlpha;
    [self setupMakeupInfoView];
}

#pragma mark - 设置美妆信息界面选中颜色值（十六进制rgba）
/*
 设置美妆信息界面选中颜色值（十六进制rgba）
 Set the selected color value in the beauty information interface (hexadecimal rgba)
 
 @param makeupInfoColorValue 颜色值 Color value
 */
- (void)setMakeupInfoColorValue:(NSString *)makeupInfoColorValue {
    _makeupInfoColorValue = makeupInfoColorValue;
    [self setupMakeupInfoView];
}

- (void)setHasNetwork:(BOOL)hasNetwork {
    _hasNetwork = hasNetwork;
    self.dataManager.hasNetwork = hasNetwork;
}

@end
