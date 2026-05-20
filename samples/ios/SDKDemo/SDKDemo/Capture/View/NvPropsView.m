//
//  NvPropsView.m
//  SDKDemo
//
//  Created by MS on 2020/7/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvPropsView.h"
#import "NVHeader.h"
#import "NvPropViewCell.h"
@interface NvPropsView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *titleButtonArr;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *categoryArr;
@property (nonatomic, strong) NvBaseModel *noneModel;
@property (nonatomic, assign) NSInteger currentCategory;
@end
@implementation NvPropsView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleButtonArr = [NSMutableArray array];
        self.dataArray = [NSMutableArray array];
        self.categoryArr = [NSMutableArray array];
        self.noneModel = [NvBaseModel new];
        [self addSubviews];
    }
    return self;
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubviews {
    CGFloat width = self.frame.size.width;
    CGFloat topHeight = 35*SCREENSCALE;
    CGFloat bottomViewHeight = self.frame.size.height - topHeight;
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, topHeight)];
    [self addSubview:self.topView];
    UIButton *moreB = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreB setBackgroundImage:NvImageNamed(@"Nv_capture_filter_more") forState:UIControlStateNormal];
    [moreB addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:moreB];
    [moreB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.topView.mas_centerY);
        make.left.equalTo(self.topView).offset(12 * SCREENSCALE);
        make.width.offset(32 * SCREENSCALE);
        make.height.offset(32 * SCREENSCALE);
    }];
    
    UIButton *noneB = [UIButton buttonWithType:UIButtonTypeCustom];
    [noneB setBackgroundImage:NvImageNamed(@"nv_capture_props_none") forState:UIControlStateNormal];
    [noneB addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    noneB.tag = 0;
    [self.topView addSubview:noneB];
    [noneB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(moreB.mas_centerY);
        make.left.equalTo(moreB.mas_right).offset(19 * SCREENSCALE);
        make.width.offset(17 * SCREENSCALE);
        make.height.offset(17 * SCREENSCALE);
    }];
    
    UIScrollView *topScrollView = [[UIScrollView alloc] init];
    topScrollView.showsHorizontalScrollIndicator = NO;
    topScrollView.contentSize = CGSizeMake(SCREENWIDTH*1.5, topHeight);
    [self.topView addSubview:topScrollView];
    [topScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_top);
        make.bottom.equalTo(self.topView.mas_bottom);
        make.left.equalTo(noneB.mas_right);
        make.right.equalTo(self.topView.mas_right);
    }];
    NSArray *titleArr = @[NvLocalString(@"All",@"全部"),@"3D",@"2D",NvLocalString(@"Foreground", @"前景"),NvLocalString(@"Head", @"头部"),NvLocalString(@"Big Eyes", @"眼部"),NvLocalString(@"Mouth", @"嘴部")];
    for (int i=0; i<titleArr.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:titleArr[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setContentMode:UIViewContentModeCenter];
        button.titleLabel.font = [NvUtils regularFontWithSize:13*SCREENSCALE] ;
        button.tag = i+1;
        [topScrollView addSubview:button];
        if (i==0) {
            [button setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
            self.currentCategory = 1;
        }
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView.mas_centerY);
            make.left.equalTo(topScrollView.mas_left).offset(32*SCREENSCALE*i + 11 * SCREENSCALE*(i+1));
            make.width.offset(28 * SCREENSCALE);
            make.height.offset(28 * SCREENSCALE);
        }];
        [button addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.titleButtonArr addObject:button];
    }
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, topHeight -1, width, 0.5)];
    lineView.backgroundColor = [UIColor nv_colorWithHexRGBA:@"#0000001E"];
    [self.topView addSubview:lineView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49*SCREENSCALE, 75*SCREENSCALE);
    layout.minimumLineSpacing = 10*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 12*SCREENSCALE, bottomViewHeight - 90*SCREENSCALE, 0);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,topHeight,width, bottomViewHeight) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[NvPropViewCell class] forCellWithReuseIdentifier:@"NvPropViewCell"];
    [self addSubview:self.collectionView];
}

#pragma mark - 更多按钮点击事件
/*
 更多按钮点击事件
 More button click events
 
 @param button 更多按钮
 More button
 */
- (void)moreClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(NvPropsView:moreClick:)]) {
        [self.delegate NvPropsView:self moreClick:button];
    }
}

#pragma mark - 标签按钮点击事件
/*
 标签按钮点击事件
 Label button click event
 
 @param button 按钮
 button
 */
- (void)titleButtonClicked:(UIButton *)button {
    NSInteger index = button.tag;
    self.currentCategory = index;
    if (index == 0) {
        for (NvBaseModel *model in self.dataArray) {
            model.selected = NO;
        }
        [self.collectionView reloadData];
        if ([self.delegate respondsToSelector:@selector(NvPropsView:withFilterModel:)]) {
            [self.delegate NvPropsView:self withFilterModel:self.noneModel];
        }
    }else{
        for (UIButton *btn in self.titleButtonArr) {
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        [button setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateNormal];
        [self setButtonSelected:button.tag];
    }
}

#pragma mark - 根据参数刷新界面数据
/*
 根据参数刷新界面数据
 Refresh the interface data according to the parameters
 
 @param index 标签下标
 Label subscript
 */
- (void)setButtonSelected:(NSInteger)index {
    [self.categoryArr removeAllObjects];
    if (index > 1) {
        NSInteger categoryId = [self getAdditionalCategoryId:index];
        for (NvBaseModel *model in self.dataArray) {
            if (model.categoryId == categoryId) {
                [self.categoryArr addObject:model];
            }
        }
    }else{
        self.categoryArr = [NSMutableArray arrayWithArray:self.dataArray];
    }
    [self.collectionView reloadData];
}

#pragma mark - 根据参数返回类别
/*
 根据参数返回类别
 Return categories based on parameters
 
 @param index 标签下标
 Label subscript
 
 return 返回NSInteger值。返回道具的类别
 Return to the category of the item
 */
- (NSInteger)getAdditionalCategoryId:(NSInteger)index {
    NSInteger categoryId = 0;
    switch (index) {
        case 2:
            categoryId = 2;
            break;
        case 3:
            categoryId = 1;
            break;
        case 4:
            categoryId = 3;
            break;
        case 5:
            categoryId = 7;
            break;
        case 6:
            categoryId = 5;
            break;
        case 7:
            categoryId = 6;
            break;
        default:
            break;
    }
    return categoryId;
}

#pragma mark 配置数据源,并且刷新视图 Configure the data source, and refresh the view
- (void)configDataSource:(NSMutableArray <NvBaseModel *>*)array {
    self.dataArray = [NSMutableArray arrayWithArray:array];
    [self setButtonSelected:self.currentCategory];
}

#pragma mark - 刷新视图
/*
 刷新视图
 Refresh view
 */
- (void)reloadDataSource{
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.categoryArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvPropViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvPropViewCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.categoryArr[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvBaseModel *model in self.dataArray) {
        model.selected = NO;
    }
    for (NvBaseModel *model in self.categoryArr) {
        model.selected = NO;
    }

    NvBaseModel *model = self.categoryArr[indexPath.item];
    for (NvBaseModel *models in self.dataArray) {
        if ([models.displayName isEqualToString:model.displayName]) {
            models.selected = YES;
            break;
        }
    }
    model.selected = YES;
    if ([self.delegate respondsToSelector:@selector(NvPropsView:withFilterModel:)]) {
        [self.delegate NvPropsView:self withFilterModel:model];
    }
    [collectionView reloadData];
}
@end
