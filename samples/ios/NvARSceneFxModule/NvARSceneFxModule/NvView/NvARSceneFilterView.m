//
//  NvARSceneFilterView.m
//  NvARSceneFxModule
//
//  Created by ms20180425 on 2022/8/24.
//

#import "NvARSceneFilterView.h"
#import "NvCaptureFilterModel.h"
#import "NvBeautySliderView.h"
#import "NvARSceneMacro.h"
#import "NvARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvColor.h"

@interface NvARSceneFilterView()<UICollectionViewDelegate,UICollectionViewDataSource,NvBeautySliderViewDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;


@property (nonatomic, strong) NvBeautySliderView *filterSlider;

@property (nonatomic, strong) UICollectionView *filterCollectionView;

@property (nonatomic, strong) NSMutableArray *filterArray;

@property (nonatomic, strong) UIView *filterBCView;

@property (nonatomic, strong) NvCaptureFilterModel *currentFilterModel;
@end

@implementation NvARSceneFilterView

- (void)dealloc{
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubviews];
    }
    return self;
}

#pragma mark 添加子视图
- (void)addSubviews{
    self.topView = [[UIView alloc]init];
    self.topView.backgroundColor = UIColor.clearColor;
    
    self.bottomView = [[UIView alloc]init];
    self.bottomView.backgroundColor = UIColor.whiteColor;
    
    [self addSubview:self.topView];
    [self addSubview:self.bottomView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.equalTo(self.mas_width);
        make.height.offset(80 * SCREENSCALE);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.mas_width);
    }];
    
    [self addFilter];
}

#pragma mark 添加滤镜视图
- (void)addFilter{
    self.filterSlider = [NvBeautySliderView new];
    self.filterSlider.hidden = YES;
    self.filterSlider.delegate = self;
    [self.topView addSubview:self.filterSlider];
    [self.filterSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * SCREENSCALE);
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.offset(273 * SCREENSCALE);
        make.height.offset(30 * SCREENSCALE);
    }];
    [self.filterSlider layoutIfNeeded];
    self.filterBCView = [UIView new];
    self.filterBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:self.filterBCView];
    
    [self.filterBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView).offset(0 * SCREENSCALE);
        make.width.equalTo(self.bottomView.mas_width);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49*SCREENSCALE, 79*SCREENSCALE);
    layout.minimumLineSpacing = 20*SCREENSCALE;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 11*SCREENSCALE, 0, 0);
    self.filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,0,0) collectionViewLayout:layout];
    self.filterCollectionView.delegate = self;
    self.filterCollectionView.dataSource = self;
    self.filterCollectionView.backgroundColor = [UIColor clearColor];
    self.filterCollectionView.showsHorizontalScrollIndicator = NO;
    [self.filterBCView addSubview:self.filterCollectionView];
    [self.filterCollectionView registerClass:[NvARSeceneCaptureFilterCell class] forCellWithReuseIdentifier:@"NvARSeceneCaptureFilterCell"];
    [self.filterCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.filterBCView.mas_top).offset(10 * SCREENSCALE);
        make.left.equalTo(self.filterBCView.mas_left);
        make.right.equalTo(self.filterBCView.mas_right).offset(-10 * SCREENSCALE);
        make.height.offset(84 * SCREENSCALE);
    }];
}

#pragma mark 配置滤镜数据
- (void)configFilterArray:(NSMutableArray *)array{
    self.filterArray = [NSMutableArray array];
    [self.filterArray addObjectsFromArray:array];
}

#pragma mark 滑杆拖动的回调
-(void)sliderValueChanged:(UISlider *)paramSender{
    self.currentFilterModel.value = paramSender.value;
    [self.delegate nvARSceneFilterView:self withFilter:self.currentFilterModel withState:NO];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filterArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvARSeceneCaptureFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvARSeceneCaptureFilterCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.filterArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    NvCaptureFilterModel *model = self.filterArray[indexPath.item];
    if ([self.currentFilterModel isEqual:model]) {
        return;
    }
    for (NvCaptureFilterModel *model in self.filterArray) {
        model.value = 1;
        model.selected = NO;
    }
    self.filterSlider.value = 1;
    
    if (indexPath.item == 0) {
        self.filterSlider.hidden = YES;
    }else{
        self.filterSlider.hidden = NO;
    }
    self.currentFilterModel = model;
    self.currentFilterModel.selected = YES;
    [self.delegate nvARSceneFilterView:self withFilter:self.currentFilterModel withState:YES];
    [collectionView reloadData];
}

- (void)closeFilter{
    for (NvCaptureFilterModel *model in self.filterArray) {
        model.value = 1;
        model.selected = NO;
    }
    self.filterSlider.hidden = YES;
    [self.filterCollectionView reloadData];
}

@end
