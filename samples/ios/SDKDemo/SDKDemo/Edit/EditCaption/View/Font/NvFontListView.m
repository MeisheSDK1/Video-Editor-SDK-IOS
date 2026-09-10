//
//  NvFontListView.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvFontListView.h"
#import "NVHeader.h"
#import "NvFontCollectionViewCell.h"

@interface NvFontListView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIView *line;
@end

@implementation NvFontListView

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        _containFinishButton = NO;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(77*SCREENSCALE, 49*SCREENSCALE);
        flowLayout.minimumLineSpacing = 8*SCREENSCALE;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[NvFontCollectionViewCell class] forCellWithReuseIdentifier:@"NvFontCollectionViewCell"];

        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(8*SCREENSCALE));
            make.top.equalTo(@(8*SCREENSCALEHEIGHT));
            make.right.equalTo(@(-8*SCREENSCALE));
            make.height.equalTo(@(49*SCREENSCALE));
        }];
        
        self.boldButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Bold", @"加粗") textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"] fontSize:12 image:nil];
        self.boldButton.titleLabel.font = [NvUtils regularFontWithSize:12];
        self.boldButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        
        self.italicButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Italic", @"斜体") textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"] fontSize:12 image:nil];
        self.italicButton.titleLabel.font = [NvUtils regularFontWithSize:12];
        self.italicButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);

        self.underLineButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Underline", @"下划线") textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"] fontSize:12 image:nil];
        self.underLineButton.titleLabel.font = [NvUtils regularFontWithSize:12];
        self.underLineButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        
        [self.boldButton setBackgroundImage:NvImageNamed(@"NvCaptionBackGroundButton") forState:UIControlStateNormal];
        [self.italicButton setBackgroundImage:NvImageNamed(@"NvCaptionBackGroundButton") forState:UIControlStateNormal];

        [self.underLineButton setBackgroundImage:NvImageNamed(@"NvCaptionBackGroundButton") forState:UIControlStateNormal];
        [self.boldButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
        [self.italicButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];

        [self.underLineButton setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
        self.boldButton.layer.borderWidth = 1;
        self.boldButton.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.boldButton.layer.cornerRadius = 20.0/2*SCREENSCALE;
        self.boldButton.layer.masksToBounds = YES;
        self.italicButton.layer.borderWidth = 1;
        self.italicButton.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.italicButton.layer.cornerRadius = 20.0/2*SCREENSCALE;
        self.italicButton.layer.masksToBounds = YES;

        self.underLineButton.layer.borderWidth = 1;
        self.underLineButton.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.underLineButton.layer.cornerRadius = 20.0/2*SCREENSCALE;
        self.underLineButton.layer.masksToBounds = YES;
        [self addSubview:self.boldButton];
        [self addSubview:self.italicButton];

        [self addSubview:self.underLineButton];
        [self.boldButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            make.top.equalTo(self.collectionView.mas_bottom).offset(14*SCREENSCALEHEIGHT);
            make.height.equalTo(@(20*SCREENSCALE));
        }];
        [self.italicButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.boldButton.mas_right).offset(18*SCREENSCALE);
            make.top.equalTo(self.boldButton);
            make.height.equalTo(@(20*SCREENSCALE));
        }];

        [self.underLineButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.italicButton.mas_right).offset(18*SCREENSCALE);
            make.top.equalTo(self.boldButton);
            make.height.equalTo(@(20*SCREENSCALE));
            make.right.mas_lessThanOrEqualTo(-13*SCREENSCALE);
        }];
        __weak typeof(self)weakSelf = self;
        [self.boldButton nv_BtnClickHandler:^{
            weakSelf.boldButton.selected = !weakSelf.boldButton.selected;
            
            if (weakSelf.boldButton.selected) {
                weakSelf.boldButton.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
            } else {
                weakSelf.boldButton.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
            }

            if ([weakSelf.delegate respondsToSelector:@selector(nvFontListView:blodClick:)]) {
                [weakSelf.delegate nvFontListView:weakSelf blodClick:weakSelf.boldButton];
            }
        }];
        [self.italicButton nv_BtnClickHandler:^{
            weakSelf.italicButton.selected = !weakSelf.italicButton.selected;
            if (weakSelf.italicButton.selected) {
                weakSelf.italicButton.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
            } else {
                weakSelf.italicButton.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
            }

            if ([weakSelf.delegate respondsToSelector:@selector(nvFontListView:italicClick:)]) {
                [weakSelf.delegate nvFontListView:weakSelf italicClick:weakSelf.italicButton];
            }
        }];

        [self.underLineButton nv_BtnClickHandler:^{
            weakSelf.underLineButton.selected = !weakSelf.underLineButton.selected;
            if (weakSelf.underLineButton.selected) {
                weakSelf.underLineButton.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
            } else {
                weakSelf.underLineButton.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
            }
            if ([weakSelf.delegate respondsToSelector:@selector(nvFontListView:underLineClick:)]) {
                [weakSelf.delegate nvFontListView:weakSelf underLineClick:weakSelf.underLineButton];
            }
        }];
        
        self.applyButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"NvNoApplyAll")];
        [self.applyButton setImage:NvImageNamed(@"NvApplyAll") forState:UIControlStateSelected];
        self.styleApplyLabel = [UILabel nv_labelWithText:NvLocalString(@"Apply all Font", @"将字体应用到所有字幕") fontSize:10 textColor:[UIColor whiteColor]];
        self.styleApplyLabel.font = [NvUtils regularFontWithSize:10];
        self.styleApplyLabel.alpha = 0.8;
        [self.applyButton nv_BtnClickHandler:^{
            weakSelf.applyButton.selected = !weakSelf.applyButton.selected;
            if (weakSelf.applyButton.selected) {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
            } else {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(applyFontToAllCaption:)]) {
                [weakSelf.delegate applyFontToAllCaption:weakSelf.applyButton.selected];
            }
        }];
        
        [self addSubview:self.applyButton];
        [self addSubview:self.styleApplyLabel];
        
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-36*SCREENSCALE);
            make.width.height.equalTo(@(15*SCREENSCALE));
        }];

        [self.styleApplyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.applyButton.mas_centerY);
            make.left.equalTo(self.applyButton.mas_right).offset(7*SCREENSCALE);
            make.width.mas_lessThanOrEqualTo(KScale6s(200));
        }];

        self.dataSource = [NSMutableArray new];
    }
    return self;
}

- (void)renderListWithItems:(NSMutableArray <NvCaptionFontItem *>*)dataSource {
    self.dataSource = dataSource;
    [self.collectionView reloadData];
}

- (void)setDefauleDataSource:(NSMutableArray *)dataSource {
    self.dataSource = dataSource;
    [self.collectionView reloadData];
    self.currentItem = nil;
    for (int i = 0; i < dataSource.count; i++) {
        NvCaptionFontItem *item = self.dataSource[i];
        if ([item isKindOfClass:[NvCaptionFontItem class]]) {
            if (item.selected) {
                self.currentItem = item;
            }
        }
    }
    self.applyButton.selected = NO;
    self.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
}

- (void)setDefaultFontBoldButton:(BOOL)isBold italic:(BOOL)isItalic shadow:(BOOL)isShadow underline:(BOOL)isUnderline {
    self.boldButton.selected = isBold;
    self.italicButton.selected = isItalic;

    self.underLineButton.selected = isUnderline;
    if (self.boldButton.selected) {
        self.boldButton.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
    } else {
        self.boldButton.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    if (self.italicButton.selected) {
        self.italicButton.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
    } else {
        self.italicButton.layer.borderColor = [UIColor whiteColor].CGColor;
    }

    if (self.underLineButton.selected) {
        self.underLineButton.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
    } else {
        self.underLineButton.layer.borderColor = [UIColor whiteColor].CGColor;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvFontCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvFontCollectionViewCell" forIndexPath:indexPath];
    if (self.selectColor) {
        cell.selectColor = self.selectColor;
    }
    [cell renderCellWithItem:self.dataSource[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.dataSource enumerateObjectsUsingBlock:^(NvCaptionFontItem *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.lastSelect = NO;
        obj.selected = NO;
    }];
    NvCaptionFontItem *item = self.dataSource[indexPath.item];
    item.lastSelect = YES;
    item.selected = YES;
    NvFontCollectionViewCell *cell = (NvFontCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell renderCellWithItem:self.dataSource[indexPath.item]];
    self.currentItem = item;
    if ([self.delegate respondsToSelector:@selector(selectFont:)]) {
        [self.delegate selectFont:self.currentItem];
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
    __weak typeof(self)weakSelf = self;
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

- (void)updateProgress:(float)progress uuid:(NSString *)uuid{
    
}
- (void)downloadFailduuid:(NSString *)uuid{
    
}

@end
