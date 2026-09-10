//
//  NvCompoundCaptionCell.m
//  SDKDemo
//
//  Created by MS on 2019/5/16.
//  Copyright © 2019 meishe. All rights reserved.
//

#import "NvCompoundCaptionCell.h"
#import "NVHeader.h"
#import <UIImageView+YYWebImage.h>
#import "YYWebImage.h"

@interface NvCompoundCaptionCell ()

@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIImageView *noneImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@end

@implementation NvCompoundCaptionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.imageView = [YYAnimatedImageView new];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.noneImageView = [UIImageView new];
        self.noneImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont systemFontOfSize:12*SCREENSCALE];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.noneImageView];
        [self.contentView addSubview:self.nameLabel];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.imageView.mas_bottom).offset(KScale6s(18));
            make.left.equalTo(self.contentView).offset(KScale6s(5));
            make.right.equalTo(self.contentView).offset(-KScale6s(5));
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.left.right.equalTo(@0);
            make.height.mas_equalTo(49*SCREENSCALE);
        }];
        
        [self.noneImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top);
            make.left.right.equalTo(@0);
            make.height.mas_equalTo(49*SCREENSCALE);
        }];
        self.coverView = [UIImageView new];
        [self.contentView addSubview:self.coverView];
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imageView);
        }];
        
    }
    return self;
}

- (void)renderCellWithItem:(NvCaptionStyleItem *)item {
    if (item.isSelect) {
        self.coverView.layer.cornerRadius = 2;
        self.coverView.layer.masksToBounds = YES;
        self.coverView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#58A8EE"];
    } else {
        self.coverView.layer.cornerRadius = 2;
        self.coverView.layer.masksToBounds = YES;
        self.coverView.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor whiteColor];
    }
    NSString *imagePath = [[[NSBundle mainBundle] pathForResource:@"compoundCaptionPackage" ofType:@"bundle"] stringByAppendingPathComponent:item.packageId];
    UIImage *defaultImage = [UIImage imageWithContentsOfFile:imagePath];
    if (defaultImage) {
        self.noneImageView.hidden = YES;
        self.imageView.image = defaultImage ? defaultImage : [UIImage imageNamed:@"NvsFilterNone"];
        self.nameLabel.text = item.name;
    }else{
        if ([item.imageUrl containsString:@"http"]) {
            [self.imageView yy_setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholder:nil];
            self.noneImageView.hidden = YES;
            self.nameLabel.text = item.name;
        } else {
            if ([item.imageUrl isEqualToString:@"NvsFilterNone"]) {
                self.imageView.image = [UIImage new];
                self.noneImageView.hidden = NO;
                self.noneImageView.image = NvImageNamed(item.imageUrl);
                self.nameLabel.text = NvLocalString(@"More", @"更多");
            }else{
                
                self.noneImageView.hidden = YES;
                 self.nameLabel.text = item.name;
                NSFileManager * fm = [NSFileManager defaultManager];
                UIImage * localImage;
                if ([fm fileExistsAtPath:item.imageUrl]) {
                    
                    if ([item.imageUrl hasSuffix:@".webp"] ||
                        [item.imageUrl hasSuffix:@".gif"]) {
                        
                        NSData *imageData = [NSData dataWithContentsOfFile:item.imageUrl];
                        YYImage *image = [YYImage imageWithData:imageData];
                        localImage = image;
                    }else{
                        
                        localImage = [UIImage imageWithContentsOfFile:item.imageUrl];
                    }
                }
                if (!localImage) {
                    NSString * compoundFilePath = [[NSHomeDirectory() stringByAppendingPathComponent:NV_ASSET_DOWNLOAD_PATH_COMPOUND_CAPTION] stringByAppendingPathComponent:item.imageUrl];
                    localImage = [UIImage imageWithContentsOfFile:compoundFilePath];
                }
                self.imageView.image = localImage ? : [UIImage imageNamed:@"NvsFilterNone"];
            }
        }
    }
    
}
@end
