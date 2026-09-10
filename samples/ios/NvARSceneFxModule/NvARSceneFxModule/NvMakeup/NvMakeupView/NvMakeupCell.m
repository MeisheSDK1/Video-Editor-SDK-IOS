//
//  NvMakeupCell.m
//  SDKDemo
//
//  Created by MS on 2020/7/16.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvMakeupCell.h"
#import "NvARSceneMacro.h"
#import "NvARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvColor.h"

@interface NvMakeupCell ()
@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, assign) CGFloat sizeFloat;
@property (nonatomic, assign) CGFloat sepHeight; 
@end

@implementation NvMakeupCell
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
        self.nameLabel.font = [UIFont systemFontOfSize:11*SCREENSCALE];
        [self.bgView addSubview:self.nameLabel];
        
    }
    return self;
}

- (void)renderCellWithToolDataModel:(NvMakeupToolDataModel *)model{
    self.coverView.image = nil;
    if (model.conLevel == 1) {
        self.bgView.backgroundColor = [UIColor whiteColor];
        self.bgView.frame = CGRectMake(0, self.sepHeight, self.contentView.frame.size.width, self.contentView.frame.size.height-self.sepHeight);
        self.coverView.frame = CGRectMake(0, 0, self.contentView.frame.size.width-18*SCREENSCALE, self.contentView.frame.size.width-18*SCREENSCALE);
        self.coverView.center = CGPointMake(self.contentView.center.x, self.coverView.center.y);
        self.coverView.layer.cornerRadius = (self.contentView.frame.size.width-18*SCREENSCALE)/2;
        self.coverView.layer.masksToBounds = YES;
        self.maskView.hidden = YES;
        if (model.selected) {
            self.coverView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
            self.coverView.layer.borderWidth = 1.f;
            self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        }else{
            self.coverView.layer.borderColor = [UIColor clearColor].CGColor;
            self.coverView.layer.borderWidth = 0;
            self.nameLabel.textColor = [UIColor nv_colorWithHexRGBA:@"#0000005A"];
        }
        self.nameLabel.backgroundColor = [UIColor whiteColor];
        self.nameLabel.frame = CGRectMake(0, self.contentView.frame.size.width-12*SCREENSCALE, self.contentView.frame.size.width, 15 * SCREENSCALE);
    }else{
        
        self.coverView.layer.masksToBounds = NO;
        self.coverView.layer.borderColor = [UIColor clearColor].CGColor;
        self.coverView.layer.borderWidth = 0;
        self.coverView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.width);
        self.nameLabel.frame = CGRectMake(0, self.contentView.frame.size.height-self.sepHeight-15 * SCREENSCALE, self.contentView.frame.size.width, 15 * SCREENSCALE);
        
        
        if (model.labelColorStr.length > 0) {
            self.nameLabel.backgroundColor = [UIColor nv_colorWithHexRGBA:model.labelColorStr];
        }else{
            self.nameLabel.backgroundColor = [UIColor whiteColor];
        }
        if (model.textColorStr.length > 0) {
            self.nameLabel.textColor = [UIColor nv_colorWithHexRGBA:model.textColorStr];
        }else{
            self.nameLabel.textColor = [UIColor nv_colorWithHexRGBA:@"#FFFFFFFF"];
        }
        
        
        if (model.selected && model.hasBgColor) {
            self.maskView.hidden = NO;
            self.maskView.backgroundColor = [UIColor nv_colorWithHexRGBA:model.labelColorStr];
            self.maskView.alpha = 0.6;
            self.bgView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height-self.sepHeight);
            self.maskView.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height-self.sepHeight);
            [self.bgView bringSubviewToFront:self.maskView];
        }else{
            self.maskView.hidden = YES;
            self.bgView.frame = CGRectMake(0, self.sepHeight, self.contentView.frame.size.width, self.contentView.frame.size.height-self.sepHeight);
        }
        if (model.bgColorStr.length > 0) {
           self.bgView.backgroundColor = [UIColor nv_colorWithHexRGBA:model.bgColorStr];
        }else{
           self.bgView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    if (model.coverImage != nil && ![model.coverImage isEqualToString:@""]) {
        if ([model.coverImage hasPrefix:@"http"]) {
            
        } else {
            UIImage *image = [UIImage imageWithContentsOfFile:model.coverImage];
            if (!image) {
                image = [NvARSceneUtils imageWithName:model.coverImage];
            }
            self.coverView.image = image;
        }
    }
    self.nameLabel.text = @"";
    if ([NvARSceneUtils currentLanguagesIsChanese]){
        if (model.translation.count > 0 ) {
            if (model.translation[0].targetText.length > 0) {
                model.displayName = model.translation[0].targetText;
            }
        }else if (model.displayNameZhCn.length > 0) {
            model.displayName = model.displayNameZhCn;
        }
    }else{
        if (model.translation.count > 0 ) {
            if (model.translation[0].targetText.length > 0) {
                model.displayName = model.translation[0].originalText;
            }
        }else if (model.displayName.length > 0) {
            model.displayName = model.displayName;
        }
    }
    self.nameLabel.text = model.displayName > 0 ? model.displayName : model.name;
}

@end
