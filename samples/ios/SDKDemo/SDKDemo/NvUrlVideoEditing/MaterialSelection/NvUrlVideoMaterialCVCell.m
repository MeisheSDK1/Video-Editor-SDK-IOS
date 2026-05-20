//
//  NvUrlVideoMaterialCVCell.m
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/2.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvUrlVideoMaterialCVCell.h"
#import "YYWebImage.h"

@implementation NvListMediaInfoModel

@end

@interface NvUrlVideoMaterialCVCell()

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) YYAnimatedImageView *coverView;
@property (nonatomic, strong) UIButton *linkButton;
@property (nonatomic, strong) NvListMediaInfoModel *infoModel;
@end

@implementation NvUrlVideoMaterialCVCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    self.contentView.backgroundColor = UIColor.clearColor;
    self.contentView.layer.cornerRadius = 2*SCREENSCALE;
    
    self.coverView = [YYAnimatedImageView new];
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverView.layer.masksToBounds = YES;
    self.coverView.backgroundColor = UIColor.clearColor;
    
    [self.contentView addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.contentView);
    }];
    
    self.linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.linkButton setBackgroundImage:NvImageNamed(@"NvUrlEdit_linkCopy") forState:UIControlStateNormal];
    [self.linkButton addTarget:self action:@selector(linkButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.linkButton];
    [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.coverView).offset(- 5 * SCREENSCALE);
        make.bottom.equalTo(self.contentView).offset(-5 * SCREENSCALE);
        make.width.offset(22 * SCREENSCALE);
        make.height.offset(22 * SCREENSCALE);
    }];
    
    self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.editButton setBackgroundImage:NvImageNamed(@"NvUrlEdit_item_noselect") forState:UIControlStateNormal];
    [self.editButton setBackgroundImage:NvImageNamed(@"NvUrlEdit_item_select") forState:UIControlStateSelected];
    self.editButton.userInteractionEnabled = false;
    [self.contentView addSubview:self.editButton];
    [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView).offset(-5 * SCREENSCALE);
        make.top.equalTo(self.contentView).offset(5 * SCREENSCALE);
        make.width.offset(22 * SCREENSCALE);
        make.height.offset(22 * SCREENSCALE);
    }];
}

- (void)linkButtonClick{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.infoModel.url;
    [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_copy", nil)];
}

- (void)editButtonClick{
    
}

- (void)renderCellWithItem:(nonnull NvListMediaInfoModel *)item {
    self.infoModel = item;
    self.editButton.hidden = !item.selectedModel;
    self.editButton.selected = item.isSelected;
    [self.coverView yy_setImageWithURL:[NSURL URLWithString:item.coverUrl] options:YYWebImageOptionProgressive];
}

@end
