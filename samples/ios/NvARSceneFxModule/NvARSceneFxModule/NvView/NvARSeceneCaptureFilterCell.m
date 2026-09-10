//
//  NvARSeceneCaptureFilterCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvARSeceneCaptureFilterCell.h"
#import "NvARSceneMacro.h"
#import "NvARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvColor.h"

@interface NvARSeceneCaptureFilterCell()

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *maskView;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIImageView *imageViewType;

@property (nonatomic, assign) CGFloat sizeFloat;
@end

@implementation NvARSeceneCaptureFilterCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.sizeFloat = frame.size.width;
        self.coverView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.coverView.contentMode = UIViewContentModeScaleToFill;
        self.coverView.layer.cornerRadius = 4 * SCREENSCALE;
        self.coverView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#E3E3E3"];
        [self.contentView addSubview:self.coverView];
        
        self.maskView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.maskView.contentMode = UIViewContentModeScaleAspectFit;
        self.maskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
        self.maskView.layer.masksToBounds = YES;
        self.maskView.layer.cornerRadius = 4 * SCREENSCALE;
        [self.contentView addSubview:self.maskView];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.maskView.frame.size.height + 8 * SCREENSCALE, frame.size.width, 15 * SCREENSCALE)];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.alpha = 0.8;
        self.nameLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:self.nameLabel];
        
        self.imageViewType = [[UIImageView alloc] initWithImage:[NvARSceneUtils imageWithName:@"NvProps3D"]];
        [self.contentView addSubview:self.imageViewType];
        [self.imageViewType mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.coverView.mas_right);
            make.bottom.equalTo(self.coverView.mas_bottom);
            make.width.equalTo(@(19 * SCREENSCALE));
            make.height.offset(19 * SCREENSCALE);
        }];
    }
    return self;
}

- (void)renderCellWithModel:(NvBaseModel *)model{
    self.coverView.layer.masksToBounds = YES;
    self.coverView.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"].CGColor;
    self.maskView.hidden = YES;
    if ([model.coverName isEqualToString:@"NvsFilterNone"]) {
        self.coverView.layer.masksToBounds = NO;
        self.imageViewType.hidden = YES;
    } else {
        self.imageViewType.hidden = NO;
    }
    if (model.coverName != nil && ![model.coverName isEqualToString:@""]) {
        self.coverView.image = [UIImage imageWithContentsOfFile:model.coverName];
    }else{
        self.coverView.image = [NvARSceneUtils imageWithName:@"NvDefaultProps"];
    }

    if ([NvARSceneUtils currentLanguagesIsChanese]){
        self.nameLabel.text = model.displayNameZhCn;
    }else{
        self.nameLabel.text = model.displayName;
    }
    
    if (model.selected) {
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.coverView.layer.borderWidth = 1;
    }else{
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#828282"];
        self.coverView.layer.borderWidth = 0;
    }
    switch (model.categoryId) {
        case 1:
            self.imageViewType.image = [NvARSceneUtils imageWithName:@"NvProps2D"];
            break;
        case 2:
            self.imageViewType.image = [NvARSceneUtils imageWithName:@"NvProps3D"];
            break;
        case 3:
            self.imageViewType.image = [NvARSceneUtils imageWithName:@"NvPropsForeground"];
            break;
        case 4:
            self.imageViewType.image = [NvARSceneUtils imageWithName:@"NvPropsBackground"];
            break;
        case 5:
            self.imageViewType.image = [NvARSceneUtils imageWithName:@"NvPropsEye"];
            break;
        case 6:
            self.imageViewType.image = [NvARSceneUtils imageWithName:@"NvPropsMouth"];
            break;
        case 7:
            self.imageViewType.image = [NvARSceneUtils imageWithName:@"NvPropsHead"];
            break;
        case 8:
            self.imageViewType.image = [NvARSceneUtils imageWithName:@"NvPropsGesture"];
            break;
        default:
            break;
    }
    
    self.imageViewType.hidden = YES;
}

@end
