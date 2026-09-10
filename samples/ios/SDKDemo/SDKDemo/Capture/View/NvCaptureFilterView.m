//
//  NvCaptureFilterView.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCaptureFilterView.h"
#import "NvHeader.h"
#import "NvCaptureFilterCell.h"

@interface NvCaptureFilterView()<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation NvCaptureFilterView

- (instancetype)initWithFrame:(CGRect)frame HaveTopView:(BOOL)haveTop WithTopViewHeight:(CGFloat)heightTop withMore:(BOOL)have withlayout:(UICollectionViewFlowLayout *)layout{
    self = [super initWithFrame:frame];
    if (self) {
        self.dataArray = [NSMutableArray array];
        self.backgroundColor = UIColor.clearColor;
        [self addSubviews:frame HaveTopView:haveTop WithTopViewHeight:heightTop withMore:have withlayout:layout];
    }
    return self;
}

#pragma mark 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubviews:(CGRect)rect HaveTopView:(BOOL)haveTop WithTopViewHeight:(CGFloat)heightTop withMore:(BOOL)have withlayout:(UICollectionViewFlowLayout *)layout{
    if (haveTop) {
        self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, rect.size.width, heightTop)];
        self.topView.hidden = YES;
        [self addSubview:self.topView];
        
        self.strengthSlider = [[UISlider alloc]init];
        [self.strengthSlider setMinimumValue:0.0];
        [self.strengthSlider setMaximumValue:1.0];
        self.strengthSlider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
        self.strengthSlider.maximumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
        [self.strengthSlider setThumbImage:NvImageNamed(@"NvsliderWhite") forState:UIControlStateNormal];
        [self.strengthSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self.topView addSubview:self.strengthSlider];
        [self.strengthSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView.mas_centerY);
            make.centerX.equalTo(self.topView.mas_centerX);
            make.width.offset(281 * SCREENSCALE);
        }];
        
    }else{
        heightTop = 0;
    }
    CGFloat bottomViewHeight = rect.size.height - heightTop;
    self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, heightTop, rect.size.width, bottomViewHeight)];
    self.bottomView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
    [self addSubview:self.bottomView];
    
    UIButton *moreB = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreB setImage:NvImageNamed(@"NvsFilterMore") forState:UIControlStateNormal];
    [moreB addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:moreB];
    CGSize moreBtnSize = CGSizeMake(35 * SCREENSCALE, 49 * SCREENSCALE);
    if (![NvUtils currentLanguagesIsChinese]) {
        moreBtnSize = CGSizeMake(61*SCREENSCALE, 75*SCREENSCALE);
    }
    [moreB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView).offset(5 * SCREENSCALE);
        make.left.equalTo(self.bottomView).offset(13 * SCREENSCALE);
        make.width.offset(moreBtnSize.width);
        make.height.offset(moreBtnSize.height);
    }];
    
    UILabel *moreL = [[UILabel alloc]init];
    moreL.text = NvLocalString(@"More", @"更多");
    moreL.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    moreL.font = [NvUtils regularFontWithSize:11];
    [self.bottomView addSubview:moreL];
    [moreL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(moreB.mas_bottom).offset(18 * SCREENSCALE);
        make.centerX.equalTo(moreB.mas_centerX);
        make.width.mas_lessThanOrEqualTo(moreB.mas_width);
    }];
    
    if (!have) {
        moreB.hidden = YES;
        moreL.hidden = YES;
    }
    
    if (!layout) {
        layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(49*SCREENSCALE, 86*SCREENSCALE);
        layout.minimumLineSpacing = 10*SCREENSCALE;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    if (![NvUtils currentLanguagesIsChinese]) {
        layout.itemSize = CGSizeMake(75*SCREENSCALE, 112*SCREENSCALE);
    }
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,rect.size.width, bottomViewHeight) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[NvCaptureFilterCell class] forCellWithReuseIdentifier:@"NvCaptureFilterCell"];
    [self.bottomView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top).offset(5 * SCREENSCALE);
        if (have) {
            make.left.equalTo(moreB.mas_right).offset(15 * SCREENSCALE);
        }else{
            make.left.equalTo(self.bottomView);
        }
        make.right.equalTo(self.bottomView.mas_right);
        make.height.offset(layout.itemSize.height + 1);
    }];
}

#pragma mark - moreClick点击事件
/*
 moreClick点击事件
 moreClick click event
 
 @param sender 更多按钮
 More buttons
 
 */
- (void)moreClick:(UIButton *)sender{
    [self.delegate NvCaptureFilterView:self moreClick:sender];
}

#pragma mark - 滤镜强度调节
/*
 滤镜强度调节
 Filter intensity adjustment
 
 @param slider 滑杆 slider
 */
- (void)sliderValueChanged:(UISlider *)slider{
    [self.delegate NvCaptureFilterView:self sliderValueChanged:slider];
}

#pragma mark - 配置数据源,并且刷新视图 Configure the data source, and refresh the view
- (void)configDataSource:(NSMutableArray *)array{
    self.dataArray = array;
    [self reloadDataSource];
}

#pragma mark - 更新数据源，不刷新视图 Update the data source without refreshing the view
- (void)updateDataSource:(NSMutableArray *)array{
    self.dataArray = array;
}

#pragma mark - 刷新视图 Refresh view
- (void)reloadDataSource{
    [self.collectionView reloadData];
}

#pragma mark - 配置Slider默认值 Set the default value for Slider
- (void)configSliderValue:(CGFloat)value withHidden:(BOOL)hidden{
    self.topView.hidden = !hidden;
    self.strengthSlider.value = value;
}

#pragma mark - 设置背景颜色 Setting background color
- (void)backColor:(UIColor *)color{
    self.bottomView.backgroundColor = color;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvCaptureFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvCaptureFilterCell" forIndexPath:indexPath];
    cell.type = self.type;
    [cell renderCellWithModel:self.dataArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    for (NvBaseModel *model in self.dataArray) {
        model.selected = NO;
    }
    
    NvBaseModel *model = self.dataArray[indexPath.item];
    model.selected = YES;
    
    if (indexPath.item == 0) {
        if (self.topView) {
            self.topView.hidden = YES;
        }
        
    }else{
        if (self.topView) {
            self.topView.hidden = NO;
            self.strengthSlider.value = 1;
        }
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(NvCaptureFilterView:withFilterModel:)]) {
        [self.delegate NvCaptureFilterView:self withFilterModel:model];
    }
    [collectionView reloadData];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
