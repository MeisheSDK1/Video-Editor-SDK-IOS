//
//  NvUrlMusicMaterialCVCell.m
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/10.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvUrlMusicMaterialCVCell.h"
#import "NvUrlVideoMaterialCVCell.h"
#import "YYWebImage.h"

@interface NvUrlMusicMaterialCVCell()

@property (nonatomic, strong) YYAnimatedImageView *coverView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *linkButton;

@property (nonatomic, strong) NvListMediaInfoModel *infoModel;

@property (nonatomic, strong) UIView *boxView;

@end

@implementation NvUrlMusicMaterialCVCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    self.contentView.backgroundColor = UIColor.clearColor;
    
    self.boxView = [[UIView alloc] init];
    self.boxView.layer.cornerRadius = 4*SCREENSCALE;
    self.boxView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#333333"];
    [self.contentView addSubview:self.boxView];
    [self.boxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(25 * SCREENSCALE);
        make.right.equalTo(self.contentView).offset(-25 * SCREENSCALE);
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-15 * SCREENSCALE);
    }];
    
    self.coverView = [YYAnimatedImageView new];
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverView.layer.cornerRadius = 3*SCREENSCALE;
    self.coverView.layer.masksToBounds = YES;
    self.coverView.userInteractionEnabled = true;
    self.coverView.backgroundColor = UIColor.clearColor;
    [self.boxView addSubview:self.coverView];
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.boxView).offset(5 * SCREENSCALE);
        make.width.height.offset(55 * SCREENSCALE);
        make.centerY.equalTo(self.boxView);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = [UIFont systemFontOfSize:12];
    self.nameLabel.textColor = UIColor.whiteColor;
    self.nameLabel.numberOfLines = 1;
    [self.boxView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverView.mas_right).offset(10 * SCREENSCALE);
        make.right.equalTo(self.boxView).offset(-10 * SCREENSCALE);
        make.top.equalTo(self.boxView).offset(15 * SCREENSCALE);
    }];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont systemFontOfSize:12];
    self.timeLabel.textColor = [UIColor nv_colorWithHexRGB:@"#A4A4A4"];
    self.timeLabel.numberOfLines = 1;
    [self.boxView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.bottom.equalTo(self.boxView).offset(-15 * SCREENSCALE);
    }];
    
    self.linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.linkButton setBackgroundImage:NvImageNamed(@"NvUrlEdit_linkCopy") forState:UIControlStateNormal];
    [self.linkButton addTarget:self action:@selector(linkButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.boxView addSubview:self.linkButton];
    [self.linkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.boxView).offset(-10 * SCREENSCALE);
        make.bottom.equalTo(self.boxView).offset(-5 * SCREENSCALE);
        make.width.offset(23 * SCREENSCALE);
        make.height.offset(23 * SCREENSCALE);
    }];
}

- (void)renderCellWithItem:(nonnull NvListMediaInfoModel *)item {
    self.infoModel = item;
    self.nameLabel.text = item.displayName;
    self.timeLabel.text = [self convertTimecode:item.duration];
    [self.coverView yy_setImageWithURL:[NSURL URLWithString:item.coverUrl] options:YYWebImageOptionProgressive];
}

- (void)linkButtonClick{
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.infoModel.url;
    [NvToast showInfoWithMessage:NvLocalString(@"urlEditing_home_copy", nil)];
}

- (NSString *)convertTimecode:(float)time {
    time = (time + 0.5) / 1;
    int min = (int)time / 60;
    int sec = (int)time % 60;
    if (min >= 10 && sec >= 10)
        return [NSString stringWithFormat:@"%d:%d", min, sec];
    else if (min >= 10)
        return [NSString stringWithFormat:@"%d:0%d", min, sec];
    else if (sec >= 10)
        return [NSString stringWithFormat:@"0%d:%d", min, sec];
    else
        return [NSString stringWithFormat:@"0%d:0%d", min, sec];
}

@end
