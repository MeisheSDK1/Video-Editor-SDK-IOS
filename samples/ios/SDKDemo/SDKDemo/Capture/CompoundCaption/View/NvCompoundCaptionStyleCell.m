//
//  NvCompoundCaptionStyleCell.m
//  SDKDemo
//
//  Created by ms on 2021/6/29.
//  Copyright © 2021 meishe. All rights reserved.
//

#import "NvCompoundCaptionStyleCell.h"
#import <UIImageView+YYWebImage.h>
#import "NVHeader.h"
#import "NvGraphicBtn.h"
#import "NvCaptionStyleItem.h"
#import "YYWebImage.h"


@interface NvCompoundCaptionStyleCell ()
@property (nonatomic, strong) YYAnimatedImageView *imageView;        //
@end

@implementation NvCompoundCaptionStyleCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[YYAnimatedImageView alloc]init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.contentView.backgroundColor = [UIColor nv_colorWithHexString:@"#F5F5F5"];
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.right.mas_equalTo(0);
        }];
        
    }
    return self;
}

-(void)setAssetModel:(NvCaptionStyleItem *)assetModel{
    _assetModel = assetModel;
    if ([assetModel.imageUrl hasPrefix:@"http"]) {
        if ([assetModel.imageUrl hasSuffix:@".webp"] || [assetModel.imageUrl hasSuffix:@".gif"]) {
            [self.imageView yy_setImageWithURL:[NSURL URLWithString:assetModel.imageUrl] options:YYWebImageOptionProgressive];
        }
        else {
            [self.imageView yy_setImageWithURL:[NSURL URLWithString:assetModel.imageUrl] placeholder:nil];
        }
    } else {
        NSString *p = [self getUrlString:assetModel.imageUrl];
        if ([p isEqualToString:@""]) {
            self.imageView.image = nil;
        } else {
            if ([p hasSuffix:@".webp"] || [p hasSuffix:@".gif"]) {
                [self.imageView yy_setImageWithURL:[NSURL fileURLWithPath:p] options:YYWebImageOptionProgressive];
            } else {
                self.imageView.image = NvImageNamed(assetModel.imageUrl);
            }
        }
  
    }
    if (assetModel.isSelect) {
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.cornerRadius = 3.0f;
        self.contentView.layer.borderWidth = 3.0;
        self.contentView.layer.borderColor = [UIColor nv_colorWithHexString:@"#63ABFF"].CGColor;
    }else{
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    }
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
