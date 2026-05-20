//
//  NvSetUpViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/24.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvSetUpViewController.h"
#import "NvsStreamingContext.h"
#import "NvAttributeLabel.h"
#import "NvWebViewController.h"
#import <NvBaseCommon/UIColor+NvColor.h>
#import <NvBaseCommon/NvToast.h>
#import <NvSDKCommon/NvUtils.h>
#import <Masonry/Masonry.h>
#import "NvBeautySliderView.h"
#import <NvSDKCommon/NvSDKUtils.h>
#import <NvSDKCommon/NvHttpRequest.h>

@interface NvSetUpViewController ()<UITextFieldDelegate, NvAttributeLabelDelegate,NvBeautySliderViewDelegate>

//type: 0.拍摄分辨率  1.输出分辨率  2.HDR设置   3.resolution设置    4.导出设置   5、缓存buffer
//type: 0. Shooting resolution 1. Output resolution 2.HDR setting 3.resolution setting 4. 5. Cache the buffer
@property (nonatomic, copy) void(^btnClickBlock)(UIButton *btn, NSInteger type);

//硬件编码器支持
// Hardware encoder support
@property (nonatomic, strong) UISwitch *hardwareSwitch;

//背景模糊填充
// Background blur fill
@property (nonatomic, strong) UISwitch *fillSwitch;

//开启素材授权
//Enabling asset licensing
@property (nonatomic, strong) UISwitch *assetLicSwitch;
//显示内测素材
//Displays the private test material
@property (nonatomic, strong) UISwitch *testMaterialSwitch;

//码率
// Bit rate
@property (nonatomic, strong) UITextField *bitField;

@property (nonatomic, assign) int64_t advice;

//是否切换hevc
// Whether to switch hevc
@property (nonatomic, strong) UISwitch *hevcSwitch;

@property (nonatomic, strong) NSArray *hevcConfigArray;

@property (nonatomic, strong) UIView *hdrView;

@property (nonatomic, strong) UISwitch *pictureModeSwitch;

@property (nonatomic, strong) NvBeautySliderView *hdrSlider;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UILabel *otherLabel;
@end

@implementation NvSetUpViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__func__);
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"Setting" , @"设置");
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#F5F5F5"];
    
    if (@available(iOS 15.0, *)) {
        self.navigationController.navigationBar.scrollEdgeAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor nv_colorWithHexRGB:@"#000000"], NSFontAttributeName:[NvUtils fontWithSize:16]};
        self.navigationController.navigationBar.scrollEdgeAppearance.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.standardAppearance.backgroundColor = [UIColor whiteColor];
        self.navigationController.navigationBar.standardAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor nv_colorWithHexRGB:@"#000000"], NSFontAttributeName:[NvUtils fontWithSize:16]};
        
    } else {
        // Fallback on earlier versions
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor nv_colorWithHexRGB:@"#000000"], NSForegroundColorAttributeName, [NvUtils fontWithSize:16], NSFontAttributeName, nil]];
    }
    
    [self.backButton setImage:NvImageNamed(@"NvBlackBack") forState:UIControlStateNormal];
    [self addSubViews];
    
    NvAttributeLabel *serviceLabel = [[NvAttributeLabel alloc] initWithFrame:CGRectMake(30, SCREENHEIGHT - 140 * SCREENSCALE - INDICATOR, SCREENWIDTH - 60, 34 * SCREENSCALE)];
    serviceLabel.attriContent = [self getAttributeContext];
    serviceLabel.links = @[@"service",@"private"];
    serviceLabel.delegate = self;
    [self.view addSubview:serviceLabel];
    serviceLabel.alignment = NSTextAlignmentCenter;
    
    UILabel *version = [UILabel new];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    version.text = [infoDict objectForKey:@"CFBundleShortVersionString"];
    version.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    version.font = [UIFont systemFontOfSize:12 * SCREENSCALE ];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVersion)];
    [version addGestureRecognizer:tap];
    version.userInteractionEnabled = YES;
    [self.view addSubview:version];
    
    [version mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-INDICATOR);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (@available(iOS 15.0, *)) {
        self.navigationController.navigationBar.scrollEdgeAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[NvUtils fontWithSize:16]};
        self.navigationController.navigationBar.scrollEdgeAppearance.backgroundColor = [UIColor blackColor];
        self.navigationController.navigationBar.standardAppearance = [[UINavigationBarAppearance alloc] init];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.bitField resignFirstResponder];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return [self validateNumberByRegExp:string];
}

//限制只能输入数字
// Only numbers can be entered
- (BOOL)validateNumberByRegExp:(NSString*)string {
    BOOL isValid = YES;
    NSUInteger len = string.length;
    if (len > 0) {
        NSString *numberRegex = @"^[0-9.]*$";
        NSPredicate *numberPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
        isValid = [numberPredicate evaluateWithObject:string];
    }
    return isValid;
}

#pragma mark 拍摄1080，720选择点击事件
//Shoot 1080,720 Select Click event
- (void)SResolutionClick:(UIButton *)btn{
    btn.selected = YES;
    self.btnClickBlock(btn, 0);
}

#pragma mark 输出4k，1080，720，540选择点击事件
//Output 4k, 1080,720,540 Select Click Event
- (void)OResolutionClick:(UIButton *)btn{
    
    if ([btn.titleLabel.text isEqualToString:@"4K"]) {
        
        NSSet *set = [NSSet setWithObjects:
                      @"iPhone 4S",
                      @"iPhone 5",
                      @"iPhone 5c",
                      @"iPhone 5s",
                      @"iPhone 6 Plus",
                      @"iPhone 6",
                      @"iPhone 6s",
                      @"iPhone 6s Plus",
                      @"iPhone SE",
                      nil];
        if ([set containsObject:[NvUtils iphoneType]]) {
            
            [UIAlertController presentAlertFromVC:self
                                            title:NvLocalString(@"Tips" , @"提示")
                                          message:NvLocalString(@"Set4KTip" , @"iphone7以下设备不支持4k生成")
                                buttonTitleColors:nil
                                cancelButtonTitle:nil
                                 otherButtonTitle:NvLocalString(@"Sure", @"确定")
                               cancelButtonAction:nil
                                otherButtonAction:nil];

            return;
        }
    }
    btn.selected = YES;
    self.btnClickBlock(btn, 1);
}

#pragma mark 硬件编码器支持
//Hardware encoder support
-(void)switchAction:(UISwitch *)sender
{
    NSNumber *choose = sender.isOn?@1:@0;
    
    if ([self.fillSwitch isEqual:sender]) {
        [[NSUserDefaults standardUserDefaults] setValue:choose forKey:@"NvBackgroudBlurFilled"];
    }else if ([self.hevcSwitch isEqual:sender]){
        [self hiddenHEVCConfiguration:!sender.isOn];
        [[NSUserDefaults standardUserDefaults] setValue:choose forKey:@"NvHEVCModel"];
    }else if ([self.assetLicSwitch isEqual:sender]){
        [[NSUserDefaults standardUserDefaults] setValue:choose forKey:@"NvEnablingAssetLic"];
    }else if ([self.pictureModeSwitch isEqual:sender]){
        [[NSUserDefaults standardUserDefaults] setValue:choose forKey:@"NvSwitchPictureMode"];
    }else if ([self.testMaterialSwitch isEqual:sender]){
        [[NSUserDefaults standardUserDefaults] setValue:choose forKey:@"NvTestNumMaterial"];
    }
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark 添加子视图 Add subview
- (void)addSubViews{
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view);
        make.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-60 * SCREENSCALE - INDICATOR);
    }];
    
    self.containerView = [UIView new];
    [self.scrollView addSubview:self.containerView];
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.scrollView);
        make.width.mas_equalTo(self.scrollView);
    }];
    
    
    UILabel *shootingLabel = [UILabel new];
    shootingLabel.text = NvLocalString(@"CaptureSetting" , @"拍摄设置");
    shootingLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    shootingLabel.font = [UIFont boldSystemFontOfSize:16*SCREENSCALE];
    
    UIView *shootingView = [UIView new];
    shootingView.backgroundColor = [UIColor whiteColor];
    
    UILabel *SResolutionLabel = [UILabel new];
    SResolutionLabel.text = NvLocalString(@"CaptureResolution" , @"拍摄分辨率");
    SResolutionLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    SResolutionLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    
    UIButton *SResolution4KBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [SResolution4KBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [SResolution4KBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    SResolution4KBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    SResolution4KBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [SResolution4KBtn setTitle:@"4K" forState:UIControlStateNormal];
    [SResolution4KBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    SResolution4KBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [SResolution4KBtn addTarget:self action:@selector(SResolutionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *SResolution1080Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [SResolution1080Btn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [SResolution1080Btn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    SResolution1080Btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    SResolution1080Btn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [SResolution1080Btn setTitle:@"1080" forState:UIControlStateNormal];
    [SResolution1080Btn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    SResolution1080Btn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [SResolution1080Btn addTarget:self action:@selector(SResolutionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *SResolution720Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [SResolution720Btn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [SResolution720Btn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    SResolution720Btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    SResolution720Btn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [SResolution720Btn setTitle:@"720" forState:UIControlStateNormal];
    [SResolution720Btn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    SResolution720Btn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [SResolution720Btn addTarget:self action:@selector(SResolutionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    AVCaptureSession *session = [AVCaptureSession new];
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] ;
    BOOL sessionSupport3840x2160 = [session canSetSessionPreset:AVCaptureSessionPreset3840x2160];
    BOOL deviceSupport3840x2160 = [videoDevice supportsAVCaptureSessionPreset:AVCaptureSessionPreset3840x2160];
    
    [shootingView addSubview:SResolutionLabel];
    if (sessionSupport3840x2160 && deviceSupport3840x2160) {
        [shootingView addSubview:SResolution4KBtn];
    }
    
    [shootingView addSubview:SResolution1080Btn];
    [shootingView addSubview:SResolution720Btn];
    
    //    UILabel *line_1 = [UILabel new];
    //    line_1.backgroundColor = [UIColor nv_colorWithHexARGB:@"#10000000"];
    //
    //    UILabel *switchPictureModeLabel = [UILabel new];
    //    switchPictureModeLabel.text = NvLocalString(@"SwitchPictureMode" , @"切换为原生摄像机拍照");
    //    switchPictureModeLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    //    switchPictureModeLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    //
    //    self.pictureModeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH - 60, 45/2 * SCREENSCALE -31/2, 54 * SCREENSCALE, 11 * SCREENSCALE)];
    //    self.pictureModeSwitch.tag = 3333;
    //    [self.pictureModeSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    //
    //    [shootingView addSubview:line_1];
    //    [shootingView addSubview:switchPictureModeLabel];
    //    [shootingView addSubview:self.pictureModeSwitch];
    
    [self.containerView addSubview:shootingLabel];
    [self.containerView addSubview:shootingView];
    
    
    CGFloat left = 12 * SCREENSCALE;
    CGFloat top = 13 * SCREENSCALE;
    CGFloat space = 10 * SCREENSCALE;
    
    [shootingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView.mas_top).offset(20 * SCREENSCALE);
        make.left.mas_equalTo(left);
        make.right.mas_lessThanOrEqualTo(-left);
    }];
    
    [shootingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shootingLabel.mas_bottom).offset(5 * SCREENSCALE);
        make.left.mas_equalTo(0);
        make.width.offset(SCREENWIDTH);
        make.height.offset(50 * SCREENSCALE);
    }];
    
    [SResolutionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left);
        make.top.equalTo(shootingView.mas_top).offset(top * SCREENSCALE);
    }];
    
    [SResolution720Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.equalTo(SResolutionLabel.mas_centerY);
        make.width.mas_equalTo(60 * SCREENSCALE);
        make.right.mas_equalTo(-left);
    }];
    
    if (sessionSupport3840x2160 && deviceSupport3840x2160) {
        
        [SResolution1080Btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(SResolution720Btn.mas_left).offset(-space);
            make.centerY.equalTo(SResolutionLabel.mas_centerY);
            make.width.offset(60 * SCREENSCALE);
        }];
        [SResolution4KBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(SResolution1080Btn.mas_left).offset(-space);
            make.left.greaterThanOrEqualTo(SResolutionLabel.mas_right).offset(space);
            make.centerY.equalTo(SResolutionLabel.mas_centerY);
            make.width.offset(60 * SCREENSCALE);
        }];
    }else {
        
        [SResolution1080Btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(SResolution720Btn.mas_left).offset(-space);
            make.left.greaterThanOrEqualTo(SResolutionLabel.mas_right).offset(space);
            make.centerY.equalTo(SResolutionLabel.mas_centerY);
            make.width.offset(60 * SCREENSCALE);
        }];
    }
    
    //    [line_1 mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(SResolutionLabel.mas_bottom).offset(top * SCREENSCALE);
    //        make.left.equalTo(shootingView.mas_left).offset(left * SCREENSCALE);
    //        make.right.equalTo(shootingView.mas_right);
    //        make.height.offset(0.5);
    //    }];
    //
    //    [switchPictureModeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.left.equalTo(self.containerView.mas_left).offset(left * SCREENSCALE);
    //        make.top.equalTo(line_1.mas_bottom).offset(top * SCREENSCALE);
    //    }];
    //
    //    [self.pictureModeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.right.mas_equalTo(shootingView.mas_right).offset(-2*SCREENSCALE);
    //        make.top.equalTo(line_1.mas_bottom).offset(8 * SCREENSCALE);
    //        make.width.mas_equalTo(54 * SCREENSCALE );
    //        make.height.mas_equalTo(21 * SCREENSCALE);
    //    }];
    
    UILabel *outputLabel = [UILabel new];
    outputLabel.text = NvLocalString(@"Output Setting" , @"输出设置");
    outputLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    outputLabel.font = [UIFont boldSystemFontOfSize:16*SCREENSCALE];
    
    UIView *outputView = [UIView new];
    outputView.backgroundColor = [UIColor whiteColor];
    
    UILabel *OResolutionLabel = [UILabel new];
    OResolutionLabel.text = NvLocalString(@"OutputResolution" , @"输出分辨率");
    OResolutionLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    OResolutionLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    
    UIButton *OResolution4KBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [OResolution4KBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [OResolution4KBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    OResolution4KBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    OResolution4KBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [OResolution4KBtn setTitle:@"4K" forState:UIControlStateNormal];
    [OResolution4KBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    OResolution4KBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [OResolution4KBtn addTarget:self action:@selector(OResolutionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *OResolution1080PBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [OResolution1080PBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [OResolution1080PBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    OResolution1080PBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    OResolution1080PBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [OResolution1080PBtn setTitle:@"1080" forState:UIControlStateNormal];
    [OResolution1080PBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    OResolution1080PBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [OResolution1080PBtn addTarget:self action:@selector(OResolutionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *OResolution720Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [OResolution720Btn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [OResolution720Btn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    OResolution720Btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    OResolution720Btn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [OResolution720Btn setTitle:@"720" forState:UIControlStateNormal];
    [OResolution720Btn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    OResolution720Btn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [OResolution720Btn addTarget:self action:@selector(OResolutionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *OResolution540Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [OResolution540Btn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [OResolution540Btn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    OResolution540Btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    OResolution540Btn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [OResolution540Btn setTitle:@"540" forState:UIControlStateNormal];
    [OResolution540Btn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    OResolution540Btn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [OResolution540Btn addTarget:self action:@selector(OResolutionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *line = [UILabel new];
    line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#10000000"];
    
    UILabel *bitLabel = [UILabel new];
    bitLabel.text = NvLocalString(@"Bitrate" , @"码率");
    bitLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    bitLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    
    self.bitField = [UITextField new];
    self.bitField.delegate = self;
    NSAttributedString * string = [[NSAttributedString alloc]initWithString:NvLocalString(@"suggest Bitrate" , @"  建议6Mbps，最大500Mbps") attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xA8A2A2),NSFontAttributeName:[UIFont systemFontOfSize:12 * SCREENSCALE]}];
    self.bitField.attributedPlaceholder = string;
    self.bitField.backgroundColor = [UIColor clearColor];
    self.bitField.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#E5E5E5"].CGColor;
    self.bitField.layer.borderWidth = 0.5f;
    self.bitField.textColor = UIColor.blackColor;
    self.bitField.font = [UIFont systemFontOfSize:12 * SCREENSCALE];
    self.bitField.keyboardType = UIKeyboardTypeNumberPad;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textFieldDidChangeValue:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:_bitField];
    UILabel *Mlabel = [UILabel new];
    Mlabel.text = @"Mbps";
    Mlabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    Mlabel.font = [UIFont systemFontOfSize:12 * SCREENSCALE];
    
    [self.containerView addSubview:outputLabel];
    [self.containerView addSubview:outputView];
    [outputView addSubview:OResolutionLabel];
    [outputView addSubview:OResolution4KBtn];
    [outputView addSubview:OResolution1080PBtn];
    [outputView addSubview:OResolution720Btn];
    [outputView addSubview:OResolution540Btn];
    [outputView addSubview:line];
    [outputView addSubview:bitLabel];
    [outputView addSubview:_bitField];
    [outputView addSubview:Mlabel];
    
    [outputLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shootingView.mas_bottom).offset(20 * SCREENSCALE);
        make.left.mas_equalTo(left);
        make.right.mas_lessThanOrEqualTo(-left);
    }];
    
    [outputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(outputLabel.mas_bottom).offset(5 * SCREENSCALE);
        make.width.offset(SCREENWIDTH);
        make.height.offset(90 * SCREENSCALE);
        make.left.mas_equalTo(0);
    }];
    
    [OResolutionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left);
        make.top.equalTo(outputView.mas_top).offset(top * SCREENSCALE);
    }];
    
    [OResolution4KBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(OResolutionLabel.mas_right).offset(space);
        make.centerY.equalTo(OResolutionLabel.mas_centerY);
        make.width.offset(50 * SCREENSCALE);
    }];
    
    [OResolution1080PBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(OResolution4KBtn.mas_right).offset(space);
        make.centerY.equalTo(OResolutionLabel.mas_centerY);
        make.width.offset(60 * SCREENSCALE);
    }];
    
    [OResolution720Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(OResolution1080PBtn.mas_right).offset(space);
        make.centerY.equalTo(OResolutionLabel.mas_centerY);
        make.width.mas_equalTo(55 * SCREENSCALE);
    }];
    
    [OResolution540Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(OResolution720Btn.mas_right).offset(space);
        make.right.mas_equalTo(-space);
        make.centerY.equalTo(OResolutionLabel.mas_centerY);
        make.width.mas_equalTo(55 * SCREENSCALE);
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(OResolutionLabel.mas_bottom).offset(top * SCREENSCALE);
        make.left.mas_equalTo(left);
        make.right.mas_equalTo(0);
        make.height.offset(0.5);
    }];
    
    [bitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line.mas_top).offset(top * SCREENSCALE);
        make.left.mas_equalTo(left);
    }];
    
    [_bitField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(bitLabel.mas_right).offset(space);
        make.centerY.equalTo(bitLabel.mas_centerY);
        make.height.offset(21 * SCREENSCALE);
        make.width.offset(180 * SCREENSCALE);
    }];
    
    [Mlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self->_bitField.mas_right).offset(space);
        make.right.mas_equalTo(-left);
        make.centerY.equalTo(self->_bitField.mas_centerY);
    }];
    
    //-------
    
    UILabel *hdrLabel = [UILabel new];
    hdrLabel.text = NvLocalString(@"HDR Configuration" , @"HDR设置");
    hdrLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    hdrLabel.font = [UIFont boldSystemFontOfSize:16*SCREENSCALE];
    
    self.hdrView = [UIView new];
    self.hdrView.backgroundColor = [UIColor whiteColor];
    
    UILabel *liveWindowLabel = [UILabel new];
    liveWindowLabel.text = NvLocalString(@"Preview Mode" , @"预览模式");
    liveWindowLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    liveWindowLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    
    UIButton *sdrBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sdrBtn.tag = 1;
    [sdrBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [sdrBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    sdrBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    sdrBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [sdrBtn setTitle:@"SDR" forState:UIControlStateNormal];
    [sdrBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    sdrBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [sdrBtn addTarget:self action:@selector(liveWindowClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *autoSDRBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    autoSDRBtn.tag = 3;
    [autoSDRBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [autoSDRBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    autoSDRBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    autoSDRBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [autoSDRBtn setTitle:@"ToMapSDR" forState:UIControlStateNormal];
    [autoSDRBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    autoSDRBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [autoSDRBtn addTarget:self action:@selector(liveWindowClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *deviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deviceBtn.tag = 4;
    [deviceBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [deviceBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    deviceBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    deviceBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [deviceBtn setTitle:@"Device" forState:UIControlStateNormal];
    [deviceBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    deviceBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [deviceBtn addTarget:self action:@selector(liveWindowClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *line2 = [UILabel new];
    line2.backgroundColor = [UIColor nv_colorWithHexARGB:@"#10000000"];
    
    UILabel *resolutionLabel = [UILabel new];
    resolutionLabel.text = NvLocalString(@"Bit Depth" , @"位深度配置");
    resolutionLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    resolutionLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    
    
    UIButton *resolution_8btBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resolution_8btBtn.tag = 1;
    [resolution_8btBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [resolution_8btBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    resolution_8btBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    resolution_8btBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [resolution_8btBtn setTitle:@"8bit" forState:UIControlStateNormal];
    [resolution_8btBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    resolution_8btBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [resolution_8btBtn addTarget:self action:@selector(resolutionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *resolution_16btBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resolution_16btBtn.tag = 2;
    [resolution_16btBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [resolution_16btBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    resolution_16btBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    resolution_16btBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [resolution_16btBtn setTitle:@"16bit" forState:UIControlStateNormal];
    [resolution_16btBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    resolution_16btBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [resolution_16btBtn addTarget:self action:@selector(resolutionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *resolution_autoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resolution_autoBtn.tag = 3;
    [resolution_autoBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [resolution_autoBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    resolution_autoBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    resolution_autoBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [resolution_autoBtn setTitle:@"auto" forState:UIControlStateNormal];
    [resolution_autoBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    resolution_autoBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [resolution_autoBtn addTarget:self action:@selector(resolutionClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *line3 = [UILabel new];
    line3.backgroundColor = [UIColor nv_colorWithHexARGB:@"#10000000"];
    
    UILabel *SdrtoHdrLabel = [UILabel new];
    SdrtoHdrLabel.text = NvLocalString(@"SDR to HDR Color gain" , @"SDR to HDR颜色增益");
    SdrtoHdrLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    SdrtoHdrLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    
    self.hdrSlider = [[NvBeautySliderView alloc] init];
    self.hdrSlider.minValue = 0;
    self.hdrSlider.maxValue = 10.0;
    self.hdrSlider.value = 0;
    self.hdrSlider.delegate = self;
    self.hdrSlider.hiddenIndicatorView = YES;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ISCHANGESDRTOHDRCOLORGAIN"]) {
        float value = [[NSUserDefaults standardUserDefaults] floatForKey:@"SDRTOHDRCOLORGAIN"];
        self.hdrSlider.value = [[NSString stringWithFormat:@"%.2f", value] floatValue];
    }else{
        self.hdrSlider.value = 2.0;
    }
    self.hdrSlider.thumbImage = @"Nvslider";
    self.hdrSlider.indicatorTextColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    self.hdrSlider.pointForamt = @"%.1f";
    
    UILabel *lineSdrtoHdr = [UILabel new];
    lineSdrtoHdr.backgroundColor = [UIColor nv_colorWithHexARGB:@"#10000000"];
    
    UILabel *HEVCLabel = [UILabel new];
    HEVCLabel.text = NvLocalString(@"Switch HEVC" , @"切换导出格式为HEVC");
    HEVCLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    HEVCLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    
    self.hevcSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH - 60, 135*SCREENSCALE - 45 * SCREENSCALE+30*SCREENSCALE/2.0, 54 * SCREENSCALE, 11 * SCREENSCALE)];
    self.hevcSwitch.tag = 1012;
    [self.hevcSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *line4 = [UILabel new];
    line4.backgroundColor = [UIColor nv_colorWithHexARGB:@"#10000000"];
    
    UILabel *exportLabel = [UILabel new];
    exportLabel.text = NvLocalString(@"export Model" , @"导出配置");
    exportLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    exportLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    
    UIButton *export_noneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    export_noneBtn.tag = 1;
    [export_noneBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [export_noneBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    export_noneBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    export_noneBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [export_noneBtn setTitle:@"SDR" forState:UIControlStateNormal];
    [export_noneBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    export_noneBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [export_noneBtn addTarget:self action:@selector(exportBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *export_st2084Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    export_st2084Btn.tag = 2;
    [export_st2084Btn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [export_st2084Btn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    export_st2084Btn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    export_st2084Btn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [export_st2084Btn setTitle:@"ST2084" forState:UIControlStateNormal];
    [export_st2084Btn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    export_st2084Btn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [export_st2084Btn addTarget:self action:@selector(exportBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *export_hlgBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    export_hlgBtn.tag = 3;
    [export_hlgBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [export_hlgBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    export_hlgBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    export_hlgBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [export_hlgBtn setTitle:@"HLG" forState:UIControlStateNormal];
    [export_hlgBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    export_hlgBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [export_hlgBtn addTarget:self action:@selector(exportBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *export_dolbyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    export_dolbyBtn.tag = 4;
    [export_dolbyBtn setImage:NvImageNamed(@"Oval 2 Copy") forState:UIControlStateNormal];
    [export_dolbyBtn setImage:NvImageNamed(@"NvSetting_Select") forState:UIControlStateSelected];
    export_dolbyBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 6 * SCREENSCALE, 0, 0);
    export_dolbyBtn.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    [export_dolbyBtn setTitle:@"DOLBY" forState:UIControlStateNormal];
    [export_dolbyBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#333333"] forState:UIControlStateNormal];
    export_dolbyBtn.titleLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    [export_dolbyBtn addTarget:self action:@selector(exportBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.containerView addSubview:hdrLabel];
    [self.containerView addSubview:self.hdrView];
    
    self.hevcConfigArray = @[line4,exportLabel,export_noneBtn,export_st2084Btn,export_hlgBtn,export_dolbyBtn];
    
    [self.hdrView addSubview:liveWindowLabel];
    [self.hdrView addSubview:sdrBtn];
    [self.hdrView addSubview:autoSDRBtn];
    [self.hdrView addSubview:deviceBtn];
    [self.hdrView addSubview:line2];
    [self.hdrView addSubview:resolutionLabel];
    [self.hdrView addSubview:resolution_8btBtn];
    [self.hdrView addSubview:resolution_16btBtn];
    [self.hdrView addSubview:resolution_autoBtn];
    [self.hdrView addSubview:line3];
    [self.hdrView addSubview:SdrtoHdrLabel];
    [self.hdrView addSubview:self.hdrSlider];
    [self.hdrView addSubview:lineSdrtoHdr];
    [self.hdrView addSubview:HEVCLabel];
    [self.hdrView addSubview:self.hevcSwitch];
    [self.hdrView addSubview:line4];
    [self.hdrView addSubview:exportLabel];
    [self.hdrView addSubview:export_noneBtn];
    [self.hdrView addSubview:export_st2084Btn];
    [self.hdrView addSubview:export_hlgBtn];
    [self.hdrView addSubview:export_dolbyBtn];
    
    [hdrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(outputView.mas_bottom).offset(20 * SCREENSCALE);
        make.left.mas_equalTo(left);
        make.right.mas_lessThanOrEqualTo(-left);
    }];
    
    [self.hdrView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(hdrLabel.mas_bottom).offset(5 * SCREENSCALE);
        make.left.mas_equalTo(0);
        make.width.offset(SCREENWIDTH);
    }];
    
    [liveWindowLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left);
        make.top.equalTo(self.hdrView.mas_top).offset(top * SCREENSCALE);
    }];
    
    [sdrBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(liveWindowLabel.mas_right).offset(space);
        make.centerY.equalTo(liveWindowLabel.mas_centerY);
        make.width.offset(50 * SCREENSCALE);
    }];
    
    [autoSDRBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sdrBtn.mas_right).offset(space);
        make.centerY.equalTo(liveWindowLabel.mas_centerY);
        make.width.offset(100 * SCREENSCALE);
    }];
    
    [deviceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(autoSDRBtn.mas_right).offset(space);
        make.right.mas_equalTo(-left);
        make.centerY.equalTo(liveWindowLabel.mas_centerY);
        make.width.offset(80 * SCREENSCALE);
    }];
    
    if (![NvHDRManager isSupportLivewindow]) {
        
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.hdrView.mas_top).offset(0 * SCREENSCALE);
            make.left.equalTo(self.hdrView.mas_left).offset(left);
            make.right.equalTo(self.hdrView.mas_right);
            make.height.offset(0.5);
            
        }];
        liveWindowLabel.hidden = YES;
        sdrBtn.hidden = YES;
        autoSDRBtn.hidden = YES;
        deviceBtn.hidden = YES;
    }else{
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(liveWindowLabel.mas_bottom).offset(top * SCREENSCALE);
            make.left.equalTo(self.hdrView.mas_left).offset(left);
            make.right.equalTo(self.hdrView.mas_right);
            make.height.offset(0.5);
        }];
    }
    
    [resolutionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line2.mas_top).offset(top * SCREENSCALE);
        make.left.mas_equalTo(left);
    }];
    
    [resolution_8btBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(resolutionLabel.mas_right).offset(space);
        make.centerY.equalTo(resolutionLabel.mas_centerY);
        make.width.offset(60 * SCREENSCALE);
    }];
    
    [resolution_16btBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(resolution_8btBtn.mas_right).offset(space);
        make.centerY.equalTo(resolutionLabel.mas_centerY);
        make.width.offset(60 * SCREENSCALE);
    }];
    
    [resolution_autoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(resolution_16btBtn.mas_right).offset(space);
        make.right.mas_equalTo(-left);
        make.centerY.equalTo(resolutionLabel.mas_centerY);
        make.width.offset(60 * SCREENSCALE);
    }];
    
    if (![NvHDRManager isSupportEditing]) {
        [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(line2.mas_bottom).offset(0);
            make.left.equalTo(self.hdrView.mas_left).offset(left);
            make.right.equalTo(self.hdrView.mas_right);
            make.height.offset(0.5);
            if (![NvHDRManager isSupportExporter]) {
                make.bottom.mas_equalTo(self.hdrView.mas_bottom).offset(0);
            }
        }];
        resolutionLabel.hidden = YES;
        resolution_8btBtn.hidden = YES;
        resolution_16btBtn.hidden = YES;
        resolution_autoBtn.hidden = YES;
    }else{
        [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(resolutionLabel.mas_bottom).offset(top * SCREENSCALE);
            make.left.equalTo(self.hdrView.mas_left).offset(left);
            make.right.equalTo(self.hdrView.mas_right);
            make.height.offset(0.5);
            if (![NvHDRManager isSupportExporter]) {
                make.bottom.mas_equalTo(self.hdrView.mas_bottom).offset(0);
            }
        }];
    }
    
    [SdrtoHdrLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line3.mas_top).offset(top * SCREENSCALE);
        make.left.mas_equalTo(left);
    }];
    
    [self.hdrSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(SdrtoHdrLabel.mas_right).offset(space);
        make.top.equalTo(line3.mas_top).offset(6 * SCREENSCALE);
        make.right.mas_equalTo(- left);
        make.height.mas_equalTo(30.0f);
        make.width.mas_greaterThanOrEqualTo(150.0f);
    }];
    
    [lineSdrtoHdr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(SdrtoHdrLabel.mas_bottom).offset(top * SCREENSCALE);
        make.left.mas_equalTo(left);
        make.right.mas_equalTo(0);
        make.height.offset(0.5);
    }];
    
    [HEVCLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lineSdrtoHdr.mas_top).offset(top * SCREENSCALE);
        make.left.mas_equalTo(left);
    }];
    
    [_hevcSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-space);
        make.left.greaterThanOrEqualTo(HEVCLabel.mas_right).offset(space);
        make.centerY.equalTo(HEVCLabel.mas_centerY).offset(-3* SCREENSCALE);
        make.width.offset(54 * SCREENSCALE);
        make.height.offset(21 * SCREENSCALE);
    }];
    
    [line4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(HEVCLabel.mas_bottom).offset(top * SCREENSCALE);
        make.left.mas_equalTo(left);
        make.right.mas_equalTo(0);
        make.height.offset(0.5);
    }];
    
    [exportLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(line4.mas_top).offset(top * SCREENSCALE);
        make.left.mas_equalTo(left);
        if ([NvHDRManager isSupportExporter]) {
            make.bottom.mas_equalTo(self.hdrView.mas_bottom).offset(-top * SCREENSCALE);
        }
    }];
    
    [export_noneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.greaterThanOrEqualTo(exportLabel.mas_right).offset(5 * SCREENSCALE);
        make.centerY.equalTo(exportLabel.mas_centerY);
        make.width.offset(50 * SCREENSCALE);
    }];
    
    [export_st2084Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(export_noneBtn.mas_right).offset(5 * SCREENSCALE);
        make.centerY.equalTo(exportLabel.mas_centerY);
        make.width.offset(70 * SCREENSCALE);
    }];
    
    [export_hlgBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(export_st2084Btn.mas_right).offset(5 * SCREENSCALE);
        make.centerY.equalTo(exportLabel.mas_centerY);
        make.width.offset(50 * SCREENSCALE);
    }];
    
    [export_dolbyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(export_hlgBtn.mas_right).offset(5 * SCREENSCALE);
        make.right.mas_equalTo(-left);
        make.centerY.equalTo(exportLabel.mas_centerY);
        make.width.offset(70 * SCREENSCALE);
    }];
    
    if (![NvHDRManager isSupportExporter]) {
        for (UIView *view in self.hevcConfigArray) {
            view.hidden = YES;
        }
        HEVCLabel.hidden = YES;
        self.hevcSwitch.hidden = YES;
        exportLabel.hidden = YES;
    }
    //-------
    UILabel *otherLabel = [UILabel new];
    otherLabel.text = NvLocalString(@"Other" , @"其他");
    otherLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    otherLabel.font = [UIFont boldSystemFontOfSize:16*SCREENSCALE];
    self.otherLabel = otherLabel;
    
    UIView *otherView = [UIView new];
    otherView.backgroundColor = [UIColor whiteColor];
    
    UILabel *fillLabel = [UILabel new];
    fillLabel.text = NvLocalString(@"Blur" , @"背景模糊填充");
    fillLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    fillLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    
    self.fillSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH - 60, 45/2 * SCREENSCALE -31/2, 54 * SCREENSCALE, 11 * SCREENSCALE)];
    self.fillSwitch.tag = 1011;
    [self.fillSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *assetLicLine = [UILabel new];
    assetLicLine.backgroundColor = [UIColor nv_colorWithHexARGB:@"#10000000"];
    
    UILabel *assetLicLabel = [UILabel new];
    assetLicLabel.text = NvLocalString(@"Enabling Asset Licensing" , @"开启素材授权");
    assetLicLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    assetLicLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
    
    NSString *bundleid = [[NSBundle mainBundle] bundleIdentifier];
    if (![bundleid isEqualToString:@"com.meishe.videoshow"]) {
        self.assetLicSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH - 60, 45/2 * SCREENSCALE -31/2, 54 * SCREENSCALE, 11 * SCREENSCALE)];
        self.assetLicSwitch.tag = 1112;
        [self.assetLicSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    
    [self.containerView addSubview:otherLabel];
    [self.containerView addSubview:otherView];
    [otherView addSubview:fillLabel];
    [otherView addSubview:_fillSwitch];

    if (self.assetLicSwitch) {
        [otherView addSubview:assetLicLine];
        [otherView addSubview:assetLicLabel];
        [otherView addSubview:_assetLicSwitch];
    }
    
    if (![NvHDRManager isSupportExporter] && ![NvHDRManager isSupportEditing] && ![NvHDRManager isSupportLivewindow]) {
        hdrLabel.hidden = YES;
        self.hdrView.hidden = YES;
        [otherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(outputView.mas_bottom).offset(20 * SCREENSCALE);
            make.left.mas_equalTo(left);
            make.right.mas_lessThanOrEqualTo(-left);
        }];
    }else{
        [otherLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.hdrView.mas_bottom).offset(20 * SCREENSCALE);
            make.left.mas_equalTo(left);
            make.right.mas_lessThanOrEqualTo(-left);
        }];
    }
    
    [fillLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(left);
        make.top.equalTo(otherView.mas_top).offset(top * SCREENSCALE);
    }];
    [self.fillSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-space);
        make.left.greaterThanOrEqualTo(fillLabel.mas_right).offset(space);
        make.centerY.equalTo(fillLabel.mas_centerY).offset(-3* SCREENSCALE);
        make.width.mas_equalTo(54 * SCREENSCALE );
        make.height.offset(21 * SCREENSCALE);
    }];
    
    
    
    if (self.assetLicSwitch) {
        [assetLicLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.fillSwitch.mas_bottom).offset(top * SCREENSCALE);
            make.left.mas_equalTo(left);
            make.right.mas_equalTo(0);
            make.height.offset(0.5);
        }];
        
        [assetLicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(left);
            make.top.equalTo(assetLicLine.mas_bottom).offset(top * SCREENSCALE);
        }];
        
        [self.assetLicSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-space);
            make.left.greaterThanOrEqualTo(assetLicLabel.mas_right).offset(space);
            make.centerY.equalTo(assetLicLabel.mas_centerY).offset(-3* SCREENSCALE);
            make.width.mas_equalTo(54 * SCREENSCALE );
            make.height.offset(21 * SCREENSCALE);
        }];
        [otherView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(otherLabel.mas_bottom).offset(5 * SCREENSCALE);
            make.left.equalTo(self.view.mas_left);
            make.width.offset(SCREENWIDTH);
            make.bottom.equalTo(self.assetLicSwitch.mas_bottom).offset(top * SCREENSCALE);
        }];
    }else{
        [otherView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(otherLabel.mas_bottom).offset(5 * SCREENSCALE);
            make.left.equalTo(self.view.mas_left);
            make.width.offset(SCREENWIDTH);
            make.bottom.equalTo(self.fillSwitch.mas_bottom).offset(top * SCREENSCALE);
        }];
    }
    
    [self.containerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.scrollView);
        make.width.mas_equalTo(self.scrollView);
        make.bottom.mas_equalTo(otherView.mas_bottom).offset(20);
    }];
    
    [self.view layoutIfNeeded];
    
    __weak typeof(self) weakSelf = self;
    self.btnClickBlock = ^(UIButton *btn, NSInteger type) {
        if (type == 0) {
            NSNumber *num;
            if ([btn.titleLabel.text isEqualToString:@"4K"]) {
                SResolution1080Btn.selected = NO;
                SResolution720Btn.selected = NO;
                num = @2160;
            }else if ([btn.titleLabel.text isEqualToString:@"1080"]) {
                SResolution4KBtn.selected = NO;
                SResolution720Btn.selected = NO;
                num = @1080;
            }else{
                SResolution4KBtn.selected = NO;
                SResolution1080Btn.selected = NO;
                num = @720;
            }
            [[NSUserDefaults standardUserDefaults] setValue:num forKey:@"NvRecordResolution"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else if(type == 1){
            NSNumber *num;
            NSNumber *num1;
            int64_t numt;
            if ([btn.titleLabel.text isEqualToString:@"4K"]) {
                weakSelf.advice = 60;
                OResolution1080PBtn.selected = NO;
                OResolution720Btn.selected = NO;
                OResolution540Btn.selected = NO;
                num = @2160;
                numt = 60 * NV_TIME_BASE;
                num1 = @(numt);
            }else if ([btn.titleLabel.text isEqualToString:@"1080"]){
                OResolution4KBtn.selected = NO;
                OResolution720Btn.selected = NO;
                OResolution540Btn.selected = NO;
                weakSelf.advice = 15;
                num = @1080;
                numt = 15 * NV_TIME_BASE;
                num1 = @(numt);
            }else if ([btn.titleLabel.text isEqualToString:@"720"]){
                OResolution1080PBtn.selected = NO;
                OResolution540Btn.selected = NO;
                OResolution4KBtn.selected = NO;
                weakSelf.advice = 7;
                num = @720;
                numt = 7 * NV_TIME_BASE;
                num1 = @(numt);
            }else{
                OResolution1080PBtn.selected = NO;
                OResolution720Btn.selected = NO;
                OResolution4KBtn.selected = NO;
                weakSelf.advice = 4;
                num = @540;
                numt = 4 * NV_TIME_BASE;
                num1 = @(numt);
            }
            weakSelf.bitField.text = 0;
            [[NSUserDefaults standardUserDefaults] setValue:num1 forKey:@"NvCompileBitrate"];
            [[NSUserDefaults standardUserDefaults] setValue:num forKey:@"NvCompileResolution"];
        }else if(type == 2){
            NSNumber *num = [NSNumber numberWithInteger:btn.tag];
            if (btn.tag == 1) {
                autoSDRBtn.selected = NO;
                deviceBtn.selected = NO;
            }else if(btn.tag ==3 ){
                sdrBtn.selected = NO;
                deviceBtn.selected = NO;
            }else if(btn.tag ==4 ){
                sdrBtn.selected = NO;
                autoSDRBtn.selected = NO;
            }
            [[NSUserDefaults standardUserDefaults] setValue:num forKey:@"NvLiveWindowModel"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else if(type == 3){
            NSNumber *num = [NSNumber numberWithInteger:btn.tag];
            if (btn.tag == 1) {
                resolution_16btBtn.selected = NO;
                resolution_autoBtn.selected = NO;
            }else if(btn.tag == 2){
                resolution_8btBtn.selected = NO;
                resolution_autoBtn.selected = NO;
            }else if(btn.tag ==3 ){
                resolution_16btBtn.selected = NO;
                resolution_8btBtn.selected = NO;
            }
            [[NSUserDefaults standardUserDefaults] setValue:num forKey:@"NvResolutionConfiguration"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else if(type == 4){
            NSNumber *num = [NSNumber numberWithInteger:btn.tag];
            if (btn.tag == 1) {
                export_st2084Btn.selected = NO;
                export_hlgBtn.selected = NO;
                export_dolbyBtn.selected = NO;
            } else if(btn.tag == 2){
                export_noneBtn.selected = NO;
                export_hlgBtn.selected = NO;
                export_dolbyBtn.selected = NO;
            } else if(btn.tag ==3 ){
                export_st2084Btn.selected = NO;
                export_noneBtn.selected = NO;
                export_dolbyBtn.selected = NO;
            } else if(btn.tag ==4 ){
                export_st2084Btn.selected = NO;
                export_noneBtn.selected = NO;
                export_hlgBtn.selected = NO;
            }
            [[NSUserDefaults standardUserDefaults] setValue:num forKey:@"NvExportConfiguration"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }else{
            
        }
    };
    
    NSNumber * SResolutionNum = NV_UserInfo(@"NvRecordResolution");
    NSNumber * pictureModeNum = NV_UserInfo(@"NvSwitchPictureMode");
    NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
    NSNumber * fillNum = NV_UserInfo(@"NvBackgroudBlurFilled");
    NSNumber * beautyNum = NV_UserInfo(@"DefaultFilterBeautyEffect");
    NSNumber * bitNum = NV_UserInfo(@"NvCompileBitrate");
    
    NSNumber * liveWindowNum = NV_UserInfo(@"NvLiveWindowModel");
    NSNumber * resolutionNum = NV_UserInfo(@"NvResolutionConfiguration");
    NSNumber * exportNum = NV_UserInfo(@"NvExportConfiguration");
    NSNumber * hevcNum = NV_UserInfo(@"NvHEVCModel");
    
    NSNumber * assetLicNum = NV_UserInfo(@"NvEnablingAssetLic");
    
    if (SResolutionNum!=nil) {
        if (SResolutionNum.intValue == 1080) {
            SResolution1080Btn.selected = YES;
        }else if (SResolutionNum.intValue == 720){
            SResolution720Btn.selected = YES;
        }else if (SResolutionNum.intValue == 2160){
            SResolution4KBtn.selected = YES;
        }
    }
    
    if (pictureModeNum != nil) {
        if (pictureModeNum.intValue == 1) {
            [self.pictureModeSwitch setOn:YES];
        }else{
            [self.pictureModeSwitch setOn:NO];
        }
    }
    
    if (OResolutionNum!=nil) {
        if (OResolutionNum.intValue == 2160) {
            OResolution4KBtn.selected = YES;
        }else if (OResolutionNum.intValue == 1080){
            OResolution1080PBtn.selected = YES;
        }else if (OResolutionNum.intValue == 720){
            OResolution720Btn.selected = YES;
        }else if (OResolutionNum.intValue == 540){
            OResolution540Btn.selected = YES;
        }
    }
    
    if (fillNum!=nil) {
        if (fillNum.intValue == 1) {
            [_fillSwitch setOn:YES];
        }else{
            [_fillSwitch setOn:NO];
        }
    }
    
    
    if (self.assetLicSwitch) {
        if (assetLicNum!=nil) {
            if (assetLicNum.intValue == 1) {
                [_assetLicSwitch setOn:YES];
            }else{
                [_assetLicSwitch setOn:NO];
            }
        }else{
            [_assetLicSwitch setOn:YES];
        }
    }
    
    if (bitNum.longLongValue/NV_TIME_BASE == 15 || bitNum.longLongValue/NV_TIME_BASE == 7 || bitNum.longLongValue/NV_TIME_BASE == 4 || bitNum.longLongValue/NV_TIME_BASE == 60) {
        self.advice = bitNum.longLongValue/NV_TIME_BASE;
    }else{
        self.bitField.text = [NSString stringWithFormat:@"%lld",bitNum.longLongValue/NV_TIME_BASE];
    }
    
    if (liveWindowNum!=nil) {
        if (liveWindowNum.intValue == 1) {
            sdrBtn.selected = YES;
        }else if (liveWindowNum.intValue == 3){
            autoSDRBtn.selected = YES;
        }else if (liveWindowNum.intValue == 4){
            deviceBtn.selected = YES;
        }
    }
    
    if (resolutionNum!=nil) {
        if (resolutionNum.intValue == 1) {
            resolution_8btBtn.selected = YES;
        }else if (resolutionNum.intValue == 2){
            resolution_16btBtn.selected = YES;
        }else if (resolutionNum.intValue == 3){
            resolution_autoBtn.selected = YES;
        }
    }
    
    if (exportNum!=nil) {
        if (exportNum.intValue == 1) {
            export_noneBtn.selected = YES;
        } else if (exportNum.intValue == 2){
            export_st2084Btn.selected = YES;
        } else if (exportNum.intValue == 3){
            export_hlgBtn.selected = YES;
        } else if (exportNum.intValue == 4){
            export_dolbyBtn.selected = YES;
        }
    }
    
    [self hiddenHEVCConfiguration:YES];
    if (hevcNum!=nil) {
        if (hevcNum.intValue == 1) {
            [self.hevcSwitch setOn:YES];
            [self hiddenHEVCConfiguration:NO];
        }else{
            [self.hevcSwitch setOn:NO];
            [self hiddenHEVCConfiguration:YES];
        }
        
    }
    
    [self addTest:otherView];
}

- (void)addTest:(UIView *)otherView{
    
    if ([NvHttpRequest getTestMaterial]){
        
        CGFloat left = 12 * SCREENSCALE;
        CGFloat top = 13 * SCREENSCALE;
        CGFloat space = 10 * SCREENSCALE;
        NSNumber * testNumMaterialNum = NV_UserInfo(@"NvTestNumMaterial");
        
        UILabel *line = [UILabel new];
        line.backgroundColor = [UIColor nv_colorWithHexARGB:@"#10000000"];
        
        UILabel *testMaterialLabel = [UILabel new];
        testMaterialLabel.text = NvLocalString(@"Private test material" , @"显示内测素材");
        testMaterialLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
        testMaterialLabel.font = [UIFont systemFontOfSize:15 * SCREENSCALE];
        
        self.testMaterialSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(SCREENWIDTH - 60, 45/2 * SCREENSCALE -31/2, 54 * SCREENSCALE, 11 * SCREENSCALE)];
        self.testMaterialSwitch.tag = 4444;
        [self.testMaterialSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
        
        [otherView addSubview:line];
        [otherView addSubview:testMaterialLabel];
        [otherView addSubview:self.testMaterialSwitch];
        
        if (self.assetLicSwitch) {
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.assetLicSwitch.mas_bottom).offset(top * SCREENSCALE);
                make.left.equalTo(otherView.mas_left).offset(left * SCREENSCALE);
                make.right.equalTo(otherView.mas_right);
                make.height.offset(0.5);
            }];
        }else{
            [line mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.fillSwitch.mas_bottom).offset(top * SCREENSCALE);
                make.left.equalTo(otherView.mas_left).offset(left * SCREENSCALE);
                make.right.equalTo(otherView.mas_right);
                make.height.offset(0.5);
            }];
        }
        
        [testMaterialLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(left);
            make.top.equalTo(line.mas_bottom).offset(top * SCREENSCALE);
            make.right.lessThanOrEqualTo(self.testMaterialSwitch.mas_left).offset(-space);
        }];
        
        [self.testMaterialSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-space);
            make.top.equalTo(line.mas_bottom).offset(8 * SCREENSCALE);
            make.width.mas_equalTo(54 * SCREENSCALE);
            make.height.mas_equalTo(21 * SCREENSCALE);
        }];
        
        [otherView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.otherLabel.mas_bottom).offset(5 * SCREENSCALE);
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(SCREENWIDTH);
            make.bottom.equalTo(self.testMaterialSwitch.mas_bottom).offset(top * SCREENSCALE);
        }];
        
        if (testNumMaterialNum){
            self.testMaterialSwitch.on = testNumMaterialNum.boolValue;
        }
    }
}

- (void)liveWindowClick:(UIButton *)sender{
    sender.selected = YES;
    self.btnClickBlock(sender, 2);
}

- (void)resolutionClick:(UIButton *)sender{
    sender.selected = YES;
    self.btnClickBlock(sender, 3);
}

- (void)exportBtnClick:(UIButton *)sender{
    sender.selected = YES;
    self.btnClickBlock(sender, 4);
}

- (void)hiddenHEVCConfiguration:(BOOL)hidden{
    for (UIView *view in self.hevcConfigArray) {
        view.hidden = hidden;
    }
}

- (void)setAdvice:(int64_t)advice{
    _advice = advice;
    NSAttributedString * string = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:NvLocalString(@"Suggest Bitrate" , @"  建议%lldMbps，最大500Mbps"),advice] attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xA8A2A2),NSFontAttributeName:[UIFont systemFontOfSize:12 * SCREENSCALE]}];
    self.bitField.attributedPlaceholder = string;
}

- (void)tapVersion{
    NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"存储失败"];
    if (string) {
        [NvToast showInfoWithMessage:@"存储失败"];
    }
}

- (void)textFieldDidChangeValue:(NSNotification *)notification
{
    UITextField *sender = (UITextField *)[notification object];
    if (sender.text.length == 0) {
        NSNumber *num;
        int64_t numt;
        NSNumber * OResolutionNum = NV_UserInfo(@"NvCompileResolution");
        if (OResolutionNum!=nil) {
            if (OResolutionNum.intValue == 2160) {
                self.advice = 60;
                numt = 60 * NV_TIME_BASE;
                num = @(numt);
            }else if (OResolutionNum.intValue == 1080){
                self.advice = 15;
                numt = 15 * NV_TIME_BASE;
                num = @(numt);
            }else if (OResolutionNum.intValue == 720){
                self.advice = 7;
                numt = 7 * NV_TIME_BASE;
                num = @(numt);
            }else if (OResolutionNum.intValue == 540){
                self.advice = 4;
                numt = 4 * NV_TIME_BASE;
                num = @(numt);
            }
        }
        [[NSUserDefaults standardUserDefaults] setValue:num forKey:@"NvCompileBitrate"];
    }else{
        NSNumber *num;
        double i = sender.text.doubleValue;
        int64_t j;
        if (i >= 500) {
            j = 500 * NV_TIME_BASE;
        }else{
            j = i * NV_TIME_BASE;
        }
        num = @(j);
        [[NSUserDefaults standardUserDefaults] setValue:num forKey:@"NvCompileBitrate"];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

- (void)attributeLabel:(NvAttributeLabel *)label didResponseLink:(NSString *)link {
    NSString *url = @"";
    if ([link isEqualToString:@"service"]) {
        url = @"https://vsapi.meishesdk.com/app/privacy/service-agreement.html";
    }else if ([link isEqualToString:@"private"]) {
        url = @"https://vsapi.meishesdk.com/app/privacy/privacy-policy.html";
    }
    if (url.length > 0) {
        NvWebViewController *vc = [[NvWebViewController alloc] init];
        vc.urlString = url;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSMutableAttributedString *)getAttributeContext{
    NSString *str = NvLocalString(@"Service      Privacy", @"服务协议      隐私政策");
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:str];
    [attriStr addAttribute:NSFontAttributeName value:[NvUtils regularFontWithSize:15 * SCREENSCALE] range:NSMakeRange(0, str.length)];
    NSRange serviceRange = NSMakeRange(0, 4);
    NSRange privateRange = NSMakeRange(str.length - 4, 4);
    
    if (![NvUtils currentLanguagesIsChinese]){
        serviceRange = [str rangeOfString:@"Service"];
        privateRange = [str rangeOfString:@"Privacy"];
    }
    
    [attriStr addAttribute:NSForegroundColorAttributeName value:[UIColor nv_colorWithHexString:@"#5DA8F8"] range:serviceRange];
    [attriStr addAttribute:NSForegroundColorAttributeName value:[UIColor nv_colorWithHexString:@"#5DA8F8"] range:privateRange];
    [attriStr addAttribute:NSLinkAttributeName value:@"service://" range:serviceRange];
    [attriStr addAttribute:NSLinkAttributeName value:@"private://" range:privateRange];
    return attriStr;
}

#pragma mark - NvBeautySliderViewDelegate
-(void)sliderValueChanged:(UISlider *)paramSender {
    [[NvSDKUtils getSDKContext] setColorGainForSDRToHDR:paramSender.value];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ISCHANGESDRTOHDRCOLORGAIN"];
    [[NSUserDefaults standardUserDefaults] setFloat: paramSender.value forKey:@"SDRTOHDRCOLORGAIN"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
