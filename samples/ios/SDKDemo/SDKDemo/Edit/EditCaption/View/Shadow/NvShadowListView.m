//
//  NvShadowListView.m
//  SDKDemo
//
//  Created by Meishe on 2022/9/15.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvShadowListView.h"
#import "NvBgColorCollectionViewCell.h"

@interface NvShadowListView()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *alphaLabel;
@property (nonatomic, strong) UILabel *alphaNumLabel;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIView *line;
@end

@implementation NvShadowListView

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _containFinishButton = NO;
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.layer.masksToBounds = YES;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(25*SCREENSCALE, 25*SCREENSCALE);
        flowLayout.minimumLineSpacing = 29*SCREENSCALE;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        [self.collectionView setShowsHorizontalScrollIndicator:NO];
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[NvBgColorCollectionViewCell class] forCellWithReuseIdentifier:@"NvBgColorCollectionViewCell"];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(13*SCREENSCALE);
            make.top.equalTo(@(20*SCREENSCALEHEIGHT));
            make.right.equalTo(@(-13*SCREENSCALE));
            make.height.equalTo(@(25*SCREENSCALE));
        }];
        self.alphaLabel = [UILabel nv_labelWithText:NvLocalString(@"Opacity", @"不透明度") fontSize:12 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        self.alphaLabel.alpha = 0.8;
        self.alphaLabel.font = [NvUtils regularFontWithSize:12];
        [self addSubview:self.alphaLabel];
        [self.alphaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            make.top.equalTo(self.collectionView.mas_bottom).offset(21*SCREENSCALEHEIGHT);
        }];
        
        self.alphaNumLabel = [UILabel nv_labelWithText:@"100" fontSize:12 textColor:[UIColor whiteColor]];
        self.alphaNumLabel.alpha = 0.8;
        self.alphaNumLabel.font = [NvUtils regularFontWithSize:12];
        [self addSubview:self.alphaNumLabel];
        [self.alphaNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-17*SCREENSCALE));
            make.centerY.equalTo(self.alphaLabel);
            make.width.equalTo(@(25*SCREENSCALE));
        }];
        
        self.slider = [[UISlider alloc] init];
        self.slider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#FFFFFFFF"];
        self.slider.maximumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#FF3B3B3B"];
        [self.slider setThumbImage:NvImageNamed(@"NvSliderIcon") forState:UIControlStateNormal];
        self.slider.value = 1;
        [self addSubview:self.slider];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.alphaLabel.mas_right).offset(19*SCREENSCALE);
            make.right.equalTo(self).offset(-60*SCREENSCALE);
            make.centerY.equalTo(self.alphaLabel);
        }];
        
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        __weak typeof(self)weakSelf = self;
        
        self.applyButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"NvNoApplyAll")];
        [self.applyButton setImage:NvImageNamed(@"NvApplyAll") forState:UIControlStateSelected];
        self.styleApplyLabel = [UILabel nv_labelWithText:NvLocalString(@"Apply all Shadow", @"将阴影应用到所有字幕") fontSize:10 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        self.styleApplyLabel.font = [NvUtils regularFontWithSize:10];
        self.styleApplyLabel.alpha = 0.8;
        
        [self.applyButton nv_BtnClickHandler:^{
            weakSelf.applyButton.selected = !weakSelf.applyButton.selected;
            if (weakSelf.applyButton.selected) {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
            } else {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(applyShadowColorToAllCaption:)]) {
                [weakSelf.delegate applyShadowColorToAllCaption:weakSelf.applyButton.selected];
            }
        }];
        
        [self addSubview:self.applyButton];
        [self addSubview:self.styleApplyLabel];
        
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-36*SCREENSCALE);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self.mas_bottom).offset(-36*SCREENSCALE);
            }
            make.width.height.equalTo(@(15*SCREENSCALE));
        }];
        [self.styleApplyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.applyButton.mas_centerY);
            make.left.equalTo(self.applyButton.mas_right).offset(7*SCREENSCALE);
        }];
        

        self.dataSource = [NSMutableArray new];
        [[NvUtils rgbBgColors] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NvCaptionColorItem *item = [NvCaptionColorItem new];
            item.isSelect = NO;
            item.colorString = obj;
            [self.dataSource addObject:item];
        }];
        self.currentItem = self.dataSource.firstObject;
        self.currentItem.isSelect = YES;
        self.slider.hidden = YES;
        self.alphaLabel.hidden = YES;
        self.alphaNumLabel.hidden = YES;
        [self.collectionView reloadData];
        self.currentItem = self.dataSource.firstObject;
    }
    return self;
}

///刷新列表用于外界设置默认数据
///The refresh list is used to set default data for the outside world
- (void)setDefaultDataSource:(NSMutableArray *)dataSource alpha:(float)value {
    self.dataSource = dataSource;
    self.currentItem = nil;
    for (NvCaptionColorItem *item in dataSource) {
        if (item.isSelect) {
            self.currentItem = item;
        }
    }
    [self.collectionView reloadData];
    self.slider.value = value;
    self.alphaNumLabel.text = [NSString stringWithFormat:@"%ld",(NSInteger)(self.slider.value*100)];
    self.applyButton.selected = NO;
    self.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    
    if ([self.currentItem.colorString containsString:@","] && self.currentItem) {
        self.slider.hidden = NO;
        self.alphaLabel.hidden = NO;
        self.alphaNumLabel.hidden = NO;
    }else {
        self.slider.hidden = YES;
        self.alphaLabel.hidden = YES;
        self.alphaNumLabel.hidden = YES;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvBgColorCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvBgColorCollectionViewCell" forIndexPath:indexPath];
    [cell renderCellWithItem:self.dataSource[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvCaptionColorItem *item in self.dataSource) {
        item.isSelect = NO;
    }
    NvCaptionColorItem *item = self.dataSource[indexPath.item];
    item.isSelect = YES;
    self.currentItem = item;
    [self.collectionView reloadData];
    if ([item.colorString containsString:@","]) {
        self.slider.hidden = NO;
        self.alphaLabel.hidden = NO;
        self.alphaNumLabel.hidden = NO;
    }else {
        self.slider.hidden = YES;
        self.alphaLabel.hidden = YES;
        self.alphaNumLabel.hidden = YES;
    }
    if ([self.delegate respondsToSelector:@selector(selectShadowColor:)] && self.currentItem) {
        [self.delegate selectShadowColor:self.currentItem];
    }
    if (indexPath.item == 0){
        
    }else{
        if ([self.delegate respondsToSelector:@selector(alphaShadowChanged:)]) {
            [self.delegate alphaShadowChanged:self.slider.value];
        }
    }
    
}

- (void)sliderValueChanged:(UISlider *)slider {
    self.alphaNumLabel.text = [NSString stringWithFormat:@"%ld",(NSInteger)(slider.value*100)];
    if ([self.delegate respondsToSelector:@selector(alphaShadowChanged:)]) {
        [self.delegate alphaShadowChanged:slider.value];
    }
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(SCREENWIDTH, 87*SCREENSCALE);
}

- (void)setContainFinishButton:(BOOL)containFinishButton {
    _containFinishButton = containFinishButton;
    if (containFinishButton) {
        [self remakeupSubviews];
    }
}

- (void)remakeupSubviews {
    __weak typeof(self)weakSelf = self;
    self.okButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
    [self addSubview:self.okButton];
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALEHEIGHT));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALEHEIGHT);
        } else {
            make.bottom.equalTo(@(-15*SCREENSCALEHEIGHT));
        }
    }];
    
    [self.okButton nv_BtnClickHandler:^{
        if ([weakSelf.delegate respondsToSelector:@selector(okClick)]) {
            [weakSelf.delegate okClick];
        }
    }];
    
    self.line = [UIView new];
    self.line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    [self addSubview:self.line];
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(self.okButton.mas_top).offset(-12*SCREENSCALE);
    }];
    
    [self.applyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(13*SCREENSCALE));
        make.bottom.equalTo(self.line).offset(-20*SCREENSCALE);
        make.width.height.equalTo(@(15*SCREENSCALE));
    }];
    
    [self.styleApplyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.applyButton.mas_centerY);
        make.left.equalTo(self.applyButton.mas_right).offset(7*SCREENSCALE);
    }];
}

@end
