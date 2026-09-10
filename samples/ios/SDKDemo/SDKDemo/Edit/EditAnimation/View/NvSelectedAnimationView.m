//
//  NvSelectedAnimationView.m
//  SDKDemo
//
//  Created by ms on 2020/8/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvSelectedAnimationView.h"
#import "NvSelectedAnimationCell.h"
#import "NVHeader.h"
#import "NvSelectedAnimationModel.h"

@interface NvSelectedAnimationView ()<UICollectionViewDelegate, UICollectionViewDataSource, NvAnimationSliderDelegate>


@property(nonatomic, strong) UIButton *moreButton;
@property(nonatomic, strong) UIButton *applyButton; 
@property(nonatomic, strong) NSMutableArray *dataSource;
@property(nonatomic, strong) NvSelectedAnimationModel *currentItem;
@property (nonatomic, strong) UILabel *timeCountLabel;
@end

@implementation NvSelectedAnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.dataSource = [NSMutableArray array];
        [self initSubviews];
        
    }
    return self;
}

- (void)initSubviews {
    __weak typeof(self)weakSelf = self;
    

    self.moreButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:nil];
    [self.moreButton setImage:NvImageNamed(@"NvsFilterMore") forState:UIControlStateNormal];
    [self addSubview:self.moreButton];
    [self.moreButton nv_BtnClickHandler:^{
        if (weakSelf.moreBtnClick) {
            weakSelf.moreBtnClick();
        }
    }];
    
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[NvSelectedAnimationCell class] forCellWithReuseIdentifier:@"NvSelectedAnimationCell"];
    [self.collectionView setShowsHorizontalScrollIndicator:NO];
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
            // Fallback on earlier versions
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
    }];
    [self.applyButton nv_BtnClickHandler:^{
        if (weakSelf.okBtnClick) {
            weakSelf.okBtnClick();
        }
    }];
    
    UIView *bottomLine = [UIView new];
    bottomLine.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(self.applyButton.mas_top).offset(-12*SCREENSCALE);
    }];
    
    [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(13*SCREENSCALE));
        make.top.equalTo(self.collectionView.mas_top).offset(0*SCREENSCALE);
        make.width.equalTo(@(40*SCREENSCALE));
        make.height.equalTo(@(49*SCREENSCALE));
    }];
    
    UILabel *moreLabel = [[UILabel alloc] init];
    [self addSubview:moreLabel];
    moreLabel.font = [UIFont systemFontOfSize:12*SCREENSCALE];
    moreLabel.textColor = [UIColor whiteColor];
    moreLabel.text = NvLocalString(@"More", @"更多");
    moreLabel.textAlignment = NSTextAlignmentCenter;
    
    [moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.moreButton.mas_bottom).offset(18*SCREENSCALE);
        make.centerX.equalTo(self.moreButton);
        make.width.mas_lessThanOrEqualTo(49*SCREENSCALE);
    }];

    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.moreButton.mas_right).offset(18*SCREENSCALE);
        make.right.equalTo(@(0));
        make.height.equalTo(@(87*SCREENSCALE));
        make.bottom.equalTo(bottomLine.mas_top).offset(-10*SCREENSCALE);
    }];
    

    self.timeLabel = [UILabel new];
    self.timeLabel.textColor = UIColor.whiteColor;
    self.timeLabel.font = [NvUtils fontWithSize:11 * SCREENSCALE];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.text = NvLocalString(@"Animation duration", @"动画时长");;
    self.timeLabel.numberOfLines = 2;
    self.timeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.timeLabel.hidden = YES;
    [self addSubview:self.timeLabel];
    
    self.slider = [[NvAnimationSlider alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH - KScale6s(110), 2)];
    self.slider.minValue = 0;
    self.slider.maxValue = 5;
    self.slider.lineHeight = 2.0f;
    self.slider.maximumTrackTintColor = [UIColor whiteColor];
    self.slider.thumbImageView.image = NvImageNamed(@"slider_thumb");
    self.slider.delegate = self;
    self.slider.hidden = YES;
    [self addSubview:self.slider];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.timeLabel.mas_centerY);
        make.width.mas_equalTo(SCREENWIDTH - KScale6s(110));
        make.height.mas_equalTo(2);
        make.right.mas_equalTo(-10*SCREENSCALE);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15*SCREENSCALE);
        make.bottom.equalTo(self.collectionView.mas_top).offset(-20 * SCREENSCALE);
        make.height.mas_greaterThanOrEqualTo(12);
        make.right.lessThanOrEqualTo(self.slider.mas_left).offset(-KScale6s(5));
    }];
}

-(void)itemSlider:(NvAnimationSlider*)slider valueChanged:(float)value{
    if (self.valueChangeBLock) {
        self.valueChangeBLock(self, value);
    }
}
-(void)itemSliderTouchEnd:(NvAnimationSlider*)slider{
    if (self.valueChangeEndBLock) {
        self.valueChangeEndBLock();
    }
}

-(void)setAnimationDataSource:(NSMutableArray<NvSelectedAnimationModel *> *)animationDataSource{
    BOOL select = NO;
    for (NvSelectedAnimationModel *model in animationDataSource) {
        if (model.isSelect) {
            select = YES;
            break;
        }
    }
    if (select == NO) {
        for (int i=0; i<animationDataSource.count; i++) {
            NvSelectedAnimationModel *model = animationDataSource[i];
            if ([model.name isEqualToString:NvLocalString(@"None", @"无")]) {
                model.isSelect = YES;
                break;
            }
        }
    }
    _animationDataSource = animationDataSource;
    [self.collectionView reloadData];
}

#pragma mark collectionDelegate & datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.animationDataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvSelectedAnimationCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvSelectedAnimationCell" forIndexPath:indexPath];
    NvSelectedAnimationModel *model = self.animationDataSource[indexPath.item];
    if (indexPath.item != 0 && model.isSelect) {
        self.slider.hidden = NO;
        self.timeLabel.hidden = NO;
    }
    [cell renderCellWithItem:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvSelectedAnimationModel *item in self.animationDataSource) {
        item.isSelect = NO;
    }
    
    
    NvSelectedAnimationModel *item = self.animationDataSource[indexPath.item];
    item.isSelect = YES;

    self.currentItem = item;
    
    if (indexPath.item == 0) {
        self.slider.hidden = YES;
        self.timeLabel.hidden = YES;
    }else{
        self.slider.hidden = NO;
        self.timeLabel.hidden = NO;
    }
    if (self.selectAnimation) {
        self.selectAnimation(item);
    }
    [self.collectionView reloadData];
}

#pragma mark - lazyload
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(60*SCREENSCALE, 86*SCREENSCALE);
        flowLayout.minimumLineSpacing = 8*SCREENSCALE;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
       
    }
    return  _collectionView;
}

- (CGFloat)topY {
    [self layoutIfNeeded];
    return self.collectionView.frame.origin.y;
}

@end
