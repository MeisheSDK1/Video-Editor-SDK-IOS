//
//  NvLiveARSeceneCaptureFilterCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/11/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvLiveARSeceneCaptureFilterCell.h"
#import "NvLiveARSceneUtils.h"
#import "Masonry.h"
#import "UIColor+NvLiveColor.h"
#import "NvLiveBaseModel.h"
#import "NvLiveAppEnv.h"

@interface NvLiveARSeceneCaptureFilterCell ()

@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UIImageView *maskView;
@property(nonatomic, strong) UIImageView *coverView;
@property(nonatomic, strong) UIImageView *imageViewType;

@property(nonatomic, assign) CGFloat sizeFloat;
@end

@implementation NvLiveARSeceneCaptureFilterCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.sizeFloat = frame.size.width;
        self.coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.coverView.contentMode = UIViewContentModeScaleToFill;
        self.coverView.layer.cornerRadius = 4 * NvScreen(kScale);
        self.coverView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#E3E3E3"];
        [self.contentView addSubview:self.coverView];

        self.maskView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.maskView.contentMode = UIViewContentModeScaleAspectFit;
        self.maskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#804A90E2"];
        self.maskView.layer.masksToBounds = YES;
        self.maskView.layer.cornerRadius = 4 * NvScreen(kScale);
        [self.contentView addSubview:self.maskView];

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.maskView.frame.size.height + 8 * NvScreen(kScale), frame.size.width, 15 * NvScreen(kScale))];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.numberOfLines = 2;
        self.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.nameLabel.alpha = 0.8;
        self.nameLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:self.nameLabel];

        self.imageViewType = [[UIImageView alloc] initWithImage:[NvLiveARSceneUtils imageNamed:@"NvProps3D"]];
        [self.contentView addSubview:self.imageViewType];
        [self.imageViewType mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.coverView.mas_right);
            make.bottom.equalTo(self.coverView.mas_bottom);
            make.width.equalTo(@(19 * NvScreen(kScale)));
            make.height.offset(19 * NvScreen(kScale));
        }];
    }
    return self;
}

- (void)renderCellWithModel:(NvLiveBaseModel *)model {
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
    } else {
        self.coverView.image = [NvLiveARSceneUtils imageNamed:@"NvDefaultProps"];
    }

    self.nameLabel.text = model.displayName;
    if (model.selected) {
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
        self.coverView.layer.borderWidth = 1;
    } else {
        self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#828282"];
        self.coverView.layer.borderWidth = 0;
    }
    switch (model.categoryId) {
        case 1:
            self.imageViewType.image = [NvLiveARSceneUtils imageNamed:@"NvProps2D"];
            break;
        case 2:
            self.imageViewType.image = [NvLiveARSceneUtils imageNamed:@"NvProps3D"];
            break;
        case 3:
            self.imageViewType.image = [NvLiveARSceneUtils imageNamed:@"NvPropsForeground"];
            break;
        case 4:
            self.imageViewType.image = [NvLiveARSceneUtils imageNamed:@"NvPropsBackground"];
            break;
        case 5:
            self.imageViewType.image = [NvLiveARSceneUtils imageNamed:@"NvPropsEye"];
            break;
        case 6:
            self.imageViewType.image = [NvLiveARSceneUtils imageNamed:@"NvPropsMouth"];
            break;
        case 7:
            self.imageViewType.image = [NvLiveARSceneUtils imageNamed:@"NvPropsHead"];
            break;
        case 8:
            self.imageViewType.image = [NvLiveARSceneUtils imageNamed:@"NvPropsGesture"];
            break;
        default:
            break;
    }

    self.imageViewType.hidden = YES;
}

@end
