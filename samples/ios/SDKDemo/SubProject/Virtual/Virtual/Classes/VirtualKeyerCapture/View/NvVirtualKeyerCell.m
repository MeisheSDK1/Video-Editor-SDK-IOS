//
//  NvVirtualKeyerCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2019/1/8.
//  Copyright © 2019年 meishe. All rights reserved.
//

#import "NvVirtualKeyerCell.h"
#import <Masonry/Masonry.h>
#import <NvBaseCommon/NVDefineConfig.h>

@implementation NvVirtualKeyerCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)renderCellWithModel:(NvVirtualKeyerModel *)model{
    [super renderCellWithModel:model];
    self.nameLabel.hidden = YES;
    if(self.coverView.image == nil) {
        self.coverView.image = [UIImage imageNamed:model.coverName];
    }
    if(self.coverView.image == nil) {
        self.coverView.image = model.pictureObject;
    }
    [self.coverView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(6*SCREENSCALE));
        make.right.equalTo(@(-6*SCREENSCALE));
        make.top.equalTo(@(6*SCREENSCALE));
        make.bottom.equalTo(@(0*SCREENSCALE));
    }];
    
    [self.downloadMaskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(6*SCREENSCALE));
        make.right.equalTo(@(-6*SCREENSCALE));
        make.top.equalTo(@(6*SCREENSCALE));
        make.bottom.equalTo(@(0*SCREENSCALE));
    }];
    
    [self.maskView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(6*SCREENSCALE));
        make.right.equalTo(@(-6*SCREENSCALE));
        make.top.equalTo(@(6*SCREENSCALE));
        make.bottom.equalTo(@(0*SCREENSCALE));
    }];
}

@end
