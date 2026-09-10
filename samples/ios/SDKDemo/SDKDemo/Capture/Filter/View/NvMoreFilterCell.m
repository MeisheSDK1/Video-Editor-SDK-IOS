//
//  NvMoreFilterCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMoreFilterCell.h"
#import "UIImageView+WebCache.h"

@interface NvMoreFilterCell()

@property (nonatomic, strong) NSString *string;

@end

@implementation NvMoreFilterCell

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
    self.coverView.contentMode = UIViewContentModeScaleToFill;
    
    self.nameLabel = [UILabel new];
    self.nameLabel.textColor = [UIColor nv_colorWithHexRGB:@"#373B3D"];
    self.nameLabel.font = [NvUtils fontWithSize:12 * SCREANSCALE];
    
    self.drawLabel = [UILabel new];
    self.drawLabel.textColor = [UIColor nv_colorWithHexRGB:@"#373B3D"];
    self.drawLabel.font = [NvUtils fontWithSize:11 * SCREANSCALE];
    
    self.sizeLabel = [UILabel new];
    self.sizeLabel.textColor = [UIColor nv_colorWithHexRGB:@"#373B3D"];
    self.sizeLabel.font = [NvUtils fontWithSize:12 * SCREANSCALE];
    
    self.download = [NvDownloadBtn buttonWithType:UIButtonTypeCustom];
    [self.download addTarget:self action:@selector(downloadBtn) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.drawLabel];
    [self.contentView addSubview:self.sizeLabel];
    [self.contentView addSubview:self.download];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(13 * SCREANSCALE);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.offset(45 * SCREANSCALE);
        make.height.offset(45 * SCREANSCALE);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.coverView.mas_right).offset(15 * SCREANSCALE);
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
        make.right.equalTo(self.contentView.mas_right).offset(- 13 * SCREANSCALE);
        make.centerY.equalTo(self.contentView.mas_centerY);
//        make.width.offset(60 * SCREANSCALE);
        make.width.greaterThanOrEqualTo(@(60 * SCREANSCALE));
        make.height.offset(27 * SCREANSCALE);
    }];
    
    UILabel *Line = [UILabel new];
    Line.backgroundColor = [UIColor nv_colorWithHexRGB:@"#979797"];
    [self.contentView addSubview:Line];
    [Line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.offset(SCREEN_WDITH);
        make.height.offset(1);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
}

- (void)setModel:(NvBaseModel *)model{
    _model = model;
    if (_type == ASSET_FACE1_STICKER) {
        _string = NSLocalizedString(@"Frame", @"画幅");
    }else{
        _string = NSLocalizedString(@"Types", @"类型");
    }
    self.nameLabel.text = model.displayName;
    [self.coverView sd_setImageWithURL:[NSURL URLWithString:model.coverName]];
    self.sizeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Size", @"大小：%@"),model.size];
    self.drawLabel.text = [NSString stringWithFormat:@"%@：%@",_string,model.draw];
    switch (self.model.state) {
        case NODownload:
            self.download.stateTitle = NSLocalizedString(@"Download", @"下载");
            break;
        case Downloading:
            break;
        case DownloadError:
            self.download.stateTitle = NSLocalizedString(@"again", @"重试");
            break;
        case Finish:
            self.download.stateTitle = NSLocalizedString(@"Downloaded", @"已下载");
            break;
        case Update:
            self.download.stateTitle = NSLocalizedString(@"Update", @"更新");
            break;
        case NoUser:
            self.download.stateTitle = NSLocalizedString(@"Not adapted", @"不适配");
            break;
        default:
            break;
    }
}

- (void)downloadBtn{
    [_delegate nvMoreFilterCell:self nvBaseModel:self.model];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
