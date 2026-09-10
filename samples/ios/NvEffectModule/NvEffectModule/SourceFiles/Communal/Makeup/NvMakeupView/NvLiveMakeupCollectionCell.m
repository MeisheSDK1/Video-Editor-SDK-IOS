//
//  NvLiveMakeupCollectionCell.m
//  SDKDemo
//
//  Created by MS on 2020/7/16.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvLiveMakeupCollectionCell.h"
#import "NvLiveARSceneUtils.h"
#import "Masonry.h"
#import "NvLiveAppEnv.h"
#import "UIColor+NvLiveColor.h"

@interface NvLiveMakeupCollectionCell ()
@property(nonatomic, strong) UIView *bgView;

@property(nonatomic, strong) UIImageView *maskView;
@property(nonatomic, strong) UIImageView *coverView;
@property(nonatomic, assign) CGFloat sizeFloat;
@property(nonatomic, assign) CGFloat sepHeight;
@end

@implementation NvLiveMakeupCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.sizeFloat = frame.size.width;
        self.sepHeight = 7.5 * NvScreen(kScale);
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.sepHeight, self.contentView.frame.size.width, self.contentView.frame.size.height - self.sepHeight)];
        [self.contentView addSubview:self.bgView];

        self.maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height - self.sepHeight)];
        [self.bgView addSubview:self.maskView];

        self.coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.width)];
        self.coverView.contentMode = UIViewContentModeScaleToFill;
        self.coverView.layer.cornerRadius = 4 * NvScreen(kScale);
        [self.bgView addSubview:self.coverView];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.contentView.frame.size.height - self.sepHeight - 15 * NvScreen(kScale), self.contentView.frame.size.width, 15 * NvScreen(kScale))];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.font = [UIFont systemFontOfSize:11 * NvScreen(kScale)];
        [self.bgView addSubview:self.nameLabel];
    }
    return self;
}

- (void)renderCellWithToolDataModel:(NvLiveMakeupItemModel *)model {
    self.coverView.image = nil;
    self.bgView.backgroundColor = [UIColor whiteColor];
    self.bgView.frame = CGRectMake(0, self.sepHeight, self.contentView.frame.size.width, self.contentView.frame.size.height - self.sepHeight);
    self.coverView.frame = CGRectMake(0, 0, self.contentView.frame.size.width - 18 * NvScreen(kScale), self.contentView.frame.size.width - 18 * NvScreen(kScale));
    self.coverView.center = CGPointMake(self.contentView.center.x, self.coverView.center.y);
    self.coverView.layer.cornerRadius = (self.contentView.frame.size.width - 18 * NvScreen(kScale)) / 2;
    self.coverView.layer.masksToBounds = YES;
    self.maskView.hidden = YES;
    if (model.selected) {
        self.coverView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
        self.coverView.layer.borderWidth = 1.f;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    } else {
        self.coverView.layer.borderColor = [UIColor clearColor].CGColor;
        self.coverView.layer.borderWidth = 0;
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGBA:@"#0000005A"];
    }
    self.nameLabel.backgroundColor = [UIColor whiteColor];
    self.nameLabel.frame = CGRectMake(0, self.contentView.frame.size.width - 12 * NvScreen(kScale), self.contentView.frame.size.width, 15 * NvScreen(kScale));
    
    if (model.coverImage != nil && ![model.coverImage isEqualToString:@""]) {
        if ([model.coverImage hasPrefix:@"http"]) {
        } else {
            UIImage *image = [UIImage imageWithContentsOfFile:model.coverImage];
            if (!image) {
                image = [NvLiveARSceneUtils imageNamed:model.coverImage];
            }
            self.coverView.image = image;
        }
    }
    self.nameLabel.text = model.displayNameZhCn;
    if (![NvLiveARSceneUtils currentLanguagesIsChanese]) {
        self.nameLabel.text = model.displayName;
    }
}

@end
