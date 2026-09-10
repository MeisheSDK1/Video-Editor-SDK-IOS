//
//  NvARSceneMakeupView.m
//  NvARSceneFxModule
//
//  Created by ms20180425 on 2022/8/26.
//

#import "NvARSceneMakeupView.h"
#import "CQMenuTabView.h"
#import "NvARSceneMacro.h"
#import "NvARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvColor.h"
#import "NvMakeupCell.h"

@interface NvARSceneMakeupView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UICollectionView *makeupCollectionView;
@property (nonatomic, strong) NSMutableArray *makeupArray;
@property (nonatomic, strong) CQMenuTabView *tabView;

//当前美妆层级对应model
// Current makeup level corresponds to model
@property (nonatomic, strong) NvMakeupToolDataModel *currentMakeupModel;
/// 当前界面选中具体美妆model
/// The current interface selects the specific beauty model
@property (nonatomic, strong) NvMakeupToolDataModel *currentMakeupContentModel;

//选中tag item 的index 值
//Select the tag item's index value
@property (nonatomic, assign) NSInteger selectedTagIndex;

@end

@implementation NvARSceneMakeupView

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
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
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = UIColor.clearColor;
    
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.equalTo(self.mas_width);
        make.height.offset(0 * SCREENSCALE);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.mas_width);
    }];
    
    [self.bottomView addSubview:self.makeupCollectionView];
    [self.makeupCollectionView registerClass:[NvMakeupCell class] forCellWithReuseIdentifier:@"NvMakeupCell"];
    [self.makeupCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top).offset(10 * SCREENSCALE);
        make.left.equalTo(self.bottomView.mas_left);
        make.right.equalTo(self.bottomView.mas_right);
        make.height.offset(94 * SCREENSCALE);
    }];

    [self addTabView];
}

- (void)addTabView {
    self.tabView = [[CQMenuTabView alloc] initWithFrame:CGRectMake(15*SCREENSCALE, 104*SCREENSCALE, SCREEN_WIDTH-30*SCREENSCALE, 25*SCREENSCALE)];
    self.tabView.layer.masksToBounds = YES;
    self.tabView.titleFont = [UIFont systemFontOfSize:12*SCREENSCALE];
    self.tabView.normaTitleColor = [UIColor nv_colorWithHexString:@"#707070"];
    self.tabView.didSelctTitleColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    self.tabView.showCursor = YES;
    self.tabView.normaTitleColor = [UIColor blackColor];
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

- (void)configData:(NSMutableArray *)array{
    self.makeupArray = [NSMutableArray array];
    [self.makeupArray addObjectsFromArray:array];
    
    self.currentMakeupModel = [self.makeupArray firstObject];
    
    NSMutableArray *titleArr = [NSMutableArray array];
    for (NvMakeupToolDataModel *model in self.makeupArray) {
        NSString *title = [NvARSceneUtils currentLanguagesIsChanese] ? model.displayNameZhCn : model.displayName;
        [titleArr addObject:title];
    }
    self.tabView.titles = [NSArray arrayWithArray:titleArr];
}

#pragma mark - 选中tabView 选项
- (void)selectTab:(NSInteger)index {
    self.selectedTagIndex = index;
    
    self.currentMakeupModel = self.makeupArray[index];
    
    [self.makeupCollectionView reloadData];
    if (self.currentMakeupModel.contents.count > 0) {
        for (NvMakeupToolDataModel *model in self.currentMakeupModel.contents) {
            if (model.selected) {
                self.currentMakeupContentModel = model;
                break;
            }
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentMakeupModel.contents.count;
 
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvMakeupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvMakeupCell" forIndexPath:indexPath];
    [cell renderCellWithToolDataModel:self.currentMakeupModel.contents[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvMakeupToolDataModel *model in self.currentMakeupModel.contents) {
        model.selected = NO;
    }
    
    self.currentMakeupContentModel = self.currentMakeupModel.contents[indexPath.item];
    [self.makeUpInfo setObject:self.currentMakeupContentModel forKey:@(self.selectedTagIndex)];
    if(indexPath.item > 0){
        self.currentMakeupContentModel.selected = YES;
    }
    
    [self selectMakeupCollectionViewWithIndex:indexPath];
}

#pragma mark - 点击美妆collectionView
/*
 点击美妆collectionView
 Click on beauty collectionView
 
 @param indexPath 下标 index
 */
- (void)selectMakeupCollectionViewWithIndex:(NSIndexPath *)indexPath
{
    BOOL variable = YES;
    if (self.selectedTagIndex > 0) {
        //单妆
        variable = NO;
    }
    if(variable && [self.delegate respondsToSelector:@selector(nvMakeupView:applyVariableMakeupEffect:)]) {
        [self.delegate nvMakeupView:self applyVariableMakeupEffect:self.currentMakeupContentModel];
    }else if(!variable && [self.delegate respondsToSelector:@selector(nvMakeupView:applySingleKindMakeupEffect:)]){
        [self.delegate nvMakeupView:self applySingleKindMakeupEffect:self.currentMakeupContentModel];
    }
    
    [self.makeupCollectionView reloadData];
}

#pragma mark - get && set
- (UICollectionView *)makeupCollectionView {
    if (!_makeupCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(57.5*SCREENSCALE, 71.5*SCREENSCALE);
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

- (void)setSelectedTagIndex:(NSInteger)selectedTagIndex {
    _selectedTagIndex = selectedTagIndex;
}

@end
