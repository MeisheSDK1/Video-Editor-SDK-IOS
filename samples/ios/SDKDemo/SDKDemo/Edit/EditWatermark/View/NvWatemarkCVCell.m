//
//  NvWatemarkCVCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/10/18.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvWatemarkCVCell.h"
#import "NVHeader.h"

@implementation NvWatemarkItem

@end

@interface NvWatemarkCVCell()

@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UIImageView *selectImageView;
@property (nonatomic, strong) UIImageView *coverImageView_1;
@property (nonatomic, strong) UIImageView *coverImageView_2;
@property (nonatomic, strong) UIView *upperCoverView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation NvWatemarkCVCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.layer.borderWidth = 1;
        self.contentView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#848788"].CGColor;
        self.coverImageView = [[UIImageView alloc]init];
        self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.coverImageView];
        [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
        }];
        
        self.coverImageView_2 = [[UIImageView alloc]init];
        self.coverImageView_2.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.coverImageView_2];
        [self.coverImageView_2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.centerY.equalTo(self.contentView.mas_centerY).offset(-10 * SCREENSCALE);
        }];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.font = [NvUtils fontWithSize:12];
        self.titleLabel.text = NvLocalString(@"Add", @"添加");
        self.titleLabel.textColor = [UIColor nv_colorWithHexRGB:@"#909293"];
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.centerY.equalTo(self.contentView.mas_centerY).offset(10 * SCREENSCALE);
        }];
        
        self.coverImageView_1 = [[UIImageView alloc]init];
        self.coverImageView_1.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.coverImageView_1];
        [self.coverImageView_1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView.mas_centerY);
            make.left.equalTo(self.contentView.mas_left).offset(5 * SCREENSCALE);
            make.right.equalTo(self.contentView.mas_right).offset(-5 * SCREENSCALE);
        }];
        
        self.selectImageView = [[UIImageView alloc]init];
        self.selectImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.selectImageView];
        self.selectImageView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#994A90E2"];
        [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView);
            make.left.equalTo(self.contentView);
            make.right.equalTo(self.contentView);
        }];
        
        self.upperCoverView = [[UIView alloc]init];
        [self.contentView addSubview:self.upperCoverView];
        self.upperCoverView.layer.borderWidth = 1;
        self.upperCoverView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#848788"].CGColor;
        [self.upperCoverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.left.equalTo(self.contentView.mas_left).offset(7.5 * SCREENSCALE);
            make.right.equalTo(self.contentView.mas_right).offset(-7.5 * SCREENSCALE);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-15*SCREENSCALE);
        }];
        
        self.nameLabel = [[UILabel alloc]init];
        self.nameLabel.font = [NvUtils fontWithSize:12];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.coverImageView_1.mas_centerX);
            make.top.equalTo(self.coverImageView_1.mas_bottom);
            make.height.mas_equalTo(12*SCREENSCALE);
            make.width.mas_equalTo(self.contentView.mas_width);
        }];
        self.nameLabel.hidden = YES;
    }
    return self;
}

- (void)renderCellWithItem:(NvWatemarkItem *)item {
    self.nameLabel.hidden = YES;
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#848788"].CGColor;
    self.upperCoverView.hidden = YES;
    [self.coverImageView_1 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(self.contentView.mas_left).offset(5 * SCREENSCALE);
        make.right.equalTo(self.contentView.mas_right).offset(-5 * SCREENSCALE);
    }];
    [self.selectImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView);
        make.right.equalTo(self.contentView);
    }];
    if ([item.coverString isEqualToString:@"NvEditWatemarButton"]) {
        self.coverImageView_2.image = NvImageNamed(item.coverString);
        self.titleLabel.hidden = NO;
        self.coverImageView_1.image = nil;
        self.coverImageView.image = nil;
        
    }else if (item.isBuiltInEffect){
        self.upperCoverView.hidden = NO;
        self.titleLabel.hidden = YES;
        self.coverImageView_2.image = nil;
        self.coverImageView.image = nil;
        self.coverImageView_1.image = NvImageNamed(item.coverString);
        self.nameLabel.hidden = NO;
        self.contentView.layer.borderWidth = 0;
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
        [self.coverImageView_1 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.upperCoverView.mas_centerY);
            make.left.equalTo(self.contentView.mas_left).offset(12.5 * SCREENSCALE);
            make.right.equalTo(self.contentView.mas_right).offset(-12.5 * SCREENSCALE);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-25*SCREENSCALE);
        }];
        [self.selectImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.left.equalTo(self.contentView.mas_left).offset(7.5 * SCREENSCALE);
            make.right.equalTo(self.contentView.mas_right).offset(-7.5 * SCREENSCALE);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-15*SCREENSCALE);
        }];
        [self.nameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.selectImageView.mas_centerX);
            make.top.equalTo(self.selectImageView.mas_bottom).offset(3*SCREENSCALE);
            make.height.mas_equalTo(12*SCREENSCALE);
            make.width.mas_equalTo(self.contentView.mas_width);
        }];
        self.nameLabel.text = NvLocalString(item.effectName, @"") ;
        if (item.selected) {
            self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#994A90E2"];
        }else{
            self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#32FFFFFF"];
        }
    }
    else{
        self.titleLabel.hidden = YES;
        self.coverImageView_2.image = nil;
        if (item.isCacheImage) {
            self.coverImageView_1.image = nil;
            self.coverImageView.image = [UIImage imageWithContentsOfFile:[WATEMARK_PATH stringByAppendingPathComponent:[item.coverString stringByAppendingString:@".png"]]];
        }else{
            self.coverImageView.image = nil;
            self.coverImageView_1.image = NvImageNamed(item.coverString);
        }
    }
    
    if (item.selected) {
        self.selectImageView.hidden = NO;
    }else{
        self.selectImageView.hidden = YES;
    }
}
@end
