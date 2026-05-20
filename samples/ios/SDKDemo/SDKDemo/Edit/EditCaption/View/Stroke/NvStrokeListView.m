//
//  NvStrokeListView.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvStrokeListView.h"
#import "NVHeader.h"
#import "NvStrokeCollectionViewCell.h"

@interface NvStrokeListView()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *alphaLabel;
@property (nonatomic, strong) UILabel *widthLabel;
@property (nonatomic, strong) UILabel *alphaValueLabel;
@property (nonatomic, strong) UILabel *widthValueLabel;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIView *line;
@end

@implementation NvStrokeListView

- (void)dealloc {
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        _containFinishButton = NO;
        self.layer.masksToBounds = YES;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(25*SCREENSCALE, 25*SCREENSCALE);
        flowLayout.minimumLineSpacing = 29*SCREENSCALE;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        [self addSubview:self.collectionView];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.collectionView registerClass:[NvStrokeCollectionViewCell class] forCellWithReuseIdentifier:@"NvStrokeCollectionViewCell"];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(13*SCREENSCALE);
            make.top.equalTo(@(20*SCREENSCALEHEIGHT));
            make.right.equalTo(@(-13*SCREENSCALE));
            make.height.equalTo(@(25*SCREENSCALE));
        }];
        
        self.widthLabel = [UILabel nv_labelWithText:NvLocalString(@"Width", @"宽度") fontSize:12 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        self.widthLabel.alpha = 0.8;
        self.widthLabel.font = [NvUtils regularFontWithSize:12];
        [self addSubview:self.widthLabel];
        [self.widthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            make.top.equalTo(self.collectionView.mas_bottom).offset(21*SCREENSCALE);
        }];
        
        self.alphaLabel = [UILabel nv_labelWithText:NvLocalString(@"Opacity", @"不透明度") fontSize:12 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        self.alphaLabel.alpha = 0.8;
        self.alphaLabel.font = [NvUtils regularFontWithSize:12];
        [self addSubview:self.alphaLabel];
        [self.alphaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            make.top.equalTo(self.widthLabel.mas_bottom).offset(21*SCREENSCALE);
        }];
        
        self.slider = [[UISlider alloc] init];
        [self.slider setThumbImage:NvImageNamed(@"NvSliderIcon") forState:UIControlStateNormal];
        self.slider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#FFFFFFFF"];
        self.slider.maximumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#FF3B3B3B"];
        self.slider.value = 1;
        [self addSubview:self.slider];
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.alphaLabel.mas_right).offset(19*SCREENSCALE);
            make.right.equalTo(@(-80*SCREENSCALE));
            make.centerY.equalTo(self.alphaLabel);
        }];
        [self.slider addTarget:self action:@selector(alphaSliderChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.alphaValueLabel = [UILabel nv_labelWithText:@"0" fontSize:12 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        self.alphaValueLabel.alpha = 0.8;
        self.alphaValueLabel.font = [NvUtils regularFontWithSize:12];
        [self addSubview:self.alphaValueLabel];
        [self.alphaValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.slider.mas_right).offset(15*SCREENSCALE);
            make.right.equalTo(@(-15*SCREENSCALE));
            make.centerY.equalTo(self.alphaLabel);
        }];
        
        self.widthSlider = [[UISlider alloc] init];
        self.widthSlider.value = 1;
        self.widthSlider.minimumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#FFFFFFFF"];
        self.widthSlider.maximumTrackTintColor = [UIColor nv_colorWithHexARGB:@"#FF3B3B3B"];
        [self.widthSlider setThumbImage:NvImageNamed(@"NvSliderIcon") forState:UIControlStateNormal];
        [self addSubview:self.widthSlider];
        [self.widthSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.alphaLabel.mas_right).offset(19*SCREENSCALE);
            make.right.equalTo(@(-80*SCREENSCALE));
            make.centerY.equalTo(self.widthLabel);
        }];
        [self.widthSlider addTarget:self action:@selector(widthSliderChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.widthValueLabel = [UILabel nv_labelWithText:@"0" fontSize:12 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        self.widthValueLabel.alpha = 0.8;
        self.widthValueLabel.font = [NvUtils regularFontWithSize:12];
        [self addSubview:self.widthValueLabel];
        [self.widthValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.widthSlider.mas_right).offset(15*SCREENSCALE);
            make.right.equalTo(@(-15*SCREENSCALE));
            make.centerY.equalTo(self.widthLabel);
        }];
        
        __weak typeof(self)weakSelf = self;
        self.applyButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"NvNoApplyAll")];
        [self.applyButton setImage:NvImageNamed(@"NvApplyAll") forState:UIControlStateSelected];
        self.styleApplyLabel = [UILabel nv_labelWithText:NvLocalString(@"Apply all Stroke", @"将描边应用到所有字幕") fontSize:10 textColor:[UIColor whiteColor]];
        self.styleApplyLabel.font = [NvUtils regularFontWithSize:10];
        self.styleApplyLabel.alpha = 0.8;
        [self.applyButton nv_BtnClickHandler:^{
            weakSelf.applyButton.selected = !weakSelf.applyButton.selected;
            if (weakSelf.applyButton.selected) {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
            } else {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(applyStrokeToAllCaption:)]) {
                [weakSelf.delegate applyStrokeToAllCaption:weakSelf.applyButton.selected];
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
        [[NvUtils rgbColors] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NvCaptionStrokeItem *item = [NvCaptionStrokeItem new];
            item.isSelect = NO;
            item.isNone = NO;
            item.colorString = obj;
            [self.dataSource addObject:item];
        }];
        NvCaptionStrokeItem *item = [NvCaptionStrokeItem new];
        item.isSelect = YES;
        item.isNone = YES;
        item.colorString = nil;
        [self.dataSource insertObject:item atIndex:0];
        [self.collectionView reloadData];
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        
        self.alphaValueLabel.text = @"10.0";
        self.widthValueLabel.text = @"10.0";
    }
    return self;
}

///设置默认数据
///Set default data
- (void)setDefaultDataSource:(NSMutableArray *)dataSource width:(float)width alpha:(float)value {
    self.dataSource = dataSource;
    [self.collectionView reloadData];
    self.currentItem = nil;
    for (int i = 0; i < dataSource.count; i++) {
        NvCaptionStrokeItem *item = self.dataSource[i];
        if (item.isSelect) {
            self.currentItem = item;
        }
    }
    self.slider.value = value;
    self.widthSlider.value = width;
    self.alphaValueLabel.text = [NSString stringWithFormat:@"%.1f",value*10];
    self.widthValueLabel.text = [NSString stringWithFormat:@"%.1f",width*10];
    self.currentItem.alpha = self.slider.value;
    self.currentItem.width = self.widthSlider.value;
    self.applyButton.selected = NO;
    self.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    [self setSliderEnable:self.currentItem.isNone];
}

- (void)setSliderEnable:(BOOL)isNone {
    self.slider.hidden = isNone;
    self.alphaLabel.hidden = isNone;
    self.alphaValueLabel.hidden = isNone;
    self.widthSlider.hidden = isNone;
    self.widthValueLabel.hidden = isNone;
    self.widthLabel.hidden = isNone;
}

///透明度slider
///Transparency slider
- (void)alphaSliderChanged:(UISlider *)slider {
    self.currentItem.alpha = self.slider.value;
    self.currentItem.width = self.widthSlider.value;
    self.alphaValueLabel.text = [NSString stringWithFormat:@"%.1f",self.slider.value*10];
    if ([self.delegate respondsToSelector:@selector(selectStroke:withAlpha:)]) {
        [self.delegate selectStroke:self.currentItem withAlpha:slider.value];
    }
}

///宽度slider
///Width slider
- (void)widthSliderChanged:(UISlider *)slider {
    self.currentItem.alpha = self.slider.value;
    self.currentItem.width = self.widthSlider.value;
    self.widthValueLabel.text = [NSString stringWithFormat:@"%.1f",self.widthSlider.value*10];
    if ([self.delegate respondsToSelector:@selector(selectStroke:withWidth:)]) {
        [self.delegate selectStroke:self.currentItem withWidth:slider.value];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvStrokeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvStrokeCollectionViewCell" forIndexPath:indexPath];
    [cell renderCellWithItem:self.dataSource[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvCaptionStrokeItem *item in self.dataSource) {
        item.isSelect = NO;
    }
    NvCaptionStrokeItem *item = self.dataSource[indexPath.item];
    item.isSelect = YES;
    NvStrokeCollectionViewCell *cell = (NvStrokeCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell renderCellWithItem:self.dataSource[indexPath.item]];
    self.currentItem = item;
    if (indexPath.item == 0) {
        self.currentItem.isNone = YES;
    } else {
        self.currentItem.isNone = NO;
    }
    self.currentItem.alpha = self.slider.value;
    self.currentItem.width = self.widthSlider.value;
    [self setSliderEnable:self.currentItem.isNone];
    if ([self.delegate respondsToSelector:@selector(selectStroke:withAlpha:)]) {
        [self.delegate selectStroke:self.currentItem withAlpha:self.slider.value];
    }
    if ([self.delegate respondsToSelector:@selector(selectStroke:withWidth:)]) {
        [self.delegate selectStroke:self.currentItem withWidth:self.widthSlider.value];
    }
    if ([self.delegate respondsToSelector:@selector(selectStroke:)] && self.currentItem) {
        [self.delegate selectStroke:self.currentItem];
    }
    [self.collectionView reloadData];
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
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-8*SCREENSCALEHEIGHT);
        } else {
            make.bottom.equalTo(@(-8*SCREENSCALEHEIGHT));
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
        make.bottom.equalTo(self.okButton.mas_top).offset(-8*SCREENSCALE);
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

    [self.widthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(13*SCREENSCALE));
        make.top.equalTo(self.collectionView.mas_bottom).offset(12*SCREENSCALE);
    }];

    [self.alphaLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(13*SCREENSCALE));
        make.top.equalTo(self.widthLabel.mas_bottom).offset(10*SCREENSCALE);
    }];

    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
