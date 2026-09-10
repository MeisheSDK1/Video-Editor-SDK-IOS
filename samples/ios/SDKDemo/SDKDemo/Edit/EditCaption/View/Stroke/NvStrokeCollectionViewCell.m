//
//  NvStrokeCollectionViewCell.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 刘东旭. All rights reserved.
//

#import "NvStrokeCollectionViewCell.h"
#import "NVHeader.h"

@interface NvStrokeCollectionViewCell()

@property (nonatomic, strong) UIImageView *view;

@end

@implementation NvStrokeCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.view = [UIImageView new];
        [self.contentView addSubview:self.view];
        [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
    return self;
}

- (void)renderCellWithItem:(NvCaptionStrokeItem *)item {
    if (!item.colorString) {
        self.view.image = item.isSelect ? NvImageNamed(@"caption_bgColor_no") : NvImageNamed(@"caption_bgColor_no_seleted");
        self.view.backgroundColor = [UIColor clearColor];
    } else {
        self.view.image = nil;
        NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
        if (rgb.count == 4) {
            self.view.backgroundColor = [UIColor colorWithRed:[rgb[0] floatValue] green:[rgb[1] floatValue] blue:[rgb[2] floatValue] alpha:1];
        }
    }
    if (item.isSelect) {
        self.view.layer.borderWidth = 2;
        self.view.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.view.layer.cornerRadius = 12.5*SCREENSCALE;
        self.view.layer.masksToBounds = YES;
    } else {
        self.view.layer.borderWidth = 0;
        self.view.layer.borderColor = [UIColor clearColor].CGColor;
        self.view.layer.cornerRadius = 12.5*SCREENSCALE;
        self.view.layer.masksToBounds = YES;
    }
}


@end
