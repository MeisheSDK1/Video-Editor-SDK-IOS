//
//  EFEffectLayoutViewController.m
//  EffectSdkDemo
//
//  Created by 美摄 on 2021/3/11.
//  Copyright © 2021 美摄. All rights reserved.
//

#import "EFEffectLayoutViewController.h"
#import "Masonry.h"

@interface EFEffectLayoutViewController ()

@property(nonatomic,strong)EFDataSource* dataSource;


@end

@implementation EFEffectLayoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHidden = NO;
    self.dataSource = [[EFDataSource alloc] init];
    [self setupSubviews];
}

-(void)setupSubviews{
    //覆盖control view
    _contentView = [[EFContentView alloc] initWithFrame:self.view.bounds];
    _contentView.delegate = (id<EFContentViewDelegate>)self;
    [self.view addSubview:_contentView];
    _contentView.recordingButton.hidden = NO;
    
    //rectView
    self.rectView = [[EFRectOperatorView alloc] initWithFrame:CGRectZero type:NV_ANIMATED_STICKER];
    [self.contentView addSubview:self.rectView];
    [self.rectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
    self.rectView.hidden = YES;
    
    self.propsView = [[EFStickerView alloc] initWithFrame:self.view.bounds];
    self.propsView.stickerArray = self.dataSource.stickerArray;
    self.propsView.delegate = self;
    self.propsView.hidden = YES;
    [self.view addSubview:self.propsView];
    
    self.compoundCaptionView = [[EFStickerView alloc] initWithFrame:self.view.bounds];
    self.compoundCaptionView.stickerArray = [self.dataSource loadCompoundCaptionArray];
    self.compoundCaptionView.delegate = self;
    self.compoundCaptionView.hidden = YES;
    [self.view addSubview:self.compoundCaptionView];

    self.stickerView = [[EFStickerView alloc] initWithFrame:self.view.bounds];
    self.stickerView.stickerArray = [self.dataSource loadAnimatedStickerArray];
    self.stickerView.delegate = self;
    self.stickerView.hidden = YES;
    [self.view addSubview:self.stickerView];

    self.transitionView = [[EFStickerView alloc] initWithFrame:self.view.bounds];
    self.transitionView.stickerArray = [self.dataSource loadTransitionArray];
    self.transitionView.delegate = self;
    self.transitionView.hidden = YES;
    [self.view addSubview:self.transitionView];
    
    [self addZoomView];
    [self addExposureView];
    [self initFocusView];
//    [self deviceIsSupportFlash];

    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    tapGes.cancelsTouchesInView = false;
    [self.contentView addGestureRecognizer:tapGes];
}

- (void)addScenePreview{
    self.scenePreview.ARSceneFxOperator = self.ARSceneFxOperator;
    [self.view addSubview:self.scenePreview];
    
    [self.scenePreview addBeautyView];
    [self.scenePreview addFilterView];
    [self.scenePreview addMakeupView];
    
    [self.scenePreview showBeautyView:NO];
    [self.scenePreview showFilterView:NO];
    [self.scenePreview showMakeupView:NO];
}

#pragma mark - addsubview
// 添加手动对焦视图
// Add manual focus view
- (void)initFocusView{
    self.focusView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.focusView.alpha = 0;
    [_focusView setImage:[NvUtils imageWithName:@"NvsCaptureFocus"]];
    [self.view addSubview:self.focusView];
}

// 添加变焦视图
// Add zoom view
- (void)addZoomView{
    self.zoomBgView =[[EFStickerView alloc] initWithFrame:self.view.bounds];
    self.zoomBgView.hidden = YES;
    self.zoomBgView.delegate = self;
    [self.view addSubview:self.zoomBgView];
    self.zoomView = [[NvCapturePopupView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT - 130*SCREENSCALE - SafeAreaBottomHeight, SCREENWIDTH, 126 * SCREENSCALE+ SafeAreaBottomHeight) withType:CapturePopupTypeZoom];
//    [self.zoomView configMinimumValue:1 MaximumValue:self.efCapture.videoMaxZoomFactor];
    [self.zoomBgView addSubview:_zoomView];
}

// 添加曝光视图
// Add exposure view
- (void)addExposureView{
    self.exposureBgView =[[EFStickerView alloc] initWithFrame:self.view.bounds];
    self.exposureBgView.hidden = YES;
    self.exposureBgView.delegate = self;
    [self.view addSubview:self.exposureBgView];
    self.exposureView = [[NvCapturePopupView alloc]initWithFrame:CGRectMake(0, SCREENHEIGHT - 130*SCREENSCALE- SafeAreaBottomHeight, SCREENWIDTH, 126 * SCREENSCALE+ SafeAreaBottomHeight) withType:CapturePopupTypeExposure];
//    [self.exposureView configMinimumValue:self.efCapture.minISO MaximumValue:self.efCapture.maxISO];
    [self.exposureBgView addSubview:_exposureView];
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture {
}


// 给手动对焦视图添加动画
// Animate the manual focus view
- (void)animateFocusView:(CGPoint)currentPoint{
    self.focusView.center = currentPoint;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.8;
    
    CABasicAnimation *alphaAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    alphaAnimation.fromValue = @1;
    alphaAnimation.toValue   = @1;
    alphaAnimation.repeatCount = 1;
    alphaAnimation.duration = .8;
    
    CABasicAnimation *focusAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    focusAnimation.fromValue = @1.7;
    focusAnimation.toValue   = @1;
    focusAnimation.repeatCount = 1;
    focusAnimation.duration = .3;
    
    CABasicAnimation *focusAnimation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    focusAnimation1.fromValue = @1;
    focusAnimation1.toValue   = @1;
    focusAnimation1.repeatCount = 1;
    focusAnimation1.beginTime = 0.3;
    focusAnimation1.duration = 0.5;
    
    [group setAnimations:@[alphaAnimation,focusAnimation,focusAnimation1]];
    [self.focusView.layer addAnimation:group forKey:@"transform.scale"];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.isHidden) {
        self.isHidden = NO;
        self.contentView.hidden = NO;
    }
}

#pragma mark -- EFContentViewDelegate
-(void)didSelectedBtTag:(NSInteger)tag{
    switch (tag) {
        case 0:
//            [self.efCapture switchCamera];
//            [self deviceIsSupportFlash];
            break;
        case 1:
            [self.scenePreview showFilterView:YES];
            self.contentView.hidden = YES;
            self.isHidden = YES;
            break;
        case 2:
            [self.scenePreview showBeautyView:YES];
            self.isHidden = YES;
            self.contentView.hidden = YES;
            break;
        case 3:{
            if (self.propsView.hidden) {
                self.propsView.hidden = NO;
                self.contentView.hidden = YES;
            }
            break;
        }
        case 4:{
            if (self.stickerView.hidden) {
                self.stickerView.hidden = NO;
                self.contentView.hidden = YES;
            }
            break;
        }
        case 5:{
            if (self.compoundCaptionView.hidden) {
                self.compoundCaptionView.hidden = NO;
                self.contentView.hidden = YES;
            }
            break;
        }
        case 6:{
//            self.efCapture.flashOn = !self.efCapture.flashOn;
            break;
        }
        case 7:{
            if (!self.contentView.hidden) {
                self.contentView.hidden = YES;
                self.zoomBgView.hidden = NO;
            }
            break;
        }
        case 8:{
            if (!self.contentView.hidden) {
                self.contentView.hidden = YES;
                self.exposureBgView.hidden = NO;
            }
            break;
        }
        case 1000:{

        }
            break;
            
        case 9:{
            if (self.transitionView.hidden) {
                self.transitionView.hidden = NO;
                self.contentView.hidden = YES;
            }
        }
            break;
        case 10:{

            self.contentView.hidden = YES;
            NvCaptionDialogViewController *dialogVC = [NvCaptionDialogViewController new];
            dialogVC.delegate = self;
            [dialogVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
            //必要配置
            //must configure
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
            self.providesPresentationContextTransitionStyle = YES;
            self.definesPresentationContext = YES;
            [self presentViewController:dialogVC animated:YES completion:NULL];
        }
            break;
        case 12:{
            [self.scenePreview showMakeupView:YES];
            self.contentView.hidden = YES;
            self.isHidden = YES;
        }
            break;
  
        default:{
            
        }
            break;
    }
}
@end
