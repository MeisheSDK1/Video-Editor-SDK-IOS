//
//  NvMoreFilterCollectionCell.m
//  SDKDemo
//
//  Created by MS on 2020/7/27.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvMoreFilterCollectionCell.h"
#import <UIImageView+YYWebImage.h>
#import "NVHeader.h"
@interface NvMoreFilterCollectionCell ()
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) UIImageView *imageViewType;
@property (nonatomic, strong) UIImageView *adjustMarkView;
@end

@implementation NvMoreFilterCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

#pragma mark - 初始化界面
/*
 初始化界面
 Initialize the interface
 
 */
- (void)addSubviews{
    self.contentView.layer.cornerRadius = 4*SCREENSCALE;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    self.coverView = [YYAnimatedImageView new];
    self.coverView.contentMode = UIViewContentModeScaleToFill;
    
    self.nameLabel = [UILabel new];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [NvUtils boldFontWithSize:14 * SCREENSCALE];
    
    self.sizeLabel = [UILabel new];
    self.sizeLabel.textColor = [UIColor whiteColor];
    self.sizeLabel.font = [UIFont systemFontOfSize:12 * SCREENSCALE];
    
    self.download = [NvDownloadBtn buttonWithType:UIButtonTypeCustom];
    self.download.progressSize = CGSizeMake(self.frame.size.width, self.frame.size.height);
    [self.download addTarget:self action:@selector(downloadBtn) forControlEvents:UIControlEventTouchUpInside];
    
    self.categoryLabel = [[UILabel alloc] init];
    self.categoryLabel.font = [NvUtils regularFontWithSize:10*SCREENSCALE];
    self.categoryLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.categoryLabel];
    
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.sizeLabel];
    [self.contentView addSubview:self.download];
    [self.categoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.left.equalTo(self.contentView.mas_left);
        make.width.mas_equalTo(44.5*SCREENSCALE);
        make.height.mas_equalTo(18*SCREENSCALE);
    }];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.contentView.mas_top);
        make.width.mas_equalTo(self.contentView.mas_width);
        make.height.mas_equalTo(self.contentView.mas_width);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(10 * SCREENSCALE);
        make.top.equalTo(self.coverView.mas_bottom).offset(2*SCREENSCALE);
        make.height.mas_equalTo(20*SCREENSCALE);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(4*SCREENSCALE);
        make.height.mas_equalTo(17*SCREENSCALE);
    }];
    
    [self.download mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.height.offset(33 * SCREENSCALE);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
    
    self.unSuitMaskView = [[UIView alloc] init];
    self.unSuitMaskView.backgroundColor = [UIColor nv_colorWithHexRGBA:@"#00000046"];
    [self.contentView addSubview:self.unSuitMaskView];
    [self.unSuitMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.coverView.mas_bottom);
        make.left.right.equalTo(self.contentView);
    }];
    
    UILabel *unSuitLabel = [[UILabel alloc] init];
    unSuitLabel.font = [UIFont systemFontOfSize:13*SCREENSCALE];
    unSuitLabel.textColor = [UIColor whiteColor];
    unSuitLabel.textAlignment = NSTextAlignmentCenter;
    unSuitLabel.text = NvLocalString(@"Not adapted", @"不适配");
    [self.unSuitMaskView addSubview:unSuitLabel];
    [unSuitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20*SCREENSCALE);
        make.bottom.equalTo(self.unSuitMaskView.mas_bottom).offset(-21*SCREENSCALE);
        make.left.right.equalTo(self.contentView);
    }];
    
    UIImageView *unSuitImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Nv_filter_unSuit"]];
    [self.unSuitMaskView addSubview:unSuitImageView];
    [unSuitImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(35*SCREENSCALE);
        make.width.mas_equalTo(25*SCREENSCALE);
        make.bottom.equalTo(unSuitLabel.mas_top).offset(-4*SCREENSCALE);
        make.centerX.equalTo(self.unSuitMaskView.mas_centerX);
    }];
    
    self.errMaskView = [[UIView alloc] init];
    self.errMaskView.backgroundColor = [UIColor nv_colorWithHexRGBA:@"#00000046"];
    [self.contentView addSubview:self.errMaskView];
    [self.errMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.coverView.mas_bottom);
        make.left.right.equalTo(self.contentView);
    }];
    
    UILabel *errLabel = [[UILabel alloc] init];
    errLabel.font = [UIFont systemFontOfSize:13*SCREENSCALE];
    errLabel.textColor = [UIColor redColor];
    errLabel.textAlignment = NSTextAlignmentCenter;
    errLabel.text = NvLocalString(@"downloadFaild", @"下载失败");
    [self.errMaskView addSubview:errLabel];
    [errLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20*SCREENSCALE);
        make.centerY.equalTo(self.errMaskView.mas_centerY);
        make.left.right.equalTo(self.contentView);
    }];
    self.adjustMarkView = [[UIImageView alloc] initWithImage:NvImageNamed(@"NvProps3D")];
    [self.contentView addSubview:self.adjustMarkView];
    [self.adjustMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverView.mas_left);
        make.top.equalTo(self.coverView.mas_top);
        make.width.equalTo(@(24 * SCREENSCALE));
        make.height.offset(24 * SCREENSCALE);
    }];
    self.adjustMarkView.hidden = YES;

    self.unSuitMaskView.hidden = YES;
    self.errMaskView.hidden = YES;
    [self.contentView bringSubviewToFront:self.categoryLabel];
    self.contentView.layer.shadowColor = [UIColor nv_colorWithHexRGB:@"#000000"].CGColor;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 0);
    self.contentView.layer.shadowOpacity = 0.5;
    self.contentView.layer.shadowRadius = 4;
}

- (void)setModel:(NvBaseModel *)model{
    _model = model;
    self.unSuitMaskView.hidden = YES;
    self.errMaskView.hidden = YES;

    if (_type == ASSET_FACE1_STICKER) {
        _string = NvLocalString(@"Frame", @"画幅");
    }else{
        _string = NvLocalString(@"Types", @"类型");
    }

    self.nameLabel.text = model.displayName;
    [self.coverView yy_setImageWithURL:[NSURL URLWithString:model.coverName] options:YYWebImageOptionProgressive];
    self.sizeLabel.text = [NSString stringWithFormat:NvLocalString(@"Size", @"大小：%@"),model.size];
    NSString *typeString = model.draw;
    NSString *categoryColorStr = @"#FF54CC";
    if (self.type == ASSET_ARSCENE) {
        switch (model.categoryId) {
            case 1:
                typeString = @"2D";
                categoryColorStr = @"#FF54CC";
                break;
            case 2:
                typeString = @"3D";
                categoryColorStr = @"#56A4FF";
                break;
            case 3:
                typeString = NvLocalString(@"Foreground", @"前景");
                categoryColorStr = @"#FF9B44";
                break;
            case 4:
                typeString = NvLocalString(@"Background", @"背景");
                categoryColorStr = @"#8B68FF";
                break;
            case 5:
                typeString = NvLocalString(@"Eye", @"眼部");
                categoryColorStr = @"#2BC55E";
                break;
            case 6:
                typeString = NvLocalString(@"Mouth", @"嘴部");
                categoryColorStr = @"#C244FF";
                break;
            case 7:
                typeString = NvLocalString(@"Head", @"头部");
                categoryColorStr = @"#FF4B4B";
                break;
            case 8:
                typeString = NvLocalString(@"Gesture", @"手势");
                categoryColorStr = @"#AFD800";
                break;
            case 9:
                typeString = NvLocalString(@"FakeFace", @"假脸");
                categoryColorStr = @"#68FFFF";
                break;
            case 10:
                typeString = @"animoji";
                categoryColorStr = @"#FFE268";
                break;
            default:
                break;
        }
        if (categoryColorStr) {
            self.categoryLabel.text = [NSString stringWithFormat:@"%@",typeString];
            self.categoryLabel.backgroundColor = [UIColor nv_colorWithHexRGB:categoryColorStr];
        }
        
    } else {
        typeString = model.draw;
    }
 
    switch (self.model.state) {
        case NODownload:{
            self.download.stateTitle = NvLocalString(@"Download", @"下载");
        }
            break;
        case Downloading:{
            
        }
            break;
        case DownloadError:{
            self.download.stateTitle = NvLocalString(@"again", @"重试");
            self.errMaskView.hidden = NO;
            [self.contentView bringSubviewToFront:self.errMaskView];
        }
            break;
        case Finish:{
            self.download.stateTitle = NvLocalString(@"Downloaded", @"已下载");
        }
            break;
        case Update:{
            self.download.stateTitle = NvLocalString(@"Update", @"更新");
        }
            break;
        case NoUser:{
            self.download.stateTitle = NvLocalString(@"Not adapted", @"不适配");
            self.unSuitMaskView.hidden = NO;
            [self.contentView bringSubviewToFront:self.unSuitMaskView];
        }
            break;
        default:{
            
        }
            break;
    }
    if (model.isAdjusted) {
        self.adjustMarkView.hidden = NO;
        self.adjustMarkView.image = [UIImage imageNamed:@"asset_adjustable"];
    }else {
        self.adjustMarkView.hidden = YES;
    }
}

#pragma mark - 下载按钮点击事件
/*
 下载按钮点击事件
 Download button click event
 
 */
- (void)downloadBtn{
    [_delegate nvMoreFilterCollectionCell:self nvBaseModel:self.model];
}
@end
