//
//  NvCaptionSpaceView.m
//  SDKDemo
//
//  Created by 刘东旭 on 2019/11/1.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvCaptionSpaceView.h"
#import "NVHeader.h"
#import <Masonry/Masonry.h>

@interface NvCaptionSpaceView ()

@property (nonatomic, strong) UIButton *textSpaceBtn;
@property (nonatomic, strong) UIButton *lineSpaceBtn;

@property (nonatomic, strong) UIView *textSpaceView;
@property (nonatomic, strong) UIView *lineSpaceView;
@property (nonatomic, strong) UIButton *okButton;
@property (nonatomic, strong) UIView *line;
@end

@implementation NvCaptionSpaceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        _containFinishButton = NO;
        self.lineSpaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.lineSpaceBtn setTitle:NvLocalString(@"Line spacing", @"行间距") forState:UIControlStateNormal];
        self.lineSpaceBtn.titleLabel.font = [NvUtils regularFontWithSize:10];
        [self.lineSpaceBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#000000"] forState:UIControlStateNormal];
        [self.lineSpaceBtn setTitleColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"] forState:UIControlStateSelected];
        self.lineSpaceBtn.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FFE8E8E8"];
        [self.lineSpaceBtn addTarget:self action:@selector(lineSpaceBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.lineSpaceBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.lineSpaceBtn.titleLabel.numberOfLines = 2;
        self.lineSpaceBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.lineSpaceBtn];
        self.lineSpaceBtn.frame = CGRectMake(15*SCREENSCALE, 15*SCREENSCALE, 50*SCREENSCALE, 24*SCREENSCALE);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.lineSpaceBtn.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft) cornerRadii:CGSizeMake(5,5)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.lineSpaceBtn.bounds;
        maskLayer.path = maskPath.CGPath;
        self.lineSpaceBtn.layer.mask = maskLayer;

        self.textSpaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.textSpaceBtn setTitle:NvLocalString(@"Text spacing", @"字间距") forState:UIControlStateNormal];
        self.textSpaceBtn.titleLabel.font = [NvUtils regularFontWithSize:10];
        [self.textSpaceBtn setTitleColor:[UIColor nv_colorWithHexRGB:@"#000000"] forState:UIControlStateNormal];
        [self.textSpaceBtn setTitleColor:[UIColor nv_colorWithHexARGB:@"#CCFFFFFF"] forState:UIControlStateSelected];
        self.textSpaceBtn.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FFE8E8E8"];
        [self.textSpaceBtn addTarget:self action:@selector(textSpaceBtnClick) forControlEvents:UIControlEventTouchUpInside];
        self.textSpaceBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.textSpaceBtn.titleLabel.numberOfLines = 2;
        self.textSpaceBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textSpaceBtn];
        self.textSpaceBtn.frame = CGRectMake(self.lineSpaceBtn.frame.origin.x+self.lineSpaceBtn.frame.size.width, 15*SCREENSCALE, 50*SCREENSCALE, 24*SCREENSCALE);
        UIBezierPath *maskPath2 = [UIBezierPath bezierPathWithRoundedRect:self.textSpaceBtn.bounds byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight) cornerRadii:CGSizeMake(5,5)];
        CAShapeLayer *maskLayer2 = [[CAShapeLayer alloc] init];
        maskLayer2.frame = self.textSpaceBtn.bounds;
        maskLayer2.path = maskPath2.CGPath;
        self.textSpaceBtn.layer.mask = maskLayer2;
        
        [self lineSpace];
        [self textSpace];
        
        [self lineSpaceBtnClick];
        
        self.applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.applyButton.frame = CGRectMake(13*SCREENSCALE, self.frame.size.height - 35*SCREENSCALE, 15*SCREENSCALE, 15*SCREENSCALE);
        [self.applyButton setImage:NvImageNamed(@"NvNoApplyAll") forState:UIControlStateNormal];
        [self.applyButton setImage:NvImageNamed(@"NvApplyAll") forState:UIControlStateSelected];
        [self.applyButton addTarget:self action:@selector(applyButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.applyButton];
        
        self.styleApplyLabel = [UILabel new];
        self.styleApplyLabel.textColor = [UIColor whiteColor];
        self.styleApplyLabel.textAlignment = NSTextAlignmentCenter;
        self.styleApplyLabel.text = NvLocalString(@"Apply all", @"将样式应用到所有字幕");
        UIFont *font;
        if (![UIFont fontWithName:@"PingFangSC-Regular" size:10]) {
            font = [UIFont boldSystemFontOfSize:10];
        } else {
            font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
        }
        self.styleApplyLabel.font = font;
        self.styleApplyLabel.alpha = 0.8;
        
        [self addSubview:self.applyButton];
        [self addSubview:self.styleApplyLabel];
        
        
        [self.applyButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(13*SCREENSCALE));
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-36*SCREENSCALE);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self.mas_bottom).offset(-36*SCREENSCALE);
            }
            make.width.height.equalTo(@(15*SCREENSCALE));
        }];
        [self.styleApplyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.applyButton.mas_centerY);
            make.left.equalTo(self.applyButton.mas_right).offset(7*SCREENSCALE);
        }];
    }
    return self;
}

- (void)textSpace{
    self.textSpaceView = [[UIView alloc] init];
    self.textSpaceView.hidden = YES;
    [self addSubview:self.textSpaceView];
    [self.textSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(70 * SCREENSCALE);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.offset(25 * SCREENSCALE);
    }];
    
    CGFloat heightSpace = 20 * SCREENSCALE;
    CGFloat widthSpace = 64 * SCREENSCALE;
    CGFloat ySpace = 0 * SCREENSCALE;
    CGFloat space = (SCREENWIDTH-widthSpace*4.0)/5.0;
    
    self.smaller = [UIButton buttonWithType:UIButtonTypeCustom];
    self.smaller.frame = CGRectMake(space, ySpace, widthSpace, heightSpace);
    [self.smaller setTitle:NvLocalString(@"Smaller", @"较小") forState:UIControlStateNormal];
    [self.smaller setTitle:NvLocalString(@"Smaller", @"较小") forState:UIControlStateSelected];
    self.smaller.backgroundColor = [UIColor nv_colorWithHexRGB:@"#393939"];
    [self.smaller.titleLabel setFont:[NvUtils regularFontWithSize:12]];
    [self.smaller setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
    [self.smaller setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
    [self.smaller addTarget:self action:@selector(smallerClick:) forControlEvents:UIControlEventTouchUpInside];
    self.smaller.layer.borderWidth = 1;
    self.smaller.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    self.smaller.layer.cornerRadius = 20.0/2*SCREENSCALE;
    self.smaller.layer.masksToBounds = YES;
    [self.textSpaceView addSubview:self.smaller];
    
    self.standard = [UIButton buttonWithType:UIButtonTypeCustom];
    self.standard.frame = CGRectMake(widthSpace+2*space, ySpace, widthSpace, heightSpace);
    [self.standard setTitle:NvLocalString(@"Standard", @"标准") forState:UIControlStateNormal];
    [self.standard setTitle:NvLocalString(@"Standard", @"标准") forState:UIControlStateSelected];
    [self.standard.titleLabel setFont:[NvUtils regularFontWithSize:12]];
    self.standard.backgroundColor = [UIColor nv_colorWithHexRGB:@"#393939"];
    [self.standard setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
    [self.standard setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
    [self.standard addTarget:self action:@selector(standardClick:) forControlEvents:UIControlEventTouchUpInside];
    self.standard.layer.borderWidth = 1;
    self.standard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    self.standard.layer.cornerRadius = 20.0/2*SCREENSCALE;
    self.standard.layer.masksToBounds = YES;
    [self.textSpaceView addSubview:self.standard];
    
    self.larger = [UIButton buttonWithType:UIButtonTypeCustom];
    self.larger.frame = CGRectMake(2*widthSpace+3*space, ySpace, widthSpace, heightSpace);
    [self.larger setTitle:NvLocalString(@"Larger", @"较大") forState:UIControlStateNormal];
    [self.larger setTitle:NvLocalString(@"Larger", @"较大") forState:UIControlStateSelected];
    [self.larger.titleLabel setFont:[NvUtils regularFontWithSize:12]];
    self.larger.backgroundColor = [UIColor nv_colorWithHexRGB:@"#393939"];
    [self.larger setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
    [self.larger setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
    [self.larger addTarget:self action:@selector(largerClick:) forControlEvents:UIControlEventTouchUpInside];
    self.larger.layer.borderWidth = 1;
    self.larger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    self.larger.layer.cornerRadius = 20.0/2*SCREENSCALE;
    self.larger.layer.masksToBounds = YES;
    [self.textSpaceView addSubview:self.larger];
    
    self.huge = [UIButton buttonWithType:UIButtonTypeCustom];
    self.huge.frame = CGRectMake(3*widthSpace+4*space, ySpace, widthSpace, heightSpace);
    [self.huge setTitle:NvLocalString(@"Huge", @"大") forState:UIControlStateNormal];
    [self.huge setTitle:NvLocalString(@"Huge", @"大") forState:UIControlStateSelected];
    [self.huge.titleLabel setFont:[NvUtils regularFontWithSize:12]];
    self.huge.backgroundColor = [UIColor nv_colorWithHexRGB:@"#393939"];
    [self.huge setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
    [self.huge setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
    [self.huge addTarget:self action:@selector(hugeClick:) forControlEvents:UIControlEventTouchUpInside];
    self.huge.layer.borderWidth = 1;
    self.huge.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    self.huge.layer.cornerRadius = 20.0/2*SCREENSCALE;
    self.huge.layer.masksToBounds = YES;
    [self.textSpaceView addSubview:self.huge];
}

- (void)lineSpace{
    self.lineSpaceView = [[UIView alloc] init];
    [self addSubview:self.lineSpaceView];
    [self.lineSpaceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(70 * SCREENSCALE);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.offset(25 * SCREENSCALE);
    }];
    
    CGFloat heightSpace = 20 * SCREENSCALE;
    CGFloat widthSpace = 64 * SCREENSCALE;
    CGFloat ySpace = 0 * SCREENSCALE;
    CGFloat space = (SCREENWIDTH-widthSpace*4.0)/5.0;
    
    self.lineSmaller = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lineSmaller.frame = CGRectMake(space, ySpace, widthSpace, heightSpace);
    [self.lineSmaller setTitle:NvLocalString(@"Smaller", @"较小") forState:UIControlStateNormal];
    [self.lineSmaller setTitle:NvLocalString(@"Smaller", @"较小") forState:UIControlStateSelected];
    self.lineSmaller.backgroundColor = [UIColor nv_colorWithHexRGB:@"#393939"];
    [self.lineSmaller.titleLabel setFont:[NvUtils regularFontWithSize:12]];
    [self.lineSmaller setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
    [self.lineSmaller setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
    [self.lineSmaller addTarget:self action:@selector(smallerClick:) forControlEvents:UIControlEventTouchUpInside];
    self.lineSmaller.layer.borderWidth = 1;
    self.lineSmaller.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    self.lineSmaller.layer.cornerRadius = 20.0/2*SCREENSCALE;
    self.lineSmaller.layer.masksToBounds = YES;
    [self.lineSpaceView addSubview:self.lineSmaller];
    
    self.lineStandard = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lineStandard.frame = CGRectMake(widthSpace+2*space, ySpace, widthSpace, heightSpace);
    [self.lineStandard setTitle:NvLocalString(@"Standard", @"标准") forState:UIControlStateNormal];
    [self.lineStandard setTitle:NvLocalString(@"Standard", @"标准") forState:UIControlStateSelected];
    [self.lineStandard.titleLabel setFont:[NvUtils regularFontWithSize:12]];
    self.lineStandard.backgroundColor = [UIColor nv_colorWithHexRGB:@"#393939"];
    [self.lineStandard setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
    [self.lineStandard setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
    [self.lineStandard addTarget:self action:@selector(standardClick:) forControlEvents:UIControlEventTouchUpInside];
    self.lineStandard.layer.borderWidth = 1;
    self.lineStandard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    self.lineStandard.layer.cornerRadius = 20.0/2*SCREENSCALE;
    self.lineStandard.layer.masksToBounds = YES;
    [self.lineSpaceView addSubview:self.lineStandard];
    
    self.lineLarger = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lineLarger.frame = CGRectMake(2*widthSpace+3*space, ySpace, widthSpace, heightSpace);
    [self.lineLarger setTitle:NvLocalString(@"Larger", @"较大") forState:UIControlStateNormal];
    [self.lineLarger setTitle:NvLocalString(@"Larger", @"较大") forState:UIControlStateSelected];
    [self.lineLarger.titleLabel setFont:[NvUtils regularFontWithSize:12]];
    self.lineLarger.backgroundColor = [UIColor nv_colorWithHexRGB:@"#393939"];
    [self.lineLarger setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
    [self.lineLarger setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
    [self.lineLarger addTarget:self action:@selector(largerClick:) forControlEvents:UIControlEventTouchUpInside];
    self.lineLarger.layer.borderWidth = 1;
    self.lineLarger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    self.lineLarger.layer.cornerRadius = 20.0/2*SCREENSCALE;
    self.lineLarger.layer.masksToBounds = YES;
    [self.lineSpaceView addSubview:self.lineLarger];
    
    self.lineHuge = [UIButton buttonWithType:UIButtonTypeCustom];
    self.lineHuge.frame = CGRectMake(3*widthSpace+4*space, ySpace, widthSpace, heightSpace);
    [self.lineHuge setTitle:NvLocalString(@"Huge", @"大") forState:UIControlStateNormal];
    [self.lineHuge setTitle:NvLocalString(@"Huge", @"大") forState:UIControlStateSelected];
    [self.lineHuge.titleLabel setFont:[NvUtils regularFontWithSize:12]];
    self.lineHuge.backgroundColor = [UIColor nv_colorWithHexRGB:@"#393939"];
    [self.lineHuge setTitleColor:[UIColor nv_colorWithHexRGB:@"#FFFFFF"] forState:UIControlStateNormal];
    [self.lineHuge setTitleColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"] forState:UIControlStateSelected];
    [self.lineHuge addTarget:self action:@selector(hugeClick:) forControlEvents:UIControlEventTouchUpInside];
    self.lineHuge.layer.borderWidth = 1;
    self.lineHuge.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    self.lineHuge.layer.cornerRadius = 20.0/2*SCREENSCALE;
    self.lineHuge.layer.masksToBounds = YES;
    [self.lineSpaceView addSubview:self.lineHuge];
}

- (void)selectCaptionLineLetterSpace:(float)letterSpace {
    if (letterSpace == -10) {
        self.lineSmaller.selected = YES;
        self.lineStandard.selected = NO;
        self.lineLarger.selected = NO;
        self.lineHuge.selected = NO;
        
        self.lineSmaller.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.lineStandard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.lineLarger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.lineHuge.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    } else if (letterSpace == 0) {
        self.lineSmaller.selected = NO;
        self.lineStandard.selected = YES;
        self.lineLarger.selected = NO;
        self.lineHuge.selected = NO;
        
        self.lineStandard.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.lineSmaller.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.lineLarger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.lineHuge.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        
    }  else if (letterSpace == 20) {
        self.lineSmaller.selected = NO;
        self.lineStandard.selected = NO;
        self.lineLarger.selected = YES;
        self.lineHuge.selected = NO;
        self.lineSmaller.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.lineLarger.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.lineStandard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.lineHuge.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    }else {
        self.lineSmaller.selected = NO;
        self.lineStandard.selected = NO;
        self.lineLarger.selected = NO;
        self.lineHuge.selected = YES;
        
        self.lineHuge.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.lineStandard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.lineLarger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.lineSmaller.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    }
}

- (void)selectCaptionLetterSpaceType:(NvCaptionLetterSpaceType)letterSpaceType{
    if (letterSpaceType == LetterSpaceLess) {
        self.smaller.selected = YES;
        self.standard.selected = NO;
        self.larger.selected = NO;
        self.huge.selected = NO;
        
        self.smaller.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.standard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.larger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.huge.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    } else if(letterSpaceType == LetterSpaceStandard){
        self.standard.selected = YES;
        self.smaller.selected = NO;
        self.larger.selected = NO;
        self.huge.selected = NO;
        
        self.standard.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.smaller.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.larger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.huge.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    }else if(letterSpaceType == LetterSpaceMore){
        self.smaller.selected = NO;
        self.standard.selected = NO;
        self.larger.selected = YES;
        self.huge.selected = NO;
        
        self.standard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.larger.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.huge.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.smaller.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    }else if(letterSpaceType == LetterSpacelarge){
        self.smaller.selected = NO;
        self.standard.selected = NO;
        self.larger.selected = NO;
        self.huge.selected = YES;
        
        self.standard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.larger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.huge.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.smaller.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    }else {
        self.standard.selected = NO;
        self.larger.selected = NO;
        self.huge.selected = YES;
        self.smaller.selected = NO;
        
        self.standard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.larger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.huge.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.smaller.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        
    }
}

- (void)selectCaptionLetterSpace:(float)letterSpace {
    if(letterSpace == 90){
        self.smaller.selected = YES;
        self.standard.selected = NO;
        self.larger.selected = NO;
        self.huge.selected = NO;
        
        self.smaller.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.standard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.larger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.huge.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    }else if (letterSpace == 100) {
        self.standard.selected = YES;
        self.smaller.selected = NO;
        self.larger.selected = NO;
        self.huge.selected = NO;
        
        self.standard.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.smaller.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.larger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.huge.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        
    } else if (letterSpace == 150) {
        self.smaller.selected = NO;
        self.standard.selected = NO;
        self.larger.selected = YES;
        self.huge.selected = NO;
        
        self.standard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.larger.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.huge.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.smaller.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        
    } else if (letterSpace == 200) {
        self.smaller.selected = NO;
        self.standard.selected = NO;
        self.larger.selected = NO;
        self.huge.selected = YES;
        
        self.standard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.larger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.huge.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.smaller.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        
    }
    else {
        self.standard.selected = NO;
        self.larger.selected = NO;
        self.huge.selected = YES;
        self.smaller.selected = NO;
        
        self.standard.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.larger.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
        self.huge.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.smaller.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        
    }
}

- (void)applyButtonClick:(UIButton *)button {
    self.applyButton.selected = !self.applyButton.selected;
    if (self.applyButton.selected) {
        self.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    } else {
        self.styleApplyLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    }
    if ([self.delegate respondsToSelector:@selector(applyCaptionSpaceToAllCaption:)]) {
        [self.delegate applyCaptionSpaceToAllCaption:self.applyButton.selected];
    }
}

- (void)smallerClick:(UIButton *)button{
    if ([button isEqual:self.lineSmaller]) {
        [self selectCaptionLineLetterSpace:-10];
        if ([self.delegate respondsToSelector:@selector(captionSpaceView:didSelectCaptionLineLetterSpace:)]) {
            [self.delegate captionSpaceView:self didSelectCaptionLineLetterSpace:-10];
        }
    }else{
        [self selectCaptionLetterSpace:90];
        if ([self.delegate respondsToSelector:@selector(captionSpaceView:didSelectCaptionLetterSpaceType:Type:)]) {
            [self.delegate captionSpaceView:self didSelectCaptionLetterSpaceType:90 Type:LetterSpaceLess];
        }
    }
}

- (void)standardClick:(UIButton *)button {
    if ([button isEqual:self.lineStandard]) {
        [self selectCaptionLineLetterSpace:0];
        if ([self.delegate respondsToSelector:@selector(captionSpaceView:didSelectCaptionLineLetterSpace:)]) {
            [self.delegate captionSpaceView:self didSelectCaptionLineLetterSpace:0];
        }
    }else{
        [self selectCaptionLetterSpace:100];
        if ([self.delegate respondsToSelector:@selector(captionSpaceView:didSelectCaptionLetterSpaceType:Type:)]) {
            [self.delegate captionSpaceView:self didSelectCaptionLetterSpaceType:100 Type:LetterSpaceStandard];
        }
    }
}

- (void)largerClick:(UIButton *)button {
    if ([button isEqual:self.lineLarger]) {
        [self selectCaptionLineLetterSpace:20];
        if ([self.delegate respondsToSelector:@selector(captionSpaceView:didSelectCaptionLineLetterSpace:)]) {
            [self.delegate captionSpaceView:self didSelectCaptionLineLetterSpace:20];
        }
    }else{
        [self selectCaptionLetterSpace:150];
        if ([self.delegate respondsToSelector:@selector(captionSpaceView:didSelectCaptionLetterSpaceType:Type:)]) {
            [self.delegate captionSpaceView:self didSelectCaptionLetterSpaceType:150 Type:LetterSpaceMore];
        }
    }
}

- (void)hugeClick:(UIButton *)button {
    if ([button isEqual:self.lineHuge]) {
        [self selectCaptionLineLetterSpace:40];
        if ([self.delegate respondsToSelector:@selector(captionSpaceView:didSelectCaptionLineLetterSpace:)]) {
            [self.delegate captionSpaceView:self didSelectCaptionLineLetterSpace:40];
        }
    }else{
        [self selectCaptionLetterSpace:200];
        if ([self.delegate respondsToSelector:@selector(captionSpaceView:didSelectCaptionLetterSpaceType:Type:)]) {
            [self.delegate captionSpaceView:self didSelectCaptionLetterSpaceType:200 Type:LetterSpacelarge];
        }
    }
}

- (void)lineSpaceBtnClick{
    [self hiddenTextSpace];
    self.lineSpaceBtn.selected = YES;
    self.lineSpaceView.hidden = !self.lineSpaceBtn.selected;
    self.lineSpaceBtn.backgroundColor = self.lineSpaceBtn.selected?[UIColor nv_colorWithHexARGB:@"#FF4A90E2"]:[UIColor nv_colorWithHexARGB:@"#FFE8E8E8"];
}

- (void)textSpaceBtnClick{
    [self hiddenLineSpace];
    self.textSpaceBtn.selected = YES;
    self.textSpaceView.hidden = !self.textSpaceBtn.selected;
    self.textSpaceBtn.backgroundColor = self.textSpaceBtn.selected?[UIColor nv_colorWithHexARGB:@"#FF4A90E2"]:[UIColor nv_colorWithHexARGB:@"#FFE8E8E8"];
    if (self.smaller.selected) {
        [self smallerClick:self.smaller];
    }
}

- (void)hiddenLineSpace{
    self.lineSpaceBtn.selected = NO;
    self.lineSpaceView.hidden = YES;
    self.lineSpaceBtn.backgroundColor = self.lineSpaceBtn.selected?[UIColor nv_colorWithHexARGB:@"#FF4A90E2"]:[UIColor nv_colorWithHexARGB:@"#FFE8E8E8"];
}

- (void)hiddenTextSpace{
    self.textSpaceBtn.selected = NO;
    self.textSpaceView.hidden = YES;
    self.textSpaceBtn.backgroundColor = self.textSpaceBtn.selected?[UIColor nv_colorWithHexARGB:@"#FF4A90E2"]:[UIColor nv_colorWithHexARGB:@"#FFE8E8E8"];
}

- (void)setContainFinishButton:(BOOL)containFinishButton {
    _containFinishButton = containFinishButton;
    if (containFinishButton) {
        [self remakeupSubviews];
    }
}

- (void)remakeupSubviews {
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
    __weak typeof(self)weakSelf = self;
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
    
    [self.applyButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(13*SCREENSCALE));
        make.bottom.equalTo(self.line).offset(-20*SCREENSCALE);
        make.width.height.equalTo(@(15*SCREENSCALE));
    }];
    
    [self.styleApplyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.applyButton.mas_centerY);
        make.left.equalTo(self.applyButton.mas_right).offset(7*SCREENSCALE);
    }];
}

@end
