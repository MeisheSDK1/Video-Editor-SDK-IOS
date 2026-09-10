//
//  NvBeautyTypeCViewCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/10/20.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBeautyTypeCViewCell.h"
#import "NvCaptureModularVM.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "YYWebImage.h"

@interface NvBeautyTypeCViewCell()

@property (nonatomic, strong) UILabel *nameLabel;             //外部显示文字 External display text
@property (nonatomic, strong) UIImageView *coverImageView;    //封面图片 Cover picture
@property (nonatomic, strong) UIView *bgView;                 //底背景 background
@property (nonatomic, strong) UIImageView *maskView;          //选中蒙层 Selective mask

@property (nonatomic, strong) UIImageView *coverImageView_1;
@property (nonatomic, strong) UIView *pointView;

/// 下载状态图标 Download status icon
@property (nonatomic, strong) YYAnimatedImageView *downloadView;

@property (nonatomic, strong) UILabel *lineLabel;
@end

@implementation NvBeautyTypeCViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.drawTemplate = NO;
        [self addSubviews];
    }
    return self;
}

#pragma mark - 添加子视图
/*
 添加子视图
 Add subview
 */
- (void)addSubviews{
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
        make.centerY.equalTo(self.coverImageView.mas_bottom).offset(KScale6s(18));
        make.width.mas_lessThanOrEqualTo(self.contentView.mas_width);
    }];
    
    self.pointView = [[UIView alloc]init];
    self.pointView.layer.cornerRadius = 1.5*SCREENSCALE;
    self.pointView.layer.masksToBounds = YES;
    self.pointView.hidden = YES;
    [self.contentView addSubview:self.pointView];
    [self.pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.width.offset(3*SCREENSCALE);
        make.height.offset(3*SCREENSCALE);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(8*SCREENSCALE);
    }];
    
    self.lineLabel = [[UILabel alloc] init];
    self.lineLabel.backgroundColor = [UIColor nv_colorWithHexRGB:@"#E3E3E3"];
    [self.contentView addSubview:self.lineLabel];
    [self.lineLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView.mas_centerY);
        make.left.equalTo(self.contentView);
        make.height.offset(10*SCREENSCALE);
        make.width.offset(1*SCREENSCALE);
    }];
    self.lineLabel.hidden = YES;
}

- (void)renderCellWithModel:(NvBeautyTypeModel *)model{
    [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bgView.mas_centerX);
        make.centerY.equalTo(self.coverImageView.mas_bottom).offset(KScale6s(18));
        make.width.mas_lessThanOrEqualTo(self.contentView.mas_width);
    }];
    self.nameLabel.text = NvLocalString(model.nameEn.nv_isNotEmpty ? model.nameEn : model.name, model.name) ;
    UIImage *image = [UIImage imageWithContentsOfFile:model.coverImage];
    if (model.labelColor.length > 0) {
        self.nameLabel.backgroundColor = [UIColor nv_colorWithHexRGBA:model.labelColor];
    }else{
        self.nameLabel.backgroundColor = [UIColor whiteColor];
    }

    if (model.bgColor.length > 0) {
        self.bgView.backgroundColor = [UIColor nv_colorWithHexRGBA:model.bgColor];
    }else{
        self.bgView.backgroundColor = [UIColor whiteColor];
    }
    if (!image) {
        if (model.selected) {
            image = NvImageNamed(model.selectedCoverImg);
        }else{
            image = NvImageNamed(model.coverImage);
        }
    }
    
    if (self.drawTemplate) {
        if(!self.selected && ![model.coverImage isEqualToString:@"NvCaptureBeautyStrength"]) {
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.coverImageView.tintColor = self.tintColor;
        }
        
        
        self.bgView.backgroundColor = [UIColor clearColor];
        self.nameLabel.backgroundColor = [UIColor clearColor];
    }
    
    self.coverImageView.image = image;
    
    if (model.isOperation) {
        self.coverImageView.alpha = 1;
        if (model.selected) {
            self.maskView.hidden = YES;
            
            if (model.textColor.length > 0) {
                self.nameLabel.textColor = [UIColor nv_colorWithHexRGBA:model.textColor];
            }else{
                self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CC4A90E2"];
            }
        }else{
            self.maskView.hidden = YES;
            if (model.textColor.length > 0) {
                self.nameLabel.textColor = [UIColor nv_colorWithHexRGBA:model.textColor];
            }else if (self.drawTemplate){
                self.nameLabel.textColor = [UIColor whiteColor];
            }
            else{
                self.nameLabel.textColor = [UIColor nv_colorWithHexRGBA:@"#000000CC"];
            }
        }
    }else{
        self.coverImageView.alpha = 0.2;
        if (!self.drawTemplate) {
            if (model.bgColor.length > 0) {
                self.bgView.backgroundColor = [UIColor nv_colorWithHexRGBA:model.bgColor];
            }else{
                 self.bgView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#1AFFFFFF"];
            }
        }else {
            self.bgView.backgroundColor = [UIColor clearColor];
        }
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#909293"];
        
        self.maskView.hidden = YES;
    }
    if (model.value != 0.0 &&
        ![model.name isEqualToString:NvLocalString(@"Color correction", @"校色")] &&
        ![model.name isEqualToString:NvLocalString(@"Amount", @"锐度")]) {
        self.nameLabel.text = [NSString stringWithFormat:@"%@\r%@",self.nameLabel.text,@"•"];
    }else{
        self.nameLabel.text = [NSString stringWithFormat:@"%@\r%@",self.nameLabel.text,@" "];
    }
}

- (void)renderCellWithNewModel:(NvBeautyTypeModel *)model{
    self.maskView.hidden = YES;
    self.coverImageView.layer.borderWidth = 0;
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10*SCREENSCALE);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(self.bgView.mas_width);
    }];
    
    self.nameLabel.text = NvLocalString(model.nameEn.nv_isNotEmpty ? model.nameEn : model.name, model.name);
    self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#3A3A3A"];
    
    if (model.selected && !model.parentNode){
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGBA:@"#63ABFF"];
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:model.coverImage];
    if (!image) {
        if (model.selected) {
            image = NvImageNamed(model.selectedCoverImg);
        }else{
            image = NvImageNamed(model.coverImage);
        }
    }
    
    self.pointView.hidden = model.value != 0?NO:YES;
    self.pointView.backgroundColor = model.selected?[UIColor nv_colorWithHexRGBA:@"#63ABFF"]:UIColor.blackColor;
    self.coverImageView.image = image;
    
    if (model.type == NvBeautyShadowCategory){
        self.maskView.hidden = NO;
        self.maskView.backgroundColor = UIColor.clearColor;
        self.maskView.layer.borderColor =
        [UIColor nv_colorWithHexRGBA:@"#63ABFF"].CGColor;
        self.maskView.alpha = 0.7;
        
        if (model.selected){
            self.maskView.layer.borderWidth = 2*SCREENSCALE;
        }else{
            self.maskView.layer.borderWidth = 0;
        }
        
        self.maskView.layer.masksToBounds = YES;
        self.maskView.layer.cornerRadius = 10*SCREENSCALE;
        
        [self.maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView).offset(-2.5*SCREENSCALE);
            make.left.equalTo(self.bgView).offset(-2.5*SCREENSCALE);
            make.right.equalTo(self.bgView).offset(2.5*SCREENSCALE);
            make.height.equalTo(self.maskView.mas_width);
        }];
    }
}

- (void)renderCellWithStyleModel:(NvBeautyTypeModel *)model{
    NvBeautyTemplateModel *newModel = (NvBeautyTemplateModel *)model;
    
    self.pointView.hidden = newModel.displayChangedStatus?NO:YES;
    self.pointView.backgroundColor = [UIColor nv_colorWithHexRGBA:@"#63ABFF"];
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
        make.height.equalTo(self.bgView.mas_width);
    }];
    
    self.bgView.layer.cornerRadius = 8 *SCREENSCALE;
    self.bgView.layer.masksToBounds = YES;
    
    self.coverImageView_1.hidden = YES;
    
    self.maskView.hidden = YES;
    self.maskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#D9A5CFFF"];
    
    self.nameLabel.text = NvLocalString(model.nameEn.nv_isNotEmpty ? model.nameEn : model.name, model.name);
    self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#3A3A3A"];
    
    UIImage *image = [UIImage imageWithContentsOfFile:model.coverImage];
    if (!image) {
        image = NvImageNamed(model.coverImage);
    }
    
    self.coverImageView.contentMode = UIViewContentModeScaleToFill;
    self.coverImageView.image = nil;
    self.coverImageView_1.image = nil;
    
    self.lineLabel.hidden = YES;
    
    if (model.typeTemplate == 0){
        self.coverImageView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#E3E3E3"];
        
        UIImage *tempImage = [UIImage imageWithContentsOfFile:model.selectedCoverImg];
        if (!tempImage) {
            tempImage = NvImageNamed(model.selectedCoverImg);
        }
        self.coverImageView_1.hidden = NO;
        self.coverImageView_1.image = tempImage;
        self.lineLabel.hidden = NO;
       
        [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.offset(50*SCREENSCALE);
            make.height.offset(50*SCREENSCALE);
            make.centerX.equalTo(self.contentView.mas_centerX).offset(5*SCREENSCALE);
        }];
    }else{
        if (model.selected){
            UIImage *tempImage = [UIImage imageWithContentsOfFile:model.selectedCoverImg];
            if (!tempImage) {
                tempImage = NvImageNamed(model.selectedCoverImg);
            }
            self.maskView.hidden = NO;
            
            self.coverImageView_1.hidden = NO;
            self.coverImageView_1.image = tempImage;
        }
        
        if ([model.coverImage hasPrefix:@"http"] || [model.coverImage hasPrefix:@"https"]){
            [self.coverImageView yy_setImageWithURL:[NSURL URLWithString:model.coverImage] placeholder:NvImageNamed(@"NvDefaultProps")];
        }else{
            self.coverImageView.image = image;
        }
        
        if (model.typeTemplate == 2) {
            self.coverImageView.contentMode = UIViewContentModeCenter;
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

@end
