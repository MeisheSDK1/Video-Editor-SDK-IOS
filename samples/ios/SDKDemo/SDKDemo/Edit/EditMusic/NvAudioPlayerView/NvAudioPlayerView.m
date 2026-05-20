//
//  NvAudioPlayerView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/3.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvAudioPlayerView.h"
#import "NVHeader.h"
#import "REDRangeSlider.h"
#import <NvSDKCommon/NvUtils.h>
#import "YYWebImage.h"

@interface NvAudioPlayerView()<REDRangeSliderDelegate>

@property (strong, nonatomic) UIImageView *musicImage;
@property (strong, nonatomic) YYAnimatedImageView *coverView;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) UIButton *useButton;
@property (strong, nonatomic) UIButton *noMusicButton;
@property (strong, nonatomic) REDRangeSlider *slider;
@property (strong, nonatomic) UIView *progress;
@property (strong, nonatomic) UIImageView *cutPointView;

@property (strong, nonatomic) NvEditSelectMusicItem *item;
@property (assign, nonatomic) BOOL urlModel;

@end

@implementation NvAudioPlayerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
        self.musicImage = [UIImageView new];
        self.musicImage.image = NvImageNamed(@"NvEditMusic");
        [self addSubview:self.musicImage];
        self.nameLabel = [UILabel nv_labelWithText:@"" fontSize:12 textColor:[UIColor nv_colorWithHexRGB:@"#909293"]];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.nameLabel];
        
        self.currentLabel = [UILabel nv_labelWithText:@"" fontSize:12 textColor:[UIColor nv_colorWithHexRGB:@"#909293"]];
        self.currentLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.currentLabel];
        
        CGRect sliderFrame = CGRectMake(77*SCREENSCALE,40*SCREENSCALE, 283*SCREENSCALE, 20);

        self.slider = [[REDRangeSlider alloc] initWithFrame:sliderFrame];
        self.slider.delegate = self;
        self.slider.maxValue = 100;
        self.slider.minValue = 0;
        self.slider.stepValue = 1;
        self.slider.minimumSpacing = 3;
        self.slider.leftHandleImage = NvImageNamed(@"NvCutMusicHandle");
        self.slider.rightHandleImage = NvImageNamed(@"NvCutMusicHandle");
        [self addSubview:self.slider];
        
        _progress = [[UIView alloc] init];
        _progress.frame = CGRectZero;
        _progress.backgroundColor = [UIColor redColor];
        [self.slider addSubview:_progress];
        [self.slider bringSubviewToFront:_progress];
        
        self.cutPointView = [[UIImageView alloc] initWithFrame:CGRectMake(sliderFrame.origin.x, sliderFrame.origin.y, 10, sliderFrame.size.height)];
        self.cutPointView.centerY = self.slider.centerY;
        self.cutPointView.layer.cornerRadius = 2.5;
        self.cutPointView.image = NvImageNamed(@"NvCutMusicHandle");
        self.cutPointView.backgroundColor = [UIColor whiteColor];
        self.cutPointView.userInteractionEnabled = YES;
        
        [self addSubview:self.cutPointView];
        self.cutPointView.hidden = YES;
        
        [self.musicImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(@(13*SCREENSCALE));
            make.width.height.equalTo(@(49*SCREENSCALE));
        }];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.musicImage.mas_right).offset(8*SCREENSCALE);
            make.top.equalTo(@(13*SCREENSCALE));
            make.width.equalTo(@(200*SCREENSCALE));
        }];
        [self.currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.musicImage.mas_right).offset(8*SCREENSCALE);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(2*SCREENSCALE);
        }];
        
        self.useButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.useButton setTitle:NvLocalString(@"Use", @"使用") forState:UIControlStateNormal];
        self.useButton.titleLabel.textColor = [UIColor whiteColor];
        self.useButton.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.useButton.layer.cornerRadius = 4*SCREENSCALE;
        self.useButton.titleLabel.font = [NvUtils regularFontWithSize:10];
        self.useButton.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
        [self addSubview:self.useButton];
        [self.useButton addTarget:self action:@selector(useButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.useButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-13*SCREENSCALE));
            make.top.equalTo(@(13*SCREENSCALE));
            make.width.mas_lessThanOrEqualTo(@(60*SCREENSCALE));
            make.height.equalTo(@(20*SCREENSCALE));
        }];
    }
    return self;
}

- (instancetype)initUrlViewWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.urlModel = YES;
        self.backgroundColor = [UIColor nv_colorWithHexARGB:@"#99000000"];
        self.coverView = [[YYAnimatedImageView alloc] init];
        self.coverView.userInteractionEnabled = YES;
        self.coverView.image = NvImageNamed(@"NvEditMusic");
        [self addSubview:self.coverView];
        self.nameLabel = [UILabel nv_labelWithText:@"" fontSize:12 textColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"]];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.nameLabel];
        
        self.currentLabel = [UILabel nv_labelWithText:@"" fontSize:12 textColor:[UIColor nv_colorWithHexRGB:@"#A4A4A4"]];
        self.currentLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.currentLabel];
        
        CGRect sliderFrame = CGRectMake(23*SCREENSCALE,80*SCREENSCALE, SCREENWIDTH - 2 * 23 * SCREENSCALE, 20);

        self.slider = [[REDRangeSlider alloc] initWithFrame:sliderFrame];
        self.slider.delegate = self;
        self.slider.maxValue = 100;
        self.slider.minValue = 0;
        self.slider.stepValue = 1;
        self.slider.minimumSpacing = 3;
        self.slider.leftHandleImage = NvImageNamed(@"NvUrlEdit_sliderLeft");
        self.slider.rightHandleImage = NvImageNamed(@"NvUrlEdit_sliderRight");
        self.slider.leftHandleHighlightedImage = NvImageNamed(@"NvUrlEdit_sliderLeft");
        self.slider.rightHandleHighlightedImage = NvImageNamed(@"NvUrlEdit_sliderRight");
        self.slider.trackFillImage = [self.slider createImageWithColor:@"#FFFFFF"];
        [self addSubview:self.slider];
        
        _progress = [[UIView alloc] init];
        _progress.frame = CGRectZero;
        _progress.backgroundColor = [UIColor whiteColor];
        _progress.layer.cornerRadius = 5;
        [self.slider addSubview:_progress];
        [self.slider bringSubviewToFront:_progress];
        
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton setBackgroundImage:NvImageNamed(@"NvPlayback") forState:UIControlStateNormal];
        [self.playButton setBackgroundImage:NvImageNamed(@"NvPause") forState:UIControlStateSelected];
        [self.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.coverView addSubview:self.playButton];
           
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(@(18*SCREENSCALE));
            make.width.height.equalTo(@(55*SCREENSCALE));
        }];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coverView.mas_right).offset(10*SCREENSCALE);
            make.right.equalTo(self).offset(-140*SCREENSCALE);
            make.top.equalTo(self.coverView).offset(8 * SCREENSCALE);
        }];
        [self.currentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.bottom.equalTo(self.coverView).offset(-8 * SCREENSCALE);
        }];
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.coverView);
            make.width.height.equalTo(@(25*SCREENSCALE));
        }];
        
        self.useButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.useButton setTitle:NvLocalString(@"urlEditing_home_import", @"One-click import") forState:UIControlStateNormal];
        self.useButton.titleLabel.textColor = [UIColor whiteColor];
        self.useButton.layer.cornerRadius = 15*SCREENSCALE;
        self.useButton.titleLabel.font = [NvUtils regularFontWithSize:12];
        self.useButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 20);
        [self addSubview:self.useButton];
        [self.useButton addTarget:self action:@selector(useButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.useButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-13*SCREENSCALE));
            make.top.equalTo(@(13*SCREENSCALE));
            make.width.mas_lessThanOrEqualTo(@(88*SCREENSCALE));
            make.height.equalTo(@(30*SCREENSCALE));
        }];
        
        [self layoutIfNeeded];
        [self gradientView:self.useButton withColors:@[(id)[UIColor nv_colorWithHexRGB:@"#A5CFFF"].CGColor,(id)[UIColor nv_colorWithHexRGB:@"#63ABFF"].CGColor]];
    }
    return self;
}

- (void)imageHandlePan:(UIGestureRecognizer *)pan {
    CGPoint point = [pan locationInView:self];
    float y = self.cutPointView.center.y;
    if (point.x < (self.slider.frame.origin.x)) {
        return;
    }
    if (point.x > (self.slider.frame.origin.x + self.slider.frame.size.width)) {
        return;
    }

    float value = (point.x - self.slider.frame.origin.x) / (self.slider.frame.size.width);
    if ((1-value) * self.item.duration < 15.0) {
        return;
    }
    NSLog(@"------%f",value);
    self.cutPointView.center = CGPointMake(point.x, y);
    if ([self.delegate respondsToSelector:@selector(audioPlayerView:imageHandlePanChanged:)]) {
        [self.delegate audioPlayerView:self imageHandlePanChanged:value*self.item.duration];
    }
    self.slider.trimInLabel.text = [self convertTimecode:self.item.duration*value];
}

- (void)setCutHandleImageValue:(float)value {
    self.cutPointView.center = CGPointMake(value * self.slider.frame.size.width + self.slider.frame.origin.x, self.cutPointView.center.y);
}

- (void)hiddenHandleButton {
    self.slider.leftHandle.hidden = YES;
    self.slider.rightHandle.hidden = YES;
    self.slider.trimInLabel.hidden = YES;
    self.slider.trimOutLabel.hidden = YES;
}

- (void)showCutHandleImage {
    self.cutPointView.hidden = NO;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(imageHandlePan:)];
    [self addGestureRecognizer:pan];
}

///进度值更新
///Progress update
- (void)reloadProgress:(CGFloat)progress {
    CGFloat h = 10;
    CGFloat w = self.urlModel ? 10 : 2;
    if (progress <= (self.slider.rightValue )/(self.slider.maxValue )) {
        if (self.cutPointView.hidden || !self.cutPointView) {
            _progress.frame = CGRectMake((self.slider.leftHandleImage.size.width/2) +progress *(self.slider.width - (self.slider.leftHandleImage.size.width)) - w/2.0, self.slider.height/ 2.f - h / 2.f , w, h);
        } else {
            ///如果只有一个裁剪控件
            ///If there is only one clipping control
            _progress.frame = CGRectMake((self.slider.leftHandleImage.size.width/2) +progress *(self.slider.width - (self.slider.leftHandleImage.size.width/2)) , self.slider.height/ 2.f - h / 2.f , w, h);
        }
    } else {

    }
    [self.slider bringSubviewToFront:_progress];
}

- (void)renderViewWithItem:(NvEditSelectMusicItem *)item {
    _currentValue = 0;
    self.item = item;
    self.nameLabel.text = item.musicName;
    self.slider.trimInLabel.text = [self convertTimecode:_currentValue];
    self.slider.trimOutLabel.text = [self convertTimecode:item.duration];
    NSString *duration = [self convertTimecode:item.duration];
    self.currentLabel.text = [NSString stringWithFormat:@"00:00/%@",duration];
    if (self.urlModel) {
        [self.coverView yy_setImageWithURL:[NSURL URLWithString:item.coverUrl] placeholder:NvImageNamed(@"NvEditMusic") options:YYWebImageOptionProgressive completion:nil];
        self.playButton.selected = YES;
    }
}

- (void)setLeftValue:(float)leftValue rightValue:(float)rightValue {
    self.slider.leftValue = leftValue;
    self.slider.rightValue = rightValue;
}

- (void)useButtonClick:(UIButton *)button {
    if (self.urlModel) {
        if ([self.delegate respondsToSelector:@selector(audioPlayerViewImport)]) {
            [self.delegate audioPlayerViewImport];
        }
    } else {
        if (self.cutPointView.hidden) {
            if ([self.delegate respondsToSelector:@selector(audioPlayerView:withItem:trimIn:trimOut:)]) {
                [self.delegate audioPlayerView:self withItem:self.item trimIn:self.slider.leftValue/100.0*self.item.duration trimOut:self.slider.rightValue/100.0*self.item.duration];
            }
        } else {
            float value = (self.cutPointView.center.x - self.slider.frame.origin.x) / self.slider.frame.size.width;
            if ([self.delegate respondsToSelector:@selector(audioPlayerView:withItem:trimIn:trimOut:)]) {
                float trimOut = self.item.duration>15?15:self.item.duration;
                [self.delegate audioPlayerView:self withItem:self.item trimIn:value * self.item.duration trimOut:value * self.item.duration + trimOut];
            }
        }
    }
}

- (void)noMusicButtonClick:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(audioPlayerViewNoMusicClick:)]) {
        [self.delegate audioPlayerViewNoMusicClick:self];
    }
}

- (void)playButtonClick{
    self.playButton.selected = !self.playButton.selected;
    if ([self.delegate respondsToSelector:@selector(audioPlayerViewPlayClick:withPlay:)]) {
        [self.delegate audioPlayerViewPlayClick:self withPlay:self.playButton.selected];
    }
}

-(void)setCurrentValue:(CGFloat)currentValue {
    _currentValue = currentValue;
    self.currentLabel.text = [NSString stringWithFormat:@"%@/%@",[self convertTimecode:_currentValue],[self convertTimecode:self.item.duration]];
    if (self.item) {//(0-1)
        [self reloadProgress:currentValue/self.item.duration];
    }
    
}

- (NSString *)convertTimecode:(float)time {
    time = (time + 0.5) / 1;
    int min = (int)time / 60;
    int sec = (int)time % 60;
    if (min >= 10 && sec >= 10)
        return [NSString stringWithFormat:@"%d:%d", min, sec];
    else if (min >= 10)
        return [NSString stringWithFormat:@"%d:0%d", min, sec];
    else if (sec >= 10)
        return [NSString stringWithFormat:@"0%d:%d", min, sec];
    else
        return [NSString stringWithFormat:@"0%d:0%d", min, sec];
}

// MARK: REDRangeSliderDelegate(0-1)
- (void)leftPan:(CGFloat)left {
    NSLog(@"这个值的范围 The range of this value left：%f",left);
    if (self.item) {
        float s = left*self.item.duration;
        self.slider.trimInLabel.text = [self convertTimecode:s];
        if ([self.delegate respondsToSelector:@selector(audioPlayerView:leftValueChanged:)]) {
            [self.delegate audioPlayerView:self leftValueChanged:s];
        }
        if (self.playButton) {
            self.playButton.selected = YES;
        }
    }
    [self reloadProgress:left];
    
}

- (void)rightPan:(CGFloat)right {
    NSLog(@"这个值的范围 The range of this value right：%f",right);
    if (self.item) {
        float s = right*self.item.duration;
        self.slider.trimOutLabel.text = [self convertTimecode:s];
        if ([self.delegate respondsToSelector:@selector(audioPlayerView:rightValueChanged:)]) {
            [self.delegate audioPlayerView:self rightValueChanged:s];
        }
    }
}

- (void)gradientView:(UIButton *)sender withColors:(NSArray *)colors{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, sender.frame.size.width, sender.frame.size.height);
    gradientLayer.colors = colors;
    gradientLayer.locations = @[@(0.0f),@(1.0f)];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    gradientLayer.masksToBounds = YES;
    gradientLayer.cornerRadius = sender.layer.cornerRadius;
    [sender.layer insertSublayer:gradientLayer atIndex:0];
}

@end
