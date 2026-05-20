//
//  NvParticleAssetCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2019/1/4.
//  Copyright © 2019年 meishe. All rights reserved.
//

#import "NvParticleAssetCell.h"

@interface NvParticleAssetCell()

@property (nonatomic, strong) UIImageView *selectImageView;

@end

@implementation NvParticleAssetCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectImageView = UIImageView.new;
        self.selectImageView.hidden = YES;
        self.selectImageView.image = NvImageNamed(@"NvParticleItemLayer");
        self.selectImageView.backgroundColor = [UIColor clearColor];
        self.selectImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.maskView addSubview:self.selectImageView];
        [_selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.maskView);
        }];
    }
    return self;
}


- (void)renderCellWithModel:(NvParticleModel *)model{
    [super renderCellWithModel:model];
    if (model.isParGraffiti &&
        ![model.displayName isEqualToString:NvLocalString(@"None", @"无")]) {
        self.selectImageView.hidden = NO;
    }else{
        self.selectImageView.hidden = YES;
    }
}

@end
