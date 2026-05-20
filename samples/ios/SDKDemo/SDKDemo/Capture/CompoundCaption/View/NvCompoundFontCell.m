//
//  NvCompoundFontCell.m
//  SDKDemo
//
//  Created by ms on 2021/6/30.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCompoundFontCell.h"
#import "NVHeader.h"

@interface NvCompoundFontCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation NvCompoundFontCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.layer.cornerRadius = 2;
        self.imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
    }
    return self;
}

- (void)setModel:(NvCompoundCaptionModel *)model {
    _model = model;
    self.imageView.image = [UIImage imageNamed:model.iosFontName] ? [UIImage imageNamed:model.iosFontName] : [UIImage imageNamed:@"Nv_default_compound_caption"];
    if (model.isSelected == YES) {
        self.imageView.layer.borderWidth = 1.0;
        self.imageView.layer.borderColor = [UIColor nv_colorWithHexString:@"#63ABFF"].CGColor;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 2.0f;
    }else{
        self.imageView.layer.borderWidth = 1.0;
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 2.0f;
    }
}

@end
