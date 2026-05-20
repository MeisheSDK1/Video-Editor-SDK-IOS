//
//  NvAlbumCategoryCell.m
//  NvAlbum
//
//  Created by meishe20241218 on 2025/6/25.
//

#import "NvAlbumCategoryCell.h"
#import "NvAlbumUtils.h"
@interface NvAlbumCategoryCell ()
@property (nonatomic, strong) UIImageView *leftImgView;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) UILabel *numLabel;
@end
@implementation NvAlbumCategoryCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.contentView.bounds.size.height;
    CGFloat imgW = 64.0;
    CGFloat sep = 12.0;
    CGFloat y = (height - imgW) / 2;
    CGFloat labelX = 2*sep+imgW;
    CGFloat labelW = width - labelX;
    CGFloat numW = 20;
    self.contentView.backgroundColor = [UIColor blackColor];
    self.leftImgView = [[UIImageView alloc] initWithFrame:CGRectMake(sep, y, imgW, imgW)];
    self.leftImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.leftImgView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.leftImgView];

    
    self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, y, labelW, imgW)];
    self.rightLabel.textColor = [UIColor whiteColor];
    self.rightLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:self.rightLabel];
    
    self.numLabel = [[UILabel alloc] initWithFrame:CGRectMake(sep + imgW - numW/2, y-numW/2, numW, numW)];
    self.numLabel.textColor = [UIColor whiteColor];
    self.numLabel.textAlignment = NSTextAlignmentCenter;
    self.numLabel.backgroundColor = [UIColor colorWithRed:91.0/255.0 green:165.0/255.0 blue:249.0/255.0 alpha:1.0];
    self.numLabel.layer.cornerRadius = numW / 2;
    self.numLabel.layer.masksToBounds = YES;
    self.numLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.contentView addSubview:self.numLabel];
}

- (void)renderCellWithAsset:(PHAssetCollection *)assetCollection {
    PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
    NSUInteger count = result.count;
    NSString *name = assetCollection.localizedTitle;
    if (count>0) {
        __weak typeof(self)weakSelf = self;
        PHAsset *asset = result[0];
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat;
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(64, 64) contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            weakSelf.leftImgView.image = result;
        }];
    } else {
        self.leftImgView.image = nil;
    }
    NSString *numberStr = [NvAlbumUtils convertIntegerToFormatString:count];
    NSString *title = [NSString stringWithFormat:@"%@ %@",name,numberStr];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:title];
    [attributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} range:NSMakeRange(0, title.length)];
    [attributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5]} range:NSMakeRange(0, title.length)];
    NSRange range = [title rangeOfString:name];
    [attributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} range:range];
    [attributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.7]} range:range];
    self.rightLabel.attributedText = attributedString;
}

- (void)setSelectCount:(NSUInteger)selectCount {
    if (selectCount > 0) {
        self.numLabel.text = [NSString stringWithFormat:@"%u",selectCount];
    }
    self.numLabel.hidden = selectCount > 0 ? NO : YES;
}
@end
