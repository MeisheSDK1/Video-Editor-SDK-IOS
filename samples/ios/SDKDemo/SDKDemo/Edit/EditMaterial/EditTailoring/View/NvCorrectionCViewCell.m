//
//  NvCorrectionCViewCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/10/10.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvCorrectionCViewCell.h"
#import "NVHeader.h"

@interface NvCorrectionCViewCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation NvCorrectionCViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc]init];
        self.label.font = [UIFont systemFontOfSize:12];
        self.label.textColor = UIColor.whiteColor;
        self.label.alpha = 0.8;
        [self.contentView addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)renderCellWithModel:(NvCorrectionModel *)model{
    self.label.text = model.text;
    if (model.select) {
        self.label.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    }else{
        self.label.textColor = UIColor.whiteColor;
    }
}
@end
