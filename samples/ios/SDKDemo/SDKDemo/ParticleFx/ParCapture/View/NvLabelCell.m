//
//  NvLabelCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/9/19.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvLabelCell.h"
#import "NVHeader.h"

@interface NvLabelCell ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIView *leftView;

@end

@implementation NvLabelCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.label = [[UILabel alloc]init];
        self.label.textColor = UIColor.whiteColor;
        self.label.font = [NvUtils fontWithSize:12];
        [self.contentView addSubview:self.label];
        
        self.leftView = [[UIView alloc]init];
        self.leftView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#26FFFFFF"];
        [self.contentView addSubview:self.leftView];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
        }];
        
        [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(8 * SCREENSCALE);
            make.bottom.equalTo(self.contentView).offset(- 8 * SCREENSCALE);
            make.width.offset(1);
        }];
        
    }
    return self;
}

- (void)renderCellWithModel:(NvLabelModel *)model{
    self.label.text = model.labelName;
    if (model.first) {
        self.leftView.hidden = YES;
    }else{
        self.leftView.hidden = NO;
    }
    
    if (model.selected) {
        self.label.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    }else{
        self.label.textColor = UIColor.whiteColor;
    }
}
@end
