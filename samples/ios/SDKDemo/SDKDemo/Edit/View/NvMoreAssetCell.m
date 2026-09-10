//
//  NvMoreFilterCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMoreAssetCell.h"
#import <UIImageView+YYWebImage.h>


@interface NvMoreAssetCell()

@property (nonatomic, strong) NSString *string;

@end

@implementation NvMoreAssetCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self addSubviews];
    }
    return self ;
}

- (void)addSubviews{
    self.coverView = [UIImageView new];
    self.coverView.contentMode = UIViewContentModeScaleAspectFit;
    self.coverView.layer.masksToBounds = YES;
    self.coverView.layer.cornerRadius = 45 * SCREENSCALE / 2;
    
    self.nameLabel = [UILabel new];
    self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#373B3D"];
    self.nameLabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    
    self.drawLabel = [UILabel new];
    self.drawLabel.textColor = [UIColor nv_colorWithHexRGB:@"#373B3D"];
    self.drawLabel.font = [NvUtils fontWithSize:11 * SCREENSCALE];
    
    self.sizeLabel = [UILabel new];
    self.sizeLabel.textColor = [UIColor nv_colorWithHexRGB:@"#373B3D"];
    self.sizeLabel.font = [NvUtils fontWithSize:12 * SCREENSCALE];
    
    self.download = [NvDownloadBtn buttonWithType:UIButtonTypeCustom];
    [self.download addTarget:self action:@selector(downloadBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.drawLabel];
    [self.contentView addSubview:self.sizeLabel];
    [self.contentView addSubview:self.download];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(13 * SCREENSCALE);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.offset(45 * SCREENSCALE);
        make.height.offset(45 * SCREENSCALE);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverView.mas_right).offset(15 * SCREENSCALE);
        make.top.equalTo(self.coverView.mas_top);
    }];
    
    [self.drawLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.nameLabel.mas_leading);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    
    [self.sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.nameLabel.mas_leading);
        make.bottom.equalTo(self.coverView.mas_bottom);
    }];
    
    [self.download mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).offset(- 13 * SCREENSCALE);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.offset(60 * SCREENSCALE);
        make.height.offset(27 * SCREENSCALE);
    }];
    
    UILabel *Line = [UILabel new];
    Line.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [self.contentView addSubview:Line];
    [Line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(SCREENWIDTH);
        make.height.offset(1);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
}

- (void)setModel:(NvAssetCellModel *)model{
    _model = model;
    switch (_type) {
        case ASSET_THEME:
            _string = NvLocalString(@"Frame", @"画幅");
            break;
        case ASSET_FILTER:
            _string = NvLocalString(@"Frame", @"画幅");
            break;
        case ASSET_CAPTION_STYLE:
            _string = NvLocalString(@"Frame", @"画幅");
            break;
        case ASSET_ANIMATED_STICKER:
            _string = NvLocalString(@"Frame", @"画幅");
            break;
        case ASSET_VIDEO_TRANSITION:
            _string = NvLocalString(@"Frame", @"画幅");
            break;
        case ASSET_CAPTURE_SCENE:
            _string = NvLocalString(@"Frame", @"画幅");
            break;
        case ASSET_PARTICLE:
            _string = NvLocalString(@"Frame", @"画幅");
            break;
        default:
            _string = NvLocalString(@"Frame", @"画幅");
            break;
    }
    self.nameLabel.text = model.displayName;
    [self.coverView yy_setImageWithURL:[NSURL fileURLWithPath:model.cover] placeholder:nil];
    self.sizeLabel.text = [NSString stringWithFormat:NvLocalString(@"Size", @"大小：%@"),model.size];
    self.drawLabel.text = [NSString stringWithFormat:@"%@：%@",_string,model.draw];
    switch (self.model.state) {
        case NODownload:
            self.download.stateTitle = NvLocalString(@"Download", @"下载");
            break;
        case Downloading:
            break;
        case DownloadError:
            self.download.stateTitle = NvLocalString(@"again", @"重试");
            break;
        case Finish:
            self.download.stateTitle = NvLocalString(@"Downloaded", @"已下载");
            break;
        case Update:
            self.download.stateTitle = NvLocalString(@"Update", @"更新");
            break;
        default:
            break;
    }
}

- (void)downloadBtn{
    [_delegate nvMoreAssetCell:self nvAssetItem:self.model];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
