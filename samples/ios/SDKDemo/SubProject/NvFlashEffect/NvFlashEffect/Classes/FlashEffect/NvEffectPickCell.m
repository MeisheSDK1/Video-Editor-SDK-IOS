//
//  NvEffectPickCell.m
//  SDKDemo
//
//  Created by 刘东旭 on 2019/10/16.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvEffectPickCell.h"
#import <NvBaseCommon/NvBaseUtils.h>
#import <NvBaseCommon/NVDefineConfig.h>

@interface NvEffectPickCell()

@property (nonatomic, strong) UIImageView *coverImage;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation NvEffectPickCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(2*SCREENSCALE, 0, 44*SCREENSCALE, 44*SCREENSCALE)];
        [self.contentView addSubview:self.coverImage];
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 46*SCREENSCALE, 44*SCREENSCALE, 28*SCREENSCALE)];
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.font = [NvBaseUtils mediumFontWithSize:12];
        [self.contentView addSubview:self.nameLabel];
    }
    return self;
}

- (void)setModel:(NvEffectModel *)model {
    self.coverImage.image = [UIImage imageWithContentsOfFile:model.imageUrl];
    self.nameLabel.text = NvLocalStringFromTable([self class],model.name, @"star");
    self.coverImage.layer.cornerRadius = 2;
    if (model.isSelect) {
        self.coverImage.layer.borderWidth = 1;
        self.coverImage.layer.borderColor = [UIColor colorWithRed:54/255.0 green:153/255.0 blue:1 alpha:1].CGColor;
        self.nameLabel.textColor = [UIColor colorWithRed:54/255.0 green:153/255.0 blue:1 alpha:1];
    } else {
        self.coverImage.layer.borderWidth = 0;
        self.nameLabel.textColor = [UIColor whiteColor];
    }
}

@end
