//
//  NvEditBGStyleCell.m
//  SDKDemo
//
//  Created by MS on 2020/10/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditBGStyleCell.h"
#import "NVHeader.h"

@interface NvEditBGStyleCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation NvEditBGStyleCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
      
    }
    return self;
}

- (void)setModel:(NvEditBGStyleModel *)model {
    _model = model;
    self.imageView.image = nil;
    self.imageView.image = NvImageNamed(model.cover);
    if (model.isSelected) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRed:0.99 green:0.17 blue:0.33 alpha:1.0].CGColor;
    }else{
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor colorWithRed:0.99 green:0.17 blue:0.33 alpha:1.0].CGColor;
    }
}
@end
