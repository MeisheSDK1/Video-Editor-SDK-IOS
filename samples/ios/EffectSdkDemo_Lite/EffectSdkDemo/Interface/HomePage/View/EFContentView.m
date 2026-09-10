//
//  EFContentView.m
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/12.
//  Copyright © 2019 美摄. All rights reserved.
//

#import "EFContentView.h"
#import "NvGraphicBtn.h"
#import "NvConstant.h"
#import "NvRectView.h"
#import "Masonry.h"
#import "NvPsTitleCollectionViewCell.h"
#import "EFAudioOperationView.h"

@class NvRotationView;
@interface EFContentView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UIView *containerView;  //拍照、录制底部view(Take photos and record the bottom view)
@property (nonatomic, strong) UIButton *captureButton; //拍照提示按钮Photo prompt button
@property (nonatomic, strong) UIButton *recordButton; //录制提示按钮Record prompt button
@property (nonatomic, strong) NSMutableArray *leftButtonArr;
@property (nonatomic, strong) NSMutableArray *btnArray;
@property (nonatomic, strong) NSMutableArray *psTitleArray;    //拍照、拍摄title数组Take a picture, take a picture of the title array
@property (nonatomic, assign) NSInteger currentInteger;        //当前拍照、拍摄对应的current.Take the current photo and shoot the corresponding current

@property (nonatomic, strong) UIButton *moreBtn;         //顶部中间按钮Top middle button
@property (nonatomic, strong) UIButton *deviceBtn;       //切换摄像头Switching cameras
@property (nonatomic, strong) UIView *bottomView;   //更多按钮背景界面More button background interfaces
@property (nonatomic, strong) NvGraphicBtn *flashBtn;        //闪光灯Flash
@property (nonatomic, strong) NvGraphicBtn *zoomBtn;         //变焦Zoom out
@property (nonatomic, strong) NvGraphicBtn *exposureBtn;     //曝光exposure
@property (nonatomic, strong) UIView *propMoreBgView;   //更多按钮背景界面More button background interfaces
@property (nonatomic, strong) NvGraphicBtn *propBtn;        //道具 prop
@property (nonatomic, strong) NvGraphicBtn *stickerBtn;         //贴纸 sticker
@property (nonatomic, strong) NvGraphicBtn *comCaptionBtn;     //组合字幕 comcaption
@property (nonatomic, strong) NvGraphicBtn *beautyBtn;       //美颜 beauty
@property (nonatomic, strong) NvGraphicBtn *captionBtn;       //字幕 caption
@property (nonatomic, strong) NvGraphicBtn *transitionBtn;       //转场 transition
@property (nonatomic, strong) NvGraphicBtn *makeupBtn;       //美妆makeup
@property (nonatomic, strong) NvGraphicBtn *filterBtn;       //滤镜filter
@property (nonatomic, strong) NvGraphicBtn *moreEffectBtn;        //更多效果 moreEffect
@property (nonatomic, strong) UIImageView *moreBgView;   //更多按钮背景界面 more background view
@property (nonatomic, strong) UICollectionView *psTitleCollectionView; //拍照、拍摄切换视图Take a picture, take a picture and switch views
@property (nonatomic, strong) UIButton *shootingBtn;     //拍摄、拍照Take a photograph

@property (nonatomic, strong) UIButton *backBtn;         //返回 back
//@property (nonatomic, strong) EFAudioOperationView *audioOperationView;         //音频操作视图Audio operation view

@property (nonatomic, strong) UISwitch* segmentSwitch;

@end

@implementation EFContentView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.leftButtonArr = [NSMutableArray array];
        self.btnArray = [NSMutableArray array];
        self.psTitleArray = [NSMutableArray array];
        NvPsTitleModel *psTitleModel_1 = [NvPsTitleModel new];
        psTitleModel_1.name = NvLocalString(@"photo", @"拍摄");
        psTitleModel_1.selected = YES;
        psTitleModel_1.colorStr = @"#000000";
        NvPsTitleModel *psTitleModel_2 = [NvPsTitleModel new];
        psTitleModel_2.name = NvLocalString(@"shoot", @"视频");
        psTitleModel_2.selected = NO;
        psTitleModel_2.colorStr = @"#000000";
        [self.psTitleArray addObject:psTitleModel_1];
        [self.psTitleArray addObject:psTitleModel_2];
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews{
    self.backgroundColor = UIColor.clearColor;
    [self.leftButtonArr removeAllObjects];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(175.0f);
    }];
    //flip tag 0
    //翻转 tag 0
    self.deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.deviceBtn setImage:[[UIImage imageNamed:@"NvdeviceCapture"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]forState:UIControlStateNormal];
    self.deviceBtn.imageView.tintColor = [UIColor darkGrayColor];
    self.deviceBtn.tag = 0;
    [self.leftButtonArr addObject:self.deviceBtn];
    [self.btnArray addObject:self.deviceBtn];
    [self.deviceBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deviceBtn];
    [self.deviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(NV_STATUSBARHEIGHT);
        make.right.equalTo(self.mas_right).offset(-13 * SCREENSCALE);
        make.width.offset(33 * SCREENSCALE);
        make.height.offset(33 * SCREENSCALE);
    }];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(60*SCREENSCALE, 30*SCREENSCALE);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 60*SCREENSCALE, 0, 0);
    self.psTitleCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 180 * SCREENSCALE, 35 * SCREENSCALE) collectionViewLayout:layout];
    self.psTitleCollectionView.backgroundColor = UIColor.clearColor;
    self.psTitleCollectionView.delegate = self;
    self.psTitleCollectionView.dataSource = self;
    [self.psTitleCollectionView registerClass:[NvPsTitleCollectionViewCell class] forCellWithReuseIdentifier:@"NvpsTitleCell"];
    [self.bottomView addSubview:self.psTitleCollectionView];
    
    [self.psTitleCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomView.mas_bottom).offset(-15*SCREENSCALE);
        make.centerX.equalTo(self.bottomView.mas_centerX);
        make.height.offset(35 * SCREENSCALE);
        make.width.offset(180 * SCREENSCALE);
    }];
    [self.psTitleCollectionView reloadData];
    
    self.shootingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.shootingBtn.tag = 1000;
    [self.shootingBtn setImage:[UIImage imageNamed:@"Nvshooting"] forState:UIControlStateNormal];
    [self.shootingBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnArray addObject:self.psTitleCollectionView];
    [self.bottomView addSubview:self.shootingBtn];
    [self.shootingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.psTitleCollectionView.mas_top).offset(-0 * SCREENSCALE);
        make.centerX.equalTo(self.bottomView.mas_centerX);
        make.width.offset(75 * SCREENSCALE);
        make.height.offset(75 * SCREENSCALE);
    }];
    
    // caption tag 10
    //字幕 tag 10
    self.captionBtn = [NvGraphicBtn buttonWithTag:10 withTitle:NvLocalString(@"Caption", @"字幕") withImageNormal:@"Nvmakeup_b" withImageSelected:nil];
    self.captionBtn.btnLabel.textColor = [UIColor darkGrayColor];
    [self.captionBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.captionBtn];
    [self.captionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.shootingBtn.mas_centerY);
        make.left.mas_equalTo(self.bottomView.mas_left).offset(26*SCREENSCALE);
        make.width.mas_equalTo(37*SCREENSCALE);
        make.height.mas_equalTo(65*SCREENSCALE);
    }];
    [self.btnArray addObject:self.captionBtn];
    //beauty tag 2
    //美颜 tag 2
    self.beautyBtn = [NvGraphicBtn buttonWithTag:2 withTitle:NvLocalString(@"capture.beauty", @"美颜") withImageNormal:@"Nvbeauty_b" withImageSelected:nil];
    self.beautyBtn.btnLabel.textColor = [UIColor darkGrayColor];
    [self.beautyBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.beautyBtn];
    [self.beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.right.equalTo(self.shootingBtn.mas_left).offset(-35*SCREENSCALE);
        make.width.mas_equalTo(37*SCREENSCALE);
        make.height.mas_equalTo(65*SCREENSCALE);
    }];
    [self.btnArray addObject:self.beautyBtn];
    //filter tag 1
    //滤镜 tag 1
    self.filterBtn = [NvGraphicBtn buttonWithTag:1 withTitle:NvLocalString(@"Filter", @"滤镜") withImageNormal:@"Nvfilter_b" withImageSelected:nil];
    self.filterBtn.btnLabel.textColor = [UIColor darkGrayColor];
    [self.filterBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.filterBtn];
    [self.filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.left.equalTo(self.shootingBtn.mas_right).offset(35*SCREENSCALE);
        make.width.mas_equalTo(37*SCREENSCALE);
        make.height.mas_equalTo(65*SCREENSCALE);
    }];
    [self.btnArray addObject:self.filterBtn];
    self.moreEffectBtn = [NvGraphicBtn buttonWithTag:0 withTitle:NvLocalString(@"More", @"更多") withImageNormal:@"more_prop_selecte" withImageSelected:nil];
    self.moreEffectBtn.btnLabel.textColor = [UIColor darkGrayColor];
    [self.moreEffectBtn addTarget:self action:@selector(moreEffectBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.moreEffectBtn];
    [self.moreEffectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.shootingBtn.mas_centerY);
        make.right.equalTo(self.bottomView.mas_right).offset(-26*SCREENSCALE);
        make.width.mas_equalTo(40*SCREENSCALE);
        make.height.mas_equalTo(65*SCREENSCALE);
    }];
    [self.btnArray addObject:self.moreEffectBtn];
    
    self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.moreBtn setImage:[[UIImage imageNamed:@"Nvmore"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.moreBtn.imageView.tintColor = [UIColor darkGrayColor];
    [self.moreBtn addTarget:self action:@selector(moreBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(NV_STATUSBARHEIGHT);
        make.centerX.equalTo(self.mas_centerX);
        make.width.offset(28 * SCREENSCALE);
        make.height.offset(28 * SCREENSCALE);
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
        make.width.mas_equalTo(200*SCREENSCALE);
        make.height.mas_equalTo(75*SCREENSCALE);
    }];
    self.zoomBtn = [NvGraphicBtn buttonWithTag:7 withTitle:NvLocalString(@"zoom", @"焦距") withImageNormal:@"Nvzoom" withImageSelected:nil];
    [self.zoomBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreBgView addSubview:self.zoomBtn];
    [self.zoomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.moreBgView.mas_bottom).offset(-11*SCREENSCALE);
        make.left.equalTo(self.moreBgView.mas_left).offset(27*SCREENSCALE);
        make.width.mas_equalTo(40*SCREENSCALE);
        make.height.mas_equalTo(43.1*SCREENSCALE);
    }];
    self.exposureBtn = [NvGraphicBtn buttonWithTag:8 withTitle:NvLocalString(@"exposure", @"曝光") withImageNormal:@"Nvexposure" withImageSelected:nil];
    [self.exposureBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreBgView addSubview:self.exposureBtn];
    [self.exposureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.moreBgView.mas_bottom).offset(-11*SCREENSCALE);
        make.centerX.equalTo(self.moreBgView.mas_centerX);
        make.width.mas_equalTo(60*SCREENSCALE);
        make.height.mas_equalTo(43.1*SCREENSCALE);
    }];
    
    //flash tag 6
    //闪光灯 tag 6
    self.flashBtn = [NvGraphicBtn buttonWithTag:6 withTitle:NvLocalString(@"flash", @"闪光灯") withImageNormal:@"Nvflash_off" withImageSelected:@"Nvflash_on"];
    [self.flashBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.moreBgView addSubview:self.flashBtn];
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.moreBgView.mas_bottom).offset(-11*SCREENSCALE);
        make.right.equalTo(self.moreBgView.mas_right).offset(-27*SCREENSCALE);
        make.width.mas_equalTo(40*SCREENSCALE);
        make.height.mas_equalTo(43.1*SCREENSCALE);
    }];
    
    self.propMoreBgView = [[UIView alloc] init];
    self.propMoreBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [self addSubview:self.propMoreBgView];
    self.propMoreBgView.hidden = YES;
    [self.propMoreBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bottomView.mas_top).offset(-10.0);
        make.right.mas_equalTo(self).offset(-30);
        make.width.mas_equalTo(60.0);
        make.height.mas_equalTo(310.0);
    }];

    self.propBtn = [NvGraphicBtn buttonWithTag:3 withTitle:NvLocalString(@"Props", @"道具") withImageNormal:@"icon_props" withImageSelected:nil];
    [self.propBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.propBtn];

    self.stickerBtn = [NvGraphicBtn buttonWithTag:4 withTitle:NvLocalString(@"Stickers", @"贴纸") withImageNormal:@"capture_sticker_image" withImageSelected:nil];
    [self.stickerBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.stickerBtn];

    self.comCaptionBtn = [NvGraphicBtn buttonWithTag:5 withTitle:NvLocalString(@"CompoundCaption", @"复合字幕") withImageNormal:@"capture_caption_image" withImageSelected:nil];
    [self.comCaptionBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.comCaptionBtn];
    
    self.transitionBtn = [NvGraphicBtn buttonWithTag:9 withTitle:NvLocalString(@"Transition", @"转场") withImageNormal:@"NvsSwitch" withImageSelected:nil];
    [self.transitionBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.transitionBtn];
    
    self.makeupBtn = [NvGraphicBtn buttonWithTag:12 withTitle:NvLocalString(@"Makeup", @"美妆") withImageNormal:@"MSMakeup_off" withImageSelected:nil];
    [self.makeupBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.propMoreBgView addSubview:self.makeupBtn];
    
    
    [self.comCaptionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.propMoreBgView.mas_bottom).offset(-15.0);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(45.0);
    }];
    [self.stickerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.comCaptionBtn.mas_top).offset(-15.0);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(45.0);
    }];
    [self.propBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.stickerBtn.mas_top).offset(-15.0);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(45.0);
    }];
    [self.transitionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.propBtn.mas_top).offset(-15.0);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(45.0);
    }];
    [self.makeupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.transitionBtn.mas_top).offset(-15.0);
        make.centerX.mas_equalTo(self.propMoreBgView);
        make.width.mas_equalTo(50.0);
        make.height.mas_equalTo(45.0);
    }];
    
    self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 65, 60, 60)];
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [self addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.centerY.equalTo(self.deviceBtn);
        make.width.height.equalTo(@(40*SCREENSCALE));
    }];
    self.backBtn.tag = 11;
    [self.backBtn addTarget:self action:@selector(leftBtClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    
    self.segmentSwitch = [[UISwitch alloc] init];
    [self addSubview:self.segmentSwitch];
    [self.segmentSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backBtn.mas_bottom).offset(85.0);
        make.centerX.equalTo(self.backBtn).offset(25.0);
    }];
    self.segmentSwitch.on = NO;
    [self.segmentSwitch addTarget:self action:@selector(segmentSwitchValueChanged:) forControlEvents:(UIControlEventValueChanged)];
}
- (void)layoutSubviews{
    [super layoutSubviews];
//    self.audioOperationView.frame = CGRectMake(0, 0, self.frame.size.width, 40);
}
-(void)moreEffectBtnClick:(UIButton *)sender{
    self.propMoreBgView.hidden = !self.propMoreBgView.hidden;
}

-(void)segmentSwitchValueChanged:(UISwitch*)segmentSwitch{
    [self.delegate segmentSwitchValueChanged:segmentSwitch];
}


/*
 更多按钮点击
 Click more buttons
 */
- (void)moreBtnClick:(UIButton *)sender {
    if(!_moreBgView) {
        
    }
    _moreBgView.hidden = !_moreBgView.hidden;
    if (!_moreBgView.hidden) {
        [self delayHiddenMoreBgView];
    }else{
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
    }else{
        [self.shootingBtn setImage:[UIImage imageNamed:@"Nvshooting"] forState:UIControlStateNormal];
        [_psTitleCollectionView setContentOffset:CGPointMake(60 * SCREENSCALE, 0) animated:YES];
        
    }
//    self.audioOperationView.hidden = _currentInteger == 0;
    if ([self.delegate respondsToSelector:@selector(selectedCapture:)]) {
        [self.delegate selectedCapture:_currentInteger];
    }
}



- (void)hiddenInterface:(BOOL)hidden{
    
    for (NvGraphicBtn *btn in self.btnArray) {
        btn.hidden = hidden;
    }
    if (hidden) {
        self.moreBgView.hidden = hidden;
        self.propMoreBgView.hidden = hidden;
    }
}

//切换拍照、录制功能
// Toggle photo/record function
- (void)replaceAVCategory:(UIButton *)sender {
    //Move the position of the interface according to the state
    //根据状态移动界面的位置
    NSInteger index = 0;
    if(sender == self.captureButton){
        //拍照
        //take picture
        CGFloat centerX = CGRectGetMaxX(_recordingButton.frame);
        CGFloat centerY = self.containerView.center.y;
        self.containerView.center = CGPointMake(centerX, centerY);
        index = 0;
    }else if (sender == self.recordButton){
        //录制
        //record
        CGFloat centerX = CGRectGetMinX(_recordingButton.frame);
        CGFloat centerY = self.containerView.center.y;
        self.containerView.center = CGPointMake(centerX, centerY);
        index = 1;
    }
    if ([self.delegate respondsToSelector:@selector(selectedCapture:)]) {
        [self.delegate selectedCapture:index];
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
    }else{
        button.alpha = 0.5;
        button.enabled = NO;
        button.selected = false;
//        self.flashBtn.btnImageView.image = [NvUtils imageWithName:@"Nvflash_off"];
    }
}

-(void)leftBtClicked:(UIButton*)bt{
    bt.selected = !bt.selected;
    bt.enabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedBtTag:)]) {
        [self.delegate didSelectedBtTag:bt.tag];
    }
    bt.enabled = YES;
}

//#pragma -mark audioOperationDelegate
//- (void)EFAudioOperationViewDelegateChangeVolum:(CGFloat)value{
//    if ([self.delegate respondsToSelector:@selector(changeVolum:)]) {
//        [self.delegate changeVolum:value];
//    }
//}
//- (void)EFAudioOperationViewDelegateAudioPlay{
//    if ([self.delegate respondsToSelector:@selector(audioPlay)]) {
//        [self.delegate audioPlay];
//    }
//}
//- (void)EFAudioOperationViewDelegateAudioPause{
//    if ([self.delegate respondsToSelector:@selector(audioPause)]) {
//        [self.delegate audioPause];
//    }
//}
//- (void)EFAudioOperationViewDelegateChangeAudioWithPath:(NSString *)path{
//    if ([self.delegate respondsToSelector:@selector(changeAudioWithPath:)]) {
//        [self.delegate changeAudioWithPath:path];
//    }
//}
//- (EFAudioOperationView *)audioOperationView{
//#ifndef USING_AUDIO_ENGINE
//    return nil;
//#endif
//    if (!_audioOperationView) {
//        _audioOperationView = [[EFAudioOperationView alloc]init];
//        _audioOperationView.delegate = self;
//        _audioOperationView.hidden = YES;
//        [self.bottomView addSubview:_audioOperationView];
//    }
//    return _audioOperationView;;
//}
@end
