//
//  NvCompoundColorCell.m
//  SDKDemo
//
//  Created by ms on 2021/6/30.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCompoundColorCell.h"

#import "NVHeader.h"

@interface NvCompoundColorCell()

@property (nonatomic, strong) UIView *view;

@end

@implementation NvCompoundColorCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.view = [UIView new];
        [self.contentView addSubview:self.view];
        [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
    }
    return self;
}

- (void)renderCellWithItem:(NvCaptionColorItem *)item {
    if ([item.colorString containsString:@"#"]) {
        self.view.backgroundColor = [UIColor nv_colorWithHexARGB:item.colorString];
    } else {
        NSArray *rgb = [item.colorString componentsSeparatedByString:@","];
        if (rgb.count == 4) {
            self.view.backgroundColor = [UIColor colorWithRed:[rgb[0] floatValue] green:[rgb[1] floatValue] blue:[rgb[2] floatValue] alpha:1];
        }
    }
    
    if (item.isSelect) {
        self.view.layer.borderWidth = 2;
        self.view.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
    } else {
        self.view.layer.borderWidth = 0;
        self.view.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
