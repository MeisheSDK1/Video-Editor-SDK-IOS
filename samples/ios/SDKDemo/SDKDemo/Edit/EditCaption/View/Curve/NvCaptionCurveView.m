//
//  NvCaptionCurveView.m
//  SDKDemo
//
//  Created by ms on 2021/5/19.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCaptionCurveView.h"
#import "NVHeader.h"
#import "NvCaptionCurveCell.h"

static NSString *const NvCaptionCurveCellID = @"NvCaptionCurveCellID";
@interface NvCaptionCurveView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *bottomView;
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIButton *finishBtn;
@property (nonatomic, strong) UIView *lineView;
@end


@implementation NvCaptionCurveView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initDate];
        [self configUI];
    }
    return self;
}

-(void)initDate{
    NSArray *selected = @[@"caption_animation_1",
                          @"caption_animation_2",
                          @"caption_animation_3",
                          @"caption_animation_4",
                          @"caption_animation_5",
                          @"caption_animation_6",
                          @"caption_animation_7",
                          @"caption_animation_8"];
    NSArray *types = @[@(CurveAnimationType1),
                       @(CurveAnimationType2),
                       @(CurveAnimationType3),
                       @(CurveAnimationType4),
                       @(CurveAnimationType5),
                       @(CurveAnimationType6),
                       @(CurveAnimationType7),
                       @(CurveAnimationTypeCustom)];
    
    self.dataArray = [NSMutableArray array];
    for (int i = 0; i < selected.count; i ++) {
        NvCaptionCurveItem *model = [NvCaptionCurveItem new];
        model.isSelected = NO;
        model.type = [types[i] integerValue];
        model.image = selected[i];
        [self.dataArray addObject:model];
    }
}

- (void)setupSelectedDefault:(CurveAnimationType)type{
    for (NvCaptionCurveItem *model in self.dataArray) {
        if (model.type == type) {
            model.isSelected = YES;
        }
    }
    
    [_bottomView reloadData];
}

-(void)configUI{
    
    UILabel *tipLabel = [[UILabel alloc]init];
    tipLabel.textAlignment = NSTextAlignmentLeft;
    tipLabel.text = NvLocalString(@"Please select animation curve", @"请选择动画曲线");
    tipLabel.textColor = UIColor.whiteColor;
    tipLabel.numberOfLines = 0;
    tipLabel.alpha = 0.8;
    tipLabel.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:tipLabel];
    self.tipLabel = tipLabel;
    [tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10.0f);
        make.left.mas_equalTo(10.0f);
        make.right.mas_lessThanOrEqualTo(-10.0f);
        make.height.mas_equalTo(20.0f);
    }];
    
    
    UICollectionViewFlowLayout *layout1 = [[UICollectionViewFlowLayout alloc]init];
    layout1.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout1.itemSize = CGSizeMake(50 * SCREENSCALE, 40.0 *SCREENSCALE);
    layout1.minimumInteritemSpacing = (kScreenWidth - 300 * SCREENSCALE) / 3.0;
    layout1.minimumLineSpacing = 40.0f *SCREENSCALE;
    _bottomView = [[UICollectionView alloc] initWithFrame:CGRectMake(0 * SCREENSCALE, 25.0 *SCREENSCALE, SCREENWIDTH, 90*SCREENSCALE) collectionViewLayout:layout1];
    _bottomView.delegate = self;
    _bottomView.dataSource = self;
    _bottomView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_bottomView];
    [_bottomView registerClass:[NvCaptionCurveCell class] forCellWithReuseIdentifier:NvCaptionCurveCellID];
    _bottomView.backgroundColor = [UIColor clearColor];
    [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_tipLabel).offset(50.0f);
        make.left.mas_equalTo(50.0f);
        make.right.mas_equalTo(-50.0f);
        make.height.mas_equalTo(200.0f);
    }];
    
    [self addSubview:self.finishBtn];
    [self addSubview:self.lineView];
    [self.finishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(@(25*SCREENSCALEHEIGHT));
        make.height.equalTo(@(20*SCREENSCALE));
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-15*SCREENSCALE);
        } else {
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }
    }];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.height.equalTo(@1);
        make.bottom.equalTo(self.finishBtn.mas_top).offset(-12 * SCREENSCALE);
    }];
}

-(void)nvAddCaptionViewFinishEvent:(UIButton *)btn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(nvCaptionCurveViewDidFinished:)]) {
        [self.delegate nvCaptionCurveViewDidFinished:self];
    }
}

- (UIButton *)finishBtn {
    if (!_finishBtn) {
        _finishBtn = [UIButton nv_buttonWithTitle:nil textColor:nil fontSize:-1 image:NvImageNamed(@"Nvcheck - material")];
        [_finishBtn addTarget:self action:@selector(nvAddCaptionViewFinishEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishBtn;
}
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
    }
    return _lineView;
}

#pragma mark - UICollectionView Delegate

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NvCaptionCurveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NvCaptionCurveCellID forIndexPath:indexPath];
    cell.item = self.dataArray[indexPath.item];
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    for (int i = 0; i < self.dataArray.count; i ++) {
        NvCaptionCurveItem *model = self.dataArray[i];
        if (i == indexPath.item) {
            model.isSelected = YES;
        }else{
            model.isSelected = NO;
        }
    }
    [collectionView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(nvCaptionCurveViewDidSelectModel:)]) {
        [self.delegate nvCaptionCurveViewDidSelectModel:self.dataArray[indexPath.row]];
    }
    
}
@end
