//
//  NvCaptureStickerMoreStyleCell.m
//  SDKDemo
//
//  Created by ms on 2021/6/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCaptureStickerMoreStyleCell.h"
#import "NVHeader.h"
#import "NvGraphicBtn.h"


@interface NvCaptureStickerMoreStyleCell ()
@property (nonatomic, strong) NvGraphicBtn *moreBtn;

@property (nonatomic, strong) UIImageView *imageView; 
@end

@implementation NvCaptureStickerMoreStyleCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.moreBtn = [NvGraphicBtn buttonWithType:UIButtonTypeCustom withTitle:NvLocalString(@"More", @"更多") withImageNormal:@"capture_more_image" withImageSelected:@"capture_more_image"];
        self.moreBtn.userInteractionEnabled = NO;
        [self.moreBtn setCustomFontSize:11*SCREENSCALE];
        self.moreBtn.btnLabel.textColor = [UIColor nv_colorWithHexString:@"#707070"];
        [self.contentView addSubview:self.moreBtn];
        [self.moreBtn setCustomImageSize:CGSizeMake(20*SCREENSCALE, 20*SCREENSCALE) offset:7.5*SCREENSCALE];
        [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView);
            make.centerY.mas_equalTo(self.contentView);
            make.width.mas_equalTo(40.0f);
            make.height.mas_equalTo(40.0f);
        }];
        self.contentView.backgroundColor = [UIColor nv_colorWithHexString:@"#F5F5F5"];
        
    }
    return self;
}
-(void)setAssetModel:(NvAssetCellModel *)assetModel{
    _assetModel = assetModel;
    self.moreBtn.btnLabel.text = assetModel.displayName;
    self.moreBtn.btnImageView.image = NvImageNamed(assetModel.cover);
}

@end
