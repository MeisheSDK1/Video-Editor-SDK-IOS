//
//  NvCompoundFontFamilyCollectionCell.m
//  SDKDemo
//
//  Created by MS on 2019/5/21.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvCompoundFontFamilyCollectionCell.h"
#import "NVHeader.h"

@interface NvCompoundFontFamilyCollectionCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation NvCompoundFontFamilyCollectionCell

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
    [self clear];
    self.imageView.image = [UIImage imageNamed:model.iosFontName] ? [UIImage imageNamed:model.iosFontName] : [UIImage imageNamed:@"Nv_default_compound_caption"];
    if (model.isSelected == YES) {
        self.imageView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
    }else{
        self.imageView.backgroundColor = [UIColor colorWithRed:(float)92/255 green:(float)94/255 blue:(float)95/255 alpha:1];
    }
}

- (void)clear {
    self.titleLabel.text = @"";
}

@end
