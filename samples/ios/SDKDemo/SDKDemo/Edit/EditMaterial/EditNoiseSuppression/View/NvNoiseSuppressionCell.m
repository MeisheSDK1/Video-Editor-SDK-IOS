//
//  NvNoiseSuppressionCell.m
//  SDKDemo
//
//  Created by Meishe on 2022/9/9.
//  Copyright © 2022 meishe. All rights reserved.
//

#import "NvNoiseSuppressionCell.h"
#import "NVHeader.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
@interface NvNoiseSuppressionCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation NvNoiseSuppressionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = frame.size.width;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        self.imageView.contentMode = UIViewContentModeScaleToFill;
        self.imageView.layer.cornerRadius = width/2;
        self.imageView.layer.masksToBounds = YES;
        self.imageView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#EBF4FF"];
        self.imageView.centerX = self.contentView.centerX;
        [self.contentView addSubview:self.imageView];
        
    }
    return self;
}

- (void)renderCellWithModel:(NvBaseModel *)model {
    if (model.coverName != nil && ![model.coverName isEqualToString:@""]) {
        if ([model.coverName hasPrefix:@"http"]) {
            [self.imageView yy_setImageWithURL:[NSURL URLWithString:model.coverName] placeholder:NvImageNamed(@"NvDefaultProps")];
        } else {
            UIImage *image = [UIImage imageWithContentsOfFile:model.coverName];
            if (!image) {
                image = NvImageNamed(model.coverName);
            }
            self.imageView.image = image;
        }
    }
    if (model.selected) {
        self.imageView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.imageView.layer.borderWidth = 1.f;
    }else{
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.imageView.layer.borderWidth = 0.f;
    }
}

- (void)renderCaptureCellWithModel:(NvBaseModel *)model{
    if (model.coverName != nil && ![model.coverName isEqualToString:@""]) {
        UIImage *image = NvImageNamed(model.coverDefault);
        if (model.selected) {
            image = NvImageNamed(model.coverName);
        }else{
            image = NvImageNamed(model.coverDefault);
        }
        
        self.imageView.image = image;
    }
}
@end
