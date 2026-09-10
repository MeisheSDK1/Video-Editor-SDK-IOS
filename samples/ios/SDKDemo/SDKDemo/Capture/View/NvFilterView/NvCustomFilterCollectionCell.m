//
//  NvCustomFilterCollectionCell.m
//  SDKDemo
//
//  Created by MS on 2020/7/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvCustomFilterCollectionCell.h"
#import "NVHeader.h"
#import <YYWebImage/UIImageView+YYWebImage.h>

@interface NvCustomFilterCollectionCell ()
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, assign) CGFloat sizeFloat;
@property (nonatomic, assign) CGFloat sepHeight; //Difference in y value between selected and unselected
@end

@implementation NvCustomFilterCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.sizeFloat = frame.size.width;
        self.sepHeight = 7.5*SCREENSCALE;
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.sepHeight, self.contentView.frame.size.width, self.contentView.frame.size.height-self.sepHeight)];
        [self.contentView addSubview:self.bgView];
        
        self.maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height-self.sepHeight)];
        [self.bgView addSubview:self.maskView];
        
        self.coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.width)];
        self.coverView.contentMode = UIViewContentModeScaleToFill;
        self.coverView.layer.cornerRadius = 4 * SCREENSCALE;
        [self.bgView addSubview:self.coverView];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.contentView.frame.size.height-self.sepHeight-15 * SCREENSCALE, self.contentView.frame.size.width, 15 * SCREENSCALE)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.font = [NvUtils regularFontWithSize:11*SCREENSCALE];
        [self.bgView addSubview:self.nameLabel];
        
    }
    return self;
}

- (void)renderCellWithModel:(NvBaseModel *)model{
    self.coverView.image = nil;
    
    
    self.coverView.layer.masksToBounds = NO;
    self.coverView.layer.borderColor = [UIColor clearColor].CGColor;
    self.coverView.layer.borderWidth = 0;
    self.coverView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.width);
    self.nameLabel.frame = CGRectMake(0, self.contentView.frame.size.height -self.sepHeight - 15 * SCREENSCALE, self.contentView.frame.size.width, 15 * SCREENSCALE);
    
    
    if (model.labelColorStr.length > 0) {
        self.nameLabel.backgroundColor = [UIColor nv_colorWithHexRGBA:model.labelColorStr];
    }else{
        self.nameLabel.backgroundColor = [UIColor whiteColor];
    }
    if (model.textColorStr.length > 0) {
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGBA:model.textColorStr];
    }else{
        self.nameLabel.textColor = [UIColor whiteColor];
    }
    
    
    if (model.selected) {
        if (!model.bgColorStr) {
            self.bgView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height-self.sepHeight);
        }
        self.maskView.hidden = NO;
        self.maskView.backgroundColor = [UIColor nv_colorWithHexRGBA:model.labelColorStr];
        self.maskView.alpha = 0.6;
        [self.bgView bringSubviewToFront:self.maskView];
        
    }
    else{
        self.maskView.hidden = YES;
        self.bgView.frame = CGRectMake(0, self.sepHeight, self.contentView.frame.size.width, self.contentView.frame.size.height-self.sepHeight);
    }
    if (model.bgColorStr.length > 0) {
        self.bgView.backgroundColor = [UIColor nv_colorWithHexRGBA:model.bgColorStr];
    }else{
        self.bgView.backgroundColor = [UIColor whiteColor];
    }
    
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
    self.nameLabel.text = @"";
    self.nameLabel.text = NvLocalString(model.displayName, @"");
    
}

@end
