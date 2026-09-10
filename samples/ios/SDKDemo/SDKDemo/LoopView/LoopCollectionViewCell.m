//
//  LoopCollectionViewCell.m
//  ScrollViewLoop
//
//  Created by 刘东旭 on 2019/9/25.
//  Copyright © 2019 刘东旭. All rights reserved.
//

#import "LoopCollectionViewCell.h"
#import <UIImageView+YYWebImage.h>
#import <NvSDKCommon/NvUtils.h>

@interface LoopCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *backImageView;

@end

@implementation LoopCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.backImageView];
        self.backImageView.layer.masksToBounds = YES;
        
        if (NV_STATUSBARHEIGHT > 20) {
            self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16*SCREENSCALE, 0, self.frame.size.width-32*SCREENSCALE, self.frame.size.height)];
        } else {
            self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(36*SCREENSCALE, 60*SCREENSCALE, self.frame.size.width-104*SCREENSCALE, self.frame.size.height-100*SCREENSCALE)];
        }
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
        self.imageView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setModel:(NvLoopViewModel *)model {
    if ([model.coverUrl2 hasPrefix:@"http"]) {
        [self.backImageView yy_setImageWithURL:[NSURL URLWithString:model.coverUrl] placeholder:nil];
        if ([NvUtils currentLanguagesIsChinese]) {
            [self.imageView yy_setImageWithURL:[NSURL URLWithString:model.coverUrl2] placeholder:nil];
        } else {
            [self.imageView yy_setImageWithURL:[NSURL URLWithString:model.coverUrl3] placeholder:nil];
        }
        
    } else if ([model.coverUrl2 hasPrefix:@"/"]) {
        self.backImageView.image = [UIImage imageWithContentsOfFile:model.coverUrl];
        self.imageView.image = [UIImage imageWithContentsOfFile:model.coverUrl2];
    } else {
        self.backImageView.image = [UIImage imageNamed:model.coverUrl];
        self.imageView.image = [UIImage imageNamed:model.coverUrl2];
    }
}

@end
