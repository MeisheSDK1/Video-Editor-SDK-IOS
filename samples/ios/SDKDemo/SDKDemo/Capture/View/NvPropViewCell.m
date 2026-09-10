//
//  NvPropViewCell.m
//  SDKDemo
//
//  Created by MS on 2020/7/25.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvPropViewCell.h"
#import "NVHeader.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
@interface NvPropViewCell ()
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, assign) CGFloat sizeFloat;
@property (nonatomic, assign) CGFloat sepHeight;
@end

@implementation NvPropViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.sizeFloat = frame.size.width;
        self.sepHeight = 14;
        CGFloat width = 37*SCREENSCALE;
        self.coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        self.coverView.contentMode = UIViewContentModeScaleToFill;
        self.coverView.layer.cornerRadius = width/2;
        self.coverView.layer.masksToBounds = YES;
        self.coverView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#EBF4FF"];
        self.coverView.centerX = self.contentView.centerX;
        [self.contentView addSubview:self.coverView];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, width+7*SCREENSCALE, self.sizeFloat, 22 * SCREENSCALE)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.font = [NvUtils regularFontWithSize:11*SCREENSCALE];
        [self.contentView addSubview:self.nameLabel];
        
    }
    return self;
}

- (void)renderCellWithModel:(NvBaseModel *)model {
    if (model.coverName != nil && ![model.coverName isEqualToString:@""]) {
        if ([model.coverName hasPrefix:@"http"]) {
            [self.coverView yy_setImageWithURL:[NSURL URLWithString:model.coverName] placeholder:NvImageNamed(@"NvDefaultProps")];
        } else {
            UIImage *image = [UIImage imageWithContentsOfFile:model.coverName];
            if (!image) {
                image = NvImageNamed(model.coverName);
            }
            self.coverView.image = image;
        }
    }
    self.nameLabel.text = NvLocalString(model.displayName, @"");
    if (model.selected) {
        self.coverView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.coverView.layer.borderWidth = 1.f;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"];
    }else{
        self.coverView.layer.borderColor = [UIColor clearColor].CGColor;
        self.coverView.layer.borderWidth = 0.f;
        self.nameLabel.textColor = [UIColor blackColor];
    }
}

@end
