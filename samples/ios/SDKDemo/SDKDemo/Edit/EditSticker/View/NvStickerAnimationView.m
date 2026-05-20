//
//  NvStickerAnimationView.m
//  SDKDemo
//
//  Created by ms on 2021/4/20.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvStickerAnimationView.h"
#import "NvAnimationCollectionViewCell.h"

@interface NvStickerAnimationView ()<UICollectionViewDelegate, UICollectionViewDataSource>

/// 开场动画数组
/// Opening animation array
@property (nonatomic, strong) NSMutableArray *inAnimationDataSource;

/// 出场动画数组
/// Exit animation array
@property (nonatomic, strong) NSMutableArray *outAnimationDataSource;

/// 组合动画数组
/// Combinatorial animation array
@property (nonatomic, strong) NSMutableArray *comDataSource;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *inAnimationButton;
@property (nonatomic, strong) UIButton *outAnimationButton;
@property (nonatomic, strong) UIButton *comAnimationButton;
@property (nonatomic, strong) UILabel *moreLabel;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) NSArray *subBtns;
@property (nonatomic, strong) UILabel *styleApplyLabel;

@end

@implementation NvStickerAnimationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.inAnimationDataSource = [NSMutableArray array];
        self.outAnimationDataSource = [NSMutableArray array];
        self.comDataSource = [NSMutableArray array];
        self.moreButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:NvImageNamed(@"NvsFilterMore")];
        [self addSubview:self.moreButton];
        __weak typeof(self)weakSelf = self;
        [self.moreButton nv_BtnClickHandler:^{
            if ([weakSelf.delegate respondsToSelector:@selector(moreAnimationClickWithAnimationType:)]) {
                NvStickerAnimationType type = NvInStickerAnimationType;
                if (weakSelf.inAnimationButton.selected) {
                    type = NvInStickerAnimationType;
                } else if (weakSelf.outAnimationButton.selected) {
                    type = NvOutStickerAnimationType;
                } else {
                    type = NvComStickerAnimationType;
                }
                [weakSelf.delegate moreAnimationClickWithAnimationType:type];
            }
        }];
        
        self.inAnimationButton = [UIButton nv_buttonWithTitle:NvLocalString(@"In animation", @"入场动画") textColor:[UIColor nv_colorWithHexRGBA:@"#FFFFFF85"] fontSize:11 image:NvImageNamed(@"")];
        self.inAnimationButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.inAnimationButton];
        self.inAnimationButton.selected = YES;
        [self.inAnimationButton setTitleColor:[UIColor nv_colorWithHexString:@"#EA4359"] forState:UIControlStateNormal];
        [self.inAnimationButton nv_BtnClickHandler:^{
            
            [weakSelf didSelected:weakSelf.inAnimationButton];
        }];
        self.outAnimationButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Out animation", @"出场动画") textColor:[UIColor nv_colorWithHexRGBA:@"#FFFFFF85"] fontSize:11 image:NvImageNamed(@"")];
        self.outAnimationButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.outAnimationButton];
        [self.outAnimationButton nv_BtnClickHandler:^{
             [weakSelf didSelected:weakSelf.outAnimationButton];
        }];
        
        self.comAnimationButton = [UIButton nv_buttonWithTitle:NvLocalString(@"Combina animation", @"组合动画") textColor:[UIColor nv_colorWithHexRGBA:@"#FFFFFF85"] fontSize:11 image:NvImageNamed(@"")];
        self.comAnimationButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.comAnimationButton];
        [self.comAnimationButton nv_BtnClickHandler:^{
            [weakSelf didSelected:weakSelf.comAnimationButton];
        }];
        self.subBtns = @[self.inAnimationButton, self.outAnimationButton, self.comAnimationButton];
        self.moreLabel = [UILabel nv_labelWithText:NvLocalString(@"More", @"更多") fontSize:12 textColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"]];
        [self addSubview:self.moreLabel];
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(49*SCREENSCALE, 88*SCREENSCALE);
        flowLayout.minimumLineSpacing = 8*SCREENSCALE;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[NvAnimationCollectionViewCell class] forCellWithReuseIdentifier:@"NvAnimationCollectionViewCell"];
        [self.collectionView setShowsHorizontalScrollIndicator:NO];
        
        [self.inAnimationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15*SCREENSCALE);
            make.top.equalTo(@(10*SCREENSCALEHEIGHT));
            make.width.mas_lessThanOrEqualTo(@(100*SCREENSCALE));
            make.width.mas_greaterThanOrEqualTo(@(60*SCREENSCALE));
            make.height.equalTo(@(15*SCREENSCALE));
        }];
        [self.outAnimationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.inAnimationButton.mas_right).offset(18*SCREENSCALE);
            make.centerY.mas_equalTo(self.inAnimationButton);
            make.width.mas_lessThanOrEqualTo(@(100*SCREENSCALE));
            make.width.mas_greaterThanOrEqualTo(@(60*SCREENSCALE));
            make.height.equalTo(@(15*SCREENSCALE));
        }];
        [self.comAnimationButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.outAnimationButton.mas_right).offset(18*SCREENSCALE);
            make.centerY.mas_equalTo(self.inAnimationButton);
            make.width.mas_lessThanOrEqualTo(@(100*SCREENSCALE));
            make.width.mas_greaterThanOrEqualTo(@(60*SCREENSCALE));
            make.height.equalTo(@(15*SCREENSCALE));
        }];
        
        [self.moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(8*SCREENSCALE));
            make.top.equalTo(self.comAnimationButton.mas_bottom).offset(20*SCREENSCALEHEIGHT);
            make.width.equalTo(@(57*SCREENSCALE));
            make.height.equalTo(@(49*SCREENSCALE));
        }];
        
   
        [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.moreButton.mas_bottom).offset(18*SCREENSCALE);
            make.centerX.equalTo(self.moreButton);
        }];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.moreButton.mas_right).offset(5.0f);
            make.top.equalTo(self.inAnimationButton.mas_bottom).offset(20*SCREENSCALE);
            make.right.equalTo(@(-8*SCREENSCALE));
            make.height.equalTo(@(90*SCREENSCALE));
        }];
        
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
        
        self.applyButton = [NvButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"NvNoApplyAll")];
        self.applyButton.hidden = YES;
        [self.applyButton setImage:NvImageNamed(@"NvApplyAll") forState:UIControlStateSelected];
        self.styleApplyLabel = [UILabel nv_labelWithText:NvLocalString(@"Apply all", @"将样式应用到所有字幕") fontSize:10 textColor:[UIColor whiteColor]];
        self.styleApplyLabel.font = [NvUtils regularFontWithSize:10];
        self.styleApplyLabel.alpha = 0.8;
        self.styleApplyLabel.hidden = YES;
        [self.applyButton nv_BtnClickHandler:^{
            weakSelf.applyButton.selected = !weakSelf.applyButton.selected;
            if (weakSelf.applyButton.selected) {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
            } else {
                weakSelf.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
            }
            if ([weakSelf.delegate respondsToSelector:@selector(applyAnimationAllSticker:withAnimationType:)]) {
                NvStickerAnimationType type = NvInStickerAnimationType;
                if (weakSelf.inAnimationButton.selected) {
                    type = NvInStickerAnimationType;
                } else if (weakSelf.outAnimationButton.selected) {
                    type = NvOutStickerAnimationType;
                } else {
                    type = NvComStickerAnimationType;
                }
                [weakSelf.delegate applyAnimationAllSticker:weakSelf.applyButton.selected withAnimationType:type];
            }
        }];
        
        [self addSubview:self.applyButton];
        [self addSubview:self.styleApplyLabel];
        
        
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            make.bottom.equalTo(self.line).offset(-12*SCREENSCALE);
            make.width.height.equalTo(@(15*SCREENSCALE));
        }];
        [self.styleApplyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.applyButton.mas_centerY);
            make.left.equalTo(self.applyButton.mas_right).offset(7*SCREENSCALE);
        }];
        
    }
    return self;
}

-(void)didSelected:(UIButton *)btn{
    for (UIButton *subBtn in self.subBtns) {
        subBtn.selected = NO;
        if ([subBtn isEqual:btn]) {
            [subBtn setTitleColor:[UIColor nv_colorWithHexString:@"#EA4359"] forState:UIControlStateNormal];
            subBtn.selected = YES;
        }else{
            [subBtn setTitleColor:[UIColor nv_colorWithHexRGBA:@"#FFFFFF85"] forState:UIControlStateNormal];
        }
    }
    NvStickerAnimationType type = NvInStickerAnimationType;
    if (self.inAnimationButton.selected) {
        type = NvInStickerAnimationType;
    } else if (self.outAnimationButton.selected) {
        type = NvOutStickerAnimationType;
    } else {
        type = NvComStickerAnimationType;
    }
    
    [self configCurrentType:type];
    [self reloadData];
}

- (NvStickerAnimationType)getCurrenntType {
    NvStickerAnimationType type = NvInStickerAnimationType;
    if (self.inAnimationButton.selected) {
        type = NvInStickerAnimationType;
    } else if (self.outAnimationButton.selected) {
        type = NvOutStickerAnimationType;
    } else {
        type = NvComStickerAnimationType;
    }
    return type;
}

- (void)renderListWithOpenItems:(NSMutableArray<NvCaptionAnimationItem *> *)dataSource withType:(NvStickerAnimationType)type{
    switch (type) {
        case NvInStickerAnimationType:
            self.inAnimationDataSource = dataSource;
            break;
        case NvOutStickerAnimationType:
            self.outAnimationDataSource = dataSource;
            break;
        case NvComStickerAnimationType:
            self.comDataSource = dataSource;
            break;
        default:
            break;
    }
    
    [self reloadData];
}

- (void)configCurrentType:(NvStickerAnimationType)type{
    NSMutableArray *tempArray = [NSMutableArray array];
    switch (type) {
        case NvInStickerAnimationType:
            tempArray = self.inAnimationDataSource;
            break;
        case NvOutStickerAnimationType:
            tempArray = self.outAnimationDataSource;
            break;
        case NvComStickerAnimationType:
            tempArray = self.comDataSource;
            break;
        default:
            break;
    }
    
    for (int i = 0; i < tempArray.count; i++) {
        NvStickerAnimationModel *item = tempArray[i];
        if (item.isSelect) {
            self.currentItem = item;
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(changeAnimationType:data:)]) {
        [self.delegate changeAnimationType:type data:self.currentItem];
    }
}

-(void)reloadData{
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.inAnimationButton.selected) {
        return self.inAnimationDataSource.count;
    }else if (self.outAnimationButton.selected){
        return self.outAnimationDataSource.count;
    }else if (self.comAnimationButton.selected){
        return self.comDataSource.count;
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvAnimationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvAnimationCollectionViewCell" forIndexPath:indexPath];

    if (self.inAnimationButton.selected) {
        [cell renderCellWithItem:self.inAnimationDataSource[indexPath.item]];
    }else if (self.outAnimationButton.selected){
        [cell renderCellWithItem:self.outAnimationDataSource[indexPath.item]];
    }else if (self.comAnimationButton.selected){
        [cell renderCellWithItem:self.comDataSource[indexPath.item]];
    }
    
    if ([self.delegate respondsToSelector:@selector(selectAnimation:withAnimationType:)]) {
        NvStickerAnimationType type = NvInStickerAnimationType;
        NvCaptionAnimationItem *selectedItem = nil;
        if (self.inAnimationButton.selected) {
            type = NvInStickerAnimationType;
            for (NvCaptionAnimationItem *item in self.inAnimationDataSource) {
                if (item.isSelect) {
                    selectedItem = item;
                    break;
                }
            }
        } else if (self.outAnimationButton.selected) {
            type = NvOutStickerAnimationType;
            for (NvCaptionAnimationItem *item in self.outAnimationDataSource) {
                if (item.isSelect) {
                    selectedItem = item;
                    break;
                }
            }
        } else {
            type = NvComStickerAnimationType;
            for (NvCaptionAnimationItem *item in self.comDataSource) {
                if (item.isSelect) {
                    selectedItem = item;
                    break;
                }
            }
        }


    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NvStickerAnimationModel *tempItem;
    if (self.inAnimationButton.selected) {
        for (NvCaptionAnimationItem *item in self.inAnimationDataSource) {
            item.isSelect = NO;
        }
        tempItem = self.inAnimationDataSource[indexPath.item];
        tempItem.isSelect = YES;
        if (indexPath.item != 0) {
            for (int i = 0; i < self.comDataSource.count; i++) {
                NvCaptionAnimationItem *item = self.comDataSource[i];
                if (i == 0) {
                    item.isSelect = true;
                } else {
                    item.isSelect = false;
                }
            }
        }
    }else if (self.outAnimationButton.selected){
        for (NvCaptionAnimationItem *item in self.outAnimationDataSource) {
            item.isSelect = NO;
        }
        tempItem = self.outAnimationDataSource[indexPath.item];
        tempItem.isSelect = YES;
        if (indexPath.item != 0) {
            for (int i = 0; i < self.comDataSource.count; i++) {
                NvCaptionAnimationItem *item = self.comDataSource[i];
                if (i == 0) {
                    item.isSelect = true;
                } else {
                    item.isSelect = false;
                }
            }
        }
    }else if (self.comAnimationButton.selected){
        for (NvCaptionAnimationItem *item in self.comDataSource) {
            item.isSelect = NO;
        }
        tempItem = self.comDataSource[indexPath.item];
        tempItem.isSelect = YES;
        if (indexPath.item != 0) {
            for (int i = 0; i < self.inAnimationDataSource.count; i++) {
                NvCaptionAnimationItem *item = self.inAnimationDataSource[i];
                if (i == 0) {
                    item.isSelect = true;
                } else {
                    item.isSelect = false;
                }
            }
        }
        if (indexPath.item != 0) {
            for (int i = 0; i < self.outAnimationDataSource.count; i++) {
                NvCaptionAnimationItem *item = self.outAnimationDataSource[i];
                if (i == 0) {
                    item.isSelect = true;
                } else {
                    item.isSelect = false;
                }
            }
        }
    }

    self.currentItem = tempItem;
    if ([self.delegate respondsToSelector:@selector(selectAnimation:withAnimationType:)]) {
        NvStickerAnimationType type = NvInStickerAnimationType;
        if (self.inAnimationButton.selected) {
            type = NvInStickerAnimationType;
        } else if (self.outAnimationButton.selected) {
            type = NvOutStickerAnimationType;
        } else {
            type = NvComStickerAnimationType;
        }
        [self.delegate selectAnimation:self.currentItem withAnimationType:type];
    }
    [self.collectionView reloadData];
}

#pragma mark 清除数组状态 Clear array state
- (void)cleanDataArrayState{
    if (self.inAnimationButton.selected || self.outAnimationButton.selected) {
        for (NvCaptionAnimationItem *item in self.comDataSource) {
            item.isSelect = NO;
        }
    }else if (self.comAnimationButton.selected){
        for (NvCaptionAnimationItem *item in self.inAnimationDataSource) {
            item.isSelect = NO;
        }
        for (NvCaptionAnimationItem *item in self.outAnimationDataSource) {
            item.isSelect = NO;
        }
        
    }
}

@end
