//
//  NvMakeupCell.m
//  SDKDemo
//
//  Created by MS on 2020/7/16.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvMakeupCell.h"
#import "NVHeader.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "YYWebImage.h"

@interface NvMakeupCell ()
@property (nonatomic, strong) UIImageView *coverImageView;    //封面图片 Cover picture
@property (nonatomic, strong) UIView *bgView;                 //底背景 background
@property (nonatomic, strong) UIImageView *maskView;          //选中蒙层 Selective mask

@property (nonatomic, strong) UIImageView *coverImageView_1;

/// 下载状态图标 Download status icon
@property (nonatomic, strong) YYAnimatedImageView *downloadView;
@end

@implementation NvMakeupCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bgView = [[UIView alloc]init];
        self.bgView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
        [self.contentView addSubview:self.bgView];
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.width.mas_equalTo(self.contentView.width*3/5);
            make.height.mas_equalTo(self.contentView.width*3/5);
            make.top.mas_equalTo(self.contentView).offset(5);
        }];
        
        self.coverImageView = [[UIImageView alloc] init];
        self.coverImageView.contentMode = UIViewContentModeScaleToFill;
        [self.bgView addSubview:self.coverImageView];
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.bgView.mas_width);
            make.height.equalTo(self.bgView.mas_height);
            make.centerX.equalTo(self.bgView);
            make.centerY.equalTo(self.bgView);
        }];
        
        self.downloadView = [YYAnimatedImageView new];
        self.downloadView.contentMode = UIViewContentModeScaleAspectFit;
        [self.bgView addSubview:self.downloadView];
        [self.downloadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.coverImageView).offset(-2*SCREENSCALE);
            make.right.equalTo(self.coverImageView).offset(-2*SCREENSCALE);
            make.width.offset(13*SCREENSCALE);
            make.height.offset(13*SCREENSCALE);
        }];
        
        self.maskView = [[UIImageView alloc] init];
        self.maskView.contentMode = UIViewContentModeScaleAspectFit;
        self.maskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
        [self.bgView addSubview:self.maskView];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView);
            make.left.equalTo(self.bgView);
            make.right.equalTo(self.bgView);
            make.bottom.equalTo(self.bgView);
        }];
        
        self.coverImageView_1 = [[UIImageView alloc] init];
        self.coverImageView_1.hidden = YES;
        self.coverImageView_1.contentMode = UIViewContentModeScaleToFill;
        [self.bgView addSubview:self.coverImageView_1];
        [self.coverImageView_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.offset(20*SCREENSCALE);
            make.height.offset(20*SCREENSCALE);
            make.centerX.equalTo(self.bgView);
            make.centerY.equalTo(self.bgView);
        }];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.font = [UIFont systemFontOfSize:10*SCREENSCALE];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.bgView.mas_centerX);
            make.centerY.equalTo(self.coverImageView.mas_bottom).offset(KScale6s(14));
            make.width.mas_equalTo(self.contentView.mas_width);
        }];
    }
    return self;
}

- (void)renderCellWithModel:(NvMakeupCellModel *)model{
    self.bgView.layer.cornerRadius = 8 *SCREENSCALE;
    self.bgView.layer.masksToBounds = YES;
    
    self.coverImageView_1.hidden = YES;
    
    self.maskView.hidden = YES;
    self.maskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#D9A5CFFF"];
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(self.bgView.mas_width);
    }];
    
    self.nameLabel.text = @"";
    if ([NvUtils currentLanguagesIsChinese]){
        self.nameLabel.text = model.displayNameZhCn > 0 ? model.displayNameZhCn : model.displayName;
    }else {
        self.nameLabel.text = model.displayName;
    }
    self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#3A3A3A"];
    
    UIImage *image = [UIImage imageWithContentsOfFile:model.coverImage];
    if (!image) {
        image = NvImageNamed(model.coverImage);
    }
    
    self.coverImageView.image = nil;
    self.coverImageView_1.image = nil;
    
    if ([model.displayNameZhCn isEqualToString:NvLocalString(@"None", @"无")] || [model.displayName isEqualToString:NvLocalString(@"None", @"无")]){
        self.coverImageView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#E3E3E3"];
        self.coverImageView_1.hidden = NO;
        [self.coverImageView yy_setImageWithURL:nil placeholder:nil];
        self.coverImageView_1.image = image;
    }else{
        if (model.selected){
            UIImage *tempImage = NvImageNamed(@"capture_beauty_template_s");
            
            self.maskView.hidden = NO;
            
            self.coverImageView_1.hidden = NO;
            self.coverImageView_1.image = tempImage;
        }
        
        if ([model.coverImage hasPrefix:@"http"] || [model.coverImage hasPrefix:@"https"]){
            [self.coverImageView yy_setImageWithURL:[NSURL URLWithString:model.coverImage] placeholder:NvImageNamed(@"NvDefaultProps")];
        }else{
            self.coverImageView.image = image;
        }
        self.coverImageView.backgroundColor = UIColor.clearColor;
    }
    
    switch (model.state) {
        case NODownload:{
            self.downloadView.image = [UIImage imageNamed:@"NvMaterialDownload"];
        }
            break;
        case Downloading:{
            self.downloadView.image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"LocalImages/NvMaterialDownloading.gif"]];
        }
            break;
        case DownloadError:{
            self.downloadView.image = [UIImage imageNamed:@"NvMaterialDownload"];
        }
            break;
        case Finish:{
            self.downloadView.image = nil;
        }
            break;
        case Update:{
            self.downloadView.image = [UIImage imageNamed:@"NvMaterialDownload"];
        }
            break;
        case NoUser:{
           
        }
            break;
        default:{
            
        }
            break;
    }
}

-(void)setTextColor:(UIColor *)color{
    
    self.nameLabel.textColor = color;
}
@end
