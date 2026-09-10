//
//  EFContentView.m
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/12.
//  Copyright © 2019 美摄. All rights reserved.
//

#import "EFContentView.h"
#import "NvGraphicBtn.h"
#import "NvPsTitleCollectionViewCell.h"

@interface EFContentView () <UICollectionViewDelegate, UICollectionViewDataSource>
@property(nonatomic, strong) UIView *containerView; //拍照、录制底部view
@property(nonatomic, strong) NSMutableArray *leftButtonArr;
@property(nonatomic, strong) NSMutableArray *btnArray;
@property(nonatomic, strong) NSMutableArray *psTitleArray; //拍照、拍摄title数组
@property(nonatomic, assign) NSInteger currentInteger;     //当前拍照、拍摄对应的current

@property(nonatomic, strong) UIButton *moreBtn;                       //顶部中间按钮
@property(nonatomic, strong) UIButton *deviceBtn;                     //切换摄像头
@property(nonatomic, strong) UIView *bottomView;                      //更多按钮背景界面
@property(nonatomic, strong) NvGraphicBtn *flashBtn;                  //闪光灯
@property(nonatomic, strong) NvGraphicBtn *zoomBtn;                   //变焦
@property(nonatomic, strong) NvGraphicBtn *exposureBtn;               //曝光
@property(nonatomic, strong) NvGraphicBtn *propBtn;                   //道具
@property(nonatomic, strong) NvGraphicBtn *beautyBtn;                 //美颜
@property(nonatomic, strong) NvGraphicBtn *makeupBtn;                 //美妆
@property(nonatomic, strong) NvGraphicBtn *filterBtn;                 //滤镜
@property(nonatomic, strong) UIImageView *moreBgView;                 //更多按钮背景界面
@property(nonatomic, strong) UICollectionView *psTitleCollectionView; //拍照、拍摄切换视图

@property(nonatomic, strong) UIButton *backBtn; //返回

@end

@implementation EFContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.leftButtonArr = [NSMutableArray array];
        self.btnArray = [NSMutableArray array];
        self.psTitleArray = [NSMutableArray array];
        NvPsTitleModel *psTitleModel_1 = [NvPsTitleModel new];
        psTitleModel_1.name = NSLocalizedString(@"photo", @"拍摄");
        psTitleModel_1.selected = YES;
        psTitleModel_1.colorStr = @"#000000";
        NvPsTitleModel *psTitleModel_2 = [NvPsTitleModel new];
        psTitleModel_2.name = NSLocalizedString(@"shoot", @"视频");
        psTitleModel_2.selected = NO;
        psTitleModel_2.colorStr = @"#000000";
        [self.psTitleArray addObject:psTitleModel_1];
        [self.psTitleArray addObject:psTitleModel_2];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    self.backgroundColor = UIColor.clearColor;
    [self.leftButtonArr removeAllObjects];

    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(175.0f);
    }];
    //翻转 tag 0
    self.deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deviceBtn setImage:[[UIImage imageNamed:@"NvdeviceCapture"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.deviceBtn.imageView.tintColor = [UIColor darkGrayColor];
    self.deviceBtn.tag = EFContentBtTag_device;
    [self.leftButtonArr addObject:self.deviceBtn];
    [self.btnArray addObject:self.deviceBtn];
    [self.deviceBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deviceBtn];
    [self.deviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(NvScreen(kStatusBarHeight));
        make.right.equalTo(self.mas_right).offset(-13 * NvScreen(kScale));
        make.width.offset(33 * NvScreen(kScale));
        make.height.offset(33 * NvScreen(kScale));
    }];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(60 * NvScreen(kScale), 30 * NvScreen(kScale));
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 60 * NvScreen(kScale), 0, 0);
    self.psTitleCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, 180 * NvScreen(kScale), 35 * NvScreen(kScale)) collectionViewLayout:layout];
    self.psTitleCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.psTitleCollectionView.backgroundColor = UIColor.clearColor;
    self.psTitleCollectionView.delegate = self;
    self.psTitleCollectionView.dataSource = self;
    self.psTitleCollectionView.showsVerticalScrollIndicator = NO;
    self.psTitleCollectionView.showsHorizontalScrollIndicator = NO;
    [self.psTitleCollectionView registerClass:[NvPsTitleCollectionViewCell class] forCellWithReuseIdentifier:@"NvpsTitleCell"];
    //    [self.bottomView addSubview:self.psTitleCollectionView];

    //    [self.psTitleCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.bottom.equalTo(self.bottomView.mas_bottom).offset(-15 * NvScreen(kScale));
    //        make.centerX.equalTo(self.bottomView.mas_centerX);
    //        make.height.offset(45 * NvScreen(kScale));
    //        make.width.offset(180 * NvScreen(kScale));
    //    }];
    //    [self.psTitleCollectionView reloadData];

    self.shootingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shootingBtn.tag = EFContentBtTag_record;
    [self.shootingBtn setImage:[UIImage imageNamed:@"Nvshooting"] forState:UIControlStateNormal];
    [self.shootingBtn setImage:[UIImage imageNamed:@"Nvsuspended"] forState:UIControlStateSelected];
    [self.shootingBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.shootingBtn.exclusiveTouch = YES;
    [self.btnArray addObject:self.psTitleCollectionView];
    [self.bottomView addSubview:self.shootingBtn];
    [self.shootingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomView.mas_bottom).offset(-60 * NvScreen(kScale));
        make.centerX.equalTo(self.bottomView.mas_centerX);
        make.width.offset(75 * NvScreen(kScale));
        make.height.offset(75 * NvScreen(kScale));
    }];
    //字幕 tag 10
    self.makeupBtn = [NvGraphicBtn buttonWithTag:EFContentBtTag_makeup withTitle:NSLocalizedString(@"Makeup", @"美妆") withImageNormal:@"Nvmakeup_b" withImageSelected:nil];
    self.makeupBtn.btnLabel.textColor = [UIColor darkGrayColor];
    [self.makeupBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.makeupBtn];
    [self.makeupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.shootingBtn.mas_centerY);
        make.left.mas_equalTo(self.bottomView.mas_left).offset(26 * NvScreen(kScale));
        make.width.mas_equalTo(45 * NvScreen(kScale));
        make.height.mas_equalTo(65 * NvScreen(kScale));
    }];
    [self.btnArray addObject:self.makeupBtn];

    //美颜 tag 2
    self.beautyBtn = [NvGraphicBtn buttonWithTag:EFContentBtTag_beauty withTitle:NSLocalizedString(@"capture.beauty", @"美颜") withImageNormal:@"NveBeauty_b" withImageSelected:nil];
    self.beautyBtn.btnLabel.textColor = [UIColor darkGrayColor];
    [self.beautyBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.beautyBtn];
    [self.beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.right.equalTo(self.shootingBtn.mas_left).offset(-35 * NvScreen(kScale));
        make.width.mas_equalTo(45 * NvScreen(kScale));
        make.height.mas_equalTo(65 * NvScreen(kScale));
    }];
    [self.btnArray addObject:self.beautyBtn];
    //滤镜 tag 1
    self.filterBtn = [NvGraphicBtn buttonWithTag:EFContentBtTag_filter withTitle:NSLocalizedString(@"Filter", @"滤镜") withImageNormal:@"Nvfilter_b" withImageSelected:nil];
    self.filterBtn.btnLabel.textColor = [UIColor darkGrayColor];
    [self.filterBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.filterBtn];
    [self.filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.left.equalTo(self.shootingBtn.mas_right).offset(35 * NvScreen(kScale));
        make.width.mas_equalTo(45 * NvScreen(kScale));
        make.height.mas_equalTo(65 * NvScreen(kScale));
    }];
    [self.btnArray addObject:self.filterBtn];

    self.propBtn = [NvGraphicBtn buttonWithTag:EFContentBtTag_props withTitle:NSLocalizedString(@"Props", @"道具") withImageNormal:@"Nvprops_b" withImageSelected:nil];
    self.propBtn.btnLabel.textColor = [UIColor darkGrayColor];
    [self.propBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.propBtn];
    [self.propBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.right.equalTo(self.bottomView.mas_right).offset(-26 * NvScreen(kScale));
        make.width.mas_equalTo(45 * NvScreen(kScale));
        make.height.mas_equalTo(65 * NvScreen(kScale));
    }];
    [self.btnArray addObject:self.propBtn];

    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setImage:[[UIImage imageNamed:@"Nvmore"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.moreBtn.imageView.tintColor = [UIColor darkGrayColor];
    [self.moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(NvScreen(kStatusBarHeight));
        make.centerX.equalTo(self.mas_centerX);
        make.width.offset(28 * NvScreen(kScale));
        make.height.offset(28 * NvScreen(kScale));
    }];
    [self.btnArray addObject:self.moreBtn];
    self.moreBgView = [[UIImageView alloc] init];
    self.moreBgView.hidden = YES;
    [self addSubview:self.moreBgView];
    self.moreBgView.image = [UIImage imageNamed:@"NvMoreBg"];
    self.moreBgView.userInteractionEnabled = YES;
    [self.moreBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.moreBtn.mas_bottom);
        make.centerX.equalTo(self.moreBtn.mas_centerX);
        make.width.mas_equalTo(200 * NvScreen(kScale));
        make.height.mas_equalTo(75 * NvScreen(kScale));
    }];
    self.zoomBtn = [NvGraphicBtn buttonWithTag:EFContentBtTag_zoom withTitle:NSLocalizedString(@"zoom", @"焦距") withImageNormal:@"Nvzoom" withImageSelected:nil];
    [self.zoomBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreBgView addSubview:self.zoomBtn];
    [self.zoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.moreBgView.mas_bottom).offset(-11 * NvScreen(kScale));
        make.left.equalTo(self.moreBgView.mas_left).offset(27 * NvScreen(kScale));
        make.width.mas_equalTo(40 * NvScreen(kScale));
        make.height.mas_equalTo(43.1 * NvScreen(kScale));
    }];
    self.exposureBtn = [NvGraphicBtn buttonWithTag:EFContentBtTag_exposure withTitle:NSLocalizedString(@"exposure", @"曝光") withImageNormal:@"Nvexposure" withImageSelected:nil];
    [self.exposureBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreBgView addSubview:self.exposureBtn];
    [self.exposureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.moreBgView.mas_bottom).offset(-11 * NvScreen(kScale));
        make.centerX.equalTo(self.moreBgView.mas_centerX);
        make.width.mas_equalTo(60 * NvScreen(kScale));
        make.height.mas_equalTo(43.1 * NvScreen(kScale));
    }];

    //闪光灯 tag 6
    self.flashBtn = [NvGraphicBtn buttonWithTag:EFContentBtTag_flash withTitle:NSLocalizedString(@"flash", @"闪光灯") withImageNormal:@"Nvflash_off" withImageSelected:@"Nvflash_on"];
    [self.flashBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreBgView addSubview:self.flashBtn];
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.moreBgView.mas_bottom).offset(-11 * NvScreen(kScale));
        make.right.equalTo(self.moreBgView.mas_right).offset(-27 * NvScreen(kScale));
        make.width.mas_equalTo(40 * NvScreen(kScale));
        make.height.mas_equalTo(43.1 * NvScreen(kScale));
    }];

    self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 65, 60, 60)];
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [self addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.centerY.equalTo(self.deviceBtn);
        make.width.height.equalTo(@(40 * NvScreen(kScale)));
    }];

    self.backBtn.tag = EFContentBtTag_back;
    [self.backBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:(UIControlEventTouchUpInside)];
}

/*
 更多按钮点击
 Click more buttons
 */
- (void)moreBtnClick:(UIButton *)sender {
    if (!_moreBgView) {
    }
    _moreBgView.hidden = !_moreBgView.hidden;
    if (!_moreBgView.hidden) {
        [self delayHiddenMoreBgView];
    } else {
        [self hiddenMoreBgView];
    }
}
- (void)delayHiddenMoreBgView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenMoreBgView) object:nil];
    [self performSelector:@selector(hiddenMoreBgView) withObject:nil afterDelay:3.0];
}
- (void)hiddenMoreBgView {
    self.moreBgView.hidden = YES;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _psTitleArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NvPsTitleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NvpsTitleCell" forIndexPath:indexPath];
    [cell renderCellWithString:self.psTitleArray[indexPath.item]];
    return cell;
}
#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _currentInteger = indexPath.item;
    [self selectCaptureMode];
}

#pragma mark - 切换底部录制、拍照按钮
/*
 切换底部录制、拍照按钮
 Switch the bottom record and photo buttons
 */
- (void)selectCaptureMode {
    for (NvPsTitleModel *model in self.psTitleArray) {
        model.selected = NO;
    }
    NvPsTitleModel *seletedModel = self.psTitleArray[_currentInteger];
    seletedModel.selected = YES;
    [_psTitleCollectionView reloadData];

    if (_currentInteger == 0) {
        [_psTitleCollectionView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.shootingBtn setImage:[UIImage imageNamed:@"Nvshooting"] forState:UIControlStateNormal];
    } else {
        [self.shootingBtn setImage:[UIImage imageNamed:@"Nvshooting"] forState:UIControlStateNormal];
        [_psTitleCollectionView setContentOffset:CGPointMake(60 * NvScreen(kScale), 0) animated:YES];
    }
    if ([self.delegate respondsToSelector:@selector(selectedCapture:)]) {
        [self.delegate selectedCapture:_currentInteger];
    }
}

- (void)hiddenInterface:(BOOL)hidden {
    for (NvGraphicBtn *btn in self.btnArray) {
        btn.hidden = hidden;
    }
    if (hidden) {
        self.moreBgView.hidden = hidden;
    }
}

- (void)disabledFlash {
    [self setFlashButtonEnable:NO];
}

- (void)enabledFlash {
    [self setFlashButtonEnable:YES];
}

- (void)setFlashButtonEnable:(BOOL)enable {
    NvGraphicBtn *button = self.flashBtn;
    if (enable) {
        button.alpha = 1;
        button.enabled = YES;
    } else {
        button.alpha = 0.5;
        button.enabled = NO;
        button.selected = NO;
    }
}

- (void)setFlashSelected:(BOOL)selected {
    self.flashBtn.selected = selected;
}

- (void)leftBtClicked:(UIButton *)bt {
    bt.enabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedBtTag:button:)]) {
        [self.delegate didSelectedBtTag:bt.tag button:bt];
    }
    bt.enabled = YES;
}

@end
