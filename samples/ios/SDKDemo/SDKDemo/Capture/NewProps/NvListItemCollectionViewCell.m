//
//  NvListItemCollectionViewCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2022/3/17.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvListItemCollectionViewCell.h"
#import <YYWebImage/YYWebImage.h>

@interface NvListItemCollectionViewCell ()

@property (nonatomic, strong) NvBaseModel *model;

@end

@implementation NvListItemCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

#pragma mark - 初始化界面 Initialization interface
- (void)addSubviews{
    self.contentView.backgroundColor = UIColor.whiteColor;
    
    self.coverView = [YYAnimatedImageView new];
    self.coverView.contentMode = UIViewContentModeScaleToFill;
    self.coverView.layer.cornerRadius = 2*SCREENSCALE;
    self.coverView.layer.masksToBounds = YES;
    self.coverView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#2c2c2c"];
    
    self.nameLabel = [UILabel new];
    self.nameLabel.font = [NvUtils boldFontWithSize:10];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    
    self.coverMaskView = [[UIView alloc]init];
    self.coverMaskView.backgroundColor = UIColor.clearColor;
    
    self.coverMaskImageView = [[UIImageView alloc]init];
    self.coverMaskImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.downloadView = [YYAnimatedImageView new];
    self.downloadView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.coverMaskView];
    [self.contentView addSubview:self.coverMaskImageView];
    [self.contentView addSubview:self.downloadView];
    [self.contentView addSubview:self.nameLabel];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(self.contentView.mas_width);
    }];
    
    [self.downloadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.coverView).offset(-2*SCREENSCALE);
        make.right.equalTo(self.coverView).offset(-2*SCREENSCALE);
        make.width.offset(13*SCREENSCALE);
        make.height.offset(13*SCREENSCALE);
    }];
    
    [self.coverMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.coverView);
    }];
    
    [self.coverMaskImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.coverMaskView);
        make.width.height.offset(20*SCREENSCALE);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.coverView.mas_bottom).offset(4*SCREENSCALE);
    }];
    self.adjustMarkView = [[UIImageView alloc] initWithImage:NvImageNamed(@"NvProps3D")];
    self.adjustMarkView.layer.cornerRadius = 2*SCREENSCALE;
    [self.coverView addSubview:self.adjustMarkView];
    [self.adjustMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverView.mas_left);
        make.top.equalTo(self.coverView.mas_top);
        make.width.equalTo(@(15 * SCREENSCALE));
        make.height.offset(15 * SCREENSCALE);
    }];
    self.adjustMarkView.hidden = YES;
    [self.contentView layoutIfNeeded];
    
    CGFloat borderWidth = 2*SCREENSCALE;
    self.coverlayer = [CALayer layer];
    self.coverlayer.frame = CGRectMake(self.coverMaskView.frame.origin.x - borderWidth, self.coverMaskView.frame.origin.y - borderWidth, self.coverMaskView.frame.size.width + 2 * borderWidth, self.coverMaskView.frame.size.height + 2 * borderWidth);
    self.coverlayer.masksToBounds = YES;
    self.coverlayer.cornerRadius = borderWidth;
    self.coverlayer.borderWidth = borderWidth;
    self.coverlayer.borderColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"].CGColor;
    [self.coverMaskView.layer addSublayer:self.coverlayer];
}

-(void)configData:(NvBaseModel *)model{
    self.model = model;
    self.coverMaskImageView.hidden = YES;
    
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverView.mas_bottom).offset(8*SCREENSCALE);
    }];
    
    self.nameLabel.text = model.displayName;
    if ([model.coverName containsString:@"Documents/LocalAssets/"]) {
        self.coverView.image = [UIImage imageWithContentsOfFile:model.coverName];
    }else{
        [self.coverView yy_setImageWithURL:[NSURL URLWithString:model.coverName] options:YYWebImageOptionProgressive];
    }
    
    if (model.selected) {
        [self.coverMaskView.layer addSublayer:self.coverlayer];
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
        self.coverView.layer.cornerRadius = 0;
    }else{
        [self.coverlayer removeFromSuperlayer];
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#212223"];
        self.coverView.layer.cornerRadius = 2*SCREENSCALE;
    }
    
    if (model.isAdjusted) {
        self.adjustMarkView.hidden = NO;
        self.adjustMarkView.image = [UIImage imageNamed:@"asset_adjustable"];
    }else {
        self.adjustMarkView.hidden = YES;
        self.adjustMarkView.image = nil;
    }
    
    if (self.type == ASSET_FILTER) {
        [self configFilterData:model];
    }else {
        self.coverView.layer.cornerRadius = 8*SCREENSCALE;
        self.coverlayer.cornerRadius = self.coverView.layer.cornerRadius+2*SCREENSCALE;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#212223"];
        self.coverMaskView.layer.cornerRadius = self.coverView.layer.cornerRadius;
    }
    
    switch (model.state) {
        case NODownload:{
            self.downloadView.image = [UIImage imageNamed:@"NvMaterialDownload"];
        }
            break;
        case Downloading:{
            [self.downloadView yy_setImageWithURL:[NSURL fileURLWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"LocalImages/NvMaterialDownloading.gif"]] options:YYWebImageOptionSetImageWithFadeAnimation];
//            self.downloadView.image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"LocalImages/NvMaterialDownloading.gif"]];
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

- (void)setState:(DownloadState)state {
    switch (state) {
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

-(void)configFilterData:(NvBaseModel *)model{
    self.coverView.layer.cornerRadius = 8*SCREENSCALE;
    self.coverMaskView.layer.cornerRadius = self.coverView.layer.cornerRadius;
    self.coverMaskImageView.image = NvImageNamed(@"capture_beauty_template_s");
    self.coverMaskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#D9A5CFFF"];
    
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.top.equalTo(self.coverView.mas_bottom).offset(4*SCREENSCALE);
    }];
    
    [self.coverlayer removeFromSuperlayer];
    self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#212223"];
    
    if (model.selected) {
        self.coverMaskImageView.hidden = NO;
        self.coverMaskView.hidden = NO;
    }else{
        self.coverMaskImageView.hidden = YES;
        self.coverMaskView.hidden = YES;
    }
}

@end
