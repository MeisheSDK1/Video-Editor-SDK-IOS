//
//  NvPIPThemeCell.m
//  SDKDemo
//
//  Created by Meicam on 2018/6/28.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvPIPThemeCell.h"
#import "NVHeader.h"

@interface NvPIPThemeCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *selectView;

@end

@implementation NvPIPThemeCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        
        self.imageView = [UIImageView new];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.layer.cornerRadius = 4.0f;
        
        self.nameLabel = [UILabel nv_labelWithText:NvLocalString(@"None", @"无") fontSize:14 textColor:[UIColor nv_colorWithHexRGB:@"#4A90E2"]];
        self.nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.numberOfLines = 2;
        
        self.selectView = [UIView new];
        self.selectView.backgroundColor = [[UIColor nv_colorWithHexRGB:@"#52D3FF"] colorWithAlphaComponent:.7];
        self.selectView.layer.cornerRadius = 4.0f;
        self.selectView.layer.masksToBounds = YES;
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.selectView];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.width.mas_equalTo(KScale6s(49));
            make.height.mas_equalTo(KScale6s(49));
            make.centerX.mas_equalTo(0);
        }];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.imageView.mas_bottom).offset(KScale6s(20));
            make.left.right.mas_equalTo(0);
        }];
        
        [self.selectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imageView).insets(UIEdgeInsetsZero);
        }];
    }
    return self;
}


- (void)renderCellWithItem:(NvPIPThemeItem *)item {
    if (item.isSelect) {
        self.selectView.hidden = NO;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    } else {
        self.selectView.hidden = YES;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#FFFFFF"];
    }
    if (item.imageUrl && ![item.imageUrl isEqualToString:@""]) {
        if ([item.imageUrl containsString:@"/"]) {
            [self.imageView setImage:[UIImage imageWithContentsOfFile:item.imageUrl]];
        } else {
            [self.imageView setImage:NvImageNamed(item.imageUrl)];
        }
    } else {
        [self.imageView setImage:[UIImage imageWithContentsOfFile:item.bundleImagePath]];
    }
    
    self.nameLabel.text = item.name;
}

@end
