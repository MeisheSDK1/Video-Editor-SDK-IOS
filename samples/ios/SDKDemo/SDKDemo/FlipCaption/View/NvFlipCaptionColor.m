//
//  NvFlipCaptionColor.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFlipCaptionColor.h"
#import "NVHeader.h"
#import "NvColorView.h"
#import "NvCaptionColorItem.h"
#import "NvBottomView.h"

@interface NvFlipCaptionColor()<NvBottomViewDelegate>

@property (nonatomic, strong) NvBottomView *bottomView;
@property (nonatomic, strong) NvColorView *colorView;
@property (nonatomic, strong) NvCaptionColorItem *item;

@end

@implementation NvFlipCaptionColor

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.layer.masksToBounds = YES;
        _colorViewToParentSpacing = 40;
        self.bottomView = [NvBottomView new];
        self.bottomView.delegate = self;
        [self addSubview:self.bottomView];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.width.equalTo(@(SCREENWIDTH));
            make.bottom.equalTo(self);
        }];

        self.colorView = [NvColorView new];
        self.colorView.delegate = self;
        [self addSubview:self.colorView];
        [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(@0);
            make.bottom.equalTo(self.bottomView.mas_top).offset(-40*SCREENSCALE);
            make.top.equalTo(@(40*SCREENSCALE));
        }];
        
    }
    return self;
}

- (void)setColorViewToParentSpacing:(float)colorViewToParentSpacing {
    _colorViewToParentSpacing = colorViewToParentSpacing;
    [self.colorView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(@0);
        make.bottom.equalTo(self.bottomView.mas_top).offset(-(colorViewToParentSpacing*SCREENSCALE));
        make.top.equalTo(@(colorViewToParentSpacing*SCREENSCALE));
    }];
}

- (void)colorView:(NvColorView *)colorView didSelectItem:(NvCaptionColorItem *)item {
    self.item = item;
    if ([self.delegate respondsToSelector:@selector(flipCaptionColor:didSelectItem:)]) {
        [self.delegate flipCaptionColor:self didSelectItem:item];
    }
}

- (void)bottomViewOkClick:(NvBottomView *)bottomView {
    if ([self.delegate respondsToSelector:@selector(flipCaptionColor:okClickItem:)]) {
        [self.delegate flipCaptionColor:self okClickItem:self.item];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
