//
//  NvTestEditTCell.m
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/12.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvTestEditTCell.h"

@implementation NvTestEditInfoModel

@end

@interface NvTestEditTCell()

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation NvTestEditTCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.grayColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel.textColor = UIColor.whiteColor;
        self.nameLabel.numberOfLines = 2;
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10 * SCREENSCALE);
            make.right.equalTo(self.contentView).offset(-80 * SCREENSCALE);
            make.centerY.equalTo(self.contentView);
        }];
        
        self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.editButton setBackgroundImage:NvImageNamed(@"Nv_beauty_thumb") forState:UIControlStateNormal];
        [self.editButton setBackgroundImage:NvImageNamed(@"Nv_capture_finish") forState:UIControlStateSelected];
        self.editButton.userInteractionEnabled = false;
        [self.contentView addSubview:self.editButton];
        [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-5 * SCREENSCALE);
            make.centerY.equalTo(self.contentView);
            make.width.offset(20 * SCREENSCALE);
            make.height.offset(20 * SCREENSCALE);
        }];
    }
    return self;
}

- (void)renderCellWithItem:(NvTestEditInfoModel *)item {
    self.editButton.selected = item.isSelected;
    self.nameLabel.text = item.displayName;
}

@end
