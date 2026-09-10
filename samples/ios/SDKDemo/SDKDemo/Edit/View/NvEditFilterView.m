//
//  NvEditFilterView.m
//  SDKDemo
//
//  Created by MS on 2020/6/8.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditFilterView.h"
#import "NvCaptureFilterCell.h"
#import "NvFilterDataSource.h"
#import "NVDefineConfig.h"
#import "NvHeader.h"
@interface NvEditFilterView()<UICollectionViewDelegate,UICollectionViewDataSource>

///关键帧UIButton
///Keyframe imageView
@property (nonatomic, strong) UIButton *keyFrameImageView;
@end

@implementation NvEditFilterView

+(instancetype)filterViewWithAspectRatio:(AspectRatio)ratio delegate:(id<NvEditFilterViewDelegate>)delegate {
    NvFilterDataSource* dataSource = [[NvFilterDataSource alloc] initWithAspectRatio:ratio];
    NvEditFilterView* filterView = [[NvEditFilterView alloc] initWithDataSource:dataSource];
    filterView.viewDelegate = delegate;
    return filterView;
}

-(instancetype)initWithDataSource:(id<NvFilterViewDelegate>) dataSource{
    float height = 170;
    if(dataSource && [dataSource respondsToSelector:@selector(titlesForSections)]){
        height = 220;
    }
    
    CGRect frame = CGRectMake(0, SCREENHEIGHT, SCREENWIDTH, height*SCREENSCALE+INDICATOR);
    self = [super initWithFrame:frame];
    if (self) {
        self.dataSource = dataSource;
        self.dataArray = [NSMutableArray array];
        self.backgroundColor = UIColor.clearColor;
        [self addSubviews:frame HaveTopView:YES WithTopViewHeight:70 * SCREENSCALE withMore:YES withlayout:nil];
//        [self replaceTopViewAndSetupSegmentView];
    }
    return self;
}

#pragma mark 添加子视图
///Add subview
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
            make.bottom.equalTo(self.topView.mas_bottom).offset(-21 * SCREENSCALE);
            make.centerX.equalTo(self.topView.mas_centerX);
            make.width.offset(281 * SCREENSCALE);
            make.height.offset(10 * SCREENSCALE);
        }];
        
        
        self.strengthLabel = [[UILabel alloc] init];
        self.strengthLabel.backgroundColor = [UIColor clearColor];
        self.strengthLabel.font = [UIFont systemFontOfSize:12*SCREENSCALE];
        self.strengthLabel.textColor = [UIColor whiteColor];
        self.strengthLabel.textAlignment = NSTextAlignmentCenter;
        self.strengthLabel.numberOfLines = 2;
        self.strengthLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.topView addSubview:self.strengthLabel];
        [self.strengthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.strengthSlider.mas_centerY);
            make.left.equalTo(self.mas_left).offset(15*SCREENSCALE);
            make.right.equalTo(self.strengthSlider.mas_left).offset(-15*SCREENSCALE);
        }];
        
    }else{
        heightTop = 0;
    }
    
    CGFloat bottomViewHeight = 90*SCREENSCALE;
    self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, heightTop, rect.size.width, bottomViewHeight)];
    self.bottomView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
    [self addSubview:self.bottomView];

    UIButton *moreB = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreB setImage:NvImageNamed(@"NvsFilterMore") forState:UIControlStateNormal];
    [moreB addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:moreB];
    [moreB mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView).offset(14 * SCREENSCALE);
        make.left.equalTo(self.bottomView).offset(13 * SCREENSCALE);
        make.width.offset(35 * SCREENSCALE);
        make.height.offset(25 * SCREENSCALE);
    }];

    UILabel *moreL = [[UILabel alloc]init];
    moreL.text = NvLocalString(@"More", @"更多");
    moreL.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    moreL.font = [NvUtils regularFontWithSize:11];
    [self.bottomView addSubview:moreL];
    [moreL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(moreB.mas_bottom).offset(19 * SCREENSCALE);
        make.centerX.equalTo(moreB.mas_centerX);
    }];

    if (!have) {
        moreB.hidden = YES;
        moreL.hidden = YES;
    }

    if (!layout) {
        layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(49*SCREENSCALE, 82*SCREENSCALE);
        layout.minimumLineSpacing = 10*SCREENSCALE;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,rect.size.width, bottomViewHeight) collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[NvCaptureFilterCell class] forCellWithReuseIdentifier:@"NvCaptureFilterCell"];
    [self.bottomView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView.mas_top).offset(2 * SCREENSCALE);
        if (have) {
            make.left.equalTo(moreB.mas_right).offset(40 * SCREENSCALE);
        }else{
            make.left.equalTo(self.bottomView);
        }
        make.right.equalTo(self.bottomView.mas_right);
        make.height.mas_equalTo(82*SCREENSCALE);
    }];

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
            [self configSliderValue:filterInfo.strength withHidden:NO];
            self.keyFrameView.hidden = NO;
            if (self.dataSource && [self.dataSource respondsToSelector:@selector(updateSelectedModelWithModel:)]) {
                [self.dataSource updateSelectedModelWithModel:model];
            }
            [self.collectionView reloadData];
        }
    }
}

#pragma mark 刷新视图
///Refresh view
- (void)reloadDataSource{
    [self.collectionView reloadData];
}

-(void)reloadDataWithSelectedModel:(id)model{
     if (self.dataSource && [self.dataSource respondsToSelector:@selector(reloadData)]) {
           [self.dataSource reloadData];
       }
    [self updateSelectedModelWithModel:model];
}

- (void)refreshSelectedModel:(id)model {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(reloadData)]) {
        [self.dataSource reloadData];
    }
    [self updateSelectedModelWithModel:model];
}

-(void)replaceTopViewAndSetupSegmentView{
    if (self.dataSource.numberOfSections>1) {
         if([self.collectionView.collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]]){
               UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
               layout.footerReferenceSize = CGSizeMake(30 * SCREENSCALE, 50 * SCREENSCALE);//
           }
           [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FilterCollectionViewFooter"];
        
        CGRect frame = self.bottomView.frame;
        frame.origin.y=self.frame.size.height - frame.size.height;
        self.bottomView.frame = frame;
        
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(didselectModelAtIndexPath:)]) {
            NSArray* titleArray = [self.dataSource titlesForSections];
            self.segView = [[NvFilterSegTitleView alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.bottomView.frame) - 40 * SCREENSCALE ,CGRectGetWidth(self.frame), 40 * SCREENSCALE) titleArray:titleArray customHeight:40*SCREENSCALE delegate:(id<NvFilterSegTitleViewDelegate>) self];
            self.segView.backgroundColor = self.bottomView.backgroundColor;
            [self addSubview:self.segView];
            [self addKeyFrameView];
        }
        
        self.bottomTotalHeitht = self.bottomView.frame.size.height+self.segView.frame.size.height;
    }
}

- (void)setHasKeyframes:(BOOL)hasKeyframes {
    _hasKeyframes = hasKeyframes;
    self.keyFrameView.hidden = NO;
    self.strengthSlider.hidden = hasKeyframes;
    self.strengthLabel.hidden = hasKeyframes;
    self.keyFrameImageView.selected = hasKeyframes;
}

- (void)addKeyFrameView {
    self.keyFrameView = [[UIView alloc] init];
    [self.topView addSubview:self.keyFrameView];
    [self.keyFrameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_top);
        make.height.mas_equalTo(30*SCREENSCALE);
        make.left.equalTo(self.topView.mas_left);
        make.right.equalTo(self.topView.mas_right);
    }];
    self.keyFrameImageView = [UIButton nv_buttonWithTitle:[NSString stringWithFormat:@"  %@",NvLocalString(@"Add key frame", @"增加关键帧")] textColor:UIColor.whiteColor fontSize:9.0f image:NvImageNamed(@"NvKeyFrame")];
    [self.keyFrameImageView setImage:NvImageNamed(@"NvEditKeyFrame") forState:UIControlStateSelected];
    [self.keyFrameImageView setTitle:[NSString stringWithFormat:@"  %@",NvLocalString(@"EditKeyFrame", @"编辑关键帧")] forState:UIControlStateSelected];
    [self.keyFrameImageView setTitleColor:[UIColor nv_colorWithHexString:@"#F2A95D"] forState:UIControlStateSelected];
    self.keyFrameImageView.enabled = NO;
    [self.keyFrameView addSubview:self.keyFrameImageView];
    [self.keyFrameImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_greaterThanOrEqualTo(70*SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(self.keyFrameView.mas_width);
        make.centerX.equalTo(self.keyFrameView.mas_centerX);
        make.centerY.equalTo(self.keyFrameView.mas_centerY);
        make.height.mas_equalTo(15*SCREENSCALE);
    }];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self.keyFrameView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.keyFrameView.mas_bottom).offset(-4.f);
        make.left.equalTo(self.topView.mas_left);
        make.right.equalTo(self.topView.mas_right);
        make.height.mas_equalTo(1.f);
    }];
    self.topView.alpha = 1.f;
    self.keyFrameView.hidden = YES;
    self.keyFrameView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
    
    [self.strengthSlider mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView.mas_left).offset(110*SCREENSCALE);
        make.right.equalTo(self.topView.mas_right).offset(-45*SCREENSCALE);
        make.top.equalTo(lineView.mas_bottom).offset(15*SCREENSCALE);
        make.height.mas_equalTo(20*SCREENSCALE);
    }];
    
    ///添加手势方法
    ///Add gesture method
    [self addTapGestureToKeyFrameView];
}

- (void)addTapGestureToKeyFrameView {
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addKeyFrameAction)];
    [self.keyFrameView addGestureRecognizer:tapGes];
}

- (void)addKeyFrameAction {
    if ([self.viewDelegate respondsToSelector:@selector(NvEditFilterViewAddKeyFrameView:)]) {
        [self.viewDelegate NvEditFilterViewAddKeyFrameView:self];
    }
}

-(void)didselectedIndex:(NSInteger)index{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:index] atScrollPosition:(UICollectionViewScrollPositionLeft) animated:YES];
}

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
        NSLog(@"col item number %ld",(long)[self.dataSource numberOfItemsInSection:section]);
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
#pragma mark - 视图内容
///View content
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    ///视图添加到 UICollectionReusableView 创建的对象中
    ///View added to the object created by UICollectionReusableView
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
    ///目前只有三个漫画 先用 3
    ///Currently only three comics use 3 first
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
                self.keyFrameView.hidden = NO;
                self.strengthSlider.value = 1;
                [self resetStrengthLabelValue];
            }
        }
        if (self.viewDelegate&&[self.viewDelegate respondsToSelector:@selector(NvEditFilterView:withFilterModel:)]) {
            [self.viewDelegate NvEditFilterView:self withFilterModel:model];
        }
        [collectionView reloadData];
    }
}

#pragma mark - moreClick
- (void)moreClick:(UIButton *)sender{
    [self.viewDelegate NvEditFilterView:self moreClick:sender];
}

#pragma mark - sliderValueChanged
- (void)sliderValueChanged:(UISlider *)slider{
    [self resetStrengthLabelValue];
    [self.viewDelegate NvEditFilterView:self sliderValueChanged:slider];
}

- (void)resetStrengthLabelValue {
    self.strengthLabel.text = [NSString stringWithFormat:@"%@ %.f", NvLocalString(@"fxStrength", @"强度"),self.strengthSlider.value*100];
}

#pragma mark - 配置数据源,并且刷新视图
///Configure the data source, and refresh the view
- (void)configDataSource:(NSMutableArray *)array{
    self.dataArray = array;
    [self reloadDataSource];
}

#pragma mark - 更新数据源，不刷新视图
///Update the data source without refreshing the view
- (void)updateDataSource:(NSMutableArray *)array{
    self.dataArray = array;
}

#pragma mark  - 配置Slider默认值
///Set the default value for Slider
- (void)configSliderValue:(CGFloat)value withHidden:(BOOL)hidden{
    self.topView.hidden = hidden;
    self.strengthSlider.value = value;
    [self resetStrengthLabelValue];
}

-(void)dealloc{
    NSLog(@"%s",__func__);
}

@end
