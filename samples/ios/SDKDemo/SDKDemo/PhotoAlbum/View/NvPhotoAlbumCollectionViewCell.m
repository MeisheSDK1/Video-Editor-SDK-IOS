//
//  NvPhotoAlbumCollectionViewCell.m
//  SDKDemo
//
//  Created by MS on 2019/9/24.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvPhotoAlbumCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import <UIImageView+YYWebImage.h>
@interface NvPhotoAlbumCollectionViewCell ()

@end

@implementation NvPhotoAlbumCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)setModel:(NvPhotoAlbumModel *)model {
    _model = model;
    if (model.isLocalAsset) {
        self.imageView.image = [UIImage imageWithContentsOfFile:model.coverUrl];
    }else{
        [self.imageView yy_setImageWithURL:[NSURL URLWithString:model.coverUrl] placeholder:nil];
    }
    
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if ([self.delegate respondsToSelector:@selector(photoAlbumCollectionCell:didUpdateModel:)]) {
        [self.delegate photoAlbumCollectionCell:self didUpdateModel:_model];
    }
}
@end
