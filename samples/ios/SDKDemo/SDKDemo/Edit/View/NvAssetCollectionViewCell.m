//
//  StickerCollectionViewCell.m
//  Caption
//
//  Created by meishe01 on 2017/8/23.
//  Copyright © 2017年 NewAuto video team. All rights reserved.
//

#import "NvAssetCollectionViewCell.h"
#import "NVHeader.h"
#import "NvYYAnimatedImageView.h"
@interface NvAssetCollectionViewCell () {
    NvYYAnimatedImageView *_coverImage;
    UIView *_maskView;
    UIImageView *_playImageView;
    UILabel *addLabel;
    UIImageView *addImageView;
    UIView *addView;
}

@end

@implementation NvAssetCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _coverImage = [[NvYYAnimatedImageView alloc] initWithFrame:CGRectMake(10 * SCREENSCALE, 10 * SCREENSCALE, frame.size.width - 20* SCREENSCALE, frame.size.height - 20* SCREENSCALE)];
        _coverImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_coverImage];
        
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _maskView.layer.borderWidth = 2;
        _maskView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        _maskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#334A90E2"];;
        _maskView.layer.cornerRadius = 5 * SCREENSCALE;
        [self addSubview:_maskView];
        
        _playImageView = UIImageView.new;
        _playImageView.contentMode = UIViewContentModeScaleAspectFit;
        [_maskView addSubview:_playImageView];
        [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self->_maskView.mas_centerX);
            make.centerY.equalTo(self->_maskView.mas_centerY);
            make.width.height.equalTo(@(13*SCREENSCALE));
        }];
        
        addView = [[UIView alloc]init];
        addView.backgroundColor = self.backgroundColor;
        addView.layer.borderWidth = 1;
        addView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#848788"].CGColor;
        [self addSubview:addView];
        [addView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        
        addImageView = [[UIImageView alloc]init];
        addImageView.contentMode = UIViewContentModeScaleAspectFit;
        [addView addSubview:addImageView];
        [addImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self->addView.mas_centerX);
            make.centerY.equalTo(self->addView.mas_centerY).offset(-10 * SCREENSCALE);
        }];
        
        addLabel = [[UILabel alloc]init];
        addLabel.font = [NvUtils fontWithSize:12];
        addLabel.text = NvLocalString(@"Add", @"添加");
        addLabel.textColor = [UIColor nv_colorWithHexRGB:@"#909293"];
        [addView addSubview:addLabel];
        [addLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.centerY.equalTo(self.contentView.mas_centerY).offset(10 * SCREENSCALE);
        }];
        
    }
    return self;
}

- (void)renderCellWithItem:(NvAssetCellModel *)item {
    if (item.isPlay) {
        _playImageView.image = NvImageNamed(@"NvPause");
    }else{
        _playImageView.image = NvImageNamed(@"NvPlayback");
    }
    if (item.package && item.covergif && item.covergif.length > 0) {
        
        _coverImage.NVImagePath = item.covergif;
    } else {
        
        _coverImage.NVImagePath = item.cover;
    }
    
    if (item.selected) {
        _playImageView.hidden = NO;
        _maskView.hidden = NO;
    } else {
        _playImageView.hidden = YES;
        _maskView.hidden = YES;
    }
    
    if ([item.cover isEqualToString:@"NvEditWatemarButton"]) {
        addImageView.image = NvImageNamed(item.cover);
        addView.hidden = NO;
        _coverImage.hidden = YES;
    }else{
        addView.hidden = YES;
        _coverImage.hidden = NO;
    }
}

@end
