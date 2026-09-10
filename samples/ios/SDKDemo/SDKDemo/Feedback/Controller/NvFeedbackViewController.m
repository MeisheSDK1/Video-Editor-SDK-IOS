//
//  NvFeedbackViewController.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/19.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFeedbackViewController.h"
#import "NvsStreamingContext.h"
#import "NvTipsView.h"
#import <sys/utsname.h>
#import <NvSDKCommon/NvHttpRequest.h>
#import <NvSDKCommon/NvUtils.h>
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NvToast.h>
@import NvBaseCommon;

@interface NvFeedbackViewController ()<UITextViewDelegate,UITextFieldDelegate,NvHttpRequestDelegate>

@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextView *contentTextview;
@property (nonatomic, strong) UITextField *contactTextfield;
@property (nonatomic, strong) UIButton *submitBtn;

@end

@implementation NvFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NvLocalString(@"Feedback", @"反馈");
    self.view.backgroundColor = [UIColor nv_colorWithHexRGB:@"#F5F5F5"];
    if (@available(iOS 15.0, *)) {
        self.navigationController.navigationBar.scrollEdgeAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor nv_colorWithHexRGB:@"#000000"], NSFontAttributeName:[NvUtils fontWithSize:16]};
        self.navigationController.navigationBar.scrollEdgeAppearance.backgroundColor = [UIColor whiteColor];
    } else {
        // Fallback on earlier versions
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor nv_colorWithHexRGB:@"#000000"], NSForegroundColorAttributeName, [NvUtils fontWithSize:16], NSFontAttributeName, nil]];
    }
    
 
    [self.backButton setImage:NvImageNamed(@"NvBlackBack") forState:UIControlStateNormal];
    [self addSubViews];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (@available(iOS 15.0, *)) {
        self.navigationController.navigationBar.scrollEdgeAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[NvUtils fontWithSize:16]};
        self.navigationController.navigationBar.scrollEdgeAppearance.backgroundColor = [UIColor blackColor];
    }
}

#pragma mark 添加子视图  Add subview
- (void)addSubViews{
    UILabel *feedbackLabel = [[UILabel alloc]init];
    feedbackLabel.text = NvLocalString(@"Feedback Content", @"反馈内容");
    feedbackLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    feedbackLabel.font = [NvUtils fontWithSize:16.f];
    [self.view addSubview:feedbackLabel];
    [feedbackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(13 * SCREENSCALE);
        make.top.equalTo(self.view.mas_top).offset(20 * SCREENSCALE);
    }];
    
    self.contentTextview = [[UITextView alloc]init];
    self.contentTextview.backgroundColor = [UIColor whiteColor];
    self.contentTextview.delegate = self;
    self.contentTextview.font = [NvUtils fontWithSize:12];
    self.contentTextview.textColor = [UIColor nv_colorWithHexARGB:@"#CC000000"];
    [self.view addSubview:self.contentTextview];
    [self.contentTextview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(44 * SCREENSCALE);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.offset(195.5f * SCREENSCALE);
        
    }];
    
    self.placeholderLabel = [[UILabel alloc]init];
    self.placeholderLabel.text = NvLocalString(@"FeedTip", @"请描述您想反馈的问题内容");
    self.placeholderLabel.textColor = [UIColor nv_colorWithHexRGB:@"#B5B5B5"];
    self.placeholderLabel.font = [NvUtils fontWithSize:14.f];
    [self.contentTextview addSubview:self.placeholderLabel];
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentTextview).offset(8 * SCREENSCALE);
        make.left.equalTo(feedbackLabel.mas_left);
    }];
    
    
    UILabel *feedbackLabel1 = [[UILabel alloc]init];
    feedbackLabel1.text = NvLocalString(@"connect", @"联系方式（手机，微信号，QQ号）");
    feedbackLabel1.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    feedbackLabel1.font = [NvUtils fontWithSize:16.f];
    [self.view addSubview:feedbackLabel1];
    [feedbackLabel1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(feedbackLabel.mas_leading);
        make.top.equalTo(self.contentTextview.mas_bottom).offset(20 * SCREENSCALE);
    }];
    
    NSString *placeholderStr = NvLocalString(@"FeedPlaceHolder", @"     留下联系方式能帮助我们更好的解决问题哦～");
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:placeholderStr];
    [placeholder addAttribute:NSForegroundColorAttributeName value:[UIColor nv_colorWithHexRGB:@"#B5B5B5"] range:NSMakeRange(0, placeholderStr.length)];
    [placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14.f] range:NSMakeRange(0, placeholderStr.length)];
    self.contactTextfield = [[UITextField alloc]init];
    self.contactTextfield.backgroundColor = [UIColor whiteColor];
    self.contactTextfield.attributedPlaceholder = placeholder;
    self.contactTextfield.font = [NvUtils fontWithSize:14.f];
    self.contactTextfield.textColor = [UIColor nv_colorWithHexARGB:@"#CC000000"];
    self.contactTextfield.delegate = self;
    [self.view addSubview:self.contactTextfield];
    [self.contactTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentTextview.mas_leading);
        make.trailing.equalTo(self.contentTextview.mas_trailing);
        make.top.equalTo(feedbackLabel1.mas_bottom).offset(10 * SCREENSCALE);
        make.height.offset(40 * SCREENSCALE);
    }];
    
    self.submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.submitBtn setBackgroundImage:NvImageNamed(@"NvFeedback_unselected") forState:UIControlStateNormal];
    self.submitBtn.titleLabel.font = [NvUtils regularFontWithSize:16];
    [self.submitBtn setTitle:NvLocalString(@"Commit", @"提交") forState:UIControlStateNormal];
    [self.submitBtn setTitleColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"] forState:UIControlStateNormal];
    [self.submitBtn addTarget:self action:@selector(submitBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.submitBtn.layer.cornerRadius = 20*SCREENSCALE;
    [self.view addSubview:self.submitBtn];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contactTextfield.mas_bottom).offset(52 * SCREENSCALE);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.offset(173.5 * SCREENSCALE);
        make.height.offset(40 * SCREENSCALE);
    }];
    
    UILabel *bottomLabel = [[UILabel alloc]init];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.text = NvLocalString(@"Business Cooperation", @"商务合作\nTel:010-82851890\nMail:meishe_sdk@cdv.com");
    bottomLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    bottomLabel.numberOfLines = 0;
    bottomLabel.font = [NvUtils fontWithSize:12];
    [self.view addSubview:bottomLabel];
    [bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-25 * SCREENSCALE);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.contactTextfield resignFirstResponder];
    [self.contentTextview resignFirstResponder];
}

#pragma mark submitBtnClick——提交按钮点击
//submitBtnClick -- Submit button click
- (void)submitBtnClick:(UIButton *)sender{
    if (self.contentTextview.text.length == 0) {
        [self addTipsViewString:NvLocalString(@"FeedContentTip", @"反馈内容不能为空")];
        return;
    }
    if (self.contactTextfield.text.length == 0) {
        [self addTipsViewString:NvLocalString(@"Contact information", @"请填写您的联系方式")];
        return;
    }
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *model = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    int large,minor,revision;
    [NvsStreamingContext getSdkVersion:&large minorVersion:&minor revisionNumber:&revision];
    
    [[NvHttpRequest sharedInstance] feedBackWithContent:self.contentTextview.text withContact:self.contactTextfield.text withSdkVersion:[NSString stringWithFormat:@"%d.%d.%d",large,minor,revision] withDeviceModel:[self currentModel:model] withDelegate:self];
}

#pragma mark NvHttpRequestDelegate
- (void)feedBackWithDictionary:(NSDictionary *)dic{
    if ([dic[@"errNo"] integerValue] == 0) {
        [self addTipsViewString:NvLocalString(@"Commit Succes", @"提交成功")];
    }else{
        [self addTipsViewString:NvLocalString(@"Net Error", @"网络异常")];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

#pragma mark 提示视图 Prompt view
- (void)addTipsViewString:(NSString *)text{
    NvTipsView *tip = [[NvTipsView alloc]initWithFrame:self.view.frame withTitle:text withColor:[UIColor nv_colorWithHexRGB:@"#4D4F51"] withCenter:YES];
    [self.view addSubview:tip];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tip removeFromSuperview];
    });
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSMutableString * changedString=[[NSMutableString alloc]initWithString:textField.text];
      [changedString replaceCharactersInRange:range withString:string];
      
      if (changedString.length!=0 && self.contentTextview.text.length >0) {
          [self.submitBtn setBackgroundImage:NvImageNamed(@"NvFeedback") forState:UIControlStateNormal];
          self.submitBtn.enabled = YES;
      }else{
          [self.submitBtn setBackgroundImage:NvImageNamed(@"NvFeedback_unselected") forState:UIControlStateNormal];
          self.submitBtn.enabled = NO;
      }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField{
    
    return YES;
}

#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        self.placeholderLabel.hidden = NO;
    }else{
        self.placeholderLabel.hidden = YES;
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        self.placeholderLabel.hidden = NO;
    }else{
        self.placeholderLabel.hidden = YES;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView{

}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSMutableString * changedString=[[NSMutableString alloc]initWithString:textView.text];
    [changedString replaceCharactersInRange:range withString:text];
    
    if (changedString.length!=0 && self.contactTextfield.text.length >0) {
        [self.submitBtn setBackgroundImage:NvImageNamed(@"NvFeedback") forState:UIControlStateNormal];
        self.submitBtn.enabled = YES;
    }else{
        [self.submitBtn setBackgroundImage:NvImageNamed(@"NvFeedback_unselected") forState:UIControlStateNormal];
        self.submitBtn.enabled = NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length == 0) {
        self.placeholderLabel.hidden = NO;
    }else{
        self.placeholderLabel.hidden = YES;
        UITextRange *range = textView.markedTextRange;
        NSUInteger length = [self getToInt:textView.text] / 2;
        if (!range) {
            if (length > 1000) {
                [NvToast showInfoWithMessage:NvLocalString(@"FeedBackDescraption", @"描述最多输入1000个字")];
            }
        }
    }
}

- (NSInteger)getToInt:(NSString*)strtemp {
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* da = [strtemp dataUsingEncoding:enc];
    return [da length];
}

- (NSString *)currentModel:(NSString *)phoneModel {
    
    if ([phoneModel isEqualToString:@"iPhone3,1"] ||
        [phoneModel isEqualToString:@"iPhone3,2"])   return @"iPhone 4";
    if ([phoneModel isEqualToString:@"iPhone4,1"])   return @"iPhone 4S";
    if ([phoneModel isEqualToString:@"iPhone5,1"] ||
        [phoneModel isEqualToString:@"iPhone5,2"])   return @"iPhone 5";
    if ([phoneModel isEqualToString:@"iPhone5,3"] ||
        [phoneModel isEqualToString:@"iPhone5,4"])   return @"iPhone 5C";
    if ([phoneModel isEqualToString:@"iPhone6,1"] ||
        [phoneModel isEqualToString:@"iPhone6,2"])   return @"iPhone 5S";
    if ([phoneModel isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    if ([phoneModel isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    if ([phoneModel isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([phoneModel isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    if ([phoneModel isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    if ([phoneModel isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    if ([phoneModel isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    if ([phoneModel isEqualToString:@"iPhone10,1"] ||
        [phoneModel isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    if ([phoneModel isEqualToString:@"iPhone10,2"] ||
        [phoneModel isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    if ([phoneModel isEqualToString:@"iPhone10,3"] ||
        [phoneModel isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if ([phoneModel isEqualToString:@"iPad1,1"]) return @"iPad";
    if ([phoneModel isEqualToString:@"iPad2,1"] ||
        [phoneModel isEqualToString:@"iPad2,2"] ||
        [phoneModel isEqualToString:@"iPad2,3"] ||
        [phoneModel isEqualToString:@"iPad2,4"]) return @"iPad 2";
    if ([phoneModel isEqualToString:@"iPad3,1"] ||
        [phoneModel isEqualToString:@"iPad3,2"] ||
        [phoneModel isEqualToString:@"iPad3,3"]) return @"iPad 3";
    if ([phoneModel isEqualToString:@"iPad3,4"] ||
        [phoneModel isEqualToString:@"iPad3,5"] ||
        [phoneModel isEqualToString:@"iPad3,6"]) return @"iPad 4";
    if ([phoneModel isEqualToString:@"iPad4,1"] ||
        [phoneModel isEqualToString:@"iPad4,2"] ||
        [phoneModel isEqualToString:@"iPad4,3"]) return @"iPad Air";
    if ([phoneModel isEqualToString:@"iPad5,3"] ||
        [phoneModel isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
    if ([phoneModel isEqualToString:@"iPad6,3"] ||
        [phoneModel isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7-inch";
    if ([phoneModel isEqualToString:@"iPad6,7"] ||
        [phoneModel isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9-inch";
    if ([phoneModel isEqualToString:@"iPad6,11"] ||
        [phoneModel isEqualToString:@"iPad6,12"]) return @"iPad 5";
    if ([phoneModel isEqualToString:@"iPad7,1"] ||
        [phoneModel isEqualToString:@"iPad7,2"]) return @"iPad Pro 12.9-inch 2";
    if ([phoneModel isEqualToString:@"iPad7,3"] ||
        [phoneModel isEqualToString:@"iPad7,4"]) return @"iPad Pro 10.5-inch";
    
    if ([phoneModel isEqualToString:@"iPad2,5"] ||
        [phoneModel isEqualToString:@"iPad2,6"] ||
        [phoneModel isEqualToString:@"iPad2,7"]) return @"iPad mini";
    if ([phoneModel isEqualToString:@"iPad4,4"] ||
        [phoneModel isEqualToString:@"iPad4,5"] ||
        [phoneModel isEqualToString:@"iPad4,6"]) return @"iPad mini 2";
    if ([phoneModel isEqualToString:@"iPad4,7"] ||
        [phoneModel isEqualToString:@"iPad4,8"] ||
        [phoneModel isEqualToString:@"iPad4,9"]) return @"iPad mini 3";
    if ([phoneModel isEqualToString:@"iPad5,1"] ||
        [phoneModel isEqualToString:@"iPad5,2"]) return @"iPad mini 4";
    
    if ([phoneModel isEqualToString:@"iPod1,1"]) return @"iTouch";
    if ([phoneModel isEqualToString:@"iPod2,1"]) return @"iTouch2";
    if ([phoneModel isEqualToString:@"iPod3,1"]) return @"iTouch3";
    if ([phoneModel isEqualToString:@"iPod4,1"]) return @"iTouch4";
    if ([phoneModel isEqualToString:@"iPod5,1"]) return @"iTouch5";
    if ([phoneModel isEqualToString:@"iPod7,1"]) return @"iTouch6";
    
    if ([phoneModel isEqualToString:@"i386"] || [phoneModel isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return @"Unknown";
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
