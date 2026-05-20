//
//  NvAnimationCollectionViewCell.m
//  SDKDemo
//
//  Created by ms on 2020/7/22.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvAnimationCollectionViewCell.h"
#import "NVHeader.h"
#import <UIImageView+YYWebImage.h>
#import "YYWebImage.h"

@interface NvAnimationCollectionViewCell()

@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIImageView *noneImageView;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation NvAnimationCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.imageView = [YYAnimatedImageView new];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.noneImageView = [UIImageView new];
        self.noneImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.nameLabel = [UILabel nv_labelWithText:@"无" fontSize:11 textColor:[UIColor nv_colorWithHexRGB:@"#CCFFFFFF"]];
        self.nameLabel.alpha = 0.8;
        self.nameLabel.numberOfLines = 2;
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.noneImageView];
        [self.contentView addSubview:self.nameLabel];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(3*SCREENSCALE));
            make.left.right.equalTo(@0);
            make.height.equalTo(@(49*SCREENSCALE));
        }];
        [self.noneImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(3*SCREENSCALE));
            make.left.right.equalTo(@0);
            make.height.equalTo(@(49*SCREENSCALE));
        }];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.imageView.mas_bottom).offset(18*SCREENSCALE);
            make.left.right.mas_equalTo(0);
        }];
        self.coverView = [UIImageView new];
        [self.contentView addSubview:self.coverView];
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imageView);
        }];
        
    }
    return self;
}

- (void)renderCellWithItem:(NvCaptionAnimationItem *)item {
    if (item.isSelect) {
        self.coverView.layer.cornerRadius = 2;
        self.coverView.layer.masksToBounds = YES;
        self.coverView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
        self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
    } else {
        self.coverView.layer.cornerRadius = 2;
        self.coverView.layer.masksToBounds = YES;
        self.coverView.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor nv_colorWithHexARGB:@"#CCFFFFFF"];
    }
    if ([item.imageUrl containsString:@"http"]) {
        if ([item.imageUrl hasSuffix:@".webp"] ||
            [item.imageUrl hasSuffix:@".gif"]) {
            [self.imageView yy_setImageWithURL:[NSURL URLWithString:item.imageUrl] options:YYWebImageOptionProgressive];
        }
        else {
            [self.imageView yy_setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholder:nil];
        }
        
        self.noneImageView.hidden = YES;
    } else {
        if ([item.imageUrl isEqualToString:@"NvsFilterNone"]) {
            self.imageView.image = [UIImage new];
            self.noneImageView.hidden = NO;
            self.noneImageView.image = NvImageNamed(item.imageUrl);
        }else{
            self.noneImageView.hidden = YES;
            NSString *p = [self getUrlString:item.imageUrl];
            if ([p isEqualToString:@""]) {
                self.imageView.image = nil;
            } else {
                if ([p hasSuffix:@".webp"] || [p hasSuffix:@".gif"]) {
                    [self.imageView yy_setImageWithURL:[NSURL fileURLWithPath:p] options:YYWebImageOptionProgressive];
                } else {
                    self.imageView.image = NvImageNamed(item.imageUrl);
                }
            }
        }
    }
    
    self.nameLabel.text = item.name;
}

- (NSString *)getUrlString:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        return path;
    }
    if ([path hasSuffix:@".png"]) {
        NSString *p = [path stringByReplacingOccurrencesOfString:@".png" withString:@".jpg"];
        return [self getUrlString:p];
    } else if ([path hasSuffix:@".jpg"]) {
        NSString *p = [path stringByReplacingOccurrencesOfString:@".jpg" withString:@".jpeg"];
        return [self getUrlString:p];
    } if ([path hasSuffix:@".jpeg"]) {
        NSString *p = [path stringByReplacingOccurrencesOfString:@".jpeg" withString:@".webp"];
        return [self getUrlString:p];
    } else if ([path hasSuffix:@".webp"]) {
        NSString *p = [path stringByReplacingOccurrencesOfString:@".webp" withString:@".gif"];
        return [self getUrlString:p];
    } else if ([path hasSuffix:@".gif"]) {
        return @"";
    } else {
        return @"";
    }
    return @"";
}

@end
