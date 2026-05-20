//
//  NvEditBGBlurView.m
//  SDKDemo
//
//  Created by MS on 2020/10/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditBGBlurView.h"
#import "NVHeader.h"
#import "NvEditBGBlurCell.h"
@interface NvEditBGBlurView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIButton *applyButton;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *blurArr;
@end
@implementation NvEditBGBlurView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //底部应用按钮 Bottom apply button
        self.applyButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
        self.applyButton.backgroundColor = [UIColor clearColor];
        [self addSubview:self.applyButton];
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.equalTo(@(25*SCREENSCALEHEIGHT));
            make.height.equalTo(@(20*SCREENSCALE));
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
            } else {
                make.bottom.equalTo(@(-15*SCREENSCALE));
            }
        }];
        [self.applyButton addTarget:self action:@selector(applyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *bottomLine = [UIView new];
        bottomLine.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
        [self addSubview:bottomLine];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.height.equalTo(@1);
            make.bottom.equalTo(self.applyButton.mas_top).offset(-12*SCREENSCALE);
        }];
        
        //颜色collectionView Color collectionView
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 32.0*SCREENSCALE) collectionViewLayout:self.flowLayout];
        self.collectionView.backgroundColor = UIColor.clearColor;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 65.5*SCREENSCALE, 0, 0);
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.bounces = YES;
        [self.collectionView registerClass:[NvEditBGBlurCell class] forCellWithReuseIdentifier:@"NvEditBGBlurCellID"];
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(33.0*SCREENSCALE);
            make.bottom.mas_equalTo(bottomLine.mas_bottom).offset(-11.5*SCREENSCALE);
        }];
        [self.collectionView reloadData];
        
        //应用全部片段界面 Apply the full fragment interface
        UIView *applyAllView = [[UIView alloc] init];
        applyAllView.backgroundColor = [UIColor clearColor];
        [self addSubview:applyAllView];
        [applyAllView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.mas_equalTo(0);
            make.width.mas_equalTo(120*SCREENSCALE);
            make.height.mas_equalTo(14*SCREENSCALE);
        }];
        
        UIImageView *applyImgView = [[UIImageView alloc] init];
        [applyAllView addSubview:applyImgView];
        applyImgView.userInteractionEnabled = YES;
        applyImgView.image = [UIImage imageNamed:@"Nv_edit_applyAll"];
        [applyImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(applyAllView.mas_left).offset(24*SCREENSCALE);
            make.centerY.equalTo(applyAllView.mas_centerY);
            make.width.mas_equalTo(11.76*SCREENSCALE);
            make.height.mas_equalTo(16.29*SCREENSCALE);
        }];
        
        UILabel *applyLabel = [[UILabel alloc] init];
        [applyAllView addSubview:applyLabel];
        applyLabel.text = NvLocalString(@"ApplyAll", @"Apply All");
        applyLabel.textAlignment = NSTextAlignmentLeft;
        applyLabel.textColor = [UIColor whiteColor];
        applyLabel.font = [UIFont systemFontOfSize:10*SCREENSCALE];
        [applyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(applyImgView.mas_right).offset(2);
            make.right.equalTo(applyAllView.mas_right);
            make.top.bottom.mas_equalTo(0);
        }];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapApplyAllMethod:)];
        [applyAllView addGestureRecognizer:tapGes];
    }
    return self;
}

//配置数据 Configuration data
- (void)configData:(NSArray *)array {
    self.blurArr = [NSMutableArray arrayWithArray:array];
    [self.collectionView reloadData];
}

//完成按钮点击方法 Complete the button click method
- (void)applyButtonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(nvEditBGBlurView:applyButtonClicked:)]) {
        [self.delegate nvEditBGBlurView:self applyButtonClicked:button];
    }
}

//点击应用全部界面方法 Click Apply All Interface methods
- (void)tapApplyAllMethod:(UITapGestureRecognizer *)sender {
    if ([self.delegate respondsToSelector:@selector(nvEditBGBlurViewApplyAll:)]) {
        [self.delegate nvEditBGBlurViewApplyAll:self];
    }
}

#pragma mark - UICollectionView Delegate

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NvEditBGBlurCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvEditBGBlurCellID" forIndexPath:indexPath];
    cell.model = self.blurArr[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.blurArr.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(nvEditBGBlurView:selectModel:)]) {
        NvEditBGBlurModel *model = [self.blurArr objectAtIndex:indexPath.item];
        [self.delegate nvEditBGBlurView:self selectModel:model];
    }
}

#pragma mark - Lazy Load

-(UICollectionViewFlowLayout *)flowLayout{
    if (_flowLayout == nil){
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.itemSize = CGSizeMake(32.0*SCREENSCALE, 32.0*SCREENSCALE);
        _flowLayout.minimumInteritemSpacing = 0;
        _flowLayout.minimumLineSpacing = (SCREENWIDTH - 65.5*2*SCREENSCALE - 32.0*SCREENSCALE*5)/4;
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    }
    return _flowLayout;
}

@end
