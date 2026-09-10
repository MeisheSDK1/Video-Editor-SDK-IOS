//
//  NvAudioEqualizerView.m
//  SDKDemo
//
//  Created by MS on 2021/6/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvAudioEqualizerView.h"
#import <NvBaseCommon/CQMenuTabView.h>
#import "NvSDKUtils.h"
#import <NvSDKCommon/NvUtils.h>
#import "NvAudioEqualizerRectView.h"
#import "UIColor+NvColor.h"
#import "UIView+Frame.h"
#import <NvBaseCommon/NVDefineConfig.h>
#import <Masonry/Masonry.h>
#import "NvAudioListView.h"
@interface NvAudioEqualizerView ()<NvAudioEqualizerRectViewDelegate>
@property (nonatomic, strong)UILabel *presetName;
@property (nonatomic, strong)UIButton *customBtn;
@property (nonatomic, strong)UILabel *customTitle;
@property (nonatomic, strong)UIImageView *customImage;


@property (nonatomic, strong) NvAudioEqualizerRectView *customEqualizerRectView;
@property (nonatomic, strong) CQMenuTabView *tabView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NvAudioListView *audioListView;

@property (nonatomic, strong) NSArray *contentArr;
@property (nonatomic, strong) NSArray *valueArr;
@property (nonatomic, strong) NSArray *listValueArr;
@property (nonatomic, strong) NSArray *customContentArr;
@end
@implementation NvAudioEqualizerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addTabView];

    }
    return self;
}

- (void)configData:(NSArray *)dataArr valueArr:(NSArray *)valueArr{
    self.contentArr = [NSArray arrayWithArray:dataArr];
    self.valueArr = [NSArray arrayWithArray:valueArr];
    [self addScrollView];
    [self addAudioEqualizerView];
}

- (void)addTabView {
    self.presetName = [[UILabel alloc]initWithFrame:CGRectMake(20.0 * SCREENSCALE, 13.0 * SCREENSCALE, 40.0 * SCREENSCALE, 10.0 *SCREENSCALE)];
    self.presetName.text = NvLocalStringFromTable([self class],@"Equalizer preset", @"均衡器预设");
    self.presetName.numberOfLines = 0;
    self.presetName.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    self.presetName.font = [NvUtils regularFontWithSize:11];
    [self addSubview:self.presetName];
    
    
    self.customBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.customBtn.backgroundColor = [UIColor nv_colorWithHexString:@"#3C3C3C"];
    [self.customBtn addTarget:self action:@selector(customBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.customBtn];

    self.customTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.customTitle.text = NvLocalStringFromTable([self class],@"Custom", @"自定义");
    self.customTitle.numberOfLines = 0;
    self.customTitle.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    self.customTitle.font = [NvUtils regularFontWithSize:11];
    self.customTitle.textAlignment = NSTextAlignmentCenter;
    [self.customBtn addSubview:self.customTitle];
    
    [self.customBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-25.0 *SCREENSCALE);
        make.centerY.mas_equalTo(self.presetName.mas_centerY);
        make.width.mas_equalTo(100.0 *SCREENSCALE);
        make.height.mas_equalTo(22.0 * SCREENSCALE);
    }];
    
    [self.presetName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(25.0f * SCREENSCALE);
        make.top.mas_equalTo(20.0 *SCREENSCALE);
        make.right.lessThanOrEqualTo(self.customBtn.mas_left).offset(-KScale6s(15));
        make.height.mas_equalTo(15.0f *SCREENSCALE);
    }];
    
    [self.customTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.0 * SCREENSCALE);
        make.centerY.mas_equalTo(self.customBtn.mas_centerY);
        make.right.mas_equalTo(self.customBtn.mas_right).offset(-20.0 * SCREENSCALE);
        make.height.mas_equalTo(15.0 * SCREENSCALE);
    }];
    
    self.customImage = [[UIImageView alloc] init];
    self.customImage.image = NvImageNamed(@"audio_list_more");
    [self.customBtn addSubview:self.customImage];
    [self.customImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.customBtn.mas_right).offset(-5.0 * SCREENSCALE);
        make.centerY.mas_equalTo(self.customBtn.mas_centerY);
        make.width.mas_equalTo(9.0 *SCREENSCALE);
        make.height.mas_equalTo(9.0 * SCREENSCALE);
    }];
    
    self.customEqualizerRectView = [[NvAudioEqualizerRectView alloc] initWithFrame:CGRectMake(0, 60, SCREENWIDTH, self.bounds.size.height - 100.0f)];
    self.customEqualizerRectView.tag = 4;
    self.customEqualizerRectView.delegate = self;
    NSArray *contentArr = @[@"31",
                            @"63",
                            @"125",
                            @"250",
                            @"500",
                            @"1000",
                            @"2000",
                            @"4000",
                            @"8000",
                            @"16k"];
    self.customContentArr = contentArr;
    NSArray *valueArr = @[@0, @0, @0, @0, @0, @0, @0, @0, @0, @0];
    [self.customEqualizerRectView configData:NvLocalStringFromTable([self class],@"volume", @"音量") leftBottomTitle:NvLocalStringFromTable([self class],@"frequency band", @"频段") maxVoice:20 minVoice:-20 middelVoice:0 frequencyRangeArr:contentArr voiceValueArr:valueArr];
    [self addSubview:self.customEqualizerRectView];
    [self.customEqualizerRectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.presetName.mas_bottom).offset(60.0 * SCREENSCALE);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(200.0 * SCREENSCALE);
    }];

    self.tabView = [[CQMenuTabView alloc] initWithFrame:CGRectMake(15*SCREENSCALE, 27*SCREENSCALE, SCREENWIDTH-30*SCREENSCALE, 25*SCREENSCALE)];
    self.tabView.layer.borderWidth = 0.5;
    self.tabView.layer.masksToBounds = YES;
    self.tabView.layer.borderColor = [UIColor nv_colorWithHexString:@"#414141"].CGColor;
    self.tabView.layer.cornerRadius = 5;
    
    self.tabView.titleFont = [UIFont systemFontOfSize:14];
    self.tabView.normaTitleColor = [UIColor whiteColor];
    
    self.tabView.didSelctTitleColor = [UIColor whiteColor];
    self.tabView.showCursor = YES;
    self.tabView.cursorStyle = CQTabCursorWrap;
    self.tabView.layoutStyle = CQTabFillParent;
    self.tabView.speaceLineColor = [UIColor redColor];
    self.tabView.cursorView.backgroundColor = [UIColor nv_colorWithHexString:@"#63ABFF"];
    self.tabView.cursorView.layer.cornerRadius = 5;
    self.tabView.backgroundColor = [UIColor nv_colorWithHexString:@"#414141"];
    self.tabView.hidden = YES;
    __weak typeof(self)weakSelf = self;
    self.tabView.didTapItemAtIndexBlock = ^(UIView *view, NSInteger index) {
        [weakSelf selectTab:index];
    };
    [self addSubview:self.tabView];
    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.customBtn.mas_bottom).offset(15.0 * SCREENSCALE);
        make.left.mas_equalTo(20.0);
        make.right.mas_equalTo(-20.0);
        make.height.mas_equalTo(25.0*SCREENSCALE);
    }];
    self.tabView.titles = @[
        NvLocalStringFromTable([self class],@"Low frequency band", @"低频段"),
        NvLocalStringFromTable([self class],@"Intermediate frequency band", @"中频段"),
        NvLocalStringFromTable([self class],@"Medium and high frequency band", @"中高频段"),
        NvLocalStringFromTable([self class],@"High frequency band", @"高频段")
    ];
}

-(void)customBtnClick{
    self.audioListView.hidden = !self.audioListView.hidden;
}

- (void)addScrollView {
    CGFloat height = CGRectGetMaxY(self.bounds) - 100*SCREENSCALE;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100*SCREENSCALE, SCREENWIDTH, height)];
    self.scrollView.scrollEnabled = NO;
    self.scrollView.hidden = YES;
    self.scrollView.contentSize = CGSizeMake(4*SCREENWIDTH, 0);
    [self addSubview:self.scrollView];
}
-(NvAudioListView *)audioListView{
    if (!_audioListView) {
        __weak typeof(self)weakSelf = self;
        _audioListView = [[NvAudioListView alloc] init];
        [self addSubview:_audioListView];
        _audioListView.selectBlock = ^(NSString * _Nonnull name, NSUInteger index) {
            weakSelf.customTitle.text = name;
            weakSelf.audioListView.hidden = !weakSelf.audioListView.hidden;
            if (index == weakSelf.listValueArr.count) {
                weakSelf.tabView.hidden = NO;
                weakSelf.scrollView.hidden = NO;
                weakSelf.customEqualizerRectView.hidden = YES;
            }else{
                weakSelf.tabView.hidden = YES;
                weakSelf.scrollView.hidden = YES;
                weakSelf.customEqualizerRectView.hidden = NO;
                [weakSelf.customEqualizerRectView configValueData:weakSelf.listValueArr[index]];
                if ([weakSelf.delegate respondsToSelector:@selector(audioEqualizerViewSelectData:contents:values:)]) {
                    [weakSelf.delegate audioEqualizerViewSelectData:weakSelf contents:weakSelf.customContentArr values:weakSelf.listValueArr[index]];
                }
            }

        };
        [_audioListView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.customBtn.mas_bottom).offset(0);
            make.left.right.bottom.mas_equalTo(self).offset(0);
        }];
    }
    return _audioListView;
}

-(NSArray *)listValueArr{
    if (!_listValueArr) {
        _listValueArr = @[
                          @[@4, @2, @0, @-3, @-6, @-6, @-3, @0, @1, @3],
                          @[@7, @6, @3, @0, @0, @-4, @-6, @-6, @0, @0],
                          @[@3, @6, @8, @3, @-2, @0, @4, @7, @9, @10],
                          @[@0, @0, @0, @0, @0, @0, @-6, @-6, @-6, @-8],
                          @[@0, @0, @1, @4, @4, @4, @0, @1, @3, @3],
                          @[@5, @4, @2, @0, @-2, @0, @3, @6, @7, @8],
                          @[@6, @5, @0, @-5, @-4, @0, @6, @8, @8, @7],
                          @[@7, @4, @-4, @7, @-2, @1, @5, @7, @9, @9],
                          @[@5, @6, @2, @-5, @1, @1, @-5, @3, @8, @5],
                          @[@-2, @-1, @-1, @0, @3, @4, @3, @0, @0, @1],
                          @[@0, @0, @0, @0, @0, @0, @0, @0, @0, @0, @0]];
    }
    return _listValueArr;
}

- (void)addAudioEqualizerView {
    CGFloat yValue = 5*SCREENSCALE;
    CGFloat height = self.scrollView.frame.size.height - yValue;
    NvAudioEqualizerRectView *view = [[NvAudioEqualizerRectView alloc] initWithFrame:CGRectMake(0, yValue, SCREENWIDTH, height)];
    view.tag = 0;
    view.delegate = self;
    [view configData:NvLocalStringFromTable([self class],@"volume", @"音量") leftBottomTitle:NvLocalStringFromTable([self class],@"frequency band", @"频段") maxVoice:20 minVoice:-20 middelVoice:0 frequencyRangeArr:self.contentArr[0] voiceValueArr:self.valueArr[0]];
    [self.scrollView addSubview:view];
    
    
    NvAudioEqualizerRectView *secView = [[NvAudioEqualizerRectView alloc] initWithFrame:CGRectMake(SCREENWIDTH, yValue, SCREENWIDTH, height)];
    secView.tag = 1;
    secView.delegate = self;
    
    [secView configData:NvLocalStringFromTable([self class],@"volume", @"音量") leftBottomTitle:NvLocalStringFromTable([self class],@"frequency band", @"频段") maxVoice:20 minVoice:-20 middelVoice:0 frequencyRangeArr:self.contentArr[1] voiceValueArr:self.valueArr[1]];
    [self.scrollView addSubview:secView];
    
    NvAudioEqualizerRectView *thirdView = [[NvAudioEqualizerRectView alloc] initWithFrame:CGRectMake(SCREENWIDTH*2, yValue, SCREENWIDTH, height)];
    thirdView.tag = 2;
    thirdView.delegate = self;
    [thirdView configData:NvLocalStringFromTable([self class],@"volume", @"音量") leftBottomTitle:NvLocalStringFromTable([self class],@"frequency band", @"频段") maxVoice:20 minVoice:-20 middelVoice:0 frequencyRangeArr:self.contentArr[2] voiceValueArr:self.valueArr[2]];
    [self.scrollView addSubview:thirdView];
    
    NvAudioEqualizerRectView *fourthView = [[NvAudioEqualizerRectView alloc] initWithFrame:CGRectMake(SCREENWIDTH*3, yValue, SCREENWIDTH, height)];
    fourthView.tag = 3;
    fourthView.delegate = self;
    [fourthView configData:NvLocalStringFromTable([self class],@"volume", @"音量") leftBottomTitle:NvLocalStringFromTable([self class],@"frequency band", @"频段") maxVoice:20 minVoice:-20 middelVoice:0 frequencyRangeArr:self.contentArr[3] voiceValueArr:self.valueArr[3]];
    [self.scrollView addSubview:fourthView];
}

- (void)selectTab:(NSInteger)index {
//    NSLog(@"...%ld",(long)index);
    CGFloat xOffset = index * self.scrollView.viewWidth;
    self.scrollView.contentOffset = CGPointMake(xOffset, 0);
}

#pragma mark - NvAudioEqualizerRectViewDelegate
- (void)audioEqualizerRect:(NvAudioEqualizerRectView *)rectView index:(NSInteger)index changeValue:(double)value {
    NSInteger tag = rectView.tag;

    if ([self.delegate respondsToSelector:@selector(audioEqualizerView:page:index:changeValue:)]) {
        [self.delegate audioEqualizerView:self page:tag index:index changeValue:value];
    }
}

- (void)audioEqualizerRect:(NvAudioEqualizerRectView *)rectView index:(NSInteger)index endValue:(double)value {
    NSInteger tag = rectView.tag;
    if ([self.delegate respondsToSelector:@selector(audioEqualizerView:page:index:endValue:)]) {
        [self.delegate audioEqualizerView:self page:tag index:index endValue:value];
    }
}
@end
