//
//  NvAlbumBottomSelectedCell.m
//  NvAlbum
//
//  Created by meishe20241218 on 2025/6/26.
//

#import "NvAlbumBottomSelectedCell.h"
#import <Masonry/Masonry.h>
#import "NVDefineConfig.h"

@interface NvAlbumBottomSelectedCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *layerView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImageView *deleteImgView;
@end

@implementation NvAlbumBottomSelectedCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        self.layerView = [UIView new];
        self.layerView.backgroundColor = [UIColor colorWithRed:127.0/255.0 green:127.0/255.0 blue:127.0/255.0 alpha:1.0];
        self.layerView.alpha = 0.6;
        [self.contentView addSubview:self.layerView];
        [self.layerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        
        _durationLabel = UILabel.new;
        _durationLabel.font = [UIFont systemFontOfSize:9*SCREENSCALE];
        _durationLabel.textColor = [UIColor grayColor];
        _durationLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_durationLabel];
        [_durationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.imageView.mas_right).offset(-5);
            make.bottom.equalTo(self.imageView.mas_bottom).offset(-5);
        }];
        
        self.deleteImgView = [UIImageView new];
        self.deleteImgView.contentMode = UIViewContentModeScaleAspectFill;
        self.deleteImgView.layer.masksToBounds = YES;
        self.deleteImgView.image = NvImageNamed(@"nv_album_delete_icon");
        [self.contentView addSubview:self.deleteImgView];
        [self.deleteImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
    return self;
}

- (void)renderCellWithAsset:(PHAsset *)asset {
    __weak typeof(self)weakSelf = self;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(SCREENWIDTH/4, SCREENWIDTH/4) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weakSelf.imageView.image = result;
    }];

    if (asset.mediaType == PHAssetMediaTypeImage) {
        _durationLabel.hidden = YES;

    } else {
        _durationLabel.hidden = NO;
        NSInteger minutes = (NSInteger)(asset.duration / 60.0);
        NSInteger seconds = (NSInteger)round(asset.duration - 60.0 * (double)minutes);
        NSString *text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
        _durationLabel.text = text;
    }
}
@end
