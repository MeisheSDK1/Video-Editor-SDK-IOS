//
//  NvCustomButton.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/10/12.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvImageButton.h"
#import <NvBaseCommon/NVDefineConfig.h>
#import <NvBaseCommon/UIView+Dimension.h>
#import <Masonry/Masonry.h>

@interface NvImageButton()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation NvImageButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.imgView = [[UIImageView alloc] init];
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.imgView];
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(@0);
            make.width.height.equalTo(@(35*SCREENSCALE));
            make.left.right.equalTo(@0);
        }];
    }
    return self;
}

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imgView.image = _image;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
