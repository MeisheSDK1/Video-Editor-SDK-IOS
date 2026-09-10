//
//  NvFilterView.m
//  SDKDemo
//
//  Created by 美摄 on 2019/8/29.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvFilterView.h"
#import "NvCaptureFilterCell.h"
#import "NvFilterDataSource.h"
#import "NVDefineConfig.h"

@interface NvFilterView()

@end

@implementation NvFilterView

+(instancetype)filterViewWithAspectRatio:(AspectRatio)ratio delegate:(id<NvCaptureFilterViewDelegate>)delegate{
    NvFilterDataSource* dataSource = [[NvFilterDataSource alloc] initWithAspectRatio:ratio];
    NvFilterView* filterView = [[NvFilterView alloc] initWithDataSource:dataSource];
    filterView.delegate = delegate;
    return filterView;
}

+(instancetype)coverFilterViewWithAspectRatio:(AspectRatio)ratio delegate:(nullable id<NvCaptureFilterViewDelegate>)delegate{
    NvFilterDataSource* dataSource = [[NvFilterDataSource alloc] initWithBuiltinFilterAndAspectRatio:ratio];
    NvFilterView* filterView = [[NvFilterView alloc] initWithDataSource:dataSource];
    filterView.delegate = delegate;
    return filterView;
}

-(instancetype)initWithDataSource:(id<NvFilterViewDelegate>) dataSource{
    float height = 170;
    if(dataSource && [dataSource respondsToSelector:@selector(titlesForSections)]){
        height = 180;
    }
    if (![NvUtils currentLanguagesIsChinese]) {
        height += 25*SCREENSCALE;
    }
    self = [super initWithFrame:CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, height*SCREENSCALE+INDICATOR) HaveTopView:YES WithTopViewHeight:30 * SCREENSCALE withMore:YES withlayout:nil];
    if (self) {
        self.dataSource = dataSource;
        [self replaceTopViewAndSetupSegmentView];
    }
    return self;
}

-(void)reloadData{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(reloadData)]) {
        [self.dataSource reloadData];
    }
    [self.collectionView reloadData];
}

-(void)updateSelectedModelWithModel:(id)model{
    if ([model isKindOfClass:[NvTimeFilterInfoModel class]]) {
        NvTimeFilterInfoModel* filterInfo = (NvTimeFilterInfoModel*)model;
        if (filterInfo.name && ![filterInfo.name isEqualToString:@"无"]) {
            [self configSliderValue:filterInfo.strength withHidden:YES];
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(updateSelectedModelWithModel:)]) {
                [self.dataSource updateSelectedModelWithModel:model];
            }
            [self.collectionView reloadData];
        }
    }
}

-(void)reloadDataWithSelectedModel:(id)model{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(reloadData)]) {
        [self.dataSource reloadData];
    }
    [self updateSelectedModelWithModel:model];
}

#pragma mark - 视图的初始化，创建标签视图
/*
 视图的初始化，创建标签视图
 View initialization, create label view
 */
-(void)replaceTopViewAndSetupSegmentView{
    if (self.dataSource.numberOfSections>1) {
        if([self.collectionView.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]){
            UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
            layout.footerReferenceSize = CGSizeMake(30 * SCREENSCALE, 50 * SCREENSCALE);//
        }
        [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FilterCollectionViewFooter"];
        CGRect frame = self.bottomView.frame;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(didselectModelAtIndexPath:)]) {
            NSArray* titleArray = [self.dataSource titlesForSections];
            self.segView = [[NvFilterSegTitleView alloc] initWithFrame:CGRectMake(0, frame.origin.y + 5 * SCREENSCALE,CGRectGetWidth(self.frame), 35 * SCREENSCALE) titleArray:titleArray delegate:(id<NvFilterSegTitleViewDelegate>) self];
            self.segView.backgroundColor = self.bottomView.backgroundColor;
            [self addSubview:self.segView];
        }
        self.topView.frame = CGRectMake(0, self.topView.frame.origin.y, SCREENWIDTH, self.topView.frame.size.height);
        frame.origin.y+=40 * SCREENSCALE;
        frame.size.height -= 40 * SCREENSCALE;
        self.bottomView.frame = frame;
    }
}

#pragma mark - 设置选中的cell
/*
 设置选中的cell
 Set the selected cell
 
 @param index 选中的index
 Set the selected index
 */
-(void)didselectedIndex:(NSInteger)index{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:(UICollectionViewScrollPositionLeft) animated:YES];
}

#pragma mark - 设置背景颜色
/*
 设置背景颜色
 Set background color
 
 @param color 背景颜色
 background color
 */
- (void)backColor:(UIColor *)color{
    self.bottomView.backgroundColor = color;
    self.segView.backgroundColor = color;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfSections)]) {
        return [self.dataSource numberOfSections];
    }
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInSection:)]) {
        return [self.dataSource numberOfItemsInSection:section];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvCaptureFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCaptureFilterCell" forIndexPath:indexPath];
    cell.type = self.type;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(modelForIndexPath:)]) {
        NvBaseModel* model = [self.dataSource modelForIndexPath:indexPath];
        [cell renderCellWithModel:model];
    }
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
    }else if (kind == UICollectionElementKindSectionFooter) {
        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FilterCollectionViewFooter" forIndexPath:indexPath];
        NSInteger lineTag = 100001;
        UIView* lineView = [footerView viewWithTag:lineTag];
        if (!lineView) {
            lineView = [[UIView alloc] initWithFrame:CGRectMake(15 * SCREENSCALE, 5, 1, 40 * SCREENSCALE)];
            lineView.backgroundColor = [UIColor whiteColor];
            lineView.tag = lineTag;
            [footerView addSubview:lineView];
        }
        lineView.alpha = 0.3f;
        if (indexPath.section == (self.dataSource.numberOfSections-1)) {
            lineView.alpha = 0.f;
        }
        return footerView;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        [self.segView updateSelectedIndex:0];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    // 目前只有三个漫画 先用 3 Currently only three comics use 3 first
    if (indexPath.section == 0 && indexPath.row==3) {
        [self.segView updateSelectedIndex:1];
    }
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(didselectModelAtIndexPath:)]) {
        [self.dataSource didselectModelAtIndexPath:indexPath];
    }
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(modelForIndexPath:)]) {
        NvBaseModel* model = [self.dataSource modelForIndexPath:indexPath];
        if (indexPath.section == 0 && indexPath.row == 0) {
            if (self.topView) {
                self.topView.hidden = YES;
            }
        }else{
            if (self.topView) {
                self.topView.hidden = NO;
                self.strengthSlider.value = model.value;
            }
        }
        if (self.delegate&&[self.delegate respondsToSelector:@selector(NvCaptureFilterView:withFilterModel:)]) {
            [self.delegate NvCaptureFilterView:self withFilterModel:model];
        }
        [collectionView reloadData];
    }
}

- (void)setDefaultSelectedModel:(NvBaseModel *)model {
    [self.dataSource refreshSelectedModel:model];
    if (self.topView) {
        self.topView.hidden = NO;
        self.strengthSlider.value = model.value;
    }
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(NvCaptureFilterView:withFilterModel:)]) {
        [self.delegate NvCaptureFilterView:self withFilterModel:model];
    }
    [self.collectionView reloadData];
}

-(void)dealloc{
    NSLog(@"%s",__func__);
}

@end
