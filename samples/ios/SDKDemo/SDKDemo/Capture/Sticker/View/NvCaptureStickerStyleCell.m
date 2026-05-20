//
//  NvCaptureStickerStyleCell.m
//  SDKDemo
//
//  Created by ms on 2021/6/25.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCaptureStickerStyleCell.h"
#import <UIImageView+YYWebImage.h>
#import "NVHeader.h"
#import "NvGraphicBtn.h"
#import "NvAssetCellModel.h"
#import "NvYYAnimatedImageView.h"

@interface NvCaptureStickerStyleCell ()
@property (nonatomic, strong) NvYYAnimatedImageView *imageView;    
@end

@implementation NvCaptureStickerStyleCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[NvYYAnimatedImageView alloc]init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.contentView.backgroundColor = [UIColor nv_colorWithHexString:@"#F5F5F5"];
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.mas_equalTo(self.contentView).offset(0);
        }];
    }
    return self;
}

-(void)setAssetModel:(NvAssetCellModel *)assetModel{
    _assetModel = assetModel;
    if (assetModel.package && assetModel.covergif && assetModel.covergif.length > 0) {
        
        self.imageView.NVImagePath = assetModel.covergif;
    } else {
        self.imageView.NVImagePath = assetModel.cover;
    }
    
    if (assetModel.selected) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3.0f;
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [UIColor nv_colorWithHexString:@"#63ABFF"].CGColor;
    }else{
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
