//
//  NvBgColorCollectionViewCell.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/6.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBgColorCollectionViewCell.h"
#import "NVHeader.h"

@interface NvBgColorCollectionViewCell()

@property (nonatomic, strong) UIView *view;

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation NvBgColorCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.view = [UIView new];
        [self.contentView addSubview:self.view];
        [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        self.imageView = [UIImageView new];
        self.imageView.hidden = YES;
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
    return self;
}

- (void)renderCellWithItem:(NvCaptionColorItem *)item {
    self.imageView.hidden = YES;
    if ([item.colorString containsString:@"#"]) {
        self.view.backgroundColor = [UIColor nv_colorWithHexARGB:item.colorString];
    } else if([item.colorString isEqualToString:@"0"]){
        self.view.backgroundColor = UIColor.clearColor;
        self.imageView.hidden = NO;
    }else{
        NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
        if (rgb.count == 4) {
            self.view.backgroundColor = [UIColor colorWithRed:[rgb[0] floatValue] green:[rgb[1] floatValue] blue:[rgb[2] floatValue] alpha:1];
        }
    }
    
    if (self.imageView.hidden) {
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
    }else{
        self.view.layer.borderWidth = 0;
        if (item.isSelect) {
            self.imageView.image = NvImageNamed(@"caption_bgColor_no");
        } else {
            self.imageView.image = NvImageNamed(@"caption_bgColor_no_seleted");
        }
    }
}

@end
