//
//  NvFxCollectionViewCell.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/9/11.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFxCollectionViewCell.h"
#import "NVHeader.h"

@interface NvFxCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *coverView;

@property (nonatomic, strong) CABasicAnimation *base;

@end

@implementation NvFxCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(4.5*SCREENSCALE, 0, 49*SCREENSCALE, 49*SCREENSCALE)];
        [self.contentView addSubview:self.imageView];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.centerX = self.contentView.centerX;
        self.coverView = [[UIView alloc] initWithFrame:self.imageView.frame];
        self.coverView.layer.cornerRadius = 4*SCREENSCALE;
        self.coverView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#994A90E2"];
        [self.contentView addSubview:self.coverView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(-5*SCREENSCALE, 52*SCREENSCALE, frame.size.width+10*SCREENSCALE, 21*SCREENSCALE)];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [NvUtils regularFontWithSize:11];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.alpha = 0.8;
        [self.contentView addSubview:self.nameLabel];
        
        self.animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(24*SCREENSCALE/2, 24*SCREENSCALE/2, 25*SCREENSCALE, 25*SCREENSCALE)];
        [self.coverView addSubview:self.animationImageView];
        self.animationImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.animationImageView.image = NvImageNamed(@"shortVideoAnimation");
        self.base = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        self.base.fromValue = @0;
        self.base.toValue = @(2*M_PI);
        self.base.repeatCount = MAXFLOAT;
        self.base.duration = 0.8;
        self.base.fillMode = kCAFillModeForwards;
        self.animationImageView.hidden = YES;
    }
    return self;
}

- (void)renderCellWithItem:(NvVideoFxItem *)item {
    if (item.cover) {
        self.imageView.image = NvImageNamed(item.cover);
    } else {
        UIImage *image = [UIImage imageWithContentsOfFile:item.imagePath];
        self.imageView.image = image;
    }
    
    self.nameLabel.text = item.displayName;
    
    if (item.selected) {
        self.coverView.hidden = NO;
        self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#FF4A90E2"];
    } else {
        self.coverView.hidden = YES;
        self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#FFFFFFFF"];
    }
    if (item.isAnimation) {
        self.imageView.hidden = YES;
        self.animationImageView.hidden = NO;
        [self.animationImageView.layer addAnimation:self.base forKey:@"transform.rotation.z"];
    } else {
        self.imageView.hidden = NO;
        [self.animationImageView.layer removeAnimationForKey:@"transform.rotation.z"];
        self.animationImageView.hidden = YES;
    }
}

@end
