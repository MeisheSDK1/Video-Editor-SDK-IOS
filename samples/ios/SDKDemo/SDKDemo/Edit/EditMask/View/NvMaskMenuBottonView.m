//
//  NvMaskMenuBottonView.m
//  SDKDemo
//
//  Created by ms on 2021/3/5.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvMaskMenuBottonView.h"
#import "NVHeader.h"
#import "NvBottomMenuCell.h"
#import "NvMaskMenuItem.h"


static NSString *const NvBottomMenuCellID = @"NvBottomMenuCellID";
@interface NvMaskMenuBottonView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *bottomView;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIButton *flipButton;

@property (nonatomic, strong) UIView *line;
@end



@implementation NvMaskMenuBottonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

-(void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;
    [self.bottomView reloadData];
}

-(void)configUI{
    
    
    self.okButton = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
    [self addSubview:self.okButton];
    __weak typeof(self)weakSelf = self;
    [self.okButton mas_makeConstraints:^(MASConstraintMaker *make) {
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

    [self.okButton nv_BtnClickHandler:^{
        if (weakSelf.okBtnClick) {
            weakSelf.okBtnClick();
        }
    }];
    
    self.flipButton = [UIButton nv_buttonWithTitle:NvLocalString(@"reversal", @"反转") textColor:nil fontSize:11 image:nil];
    [self addSubview:self.flipButton];
    [self.flipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.0f*SCREENSCALE);
        make.width.mas_lessThanOrEqualTo(@(140*SCREENSCALE));
        make.height.equalTo(@(22*SCREENSCALE));
        make.top.mas_equalTo(5*SCREENSCALE);
    }];
    
    [self.flipButton nv_BtnClickHandler:^{
        if (weakSelf.flipBtnClick) {
            weakSelf.flipBtnClick();
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
    
    UICollectionViewFlowLayout *layout1 = [[UICollectionViewFlowLayout alloc]init];
    layout1.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout1.itemSize = CGSizeMake(65 *SCREENSCALE, 82.0 *SCREENSCALE);
    layout1.minimumLineSpacing = 5*SCREENSCALE;
    layout1.minimumInteritemSpacing = 0;
    _bottomView = [[UICollectionView alloc] initWithFrame:CGRectMake(0 * SCREENSCALE, 25.0 *SCREENSCALE, SCREENWIDTH, 100*SCREENSCALE) collectionViewLayout:layout1];
    _bottomView.backgroundColor = [UIColor clearColor];
    _bottomView.delegate = self;
    _bottomView.dataSource = self;
    _bottomView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_bottomView];
    [_bottomView registerClass:[NvBottomMenuCell class] forCellWithReuseIdentifier:NvBottomMenuCellID];
    self.backgroundColor = [UIColor blackColor];
}

#pragma mark - UICollectionView Delegate

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NvBottomMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NvBottomMenuCellID forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   

    for (int i = 0; i<self.dataArray.count; i++) {
        NvMaskMenuItem *item = self.dataArray[i];
        if (i == indexPath.item) {
            item.isSelected = YES;
        }else{
            item.isSelected  = NO;
        }
    }
    [collectionView reloadData];
    
    NvMaskMenuItem *item = self.dataArray[indexPath.item];
    if (self.selectItemClick) {
        self.selectItemClick(item.maskType);
    }

}

@end
