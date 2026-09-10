//
//  NvPreviewCollectionViewCell.m
//  NvMimoDemo
//
//  Created by MS on 2019/8/13.
//  Copyright © 2019 MS. All rights reserved.
//

#import "NvPreviewCollectionViewCell.h"
#import "NvMimoTimelineUtils.h"
#import "NVMimoDefineConfig.h"
#import <UIColor+NvColor.h>
#import "NVHeader.h"

@interface NvPreviewCollectionViewCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation NvPreviewCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A4A4A"];
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        self.titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:self.titleLabel];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:13*SCREANSCALE];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.height.mas_equalTo(20*SCREANSCALEHEIGHT);
            make.width.mas_equalTo(self.contentView.mas_width);
        }];
    }
    return self;
}

- (void)setModel:(NvShotModel *)model {
    _model = model;
    [self clear];
    if(model.selected){
        self.layer.borderWidth = 2.f;
        self.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#2A7DFF"].CGColor;
    }else{
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor clearColor].CGColor;
    }
    CGFloat duration =0.f;
    if (model.speed.count >0) {
        duration = [NvMimoTimelineUtils requiredDurationForShotModel:model];
    }else{
        duration = model.duration;
    }
     self.titleLabel.text = [NSString stringWithFormat:@"%.2fs",duration/1000000];
    
    if (model.asset != nil) {
        if ((!model.isImage) && duration > model.assetDuration) {
            self.titleLabel.textColor = [UIColor nv_colorWithHexRGB:@"#D0021B"];
        }else{
            self.titleLabel.textColor = [UIColor whiteColor];
        }
    }
    self.imageView.image = model.coverImage;
}

- (void)clear {
    self.titleLabel.text = @"";
    self.titleLabel.textColor = [UIColor whiteColor];
}
@end
