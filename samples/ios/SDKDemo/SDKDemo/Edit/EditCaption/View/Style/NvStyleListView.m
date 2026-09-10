//
//  NvStyleListView.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/5.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvStyleListView.h"
#import "NvStyleCollectionViewCell.h"

@interface NvStyleListView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UILabel *moreLabel;
@property (nonatomic, strong) NSString *cellId;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIView *line;
@end

@implementation NvStyleListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _containFinishButton = NO;
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.moreButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:NvImageNamed(@"NvsFilterMore")];
        [self addSubview:self.moreButton];
        __weak typeof(self)weakSelf = self;
        [self.moreButton nv_BtnClickHandler:^{
            [weakSelf moreClick];
        }];
        self.moreLabel = [UILabel nv_labelWithText:NvLocalString(@"More", @"更多") fontSize:12 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        self.moreLabel.numberOfLines = 2;
        [self addSubview:self.moreLabel];
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(77*SCREENSCALE, 88*SCREENSCALE);
        flowLayout.minimumLineSpacing = 8*SCREENSCALE;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        [self addSubview:self.collectionView];
        Class cl = [self registerCell];
        self.cellId = NSStringFromClass(cl);
        [self.collectionView registerClass:cl forCellWithReuseIdentifier:self.cellId];
        [self.collectionView setShowsHorizontalScrollIndicator:NO];
        [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(8*SCREENSCALE));
            make.top.equalTo(@(10*SCREENSCALEHEIGHT));
            make.width.equalTo(@(57*SCREENSCALE));
            make.height.equalTo(@(49*SCREENSCALE));
        }];
        [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.moreButton.mas_bottom).offset(18*SCREENSCALE);
            make.centerX.equalTo(self.moreButton);
            make.width.mas_lessThanOrEqualTo(self.moreButton.mas_width);
        }];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.moreButton.mas_right).offset(8*SCREENSCALE);
            make.top.equalTo(self.moreButton.mas_top).offset(-3*SCREENSCALE);
            make.right.equalTo(@(-8*SCREENSCALE));
            make.height.equalTo(@(90*SCREENSCALE));
        }];
        
        self.applyButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"NvNoApplyAll")];
        [self.applyButton setImage:NvImageNamed(@"NvApplyAll") forState:UIControlStateSelected];
        self.styleApplyLabel = [UILabel nv_labelWithText:NvLocalString(@"Apply all", @"将样式应用到所有字幕") fontSize:10 textColor:[UIColor whiteColor]];
        self.styleApplyLabel.font = [NvUtils regularFontWithSize:10];
        self.styleApplyLabel.alpha = 0.8;
        [self.applyButton nv_BtnClickHandler:^{
            weakSelf.applyButton.selected = !weakSelf.applyButton.selected;
            if (weakSelf.applyButton.selected) {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
            } else {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
            }
            [weakSelf applyAllClick:weakSelf.applyButton.selected];
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
        
    }
    return self;
}

- (Class)registerCell {
    return [NvStyleCollectionViewCell class];
}

///刷新列表用于外界设置默认数据
///The refresh list is used to set default data for the outside world
- (void)renderListWithItems:(NSMutableArray <NvCaptionStyleItem *>*)dataSource {
    self.dataSource = dataSource;
    [self.collectionView reloadData];
    self.applyButton.selected = NO;
    self.currentItem = nil;
    for (int i = 0; i < dataSource.count; i++) {
        NvCaptionStyleItem *item = self.dataSource[i];
        if (item.isSelect) {
            self.currentItem = item;
        }
    }
    
    self.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
}

- (void)okClick {
    if ([self.delegate respondsToSelector:@selector(okClick)]) {
        [self.delegate okClick];
    }
}

- (void)moreClick {
    if ([self.delegate respondsToSelector:@selector(moreStyleClick)]) {
        [self.delegate moreStyleClick];
    }
}

- (void)applyAllClick:(BOOL)applyToAll {
    if ([self.delegate respondsToSelector:@selector(applyStyleToAllCaption:)]) {
        [self.delegate applyStyleToAllCaption:applyToAll];
    }
}

- (void)selectCaptionItem:(id)item {
    if ([self.delegate respondsToSelector:@selector(selectStyle:)]) {
        [self.delegate selectStyle:item];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvStyleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:self.cellId forIndexPath:indexPath];
    [cell renderCellWithItem:self.dataSource[indexPath.item]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    for (NvCaptionStyleItem *item in self.dataSource) {
        item.isSelect = NO;
    }
    
    NvCaptionStyleItem *item = self.dataSource[indexPath.item];
    item.isSelect = YES;

    self.currentItem = item;
    [self selectCaptionItem:self.currentItem];
    [self.collectionView reloadData];
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
        [weakSelf okClick];
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
