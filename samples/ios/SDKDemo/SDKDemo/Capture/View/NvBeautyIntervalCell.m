//
//  NvBeautyIntervalCell.m
//  SDKDemo
//
//  Created by ms on 2021/10/19.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvBeautyIntervalCell.h"
#import "NVHeader.h"
@interface NvBeautyIntervalCell()

@property (nonatomic, strong) UIView *pointView;

@end

@implementation NvBeautyIntervalCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isEditModuler = NO;
        [self addSubviews];
    }
    return self;
}

-(void)addSubviews{
    self.pointView = [[UIView alloc]init];
    self.pointView.backgroundColor = [UIColor nv_colorWithHexString:@"#707070"];
    [self.contentView addSubview:self.pointView];

    [self.pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY).offset(10.0);
        make.width.mas_equalTo(5.0);
        make.height.mas_equalTo(5.0);
    }];
    
    [self.pointView layoutIfNeeded];

    self.pointView.layer.masksToBounds = YES;
    self.pointView.layer.cornerRadius = 2.5;
    
}

- (void)setIsEditModuler:(BOOL)isEditModuler {
    _isEditModuler = isEditModuler;
    if (self.isEditModuler) {
        self.pointView.backgroundColor = [UIColor whiteColor];
    }else {
        self.pointView.backgroundColor = [UIColor nv_colorWithHexString:@"#707070"];
    }
}

- (void)setIsOperation:(BOOL)isOperation {
    _isOperation = isOperation;
    self.pointView.alpha = isOperation ? 1.f : 0.2;
}
@end
