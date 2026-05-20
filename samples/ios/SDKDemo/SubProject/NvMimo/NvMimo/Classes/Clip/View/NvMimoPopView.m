//
//  NvMimoPopView.m
//  NvMimoDemo
//
//  Created by MS on 2020/7/29.
//  Copyright © 2020 MS. All rights reserved.
//

#import "NvMimoPopView.h"
#import "NVHeader.h"
#import "NVMimoDefineConfig.h"
@interface NvMimoPopView()<UIGestureRecognizerDelegate>

@property(nonatomic,assign)NvMimoPopDirection presentDirection;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UISlider *progressSlider;
@end

@implementation NvMimoPopView
-(instancetype)init{
    self = [super initWithFrame:CGRectMake(0, 0, SCREANWIDTH, SCREANHEIGHT)];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews{
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREANWIDTH, SCREANHEIGHT)];
    _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    _bgView.alpha = 0.f;
    UITapGestureRecognizer* _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgClicked:)];
    _tap.delegate = self;
    [_bgView addGestureRecognizer:_tap];
    [self addSubview:_bgView];
    self.bgView.backgroundColor = [UIColor clearColor];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240*SCREANSCALE, 99*SCREANSCALE)];
    contentView.backgroundColor = [UIColor redColor];
    [self addSubview:contentView];
    contentView.centerX = self.centerX;
    self.contentView = contentView;
    self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    self.contentView.layer.cornerRadius = 10*SCREANSCALE;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18*SCREANSCALE];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    [contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView.mas_top).offset(20*SCREANSCALE);
        make.left.right.equalTo(contentView);
        make.height.mas_equalTo(22.f*SCREANSCALE);
    }];
    
    self.progressSlider = [[UISlider alloc] init];
    [contentView addSubview:self.progressSlider];
    self.progressSlider.minimumValue = 0;
    self.progressSlider.maximumValue = 100;
    [self.progressSlider setThumbTintColor:[UIColor clearColor]];
    [self.progressSlider setMinimumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"]];
    [self.progressSlider setMaximumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#CFCFCF"]];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(contentView.mas_left).offset(7 * SCREANSCALE);
        make.right.equalTo(contentView.mas_right).offset(-7 * SCREANSCALE);
        make.centerY.equalTo(self.titleLabel.mas_bottom).offset(21*SCREANSCALE);
    }];
}

- (void)setProgressValue:(CGFloat)progressValue {
    _progressValue = progressValue;
    _progressSlider.value = progressValue;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = title.length >0 ? title : @"";
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    CGPoint localPoint = [gestureRecognizer locationInView:self];
    if(CGRectContainsPoint(self.contentView.frame,localPoint)){
        return NO;
    }
    return YES;
}

-(void)bgClicked:(UIGestureRecognizer*)gesture{

}

-(void)showWithDirection:(NvMimoPopDirection)direction completion:(void (^ __nullable)(void))completion{
    self.presentDirection = direction;
    CGRect frame = self.contentView.frame;
    
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    if (direction == NvMimoPopDirection_Bottom) {
        self.contentView.center = CGPointMake(SCREANWIDTH*0.5, SCREANHEIGHT+frame.size.height);
        frame.origin.y = SCREANHEIGHT - frame.size.height;
    }else{
        self.contentView.center = self.center;
        self.contentView.alpha = 0.f;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        if (direction == NvMimoPopDirection_Bottom) {
            self.contentView.frame = frame;
        }else{
            self.contentView.alpha = 1.f;
        }
        self.bgView.alpha = 1.f;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
    
}

-(void)dismissCompletion:(void (^ __nullable)(void))completion{
    CGRect frame = self.contentView.frame;
    frame.origin.y = SCREANHEIGHT;
    [UIView animateWithDuration:0.25 animations:^{
        if (self.presentDirection == NvMimoPopDirection_Bottom) {
            self.contentView.frame = frame;
        }else{
            self.contentView.alpha = 0.f;
        }
        self.bgView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (completion) {
            completion();
        }
    }];
}

@end
