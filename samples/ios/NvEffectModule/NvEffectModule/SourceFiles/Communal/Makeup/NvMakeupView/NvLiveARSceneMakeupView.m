//
//  NvLiveARSceneMakeupView.m
//  NvARSceneFxModule
//
//  Created by ms20180425 on 2022/8/26.
//

#import "NvLiveARSceneMakeupView.h"
#import "NvLiveMenuTabView.h"
#import "NvLiveARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvLiveColor.h"
#import "NvLiveMakeupCollectionCell.h"
#import "NvLiveBeautySliderView.h"
#import "NvLiveAppEnv.h"
#import "NvLiveMakeupItemModel.h"

@interface NvLiveARSceneMakeupView () <UICollectionViewDelegate, UICollectionViewDataSource, NvLiveBeautySliderViewDelegate>

@property(nonatomic, strong) UIView *topView;
@property(nonatomic, strong) UIView *bottomView;
@property(nonatomic, strong) UICollectionView *makeupCollectionView;
@property(nonatomic, strong) NSMutableArray *makeupArray;
@property(nonatomic, strong) NvLiveMenuTabView *tabView;

@property(nonatomic, strong) NvLiveBeautySliderView *intensitySlider;

//当前美妆层级对应model
// Current makeup level corresponds to model
@property(nonatomic, strong) NvLiveMakeupItemModel *currentMakeupModel;
/// 当前界面选中具体美妆model
/// The current interface selects the specific beauty model
@property(nonatomic, strong) NvLiveMakeupItemModel *currentMakeupContentModel;

//选中tag item 的index 值
//Select the tag item's index value
@property(nonatomic, assign) NSInteger selectedTagIndex;

@end

@implementation NvLiveARSceneMakeupView

- (void)dealloc {
    NSLog(@"%s", __func__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.makeUpInfo = [NSMutableDictionary dictionary];
        self.backgroundColor = [UIColor clearColor];
        [self addSubviews];
    }
    return self;
}

#pragma mark - 添加子视图Adding subviews
- (void)addSubviews {
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = UIColor.clearColor;

    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];

    [self addSubview:self.topView];
    [self addSubview:self.bottomView];

    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.equalTo(self.mas_width);
        make.height.equalTo(@50);
    }];

//    self.intensitySlider = [NvLiveBeautySliderView new];
//    self.intensitySlider.hidden = YES;
//    self.intensitySlider.delegate = self;
//    self.intensitySlider.minValue = 0;
//    self.intensitySlider.maxValue = 1;
//    [self.topView addSubview:self.intensitySlider];
//    [self.intensitySlider mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * NvScreen(kScale));
//        make.centerX.equalTo(self.topView.mas_centerX);
//        make.width.offset(273 * NvScreen(kScale));
//        make.height.offset(30 * NvScreen(kScale));
//    }];

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.mas_width);
    }];

    [self.bottomView addSubview:self.makeupCollectionView];
    [self.makeupCollectionView registerClass:[NvLiveMakeupCollectionCell class] forCellWithReuseIdentifier:@"NvLiveMakeupCollectionCell"];
    [self.makeupCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top).offset(10 * NvScreen(kScale));
        make.left.equalTo(self.bottomView.mas_left);
        make.right.equalTo(self.bottomView.mas_right);
        make.height.offset(94 * NvScreen(kScale));
    }];

    [self addTabView];
}

- (void)addTabView {
    self.tabView = [[NvLiveMenuTabView alloc] initWithFrame:CGRectMake(15 * NvScreen(kScale), 104 * NvScreen(kScale), NvScreen(kWidth) - 30 * NvScreen(kScale), 25 * NvScreen(kScale))];
    self.tabView.layer.masksToBounds = YES;
    self.tabView.titleFont = [UIFont systemFontOfSize:12 * NvScreen(kScale)];
    self.tabView.normaTitleColor = [UIColor nv_colorWithHexString:@"#707070"];
    self.tabView.didSelctTitleColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    self.tabView.showCursor = YES;
    self.tabView.normaTitleColor = [UIColor blackColor];
    self.tabView.cursorStyle = CQTabCursorUnderneath;
    self.tabView.layoutStyle = CQTabWrapContent;
    self.tabView.cursorView.backgroundColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    self.tabView.cursorWidth = 12 * NvScreen(kScale);
    self.tabView.speaceWidth = 15.0 * NvScreen(kScale);
    __weak typeof(self) weakSelf = self;
    self.tabView.didTapItemAtIndexBlock = ^(UIView *view, NSInteger index) {
        [weakSelf selectTab:index];
    };
    [self.bottomView addSubview:self.tabView];
}

- (void)configData:(NSMutableArray *)array {
    self.makeupArray = [NSMutableArray array];
    [self.makeupArray addObjectsFromArray:array];

    self.currentMakeupModel = [self.makeupArray firstObject];
    self.intensitySlider.hidden = YES;
    for (NvLiveMakeupItemModel *item in self.currentMakeupModel.contents) {
        if (item.selected) {
            self.currentMakeupContentModel = item;
            self.intensitySlider.hidden = NO;
            self.intensitySlider.value = [_delegate nvMakeupView:self intensity:self.currentMakeupContentModel];
            break;
        }
    }

    NSMutableArray *titleArr = [NSMutableArray array];
    for (NvLiveMakeupItemModel *model in self.makeupArray) {
        NSString *title = [NvLiveARSceneUtils currentLanguagesIsChanese] ? model.displayNameZhCn : model.displayName;
        [titleArr addObject:title];
    }
    self.tabView.titles = [NSArray arrayWithArray:titleArr];
}

#pragma mark - 选中tabView 选项
- (void)selectTab:(NSInteger)index {
    self.selectedTagIndex = index;

    self.currentMakeupModel = self.makeupArray[index];
    self.currentMakeupContentModel = nil;
    if (self.currentMakeupModel.contents.count > 0) {
        for (NvLiveMakeupItemModel *model in self.currentMakeupModel.contents) {
            [self.delegate nvMakeupView:self refetchModel:model];
            if (model.selected) {
                self.currentMakeupContentModel = model;
            }
        }
    }
    if (index == 0 && self.currentMakeupContentModel) {
        self.intensitySlider.hidden = NO;
        self.intensitySlider.value = [_delegate nvMakeupView:self intensity:self.currentMakeupContentModel];
    } else {
        self.intensitySlider.hidden = YES;
    }
    [self.makeupCollectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentMakeupModel.contents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvLiveMakeupCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvLiveMakeupCollectionCell" forIndexPath:indexPath];
    [cell renderCellWithToolDataModel:self.currentMakeupModel.contents[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvLiveMakeupItemModel *model in self.currentMakeupModel.contents) {
        model.selected = NO;
    }

    self.currentMakeupContentModel = self.currentMakeupModel.contents[indexPath.item];
    [self.makeUpInfo setObject:self.currentMakeupContentModel forKey:@(self.selectedTagIndex)];
    self.currentMakeupContentModel.selected = YES;

    [self selectMakeupCollectionViewWithIndex:indexPath];
    self.intensitySlider.hidden = YES;
    if (indexPath.item > 0) {
        self.intensitySlider.hidden = NO;
        self.intensitySlider.value = [_delegate nvMakeupView:self intensity:self.currentMakeupContentModel];
    }
}

#pragma mark - 点击美妆collectionView
/*
 点击美妆collectionView
 Click on beauty collectionView
 
 @param indexPath 下标 index
 */
- (void)selectMakeupCollectionViewWithIndex:(NSIndexPath *)indexPath {
    BOOL variable = YES;
    if (self.selectedTagIndex > 0) {
        //单妆
        variable = NO;
    }
    if (variable && [self.delegate respondsToSelector:@selector(nvMakeupView:applyVariableMakeupEffect:)]) {
        [self.delegate nvMakeupView:self applyVariableMakeupEffect:self.currentMakeupContentModel];
    } else if (!variable && [self.delegate respondsToSelector:@selector(nvMakeupView:applySingleKindMakeupEffect:)]) {
        [self.delegate nvMakeupView:self applySingleKindMakeupEffect:self.currentMakeupContentModel];
    }

    [self.makeupCollectionView reloadData];
}

#pragma mark - get && set
- (UICollectionView *)makeupCollectionView {
    if (!_makeupCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(57.5 * NvScreen(kScale), 71.5 * NvScreen(kScale));
        layout.minimumLineSpacing = 5 * NvScreen(kScale);
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 15 * NvScreen(kScale), 0, 15 * NvScreen(kScale));
        _makeupCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
        _makeupCollectionView.delegate = self;
        _makeupCollectionView.dataSource = self;
        _makeupCollectionView.backgroundColor = [UIColor clearColor];
        _makeupCollectionView.showsHorizontalScrollIndicator = NO;
    }
    return _makeupCollectionView;
}

- (void)setSelectedTagIndex:(NSInteger)selectedTagIndex {
    _selectedTagIndex = selectedTagIndex;
}

// MARK: -- NvLiveBeautySliderViewDelegate
-(void)itemSlider:(NvLiveBeautySliderView*)slider valueChanged:(float)value{
    [_delegate nvMakeupView:self update:self.currentMakeupContentModel intensity:value];
}

@end
