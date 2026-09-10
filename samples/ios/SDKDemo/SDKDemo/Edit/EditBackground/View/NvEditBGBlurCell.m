//
//  NvEditBGBlurCell.m
//  SDKDemo
//
//  Created by MS on 2020/10/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditBGBlurCell.h"
#import "NVHeader.h"
@interface NvEditBGBlurCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation NvEditBGBlurCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = self.contentView.size.width/2;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
      
    }
    return self;
}

- (void)setModel:(NvEditBGBlurModel *)model {
    _model = model;
    self.imageView.image = nil;
    self.imageView.image = NvImageNamed(model.imageName);
    if (model.isSelected) {
        self.imageView.layer.borderWidth = 1;
        self.imageView.layer.borderColor = [UIColor colorWithRed:0.99 green:0.17 blue:0.33 alpha:1.0].CGColor;
    }else{
        self.imageView.layer.borderWidth = 0;
        self.imageView.layer.borderColor = [UIColor colorWithRed:0.99 green:0.17 blue:0.33 alpha:1.0].CGColor;
    }
}

@end
