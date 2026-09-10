//
//  NvLiveHomeListCollectionCell.m
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/16.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import "NvLiveHomeListCollectionCell.h"
#import "UIColor+NvLiveColor.h"
#import "NvLiveAppEnv.h"
#import "Masonry.h"
#import "NvLiveARSceneUtils.h"

@interface NvLiveHomeListCollectionCell()

@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *numberLabel;

@property (nonatomic, strong) UILabel *stateLabel;

@property (nonatomic, strong) UIView *stateBGView;

@end

@implementation NvLiveHomeListCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews{
    self.coverImageView = [[UIImageView alloc]init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.layer.masksToBounds = YES;
    self.coverImageView.layer.cornerRadius = 5 * NvScreen(kScale);
    [self.contentView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.width.height.equalTo(self.contentView);
    }];
    
    self.stateBGView = [[UIView alloc]init];
    [self.contentView addSubview:self.stateBGView];
    [self.stateBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10 * NvScreen(kScale));
        make.left.equalTo(self.contentView).offset(10 *NvScreen(kScale));
        make.width.offset(60 * NvScreen(kScale));
        make.height.offset(22 * NvScreen(kScale));
    }];
    
    [self.stateBGView layoutIfNeeded];
    
    self.stateLabel = [[UILabel alloc]init];
    self.stateLabel.font = [UIFont systemFontOfSize:12];
    self.stateLabel.textAlignment = NSTextAlignmentCenter;
    self.stateLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.stateLabel.textColor = UIColor.whiteColor;
    [self.contentView addSubview:self.stateLabel];
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(self.stateBGView);
    }];
    
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.titleLabel.textColor = UIColor.whiteColor;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-10 * NvScreen(kScale));
        make.left.equalTo(self.contentView).offset(10 *NvScreen(kScale));
        make.right.equalTo(self.contentView).offset(- 70 * NvScreen(kScale));
    }];
    
    self.numberLabel = [[UILabel alloc]init];
    self.numberLabel.textAlignment = NSTextAlignmentRight;
    self.numberLabel.font = [UIFont systemFontOfSize:14];
    self.numberLabel.textColor = UIColor.whiteColor;
    [self.contentView addSubview:self.numberLabel];
    [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-10 * NvScreen(kScale));
        make.left.equalTo(self.titleLabel.mas_right).offset(10 *NvScreen(kScale));
        make.right.equalTo(self.contentView).offset(- 10 * NvScreen(kScale));
    }];
}

- (void)renderCellWithModel:(NvLiveModel *)model{
    if (model.online) {
         [NvLiveAppEnv gradientView:self.stateBGView withColors:@[(__bridge id)[UIColor nv_colorWithHexRGB:@"#9F7CFF"].CGColor,
                                                              (__bridge id)[UIColor nv_colorWithHexRGB:@"#5784FF"].CGColor]];
        self.stateLabel.text = NvLocalString(@"Live", @"·直播中");
    }else{
        self.stateLabel.text = NvLocalString(@"Replay", @"回放");
    }
    
    if ([model.coverUrl hasPrefix:@"http"]) {
//        [self.coverImageView setImageWithURL:[NSURL URLWithString:model.coverUrl]];
    } else {
        self.coverImageView.image = [NvLiveARSceneUtils imageNamed:model.coverUrl];
    }
    
    self.titleLabel.text = model.title;
    
    self.numberLabel.text = model.onlineUsers;
}


@end
