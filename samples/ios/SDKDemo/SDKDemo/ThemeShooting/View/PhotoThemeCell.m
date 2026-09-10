//
//  PhotoThemeCell.m
//  ThemeShooting
//
//  Created by ms on 2020/7/15.
//  Copyright © 2020 ms. All rights reserved.
//

#import "PhotoThemeCell.h"
#import "NVHeader.h"
#import <YYWebImage/UIImageView+YYWebImage.h>

@interface PhotoThemeCell ()

@property (nonatomic , strong ) UIImageView *iconImageView;
@property (nonatomic , strong ) UILabel *titleLabel;
@property (nonatomic , strong ) UILabel *numLabel;
@property (nonatomic, strong) UIImageView *numImageView;
@property (nonatomic , strong ) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *timeImageView;

@end

@implementation PhotoThemeCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.blackColor;
        
        [self initSubview];
        
        [self configAutoLayout];
    }
    return self;
}

-(void)setModel:(NvThemeShootModel *)model{
    _model = model;
    if (model.coverUrl && model.coverUrl.length > 0) {
        [self.iconImageView yy_setImageWithURL:[NSURL URLWithString:model.coverUrl] placeholder:nil];
    }else{
        NSString * dirPath = [[NSHomeDirectory() stringByAppendingPathComponent:self.model.isLocal ? @"Documents/LocalThemeShoot": @"Documents/ThemeShoot"] stringByAppendingPathComponent:self.model.uuid ? self.model.uuid : self.model.packageInfoModel.ID];
        self.iconImageView.image = [UIImage imageWithContentsOfFile:[dirPath stringByAppendingPathComponent:@"cover.png"]] ;
    }
    
    self.titleLabel.text = model.packageInfoModel.name;

    NSUInteger min = model.packageInfoModel.musicDuration / NV_TIME_BASE / 60;
    NSUInteger sec = model.packageInfoModel.musicDuration / NV_TIME_BASE % 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%2lu:%2lu", (unsigned long)min, (unsigned long)sec];
    self.numLabel.text = [NSString stringWithFormat:@"%ld",(long)model.packageInfoModel.shotsNumber];
    self.downLoadImageView.hidden = model.isDownload;
}

-(void)initSubview{
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.image = [UIImage imageNamed:@"Copy_information_bg"];
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.iconImageView.clipsToBounds = YES;
    [self.contentView addSubview:self.iconImageView];
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    _titleLabel.text = @"穿梭";
    _titleLabel.font = [UIFont systemFontOfSize:14*SCREENSCALE];
    _titleLabel.textColor = UIColor.whiteColor;
    [self.contentView addSubview:_titleLabel];
    
    self.numImageView = [[UIImageView alloc] init];
    self.numImageView.image = [UIImage imageNamed:@"themeClipNum"];
    self.numImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.numImageView];
    
    _numLabel = [[UILabel alloc] init];
    _numLabel.textAlignment = NSTextAlignmentLeft;
    _numLabel.text = @"6";
    _numLabel.font = [UIFont systemFontOfSize:10*SCREENSCALE];
    _numLabel.textColor = UIColor.whiteColor;
    [self.contentView addSubview:_numLabel];
    
    self.timeImageView = [[UIImageView alloc] init];
    self.timeImageView.image = [UIImage imageNamed:@"themeTime"];
    self.timeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.timeImageView];
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.textAlignment = NSTextAlignmentLeft;
    _timeLabel.text = @"03:35";
    _timeLabel.font = [UIFont systemFontOfSize:10*SCREENSCALE];
    _timeLabel.textColor = UIColor.whiteColor;
    [self.contentView addSubview:_timeLabel];
    
    self.downLoadImageView = [[UIImageView alloc] init];
    self.downLoadImageView.image = [UIImage imageNamed:@"themeDownload"];
    self.downLoadImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.downLoadImageView];
    self.downLoadImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadSource)];
    [self.downLoadImageView addGestureRecognizer:recog];
}

-(void)downloadSource{
    if (self.downLoadBlock) {
        self.downLoadBlock(self.model, self);
    }
}

-(void)configAutoLayout{
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.iconImageView.mas_width);
    }];

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(10*SCREENSCALE);
        make.bottom.mas_equalTo(self.contentView).offset(-10*SCREENSCALE);
        make.height.mas_equalTo(20.0f);
        make.width.mas_equalTo(60.0f);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-5*SCREENSCALE);
        make.centerY.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(20.0f*SCREENSCALE);
        make.width.mas_equalTo(30.0f*SCREENSCALE);
    }];
    [self.timeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.timeLabel.mas_left).offset(-3.0f*SCREENSCALE);
        make.height.mas_equalTo(9*SCREENSCALE);
        make.width.mas_equalTo(10*SCREENSCALE);
    }];
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.timeImageView.mas_left).offset(-15*SCREENSCALE);
        make.centerY.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(20.0f);
        make.width.mas_equalTo(10.0*SCREENSCALE);
    }];
    [self.numImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.numLabel.mas_left).offset(-3.0f*SCREENSCALE);
        make.height.mas_equalTo(8.5*SCREENSCALE);
        make.width.mas_equalTo(9*SCREENSCALE);
    }];
    [self.downLoadImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-5.0f*SCREENSCALE);
        make.top.mas_equalTo(self.contentView).offset(5.0f*SCREENSCALE);
        make.width.mas_equalTo(57.0f/2.0f);
        make.height.mas_equalTo(37.0f/2.0);
    }];
}

@end
