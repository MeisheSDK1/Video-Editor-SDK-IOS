//
//  NvAllAssetCell.m
//  SDKDemo
//
//  Created by Meicam on 2018/5/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvAllAssetCell.h"
#import "NvAlbumUtils.h"
#import <Masonry/Masonry.h>
#import "UIColor+NvColor.h"
#import "NVDefineConfig.h"
#import "PHAsset+NvAlbum.h"
@import Photos;

//#define TestOriginalFile

@interface NvAllAssetCell ()

@property (nonatomic, strong) UIView *layerView;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UIImageView *bottomBackView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) PHAsset *asset;


@property (nonatomic, strong) NSDictionary *attribtDic;

@end

@implementation NvAllAssetCell

- (void)dealloc {

}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.mutableSelect = YES;
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        self.layerView = [UIView new];
        self.layerView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.layerView.alpha = 0.6;
        [self.contentView addSubview:self.layerView];
        [self.layerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        self.layerView.hidden = YES;
        
        self.numLabel = [UILabel new];
        self.numLabel.textColor = [UIColor whiteColor];
        self.numLabel.textAlignment = NSTextAlignmentCenter;
        self.numLabel.font = [NvAlbumUtils fontWithSize:32*SCREENSCALE];
        [self.layerView addSubview:self.numLabel];
        [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.contentView);
            make.height.equalTo(@(45*SCREENSCALE));
            make.center.equalTo(self.layerView);
        }];
        
        _durationLabel = UILabel.new;
        NSShadow *shadow = [NSShadow new];
        shadow.shadowBlurRadius = 4;
        shadow.shadowColor = [UIColor blackColor];
        shadow.shadowOffset =CGSizeMake(0,2);
        self.attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleNone],
                                     NSShadowAttributeName: shadow
                                     };
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:@"00:00" attributes:self.attribtDic];
        _durationLabel.attributedText = attribtStr;
        _durationLabel.font = [NvAlbumUtils fontWithSize:9];
        _durationLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_durationLabel];
        [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.imageView.mas_right).offset(-5);
            make.bottom.equalTo(self.imageView.mas_bottom).offset(-5);
        }];
        
        self.bottomBackView = [UIImageView new];
        self.bottomBackView.image = NvImageNamedForBundle(@"videocam - material", NvCurrentBundle);
        [self.contentView addSubview:self.bottomBackView];
        [self.bottomBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.durationLabel.mas_left).offset(-3*SCREENSCALE);
            make.centerY.equalTo(self.durationLabel.mas_centerY);
            make.height.equalTo(@(12*SCREENSCALE));
            make.width.equalTo(@(18*SCREENSCALE));
        }];
        
        self.fileSwitch = [[UISwitch alloc] init];
#ifdef TestOriginalFile
        [self.contentView addSubview:self.fileSwitch];
        [self.fileSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(5);
            make.top.equalTo(self).offset(5);
        }];
        [self.fileSwitch addTarget:self action:@selector(fileSwitchValueChanged:) forControlEvents:(UIControlEventValueChanged)];
#endif
    }
    return self;
}

- (void)fileSwitchValueChanged:(UISwitch *)item {
    [self.delegate cellSwitchValueChanged:item.on asset:self.asset];
}

- (void)showLayer:(BOOL)isShow withNum:(NSInteger)num {
    self.layerView.hidden = !isShow;
    if (!self.mutableSelect) {
        self.numLabel.text = @"";
    } else {
        self.numLabel.text = [NSString stringWithFormat:@"%ld",num];
    }
}

- (void)renderCellWithAsset:(PHAsset *)asset {
    self.asset = asset;
    [self showLayer:asset.isShowLayer withNum:asset.number];
    __weak typeof(self)weakSelf = self;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];

    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(SCREENWIDTH/3, SCREENWIDTH/3) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weakSelf.imageView.image = result;
    }];

    if (asset.mediaType == PHAssetMediaTypeImage) {
        _durationLabel.hidden = YES;
        self.bottomBackView.hidden = YES;
        if ([NvAlbumUtils checkIsLivePhoto:asset] == YES) {
            asset.isLivePhoto = YES;
            self.bottomBackView.hidden = NO;
            self.bottomBackView.image = NvImageNamedForBundle(@"compile_live_tag", NvCurrentBundle);
            [self.bottomBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.contentView.mas_right).offset(-3*SCREENSCALE);
                make.centerY.equalTo(self.durationLabel.mas_centerY);
                make.height.equalTo(@(12*SCREENSCALE));
                make.width.equalTo(@(12*SCREENSCALE));
            }];
        }
    } else {
        _durationLabel.hidden = NO;
        self.bottomBackView.hidden = NO;
        NSInteger minutes = (NSInteger)(asset.duration / 60.0);
        NSInteger seconds = (NSInteger)round(asset.duration - 60.0 * (double)minutes);
        NSString *text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:text attributes:self.attribtDic];
        _durationLabel.attributedText = attribtStr;
        self.bottomBackView.image = NvImageNamedForBundle(@"videocam - material", NvCurrentBundle);
        [self.bottomBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.durationLabel.mas_left).offset(-3*SCREENSCALE);
            make.centerY.equalTo(self.durationLabel.mas_centerY);
            make.height.equalTo(@(12*SCREENSCALE));
            make.width.equalTo(@(18*SCREENSCALE));
        }];
    }
}
@end
