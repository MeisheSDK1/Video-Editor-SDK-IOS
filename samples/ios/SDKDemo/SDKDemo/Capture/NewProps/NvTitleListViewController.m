//
//  NvTitleListViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/16.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvTitleListViewController.h"
#import <JXPagingView/JXPagerView.h>
#import <JXCategoryView/JXCategoryView.h>
#import <JXCategoryView/JXCategoryTitleImageCell.h>
#import <NvSDKCommon/NvAssetManager.h>
#import <NvSDKCommon/NvHttpRequest.h>
#import <NvSDKCommon/NvSDKUtils.h>
#import "NvListCategoryModel.h"
#import "NvListSearchViewController.h"
#import "NvTitleListDataManger.h"
#import "NvStickerCustomViewController.h"

@interface NvTitleListViewController ()<JXCategoryListContainerViewDelegate, JXCategoryViewDelegate,NvAssetManagerDelegate,NvFilterListViewControllerDelegate,NvListSearchViewControllerDelegate,NvStickerCustomViewControllerDelegate>

@property (nonatomic, strong) JXCategoryTitleImageView *titleView;
@property (nonatomic, strong) JXCategoryListContainerView *listContainerView;
@property (nonatomic, strong) NvAssetManager *assetManager;
@property (nonatomic, strong) NSMutableArray *listCategoryArray;
@property (nonatomic, assign) NSInteger currentSelectedIndex;

@property (nonatomic, strong) UIButton *cancelEffectsBtn;
@property (nonatomic, copy) NSString *defaultFilter;
@property (nonatomic, assign) NSInteger destinationChangeIndex;

@property (nonatomic, strong) UIView *lineView;
@end

@implementation NvTitleListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self setupUI];
    [self loadCategtoy];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewAppearOrDisappear:(BOOL)show{
    if (show) {
        [self addNotification];
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    }
}

#pragma mark -- 添加主视图 Add master view
- (void)setupUI{
    CGFloat cancelWidth = 18*SCREENSCALE;
    CGFloat cancelLeft = 15*SCREENSCALE;
    if (self.type == ASSET_COMPOUND_CAPTION || self.type == ASSET_ANIMATED_STICKER) {
        cancelWidth = 0;
        cancelLeft = 0;
    }
    
    [self.view addSubview:self.cancelEffectsBtn];
    [self.cancelEffectsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(cancelLeft);
        make.top.equalTo(self.view).offset(14*SCREENSCALE);
        make.width.height.mas_equalTo(cancelWidth);
    }];
    
    [self.view addSubview:self.titleView];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.cancelEffectsBtn.mas_right).offset(20*SCREENSCALE);
        make.right.equalTo(self.view).offset(0);
        make.top.equalTo(self.view).offset(10*SCREENSCALE);
        make.height.mas_equalTo(30);
    }];
    
    [self.view addSubview:self.listContainerView];
    [self.listContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(0);
    }];
    
    self.titleView.titleColor = [UIColor nv_colorWithHexRGB:@"#888888"];
    self.titleView.titleSelectedColor = [UIColor nv_colorWithHexRGB:@"#1C1C1C"];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#1C1C1C"];
    [self.titleView.collectionView addSubview:self.lineView];
    
    [self.cancelEffectsBtn setBackgroundImage:[UIImage imageNamed:@"NvListNOEffectNew"] forState:UIControlStateNormal];
}

#pragma mark -- 获取分类 Acquisition classification
- (void)loadCategtoy{
    self.listCategoryArray = [NSMutableArray array];
    
    self.assetManager = [NvAssetManager sharedInstance];
    self.assetManager.delegate = self;
    
    __weak typeof(self)weakSelf = self;
    
    NSMutableArray *titleCategoryArray = [NSMutableArray array];
    NSMutableArray *coverCategoryArray = [NSMutableArray array];
    NSMutableArray *coverSelectCategoryArray = [NSMutableArray array];
    
    NSInteger CategoryWithType = 0;
    NSString *categorys = @"";
    
    switch (self.type) {
        case ASSET_FILTER:{
            CategoryWithType = 2;
            categorys = @"1,2";
            [self searchAssemblyModel:categorys];
        }
            break;
        case ASSET_ARSCENE:{
            CategoryWithType = 14;
            categorys = @"";
            [self searchAssemblyModel:categorys];
        }
            break;
        case ASSET_ANIMATED_STICKER:{
            CategoryWithType = 4;
            categorys = @"1,2";
            
            [self searchAssemblyModel:categorys];
        }
            break;
        case ASSET_COMPOUND_CAPTION:{
            CategoryWithType = 15;
            categorys = @"";
            
            [self searchAssemblyModel:categorys];
        }
            break;
            
        default:
            break;
    }
    
    [self createLocalMaterialCategorys];
    
    [NvHttpRequest RequestListCategoryWithType:CategoryWithType category:categorys sdkVersion:[NvSDKUtils getSDKVersion] page:0 pageSize:100 completionBlock:^(id respondData) {
        NSArray *array = [NSArray yy_modelArrayWithClass:NvListCategoryModel.class json:respondData];
        [weakSelf.listCategoryArray addObjectsFromArray:array];
        
        if (self.type == ASSET_ANIMATED_STICKER) {
            [self JJhAssemblyCustomModel:nil];
        }
        for (int i = 0; i < weakSelf.listCategoryArray.count; i++) {
            NvListCategoryModel *listCategoryModel = weakSelf.listCategoryArray[i];
            if ([NvUtils currentLanguagesIsChinese]) {
                [titleCategoryArray addObject:listCategoryModel.displayNameZhCn];
            }else {
                [titleCategoryArray addObject:listCategoryModel.displayName];
            }
            
            if (listCategoryModel.selectedNoCover && listCategoryModel.selectedNoCover.length > 0) {
                [coverCategoryArray addObject:listCategoryModel.selectedNoCover];
            }else{
                [coverCategoryArray addObject:@""];
            }
            if (listCategoryModel.selectedCover && listCategoryModel.selectedCover.length > 0) {
                [coverSelectCategoryArray addObject:listCategoryModel.selectedCover];
            }else{
                [coverSelectCategoryArray addObject:@""];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.titleView setDefaultSelectedIndex:1];
            weakSelf.titleView.titles = titleCategoryArray;
            weakSelf.titleView.imageNames = coverCategoryArray;
            weakSelf.titleView.selectedImageNames = coverSelectCategoryArray;
            [weakSelf.titleView reloadData];
            
            weakSelf.currentSelectedIndex = weakSelf.titleView.selectedIndex;
            
            [weakSelf categoryViewLineSelectedState:weakSelf.titleView.selectedIndex];
        });
        
        NSLog(@"respondData================%@",array);
    } failureBlock:^(NSError *error) {
        NSLog(@"error=============== %@",error);
    }];
}

#pragma mark - 创建本地素材分类 Create a local material category
- (void)createLocalMaterialCategorys{
    NSString *string = @"";
    switch (self.type) {
        case ASSET_FILTER:
            string = @"filter";
            break;
        case ASSET_ARSCENE:
            string = @"props";
            break;
        case ASSET_ANIMATED_STICKER:
            string = @"stickers";
            break;
        case ASSET_COMPOUND_CAPTION:
            string = @"compoundCaption";
            break;
            
        default:
            break;
    }
    
    if (string) {
        string = [VIDEO_PATH(@"LocalAssets") stringByAppendingPathComponent:string];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *array = [fileManager contentsOfDirectoryAtPath:string error:nil];
        if (array && array.count > 0) {
            NvListCategoryModel *model = NvListCategoryModel.new;
            model.displayName = @"";
            model.displayNameZhCn = @"本地";
            model.localMaterialPath = string;
            [self.listCategoryArray addObject:model];
        }
    }
}

- (void)JJhAssemblyCustomModel:(NSString *)categorys{
    NvListCategoryModel *model = NvListCategoryModel.new;
    model.selectedNoCover = @"";
    model.selectedCover = @"";
    model.displayName = NvLocalString(@"Custom", @"自定义");
    model.categoryList = categorys;
    model.displayNameZhCn = @"自定义";
    [self.listCategoryArray addObject:model];
}

#pragma mark - 组合搜索数据模型（搜索和全部，不是通过接口获取的是，本地组装的）
//Composite search data model (search and all, not retrieved through interfaces, are assembled locally)
- (void)searchAssemblyModel:(NSString *)categorys{
    NvListCategoryModel *model = NvListCategoryModel.new;
    model.categoryList = categorys;
    model.selectedCover = @"NvListSearchIconNew";
    model.selectedNoCover = model.selectedCover;
    model.displayName = @"";
    model.displayNameZhCn = @"";
    
    [self.listCategoryArray addObject:model];
}

#pragma mark - 组合全部数据模型（搜索和全部，不是通过接口获取的是，本地组装的）
//Combine all data models (searched and all, not retrieved via interfaces, are assembled locally)
- (void)allAssemblyModel:(NSString *)categorys{
    NvListCategoryModel *model = NvListCategoryModel.new;
    model.categoryList = categorys;
    model.displayName = @"";
    model.displayNameZhCn = @"全部";
    
    [self.listCategoryArray addObject:model];
}

#pragma mark - 取消特效 Cancel special effects
- (void)cancelEffectsBtnClick{
    [self cancelSearchResponder];
    [self selecteMaterial:@""];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(titleListVC:withApplyEffects:)]) {
        [self.delegate titleListVC:self withApplyEffects:nil];
    }
}

#pragma mark - 根据uuid选中素材 Select the material based on uuid
- (void)selecteMaterial:(NSString *)uuid{
    [NvTitleListDataManger standardDefaults].lastClickPackId = uuid;
    for (NSNumber *number in self.listContainerView.validListDict.allKeys) {
        if (number.integerValue == 0) {
            NvListSearchViewController *listSearchVC = (NvListSearchViewController *)self.listContainerView.validListDict[number];
            [listSearchVC UncheckStatus];
        }else if ([self.listContainerView.validListDict[number] isKindOfClass:NvStickerCustomViewController.class]){
            NvStickerCustomViewController *listVC = (NvStickerCustomViewController *)self.listContainerView.validListDict[number];
            [listVC UncheckStatus];
        } else{
            NvFilterListViewController *listVC = (NvFilterListViewController *)self.listContainerView.validListDict[number];
            [listVC UncheckStatus];
        }
    }
}

- (void)changeAsset:(NSString *)uuid withDestinationIndex:(NSInteger)index {
    if (self.listContainerView.validListDict.allKeys.count > 0) {
        for (NSNumber *number in self.listContainerView.validListDict.allKeys) {
            if (number.integerValue == 0 || [self.listContainerView.validListDict[number] isKindOfClass:NvStickerCustomViewController.class]) {
               
            } else{
                NvFilterListViewController *listVC = (NvFilterListViewController *)self.listContainerView.validListDict[number];
                [listVC changeAsset:uuid withDestinationIndex:index];
            }
        }
        
    }else {
        self.destinationChangeIndex = index;
        self.defaultFilter = uuid;
        return;
    }
    
}

#pragma mark - 取消搜索第一响应者 Cancel search for first responder
- (void)cancelSearchResponder{
    NvListSearchViewController *listSearchVC = (NvListSearchViewController *)self.listContainerView.validListDict[@(0)];
    listSearchVC.searchBar.firstResponder = NO;
}

#pragma mark -- JXCategoryListContainerViewDelegate
// 返回列表的数量 Returns the number of lists
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titleView.titles.count;
}

// 根据下标 index 返回对应遵守并实现 `JXCategoryListContentViewDelegate` 协议的列表实例
// According to the subscript index returns corresponding to observe and implement ` JXCategoryListContentViewDelegate ` agreement a list of examples
- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    NvListCategoryModel *model = self.listCategoryArray[index];
    if (index == 0) {
        NvListSearchViewController *vc = [[NvListSearchViewController alloc] init];
        vc.view.frame = CGRectMake(0, 0, SCREENWIDTH, listContainerView.height);
        vc.type = self.type;
        vc.delegate = self;
        vc.categoryId = 0;
        vc.kind = 0;
        vc.categoryList = model.categoryList;
        return vc;
    }else if(self.type == ASSET_ANIMATED_STICKER && [model.displayNameZhCn isEqualToString:@"自定义"]){
        NvStickerCustomViewController * vc = [[NvStickerCustomViewController alloc]init];
        vc.view.frame = CGRectMake(0, 0, SCREENWIDTH, listContainerView.height);
        vc.delegate = self;
        return vc;
    }
    NvFilterListViewController *vc = [[NvFilterListViewController alloc] init];
    vc.view.frame = CGRectMake(0, 0, SCREENWIDTH, listContainerView.height);
    vc.type = self.type;
    vc.delegate = self;
    vc.categoryId = model.category;
    vc.kind = model.kindID;
    vc.categoryList = model.categoryList;
    vc.localMaterialPath = model.localMaterialPath;
    [vc changeAsset:self.defaultFilter withDestinationIndex:self.destinationChangeIndex];
    return vc;
}

#pragma mark -- JXCategoryViewDelegate

- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    if (index != 0) {
        [self cancelSearchResponder];
    }
    
    [self categoryViewLineSelectedState:index];
}

- (void)categoryViewLineSelectedState:(NSInteger)index {
    if (index != 0) {
        self.lineView.hidden = NO;
        
        CGFloat cellWidth = [self.titleView preferredCellWidthAtIndex:index];
        
        CGRect cellFrame = [self.titleView getTargetCellFrame:index];
        
        CGFloat lineWidth = cellWidth - self.titleView.imageSize.width - self.titleView.titleImageSpacing;

        cellFrame = CGRectMake(cellFrame.origin.x+cellFrame.size.width - lineWidth + 4, cellFrame.origin.y+cellFrame.size.height - 1.5*SCREENSCALE, lineWidth - 8, 1.5*SCREENSCALE);
        self.lineView.frame = cellFrame;
    }else{
        self.lineView.hidden = YES;
    }
}

#pragma mark -- NvFilterListViewControllerDelegate
- (void)filterListVC:(NvFilterListViewController *)vc withApplyEffects:(NvBaseModel *)model{
    if (vc.type == ASSET_ANIMATED_STICKER) {
        [self titleListVC:self stickerAddWithBaseModel:model];
    }else{
        model.categoryId = vc.categoryId;
        model.kindId = vc.kind;
        [self useEffects:vc withModel:model];
    }
}

#pragma mark - NvListSearchViewControllerDelegate
- (void)listSearchListVC:(NvListSearchViewController *)vc withApplyEffects:(NvBaseModel *)model{
    if (vc.type == ASSET_ANIMATED_STICKER) {
        [self titleListVC:self stickerAddWithBaseModel:model];
    }else{
        [self useEffects:vc withModel:model];
    }
}

#pragma mark - 应用特效 Applied special effect
- (void)useEffects:(UIViewController *)vc withModel:(NvBaseModel *)model{
    for (NSNumber *number in self.listContainerView.validListDict.allKeys) {
        if (number.integerValue == 0) {
            NvListSearchViewController *listSearchVC = (NvListSearchViewController *)self.listContainerView.validListDict[number];
            if (![listSearchVC isEqual:vc]) {
                [listSearchVC UncheckStatus];
            }
        }else{
            NvFilterListViewController *listVC = (NvFilterListViewController *)self.listContainerView.validListDict[number];
            [listVC UncheckStatus];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(titleListVC:withApplyEffects:)]) {
        [self.delegate titleListVC:self withApplyEffects:model];
    }
}

#pragma -mark NvStickerCustomViewControllerDelegate
- (void)titleListVC:(NvTitleListViewController *)vc stickerAddWithBaseModel:(NvBaseModel *)model{
    for (NSNumber *number in self.listContainerView.validListDict.allKeys) {
        if (number.integerValue == 0) {
            NvListSearchViewController *listSearchVC = (NvListSearchViewController *)self.listContainerView.validListDict[number];
            if (![listSearchVC isEqual:vc]) {
                [listSearchVC UncheckStatus];
            }
        }else if (number.integerValue == self.listContainerView.validListDict.count-1) {
            NvStickerCustomViewController *listSearchVC = (NvStickerCustomViewController *)self.listContainerView.validListDict[number];
            if (![listSearchVC isEqual:vc]) {
                [listSearchVC UncheckStatus];
            }
        }else{
            NvFilterListViewController *listVC = (NvFilterListViewController *)self.listContainerView.validListDict[number];
            [listVC changeAsset:self.defaultFilter withDestinationIndex:self.destinationChangeIndex];
            [listVC UncheckStatus];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(titleListVC:stickerAddWithBaseModel:)]) {
        [self.delegate titleListVC:vc stickerAddWithBaseModel:model];
    }
}

- (void)NvStickerCustomViewControllerDelegateAddSticker:(NvStickerCustomViewController *)vc assetCellModel:(NvAssetCellModel *)model{
    if ([self.delegate respondsToSelector:@selector(titleListVC:stickerAddWithAssetCellModel:)]) {
        [self.delegate titleListVC:self stickerAddWithAssetCellModel:model];
    }
}
- (void)NvStickerCustomViewControllerDelegateAddCusstomSticker:(NvStickerCustomViewController *)vc{
    if (self.delegate && [self.delegate respondsToSelector:@selector(titleListVC:stickerAddCusstom:)]) {
        [self.delegate titleListVC:self stickerAddCusstom:nil];
    }
}
#pragma mark - 添加通知 Add notification
-(void)addNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideFrame:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillChangeFrame:(NSNotification *)notification{
    NSDictionary *userInfo = notification.userInfo;
    CGRect keyboardF = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect frame = self.view.frame;
    
    self.view.frame = CGRectMake(0, keyboardF.origin.y - CGRectGetMinY(self.listContainerView.frame) - 60*SCREENSCALE, frame.size.width, frame.size.height);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(titleListVC:withKeyboardShow:)]) {
        [self.delegate titleListVC:self withKeyboardShow:YES];
    }
}

-(void)keyboardWillHideFrame:(NSNotification *)notification{
    CGRect frame = self.view.frame;
    self.view.frame = CGRectMake(0, SCREENHEIGHT - frame.size.height, frame.size.width, frame.size.height);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(titleListVC:withKeyboardShow:)]) {
        [self.delegate titleListVC:self withKeyboardShow:NO];
    }
}

#pragma mark - lazy

- (UIButton *)cancelEffectsBtn{
    if (!_cancelEffectsBtn) {
        _cancelEffectsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelEffectsBtn setBackgroundImage:[UIImage imageNamed:@"NvListNOEffect"] forState:UIControlStateNormal];
        [_cancelEffectsBtn addTarget:self action:@selector(cancelEffectsBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelEffectsBtn;
}

- (JXCategoryTitleImageView *)titleView {
    if (!_titleView) {
        _titleView = [[JXCategoryTitleImageView alloc] init];
        _titleView.delegate = self;
        _titleView.titleColorGradientEnabled = YES;
        _titleView.averageCellSpacingEnabled = NO;
        _titleView.contentEdgeInsetLeft = 0;
        _titleView.contentEdgeInsetRight = 0;
        _titleView.titleFont = [UIFont systemFontOfSize:16 weight:UIFontWeightRegular];
        _titleView.cellSpacing = 0*SCREENSCALE;
        _titleView.titleSelectedColor = [UIColor nv_colorWithHexString:@"#55C4F9"];
        _titleView.titleColor = [UIColor nv_colorWithHexString:@"#A8A8A8"];
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

@end
