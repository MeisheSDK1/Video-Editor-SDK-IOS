//
//  NvCaptureFilterCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCaptureFilterCell.h"
#import "NvHeader.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "NvImageView.h"

@interface NvCaptureFilterCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) NvImageView *coverView;
@property (nonatomic, strong) UIImageView *imageViewType;
@property (nonatomic, strong) UIImageView *adjustMarkView;
@property (nonatomic, assign) CGFloat sizeFloat;

@property (nonatomic, strong) UIImageView *toEditImgView;
@property (nonatomic, strong) UILabel *toEditLabel;
@end

@implementation NvCaptureFilterCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.sizeFloat = frame.size.width;
        self.coverView = [[NvImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.coverView.contentMode = UIViewContentModeScaleToFill;
        self.coverView.layer.cornerRadius = 4 * SCREENSCALE;
        [self.contentView addSubview:self.coverView];
        
        self.maskView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.maskView.contentMode = UIViewContentModeScaleAspectFit;
        self.maskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
        self.maskView.layer.masksToBounds = YES;
        self.maskView.layer.cornerRadius = 4 * SCREENSCALE;
        [self.contentView addSubview:self.maskView];
        
        self.toEditImgView = [[UIImageView alloc]initWithFrame:CGRectMake(frame.size.width*3/10, frame.size.width/6, frame.size.width*2/5, frame.size.width*2/5)];
        self.toEditImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.maskView addSubview:self.toEditImgView];
        self.toEditLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.width*3/5, frame.size.width, 13 * SCREENSCALE)];
        self.toEditLabel.textAlignment = NSTextAlignmentCenter;
        self.toEditLabel.textColor = UIColor.whiteColor;
        self.toEditLabel.alpha = 0.8;
        self.toEditLabel.font = [UIFont systemFontOfSize:9*SCREENSCALE];
        [self.maskView addSubview:self.toEditLabel];
        self.toEditLabel.hidden = YES;
        self.toEditImgView.hidden = YES;
        
        self.nameLabel = [[UILabel alloc]init];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.alpha = 0.8;
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.font = [NvUtils regularFontWithSize:11];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.centerY.equalTo(self.maskView.mas_bottom).offset(KScale6s(18));
        }];
        
        self.imageViewType = [[UIImageView alloc] initWithImage:NvImageNamed(@"NvProps3D")];
        [self.contentView addSubview:self.imageViewType];
        [self.imageViewType mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.coverView.mas_right);
            make.bottom.equalTo(self.coverView.mas_bottom);
            make.width.equalTo(@(19 * SCREENSCALE));
            make.height.offset(19 * SCREENSCALE);
        }];
        
        self.adjustMarkView = [[UIImageView alloc] initWithImage:NvImageNamed(@"NvProps3D")];
        [self.contentView addSubview:self.adjustMarkView];
        self.adjustMarkView.layer.cornerRadius = 4 * SCREENSCALE;
        [self.adjustMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coverView.mas_left);
            make.top.equalTo(self.coverView.mas_top);
            make.width.equalTo(@(15 * SCREENSCALE));
            make.height.offset(15 * SCREENSCALE);
        }];
        self.adjustMarkView.hidden = YES;
    }
    return self;
}

- (void)renderCellWithModel:(NvBaseModel *)model{
    self.coverView.layer.masksToBounds = YES;
    if ([model.coverName isEqualToString:@"NvsFilterNone"]) {
        self.coverView.layer.masksToBounds = NO;
        self.imageViewType.hidden = YES;
    } else {
        self.imageViewType.hidden = NO;
    }
    if (model.coverName != nil && ![model.coverName isEqualToString:@""]) {
        if ([model.coverName hasPrefix:@"http"]) {
            [self.coverView yy_setImageWithURL:[NSURL URLWithString:model.coverName] placeholder:NvImageNamed(@"NvDefaultProps")];
        } else {
            self.coverView.image = NvImageNamed(model.coverName);
        }
        if(self.coverView.image == nil) {
            self.coverView.image = [UIImage imageWithContentsOfFile:model.coverName];
        }
    }else if (model.packageId && model.packageId.length != 0){
        NSString *coverName = [self getAssetCover:model.packageId];
        UIImage *image = NvImageNamed(coverName);
        if (!image) {
            coverName = @"NvDefaultProps";
            image = NvImageNamed(coverName);
        }
        self.coverView.image = NvImageNamed(coverName);
    }else{
        self.coverView.image = NvImageNamed(@"NvDefaultProps");
    }

    self.nameLabel.text = NvLocalString(model.displayName, model.displayName) ;
    if (model.selected) {
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.maskView.hidden = NO;
    }else{
        self.nameLabel.textColor = UIColor.whiteColor;
        self.maskView.hidden = YES;
    }
    
    if (model.selected && model.toEdit && model.toEditImg.length > 0) {
        self.toEditLabel.hidden = NO;
        self.toEditImgView.hidden = NO;
        self.toEditImgView.image = NvImageNamed(model.toEditImg);
        self.toEditLabel.text = model.toEditInfo;
    }else{
        self.toEditImgView.image = nil;
        self.toEditLabel.text = @"";
        self.toEditLabel.hidden = YES;
        self.toEditImgView.hidden = YES;
    }
    switch (model.categoryId) {
        case 1:
            self.imageViewType.image = NvImageNamed(@"NvProps2D");
            break;
        case 2:
            self.imageViewType.image = NvImageNamed(@"NvProps3D");
            break;
        case 3:
            self.imageViewType.image = NvImageNamed(@"NvPropsForeground");
            break;
        case 4:
            self.imageViewType.image = NvImageNamed(@"NvPropsBackground");
            break;
        case 5:
            self.imageViewType.image = NvImageNamed(@"NvPropsEye");
            break;
        case 6:
            self.imageViewType.image = NvImageNamed(@"NvPropsMouth");
            break;
        case 7:
            self.imageViewType.image = NvImageNamed(@"NvPropsHead");
            break;
        case 8:
            self.imageViewType.image = NvImageNamed(@"NvPropsGesture");
            break;
        default:
            break;
    }
    //如果不是ASSET_ARSCENE类型则隐藏脚标
    //If the type is not ASSET_ARSCENE, the footer is hidden
    if (self.type == ASSET_ARSCENE) {
        
    } else {
        self.imageViewType.hidden = YES;
    }
    if (model.isAdjusted) {
        self.adjustMarkView.hidden = NO;
        self.adjustMarkView.image = [UIImage imageNamed:@"asset_adjustable"];
    }else {
        self.adjustMarkView.hidden = YES;
    }
}

#pragma mark - 根据参数返回封面图
/*
 根据参数返回封面图
 Return the cover image according to the parameters
 
 @param string 素材的packageid
 The packageid of the material
 
 return 返回NSString值。封面图路径。
 Cover image path
 */
- (NSString *)getAssetCover:(NSString *)string{
    NSString *new = @"";
    NSFileManager *fm = [NSFileManager defaultManager];
    if (self.type == ASSET_ARSCENE) {
        new = [[[NSBundle mainBundle] pathForResource:@"face1sticker" ofType:@"bundle"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",string]];
        if (![fm fileExistsAtPath:new]) {
            new = [[[NSBundle mainBundle] pathForResource:@"face1sticker" ofType:@"bundle"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",string]];
        }
        if (![fm fileExistsAtPath:new]) {
            new = [[[NSBundle mainBundle] pathForResource:@"face1sticker" ofType:@"bundle"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.webp",string]];
        }
    }else{
        new = [[[NSBundle mainBundle] pathForResource:@"filter" ofType:@"bundle"]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",string]];
        if (![fm fileExistsAtPath:new]) {
            new = [[[NSBundle mainBundle] pathForResource:@"filter" ofType:@"bundle"]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",string]];
        }
        if (![fm fileExistsAtPath:new]) {
            new = [[[NSBundle mainBundle] pathForResource:@"filter" ofType:@"bundle"]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.webp",string]];
        }
    }
    
    return new;
}

@end

