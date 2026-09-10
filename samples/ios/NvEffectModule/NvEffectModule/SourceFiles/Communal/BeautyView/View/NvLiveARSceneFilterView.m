//
//  NvLiveARSceneFilterView.m
//  NvARSceneFxModule
//
//  Created by ms20180425 on 2022/8/24.
//

#import "NvLiveARSceneFilterView.h"
#import "NvLiveCaptureFilterModel.h"
#import "NvLiveBeautySliderView.h"
#import "NvLiveARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvLiveColor.h"
#import "NvLiveAppEnv.h"
#if __has_include(<NveEffectKit/NveEffectKit.h>)
#import <NveEffectKit/NveEffectKit.h>
#else
#import "NvLiveCaptureModularVM.h"
#endif

@interface NvLiveARSceneFilterView () <UICollectionViewDelegate, UICollectionViewDataSource, NvLiveBeautySliderViewDelegate>

@property(nonatomic, strong) UIView *topView;
@property(nonatomic, strong) UIView *bottomView;

@property(nonatomic, strong) NvLiveBeautySliderView *filterSlider;

@property(nonatomic, strong) UICollectionView *filterCollectionView;

@property(nonatomic, strong) NSMutableArray *filterArray;

@property(nonatomic, strong) UIView *filterBCView;

@property(nonatomic, strong) NvLiveCaptureFilterModel *currentFilterModel;

@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation NvLiveARSceneFilterView

- (void)dealloc {
    //    NSLog(@"%s", __func__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addSubviews];
    }
    return self;
}

#pragma mark 添加子视图
- (void)addSubviews {
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = UIColor.clearColor;

    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = UIColor.whiteColor;

    [self addSubview:self.topView];
    [self addSubview:self.bottomView];

    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.equalTo(self.mas_width);
        make.height.offset(80 * NvScreen(kScale));
    }];

    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topView.mas_bottom);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.width.equalTo(self.mas_width);
    }];

    [self addFilter];
    
    self.tipLabel = [[UILabel alloc]init];
    self.tipLabel.hidden = true;
    self.tipLabel.textColor = UIColor.blackColor;
    self.tipLabel.font = [UIFont systemFontOfSize:16];
}

#pragma mark 添加滤镜视图
- (void)addFilter {
    self.filterSlider = [NvLiveBeautySliderView new];
    self.filterSlider.hidden = YES;
    self.filterSlider.delegate = self;
    [self.topView addSubview:self.filterSlider];
    [self.filterSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.topView.mas_bottom).offset(-10 * NvScreen(kScale));
        make.centerX.equalTo(self.topView.mas_centerX);
        make.width.offset(273 * NvScreen(kScale));
        make.height.offset(30 * NvScreen(kScale));
    }];
    [self.filterSlider layoutIfNeeded];
    self.filterBCView = [UIView new];
    self.filterBCView.backgroundColor = UIColor.clearColor;
    [self.bottomView addSubview:self.filterBCView];

    [self.filterBCView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView).offset(0 * NvScreen(kScale));
        make.width.equalTo(self.bottomView.mas_width);
        make.bottom.equalTo(self.bottomView.mas_bottom);
    }];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(49 * NvScreen(kScale), 79 * NvScreen(kScale));
    layout.minimumLineSpacing = 20 * NvScreen(kScale);
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 11 * NvScreen(kScale), 0, 0);
    self.filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];
    self.filterCollectionView.delegate = self;
    self.filterCollectionView.dataSource = self;
    self.filterCollectionView.backgroundColor = [UIColor clearColor];
    self.filterCollectionView.showsHorizontalScrollIndicator = NO;
    [self.filterBCView addSubview:self.filterCollectionView];
    [self.filterCollectionView registerClass:[NvLiveARSeceneCaptureFilterCell class] forCellWithReuseIdentifier:@"NvLiveARSeceneCaptureFilterCell"];
    [self.filterCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.filterBCView.mas_top).offset(10 * NvScreen(kScale));
        make.left.equalTo(self.filterBCView.mas_left);
        make.right.equalTo(self.filterBCView.mas_right).offset(-10 * NvScreen(kScale));
        make.height.offset(84 * NvScreen(kScale));
    }];
}

#pragma mark 配置滤镜数据
- (void)configFilterArray:(NSMutableArray *)array needSlider:(BOOL)needSlider {
    self.filterArray = [NSMutableArray array];
    [self.filterArray addObjectsFromArray:array];
    for (NSInteger i = 0; i < array.count; i++) {
        NvLiveCaptureFilterModel *model = [array objectAtIndex:i];
        if (model.selected) {
            self.currentFilterModel = model;
            break;
        }
    }
    if (needSlider) {
        if (self.currentFilterModel && self.currentFilterModel.packageId.length > 0) {
            self.filterSlider.value = self.currentFilterModel.value;
            self.filterSlider.hidden = NO;
        }
    } else {
        [self.filterSlider removeFromSuperview];
    }
}

#pragma mark 滑杆拖动的回调
-(void)itemSlider:(NvLiveBeautySliderView*)slider valueChanged:(float)value{
    self.currentFilterModel.value = value;
    [self.delegate nvARSceneFilterView:self withFilter:self.currentFilterModel withState:NO];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filterArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvLiveARSeceneCaptureFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvLiveARSeceneCaptureFilterCell" forIndexPath:indexPath];
    [cell renderCellWithModel:self.filterArray[indexPath.item]];
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NvLiveCaptureFilterModel *model = self.filterArray[indexPath.item];
    if ([self.currentFilterModel isEqual:model]) {
        return;
    }
    for (NvLiveCaptureFilterModel *model in self.filterArray) {
        model.value = 1;
        model.selected = NO;
    }
    self.filterSlider.value = 1;

    if (indexPath.item == 0) {
        self.filterSlider.hidden = YES;
    } else {
        self.filterSlider.hidden = NO;
    }
    self.currentFilterModel = model;
    self.currentFilterModel.selected = YES;
    [self.delegate nvARSceneFilterView:self withFilter:self.currentFilterModel withState:YES];
    [collectionView reloadData];
    
    if (self.type == 1) {
        NSString * tipString = @"";
#if __has_include(<NveEffectKit/NveEffectKit.h>)
        tipString = [[NveEffectKit shareInstance] getARSceneAssetPackagePrompt:model.packageId];
#else
        tipString = [[NvsStreamingContext sharedInstanceWithFlags:NvsStreamingContextFlag_Support4KEdit].assetPackageManager getARSceneAssetPackagePrompt:model.packageId];
#endif
        
        self.tipLabel.text = tipString;
        self.tipLabel.hidden = false;
        if (!self.tipLabel.superview) {
            [self.superview addSubview:self.tipLabel];
            [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.superview);
            }];
        }
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayaf) object:nil];
        [self performSelector:@selector(delayaf) withObject:nil afterDelay:3.0];
    }
}

- (void)delayaf{
    self.tipLabel.hidden = true;
}

- (void)closeFilter {
    for (NvLiveCaptureFilterModel *model in self.filterArray) {
        model.value = 1;
        model.selected = NO;
    }
    self.filterSlider.hidden = YES;
    [self.filterCollectionView reloadData];
}

@end
