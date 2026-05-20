//
//  NvPhotoAlbumTemplateView.m
//  SDKDemo
//
//  Created by MS on 2019/9/29.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvPhotoAlbumTemplateView.h"
#import "NVDefineConfig.h"
#import "NVHeader.h"

@interface NvPhotoAlbumTemplateView ()
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UISlider *progressSlider;
@end

@implementation NvPhotoAlbumTemplateView


-(void)setupSubviews{
    [super setupSubviews];
    self.bgView.backgroundColor = [UIColor clearColor];
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 240*SCREENSCALE, 99*SCREENSCALE)];
    contentView.backgroundColor = [UIColor redColor];
    [self addSubview:contentView];
    contentView.centerX = self.centerX;
    self.contentView = contentView;
    self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    self.contentView.layer.cornerRadius = 10*SCREENSCALE;
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18*SCREENSCALE];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    [contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(contentView.mas_top).offset(20*SCREENSCALE);
        make.left.right.equalTo(contentView);
        make.height.mas_equalTo(22.f*SCREENSCALE);
    }];
    
    self.progressSlider = [[UISlider alloc] init];
    [contentView addSubview:self.progressSlider];
    self.progressSlider.minimumValue = 0;
    self.progressSlider.maximumValue = 100;
    [self.progressSlider setThumbTintColor:[UIColor clearColor]];
    [self.progressSlider setMinimumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"]];
    [self.progressSlider setMaximumTrackTintColor:[UIColor nv_colorWithHexRGB:@"#CFCFCF"]];
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(contentView.mas_left).offset(7 * SCREENSCALE);
        make.right.equalTo(contentView.mas_right).offset(-7 * SCREENSCALE);
        make.centerY.equalTo(self.titleLabel.mas_bottom).offset(21*SCREENSCALE);
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

-(void)bgClicked:(UIGestureRecognizer*)gesture{
//    [self dismissCompletion:nil];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
