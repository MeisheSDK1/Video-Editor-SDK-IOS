//
//  NvEditMakeUpView.m
//  SDKDemo
//
//  Created by ms on 2021/12/1.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvEditMakeUpView.h"
#import "NvMakeupModel.h"
#import "NvEditMakeUpCell.h"
#import "YWISOSlider.h"
#import "NvCustomColorControl.h"
#import "NVHeader.h"
#import <NvSDKCommon/NvHttpRequest.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import <CQMenuTabView.h>
#import "AFNetworkReachabilityManager.h"
#import "NvBeautySliderView.h"
#import "NvMakeupSlider.h"
#import "NvMakeupToolDataManager.h"
#import "MJRefresh.h"

@interface NvEditMakeUpView ()<UICollectionViewDelegate,UICollectionViewDataSource,NvMakeupSliderViewDelegate,NvCustomColorControlDelegate,NvAssetManagerDelegate,NvHttpRequestDelegate>

//上半部分视图
//Top half view
@property (nonatomic, strong) UIView *topView;
//下半部分视图
// Bottom half view
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UICollectionView *makeupCollectionView;
@property (nonatomic, strong) CQMenuTabView *tabView;
//程度slider
// Degree slider
@property (nonatomic, strong) NvMakeupSlider *editMakeupSlider;
//自定义颜色选择器
// Customize the color selector
@property (nonatomic, strong) NvCustomColorControl *customSlider;
//美妆界面数据
// Makeup interface data
@property (nonatomic, copy) NSArray *makeupArr;
//美妆效果混合模式数组
// makeup Effects Mix Mode array
@property (nonatomic, copy) NSArray *blendArr;
//最终应用的美妆数据
// makeup data of final application
@property (nonatomic, strong) NvsMakeupEffectInfo *totalMakeupInfo;
//保存美妆slider的value
// Save the value of the makeup slider
@property (nonatomic, strong) NSMutableDictionary *makeupLastValues;
//保存美妆slider的key
//Save the key for makeup slider
@property (nonatomic, assign) NSInteger makeupLastIndex;
//保存美妆slider的key
//Save the key for makeup slider
@property (nonatomic, strong) NSString *makeupLastKey;
//当前美妆层级对应model
// The current makeup level corresponds to model
@property (nonatomic, strong) NvMakeupLevelModel *currentMakeupLevelModel;
//当前界面选中具体整妆model
// Select a makeup model on the current screen
@property (nonatomic, strong) NvMakeupToolModel *currentMakeupVariableModel;
//当前界面选中具体单妆model
// Select the specific makeup model on the current screen
@property (nonatomic, strong) NvMakeupContentModel *currentMakeupCustomModel;
@property (nonatomic, strong) NvMakeupCellModel *selectedCellModel;
@property (nonatomic, strong) NSMutableArray *buttonArrs;

/// 是否已经应用整体美妆
/// Whether or not you have applied your overall makeup
@property (nonatomic, assign) BOOL isApplicationMakeup;

@property (nonatomic, assign) NSInteger indexPath;
//美妆信息显示界面（选中颜色及不透明度）
// Makeup information display interface (select color and opacity)
@property (nonatomic, strong) UILabel *makeupInfoView;
//美妆信息透明度
// Beauty information transparency
@property (nonatomic, assign) CGFloat makeupInfoAlpha;
//美妆信息选中颜色
// Beauty Information Select the color
@property (nonatomic, strong) NSString *makeupInfoColorValue;
@property (nonatomic, assign) NSInteger selectedTagIndex;
@property (nonatomic, strong) NSArray *tagArr;
@property (nonatomic, strong) NSMutableArray <NvMakeupModel *>*singleMakeupModelArr;

@property (nonatomic, assign) int currentCategory;
@property (nonatomic, assign) int currentKind;
@property (nonatomic, strong) NSMutableArray *installPaths;
@property (nonatomic, strong) NSMutableArray *installedMakups;
//是否请求过单妆分类（只请求一次）
//Have you requested single makeup classification (only request once)?
@property (nonatomic, assign) BOOL hasQueryKind;
@property (nonatomic, assign) BOOL hasNetwork;
@property (nonatomic,assign) NvEditMakeUpFunction functionUse;
@property (nonatomic, strong) NvMakeupToolDataManager *dataManager;
@end
@implementation NvEditMakeUpView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.dataManager = [[NvMakeupToolDataManager alloc] init];
        self.dataManager.functionMode = NvMakeupFunctionModeEdit;
        self.functionUse = NvEditMakeUpFunctionCapture;
        [self configMakeupData];
        [self addSubviews];
        [self getTagData];
        [self addVariableDatas];
    }
    return self;
}

-(instancetype)initWithFunctionUse:(NvEditMakeUpFunction)functionUse Frame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.functionUse = functionUse;
        self.dataManager = [[NvMakeupToolDataManager alloc] init];
        self.dataManager.functionMode = NvMakeupFunctionModeEdit;
        [self configMakeupData];
        [self addSubviews];
        [self getTagData];
        [self addVariableDatas];
    }
    return self;
}

-(void)setEditColor{
    self.bottomView.backgroundColor = [UIColor clearColor];
}

- (void)configMakeupData {
    [self monitorReachabilityStatus];
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
            [weakSelf checkAndResetStateInVariableModel:weakSelf.currentMakeupLevelModel];
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

//监测网络状态的方法
// Methods for monitoring network status
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
    if (makeupArr.count > 0 && self.selectedTagIndex > 0) {
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

- (NSArray *)contentArrFromPath:(NSString *)basePath path:(NSString *)path{
    NSData *varialbeData = [[NSData alloc] initWithContentsOfFile:path];
    NSDictionary *infoVarialbeStr = [NSJSONSerialization JSONObjectWithData:varialbeData options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingFragmentsAllowed|NSJSONReadingAllowFragments error:nil];
    NSArray *varialbeMakeupArr = infoVarialbeStr[@"contents"];
    NSArray *varialbeContentArr = [NSArray yy_modelArrayWithClass:[NvMakeupContentModel class] json:varialbeMakeupArr];
    //add the effect model
    for (NvMakeupContentModel *contentModel in varialbeContentArr) {
        if (contentModel.effectFileName.length > 0) {
            NSString *effectPath = [basePath stringByAppendingPathComponent:contentModel.effectFileName];
            NSData *data = [[NSData alloc] initWithContentsOfFile:effectPath];
            NSDictionary *infoStr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves|NSJSONReadingMutableContainers|NSJSONReadingFragmentsAllowed|NSJSONReadingAllowFragments error:nil];
            NvMakeupContentModel *contentM = [NvMakeupContentModel yy_modelWithJSON:infoStr];
            contentModel.effectContent = contentM.effectContent;
        }
    }
    return varialbeContentArr;
}

- (NvMakeupContentModel *)convertAssetToMakeupContentModel:(NvAsset *)asset {
    NvMakeupContentModel *model = [NvMakeupContentModel new];
    return model;
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
    self.bottomView.backgroundColor = self.functionUse == NvEditMakeUpFunctionEdit ?  [UIColor clearColor] : [UIColor whiteColor];

    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    
  
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(140 * SCREENSCALE);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.mas_width);
    }];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomView.mas_top);
        make.left.equalTo(self);
        make.width.equalTo(self.mas_width);
        make.top.mas_equalTo(self);
    }];
    
    [self.bottomView addSubview:self.makeupCollectionView];
    [self.makeupCollectionView registerClass:[NvEditMakeUpCell class] forCellWithReuseIdentifier:@"NvEditMakeUpCell"];
    [self.makeupCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top).offset(0 * SCREENSCALE);
        make.left.equalTo(self.bottomView.mas_left);
        make.right.equalTo(self.bottomView.mas_right);
        make.height.offset(94 * SCREENSCALE);
    }];
    __weak typeof(self)weakSelf = self;
    MJRefreshNormalTrailer *trailer = [MJRefreshNormalTrailer trailerWithRefreshingBlock:^{
        __block NvMakeupLevelModel *model = weakSelf.dataManager.kindArr[weakSelf.selectedTagIndex];
        model.requestPageNum++;
        if(weakSelf.selectedTagIndex > 0){
            [weakSelf.dataManager getDetailMakeupKindNetworkData:model.materialType kind:model.kind page:model.requestPageNum pageSize:10 completeBlock:^(int responsePageSize) {
                NvMakeupToolModel *totalEffect = [self getTotalEffectModel];
                if (totalEffect && totalEffect.effectContent.makeup.count > 0) {
                    for (NvMakeupCellModel *item in model.contents) {
                        NvMakeupContentModel *customM = (NvMakeupContentModel *)item.makeup;
                        [weakSelf checkAndResetValuesInCustomModel:customM];
                        item.selected = customM.selected;
                        if (item.selected) {
                            weakSelf.currentMakeupCustomModel = customM;
                        }
                        
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (weakSelf.currentMakeupCustomModel.effectContent.makeup.count > 0 && weakSelf.currentMakeupCustomModel.effectContent.makeup[0].makeupRecommendColors.count > 0) {
                            [weakSelf hiddenColorRelatedViews:NO];
                        }else{
                            [weakSelf hiddenColorRelatedViews:YES];
                        }
                        [weakSelf setMakeupTopViewState];
                    });
                    
                }
                [weakSelf.makeupCollectionView.mj_trailer endRefreshing];
                [weakSelf.makeupCollectionView reloadData];
            } failureBlock:^{
                model.requestPageNum--;
                [weakSelf.makeupCollectionView.mj_trailer endRefreshing];
            }];
        }else {
            [weakSelf.dataManager getVariableMakeupNetworkData:model.requestPageNum pageSize:10 completeBlock:^(int responsePageSize) {
                [weakSelf checkAndResetStateInVariableModel:model];
                [weakSelf.makeupCollectionView.mj_trailer endRefreshing];
                [weakSelf.makeupCollectionView reloadData];
            } failureBlock:^{
                model.requestPageNum--;
                [weakSelf.makeupCollectionView.mj_trailer endRefreshing];
            }];
        }
    }];
    trailer.arrowView.hidden = YES;
    self.makeupCollectionView.mj_trailer = trailer;
    [self layoutIfNeeded];
    [self addTabView];
    self.tabView.hidden = YES;
    [self addColorView];
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
    CGFloat topViewHeight = 100 * SCREENSCALE;
    int i = 0;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:@"Nv_custom_colorSelected"] forState:UIControlStateNormal];
    button.tag = i;
    button.frame =CGRectMake(xValue,topViewHeight - 35*SCREENSCALE*(i+1) - 7.5*SCREENSCALE*(i+1) - 7*SCREENSCALE*i, 35*SCREENSCALE, 35*SCREENSCALE);
    button.layer.cornerRadius = 17.5*SCREENSCALE;
    [button addTarget:self action:@selector(colorButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:button];
    [self.buttonArrs addObject:button];

    
    /*
     自定义颜色slider
     Custom color slider
     */
    CGFloat sep = 83*SCREENSCALE;
    CGFloat sliderY = topViewHeight - 31*SCREENSCALE;
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
    
    
    self.editMakeupSlider = [NvMakeupSlider new];
    self.editMakeupSlider.frame = CGRectMake(sep, sliderY - 25*SCREENSCALE - 16*SCREENSCALE - 25*SCREENSCALE - 16*SCREENSCALE, SCREENWIDTH - 2*sep, 25*SCREENSCALE);
    self.editMakeupSlider.delegate = self;
    self.editMakeupSlider.minValue = 0;
    self.editMakeupSlider.maxValue = 100;
    self.editMakeupSlider.hiddenIndicatorView = YES;
    [self.topView addSubview:self.editMakeupSlider];

    [self.customSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.topView.mas_bottom);
        make.left.mas_equalTo(self.topView).offset(sep);
        make.width.mas_equalTo(SCREENWIDTH - 2*sep);
        make.height.mas_equalTo(31*SCREENSCALE);
    }];
    
    [self.makeupInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.customSlider.mas_top).offset(-10.0 * SCREENSCALE);
        make.left.mas_equalTo(self.topView).offset((SCREENWIDTH - infoViewWidth)/2);
        make.width.mas_equalTo(infoViewWidth);
        make.height.mas_equalTo(25*SCREENSCALE);
    }];
    
    [self.editMakeupSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.makeupInfoView.mas_top).offset(-10.0 * SCREENSCALE);
        make.left.mas_equalTo(self.topView).offset(sep);
        make.width.mas_equalTo(SCREENWIDTH - 2*sep);
        make.height.mas_equalTo(25*SCREENSCALE);
    }];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.topView).offset(-15.0 * SCREENSCALE);
        make.centerY.mas_equalTo(self.makeupInfoView);
        make.width.mas_equalTo(35*SCREENSCALE);
        make.height.mas_equalTo(35*SCREENSCALE);
    }];
    
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
    self.tabView = [[CQMenuTabView alloc] initWithFrame:CGRectMake(15*SCREENSCALE, 104*SCREENSCALE, SCREENWIDTH-30*SCREENSCALE, 25*SCREENSCALE)];
    self.tabView.layer.masksToBounds = YES;
    self.tabView.titleFont = [UIFont systemFontOfSize:12*SCREENSCALE];
    self.tabView.normaTitleColor = [UIColor nv_colorWithHexString:@"#707070"];
    self.tabView.didSelctTitleColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    self.tabView.showCursor = YES;
    self.tabView.normaTitleColor = self.functionUse == NvEditMakeUpFunctionEdit ?  [UIColor whiteColor] : [UIColor blackColor];
    self.tabView.cursorStyle = CQTabCursorUnderneath;
    self.tabView.layoutStyle = CQTabWrapContent;
    self.tabView.cursorView.backgroundColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    self.tabView.cursorWidth = 12*SCREENSCALE;
    self.tabView.speaceWidth = 15.0*SCREENSCALE;
    __weak typeof(self)weakSelf = self;
    self.tabView.didTapItemAtIndexBlock = ^(UIView *view, NSInteger index) {
        [weakSelf selectTab:index];
    };
    [self.bottomView addSubview:self.tabView];
    
}

#pragma mark ------
- (void)selectTab:(NSInteger)index {
    if (self.dataManager.kindArr.count == 0 || self.dataManager.kindArr.count <= index) {
        return;
    }
    self.selectedTagIndex = index;
    
    self.makeupLastKey = [NSString stringWithFormat:@"%ld", (long)index];
    NvMakeupLevelModel *levelModel = self.dataManager.kindArr[index];
    self.currentMakeupLevelModel = levelModel;
    
    if(index > 0) {
        //单妆 monomakeup
        if(levelModel.contents.count>0){
            if (self.currentMakeupLevelModel.contents.count > 0) {
                for (NvMakeupCellModel *model in self.currentMakeupLevelModel.contents) {
                    NvMakeupContentModel *customM = (NvMakeupContentModel *)model.makeup;
                    [self checkAndResetValuesInCustomModel:customM];
                    model.selected = customM.selected;
                    if (model.selected) {
                        self.currentMakeupCustomModel = customM;
                    }
                }
                if (self.currentMakeupCustomModel.effectContent.makeup.count > 0 && self.currentMakeupCustomModel.effectContent.makeup[0].makeupRecommendColors.count > 0) {
                    [self hiddenColorRelatedViews:NO];
                }else{
                    [self hiddenColorRelatedViews:YES];
                }
            }
            [self.makeupCollectionView reloadData];
            //配置topView Configuring topView
            [self setMakeupTopViewState];
        }else {
            __weak typeof(self)weakSelf = self;
            [self.dataManager getDetailMakeupKindData:levelModel completeBlock:^{
                [weakSelf resetSingleEffectStateAfterSelectVariableEffect];
                [weakSelf.makeupCollectionView reloadData];
                
                if (weakSelf.currentMakeupLevelModel.contents.count > 0) {
                    for (NvMakeupCellModel *model in weakSelf.currentMakeupLevelModel.contents) {
                        NvMakeupContentModel *customM = (NvMakeupContentModel *)model.makeup;
                        [weakSelf checkAndResetValuesInCustomModel:customM];
                        if(![customM isMemberOfClass:[NvMakeupContentModel class]]) {
                            continue;
                        }
                        model.selected = customM.selected;
                        if (model.selected) {
                            weakSelf.currentMakeupCustomModel = customM;
                        }
                    }
                    if (weakSelf.currentMakeupCustomModel.effectContent.makeup.count > 0 && weakSelf.currentMakeupCustomModel.effectContent.makeup[0].makeupRecommendColors.count > 0) {
                        [weakSelf hiddenColorRelatedViews:NO];
                    }else{
                        [weakSelf hiddenColorRelatedViews:YES];
                    }
                }
                //配置topView Configuring topView
                [weakSelf setMakeupTopViewState];
            }];
        }
        
    }else{
        //整妆 Complete makeup
        [self resetSingleEffectStateAfterSelectVariableEffect];
        [self.makeupCollectionView reloadData];
        self.currentMakeupCustomModel = nil;
        
        //配置topView Configuring topView
        [self setMakeupTopViewState];
    }

}

- (NvMakeupToolModel *)getTotalEffectModel {
    if ([self.delegate respondsToSelector:@selector(nvEditMakeUpViewGetCurrentMakeupTotalModel:)]) {
        NvMakeupToolModel *totalEffect = [self.delegate nvEditMakeUpViewGetCurrentMakeupTotalModel:self];
        if (!self.currentMakeupVariableModel && totalEffect.uuid.length > 0) {
            self.currentMakeupVariableModel = totalEffect;
        }
        return totalEffect;
    }
    return nil;
}

- (void)checkAndResetStateInVariableModel:(NvMakeupLevelModel *)levelModel {
    NvMakeupToolModel *totalEffect = [self getTotalEffectModel];
    if (totalEffect) {
        for(NvMakeupCellModel *item in levelModel.contents){
            NvMakeupToolModel *variableM = (NvMakeupToolModel *)item.makeup;
            if ([variableM.uuid isEqualToString:totalEffect.uuid]) {
                item.selected = YES;
                self.currentMakeupVariableModel = variableM;
            }else {
                item.selected = NO;
            }
        }
    }
}

- (void)checkAndResetValuesInCustomModel:(NvMakeupContentModel *)model {
    NvMakeupToolModel *totalEffect = [self getTotalEffectModel];
    [self checkAndResetValuesInCustomModel:model referenceModel:totalEffect];
}

- (void)checkAndResetValuesInCustomModel:(NvMakeupContentModel *)model referenceModel:(NvMakeupToolModel *)referenceModel {
    if (!model.effectContent.makeup || model.effectContent.makeup.count == 0 || !referenceModel.effectContent.makeup || referenceModel.effectContent.makeup.count == 0) {
        return;
    }
    NvMakeupEffectContentModel *makeup = model.effectContent.makeup[0];
    for(NvMakeupToolEffectModel *effect in referenceModel.effectContent.makeup) {
        if ([effect.type isEqualToString:makeup.makeupId]) {
            model.selected = NO;
            BOOL findIt = NO;
            for(NvMakeupToolElementModel *element in effect.params) {
                if([element isKindOfClass:[NvMakeupToolElementStringModel class]]) {
                    NvMakeupToolElementStringModel *uuidModel = (NvMakeupToolElementStringModel *)element;
                    if ([uuidModel.value isEqualToString:makeup.uuid]) {
                        findIt = YES;
                        break;
                    }
                }
            }
            if (!findIt) {
                continue;
            }
            for(NvMakeupToolElementModel *element in effect.params) {
                if ([element isKindOfClass:[NvMakeupToolElementFloatModel class]] && [element.key containsString:@"Intensity"]) {
                    //强度 strength
                    NvMakeupToolElementFloatModel *intensityModel = (NvMakeupToolElementFloatModel *)element;
                    makeup.intensity = intensityModel.value;
                }else if ([element isKindOfClass:[NvMakeupToolElementColorModel class]] && [element.key containsString:@"Color"]) {
                    //颜色 color
                    NvMakeupToolElementColorModel *colorModel = (NvMakeupToolElementColorModel *)element;
                    if (colorModel.r == 0 && colorModel.g == 0 && colorModel.b == 0 && colorModel.a == 0) {
                        continue;
                    }
                    makeup.color = [NSString stringWithFormat:@"%f,%f,%f,%f", colorModel.r,colorModel.g,colorModel.b,colorModel.a];
                }
            }
            model.selected = YES;
            break;
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
        self.editMakeupSlider.value = makeupContentModel.effectContent.makeup[0].intensity*100;
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
        }else {
            self.makeupInfoColorValue = @"";
        }
        
        self.makeupInfoAlpha = self.editMakeupSlider.value;
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
    NSMutableArray <NvMakeupEffectContentModel *>*makeup = self.currentMakeupCustomModel.effectContent.makeup;
    NSArray <NvMakeupRecommendModel *>*makeupRecommendColors = makeup[0].makeupRecommendColors;
    if (makeupRecommendColors.count > index) {
        self.currentMakeupCustomModel.selectedColorStr = makeupRecommendColors[index].makeupColor;
        NvsColor color = [self nvsColorWithValue:makeupRecommendColors[index].makeupColor];
        self.makeupInfoColorValue = [NvUtils colorStringInRGBAModeWithRGB:color];
        makeup[0].color = [NSString stringWithFormat:@"%f,%f,%f,%f", color.r,color.g,color.b,color.a];
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

#pragma mark - 是否可替换 Replaceable or not
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
    NvMakeupToolModel *downloadModel;
    cellModel.selected = YES;
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
        //整妆 Complete makeup
        self.currentMakeupCustomModel = nil;
        self.currentMakeupVariableModel = (NvMakeupToolModel *)cellModel.makeup;
        downloadModel = (NvMakeupToolModel *)cellModel.makeup;
    }
    self.selectedCellModel = cellModel;
    [self.dataManager downloadAndProcessMakeupPackage:downloadModel variable:variable completeBlock:^{
        if(variable && [self.delegate respondsToSelector:@selector(nvEditMakeUpView:applyVariableMakeupEffect:)]) {
            [self.delegate nvEditMakeUpView:self applyVariableMakeupEffect:downloadModel.packagePath];
        }else if(!variable && [self.delegate respondsToSelector:@selector(nvEditMakeUpView:applySingleKindMakeupEffect:)]){
            [self.delegate nvEditMakeUpView:self applySingleKindMakeupEffect:self.currentMakeupCustomModel.effectContent];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!variable && self.currentMakeupCustomModel.effectContent.makeup.count > 0 && self.currentMakeupCustomModel.effectContent.makeup[0].makeupRecommendColors.count > 0) {
                [weakSelf hiddenColorRelatedViews:NO];
            }else{
                [weakSelf hiddenColorRelatedViews:YES];
            }
            [weakSelf resetMakeupSelectedState:cellModel];
            [weakSelf.makeupCollectionView reloadData];
        });
    }];
}

#pragma mark - 处理整妆中的美颜效果
/*
 处理整妆中的美颜效果
 Deal with the beauty effect in the makeup
 
 @param effectModel 美妆数据 makeup data
 */
- (void)processBeautyEffectInMakeup:(NvMakeupEffectModel *)effectModel {
    if ([self.delegate respondsToSelector:@selector(nvEditMakeUpView:applyMakeupBeautyEffect:)]) {
        [self.delegate nvEditMakeUpView:self applyMakeupBeautyEffect:effectModel];
    }
}

#pragma mark - 处理整妆中的美型效果
/*
 处理整妆中的美颜效果
 Deal with the beauty effect in the makeup
 
 @param effectModel 美妆数据 makeup data
 */
- (void)processBeautyTypeEffectInMakeup:(NvMakeupEffectModel *)effectModel {
    if ([self.delegate respondsToSelector:@selector(nvEditMakeUpView:applyMakeupBeautyTypeEffect:)]) {
        [self.delegate nvEditMakeUpView:self applyMakeupBeautyTypeEffect:effectModel];
    }
}

#pragma mark - 处理美妆中的微整型效果
/*
 处理美妆中的微整型效果
 Processing microShape effects in beauty
 
 @param effectModel 美妆数据 makeup data
 */
- (void)processMicroShapeEffectInMakeup:(NvMakeupEffectModel *)effectModel {
    if ([self.delegate respondsToSelector:@selector(nvEditMakeUpView:applyMakeupMicroShapeEffect:)]) {
        [self.delegate nvEditMakeUpView:self applyMakeupMicroShapeEffect:effectModel];
    }
}

#pragma mark - 处理美妆中的滤镜效果
/*
 处理美妆中的滤镜效果
 Processing filter effects in beauty
 
 @param effectModel 美妆数据 makeup data
 */
- (void)processFilterEffectInMakeup:(NvMakeupEffectModel *)effectModel {
    if ([self.delegate respondsToSelector:@selector(nvEditMakeUpView:applyMakeupFilterEffect:)]) {
        [self.delegate nvEditMakeUpView:self applyMakeupFilterEffect:effectModel];
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

#pragma mark - 应用美妆效果(美妆及滤镜)
//Apply Makeup Effects (Makeup and Filters)
- (void)applyMakeupPackage:(NvMakeupEffectModel *)effectModel {
    if([self.delegate respondsToSelector:@selector(nvEditMakeUpView:applySingleKindMakeupEffect:)]){
        [self.delegate nvEditMakeUpView:self applySingleKindMakeupEffect:effectModel];
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
-(void)sliderValueChanged:(UISlider *)paramSender{
    [self makeupItensityChanged:paramSender.value];
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

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentMakeupLevelModel.contents.count;
 
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvEditMakeUpCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvEditMakeUpCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.currentMakeupLevelModel.contents[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedTagIndex > 0 && self.currentMakeupVariableModel) {
        //已经应用妆容的情况下点击单妆需要判断是否是可替换单妆
        //When the makeup is applied, you need to determine if it is replaceable
        NvMakeupCellModel *cellModel = self.currentMakeupLevelModel.contents[indexPath.item];
        NvMakeupContentModel *contentModel = (NvMakeupContentModel *)cellModel.makeup;
        NSString *makeupId = contentModel.effectContent.makeupId.length > 0 ? contentModel.effectContent.makeupId : contentModel.effectContent.makeup[0].makeupId;
        BOOL canReplace = [self canReplace:makeupId appliedMakeupEffect:self.currentMakeupVariableModel];
        if (!canReplace) {
            if([self.delegate respondsToSelector:@selector(nvEditMakeUpView:forbiddenReplaceMakeupEffect:)]) {
                [self.delegate nvEditMakeUpView:self forbiddenReplaceMakeupEffect:contentModel.effectContent];
            }
            return;
        }
    }
    
    for (NvMakeupCellModel *model in self.currentMakeupLevelModel.contents) {
        model.selected = NO;
    }
    if(indexPath.item > 0){
        NvMakeupCellModel *selectModel = self.currentMakeupLevelModel.contents[indexPath.item];
        selectModel.selected = YES;
    }
    
    self.isApplicationMakeup = NO;

    
    [self selectMakeupCollectionViewWithIndex:indexPath];
    [collectionView reloadData];
}

#pragma mark - get && set
- (UICollectionView *)makeupCollectionView {
    if (!_makeupCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(57.5*SCREENSCALE, 92*SCREENSCALE);
        layout.minimumLineSpacing = 5 * SCREENSCALE;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 15*SCREENSCALE, 0, 15*SCREENSCALE);
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

- (void)setSelectedTagIndex:(NSInteger)selectedTagIndex {
    _selectedTagIndex = selectedTagIndex;
    self.dataManager.selectedTagIndex = selectedTagIndex;
}

- (void)setHasNetwork:(BOOL)hasNetwork {
    _hasNetwork = hasNetwork;
    self.dataManager.hasNetwork = hasNetwork;
}

#pragma mark - hitTest
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if (self.topView.hidden) {
        return [super hitTest:point withEvent:event];
    }
    for (UIView *subView in self.topView.subviews)
    {
        
        CGPoint coverPoint = [subView convertPoint:point fromView:self];
        
        UIView *hitTestView = [subView hitTest:coverPoint withEvent:event];
        if (hitTestView)
        {
            return hitTestView;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

@end
