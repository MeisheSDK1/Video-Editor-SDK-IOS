//
//  NvSelectMusicTableViewCell.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/7/2.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvSelectMusicTableViewCell.h"
#import "NVHeader.h"

@interface NvSelectMusicTableViewCell()

@property (nonatomic, strong) UIImageView *musicImage;
@property (nonatomic, strong) UILabel *musicName;
@property (nonatomic, strong) UILabel *authorName;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) NvEditSelectMusicItem *currentItem;

@end

@implementation NvSelectMusicTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.musicImage = [UIImageView new];
        self.musicImage.contentMode = UIViewContentModeScaleAspectFit;
        self.musicName = [UILabel nv_labelWithText:@"" fontSize:12 textColor:UIColor.whiteColor];
        self.musicName.textAlignment = NSTextAlignmentLeft;
        self.authorName = [UILabel nv_labelWithText:@"" fontSize:12 textColor:[UIColor nv_colorWithHexRGB:@"#909293"]];
        self.authorName.textAlignment = NSTextAlignmentLeft;
        self.playButton = [UIButton nv_buttonWithTitle:@"" textColor:nil fontSize:-1 image:NvImageNamed(@"NvListening")];
        [self.playButton setImage:NvImageNamed(@"NvStop") forState:UIControlStateSelected];
        self.bottomLine = [UIView new];
        self.bottomLine.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
        [self.contentView addSubview:self.musicImage];
        [self.contentView addSubview:self.musicName];
        [self.contentView addSubview:self.authorName];
        [self.contentView addSubview:self.playButton];
        [self.contentView addSubview:self.bottomLine];
        __weak typeof(self)weakSelf = self;
        [self.playButton nv_BtnClickHandler:^{
            if ([weakSelf.delegate respondsToSelector:@selector(nvSelectMusicTableViewCell:playItem:)]) {
                [weakSelf.delegate nvSelectMusicTableViewCell:weakSelf playItem:weakSelf.currentItem];
            }
        }];
        
        [self.musicImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(@(13*SCREENSCALE));
            make.width.height.equalTo(@(49*SCREENSCALE));
        }];
        [self.musicName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.musicImage.mas_top);
            make.left.equalTo(self.musicImage.mas_right).offset(18*SCREENSCALE);
            make.right.equalTo(self.contentView.mas_right).offset(-60*SCREENSCALE);
        }];
        [self.authorName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.musicImage);
            make.left.equalTo(self.musicImage.mas_right).offset(18*SCREENSCALE);
            make.right.equalTo(self.contentView.mas_right).offset(-60*SCREENSCALE);
        }];
        [self.playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView.mas_right).offset(-13*SCREENSCALE);
            make.width.height.equalTo(@(36*SCREENSCALE));
            make.centerY.equalTo(self.contentView);
        }];
        [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(@0);
            make.height.equalTo(@1);
        }];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)renderCellWithItem:(NvEditSelectMusicItem *)item {
    self.currentItem = item;
    self.musicImage.image = item.image;
    self.musicName.text = item.musicName;
    self.authorName.text = item.authorName;
    self.playButton.selected = item.isPlay;
    self.musicImage.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
