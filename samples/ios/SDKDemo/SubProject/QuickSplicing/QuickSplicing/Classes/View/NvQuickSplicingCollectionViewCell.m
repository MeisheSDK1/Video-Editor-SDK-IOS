//
//  NvQuickSplicingCollectionViewCell.m
//  AFNetworking
//
//  Created by ms on 2022/1/13.
//

#import "NvQuickSplicingCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/NvBaseUtils.h>
#import <NvBaseCommon/UIColor+NvColor.h>

@interface NvQuickSplicingCollectionViewCell()

@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UILabel *numLabel;

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *assetImage;
@end

@implementation NvQuickSplicingCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.assetImage = [[UIImageView alloc]init];
        self.assetImage.contentMode = UIViewContentModeScaleAspectFill;
        self.assetImage.clipsToBounds = YES;
        self.assetImage.layer.cornerRadius = 3.0 ;
        [self.contentView addSubview:self.assetImage];
        [self.assetImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(self.contentView).offset(0);
            make.left.mas_equalTo(self.contentView).offset(10.0 * SCREENSCALE);
            make.right.mas_equalTo(self.contentView).offset(-10.0 * SCREENSCALE);
        }];
        
        self.leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftBtn setImage:NvImageNamed(@"quick_splicing_add") forState:UIControlStateNormal];
        [self.leftBtn addTarget:self action:@selector(leftBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.leftBtn];
        [self.leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.left.mas_equalTo(self.contentView).offset(0);
            make.width.height.mas_equalTo(20.0 * SCREENSCALE);
        }];
        
        self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightBtn setImage:NvImageNamed(@"quick_splicing_add") forState:UIControlStateNormal];
        [self.rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.rightBtn];
        [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.contentView);
            make.right.mas_equalTo(self.contentView).offset(0);
            make.width.height.mas_equalTo(20.0 * SCREENSCALE);
        }];
        
        self.numLabel = [UILabel new];
        self.numLabel.textColor = UIColor.whiteColor;
        self.numLabel.font = [NvBaseUtils fontWithSize:9 * SCREENSCALE];
        self.numLabel.backgroundColor = [UIColor grayColor];
        self.numLabel.textAlignment = NSTextAlignmentCenter;
        self.numLabel.layer.cornerRadius = 1.0 ;
        self.numLabel.clipsToBounds = YES;
        
        [self.assetImage addSubview:self.numLabel];
        [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.assetImage).offset(3 * SCREENSCALE);
            make.top.equalTo(self.assetImage).offset(3 * SCREENSCALE);
            make.width.height.mas_equalTo(11.0 * SCREENSCALE);
        }];
        
        self.timeLabel = [UILabel new];
        self.timeLabel.textColor = UIColor.whiteColor;
        self.timeLabel.font = [NvBaseUtils fontWithSize:9 * SCREENSCALE];
        [self.assetImage addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.assetImage).offset(5 * SCREENSCALE);
            make.bottom.equalTo(self.assetImage).offset(-3 * SCREENSCALE);
            make.width.mas_equalTo(50.0 * SCREENSCALE);
            make.height.mas_equalTo(14.0 * SCREENSCALE);
        }];
        
    }
    return self;
}
-(void)leftBtnClick{
    if (self.addAssetBlock) {
        self.addAssetBlock(self.index);
    }
}
-(void)rightBtnClick{
    if (self.addAssetBlock) {
        self.addAssetBlock(self.index + 1);
    }
}

-(void)setAsset:(NvAlbumAsset *)asset{
    _asset = asset;
    
    __weak typeof(self)weakSelf = self;
    [[PHImageManager defaultManager] requestImageForAsset:asset.asset targetSize:CGSizeMake(70.0*SCREENSCALE, 70.0*SCREENSCALE) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weakSelf.assetImage.image = result;
    }];
    
    weakSelf.numLabel.text = [NSString stringWithFormat:@"%d", asset.number];
    if (asset.isSelected) {
        self.assetImage.layer.borderWidth = 1.0;
        self.assetImage.layer.borderColor = [UIColor nv_colorWithHexString:@"#63ABFF"].CGColor;
        self.leftBtn.hidden = NO;
        self.rightBtn.hidden = NO;
    }else{
        self.assetImage.layer.borderColor = [UIColor clearColor].CGColor;
        self.leftBtn.hidden = YES;
        self.rightBtn.hidden = YES;
    }
    NSInteger minutes = (NSInteger)(asset.asset.duration / 60.0);
    NSInteger seconds = (NSInteger)round(asset.asset.duration - 60.0 * (double)minutes);
    NSString *text = [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
    self.timeLabel.text = text;
}

@end
