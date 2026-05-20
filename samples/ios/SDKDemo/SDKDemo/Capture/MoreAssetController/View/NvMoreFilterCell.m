//
//  NvMoreFilterCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvMoreFilterCell.h"
#import <UIImageView+YYWebImage.h>

@interface NvMoreFilterCell()

@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) UIImageView *imageViewType;

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

#pragma mark - 初始化界面
/*
 初始化界面
 Initialize the interface
 
 */
- (void)addSubviews{
    self.coverView = [UIImageView new];
    self.coverView.contentMode = UIViewContentModeScaleToFill;
    
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
    
    self.imageViewType = [[UIImageView alloc] init];
    
    [self.contentView addSubview:self.coverView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.drawLabel];
    [self.contentView addSubview:self.sizeLabel];
    [self.contentView addSubview:self.download];
    [self.contentView addSubview:self.imageViewType];
    
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
        make.width.greaterThanOrEqualTo(@(60 * SCREENSCALE));
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
    
    [self.imageViewType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.coverView.mas_right);
        make.bottom.equalTo(self.sizeLabel.mas_bottom);
        make.width.equalTo(@(19 * SCREENSCALE));
        make.height.offset(19 * SCREENSCALE);
    }];
}

- (void)setModel:(NvBaseModel *)model{
    _model = model;
    if (_type == ASSET_FACE1_STICKER) {
        _string = NvLocalString(@"Frame", @"画幅");
    }else{
        _string = NvLocalString(@"Types", @"类型");
    }
    self.nameLabel.text = model.displayName;
    [self.coverView yy_setImageWithURL:[NSURL URLWithString:model.coverName] placeholder:nil];
    self.sizeLabel.text = [NSString stringWithFormat:NvLocalString(@"Size", @"大小：%@"),model.size];
    NSString *typeString = model.draw;
    if (self.type == ASSET_ARSCENE) {
        switch (model.categoryId) {
            case 1:
                typeString = @"2D";
                self.imageViewType.image = NvImageNamed(@"NvProps2D");
                break;
            case 2:
                typeString = @"3D";
                self.imageViewType.image = NvImageNamed(@"NvProps3D");
                break;
            case 3:
                typeString = NvLocalString(@"Foreground", @"前景");
                self.imageViewType.image = NvImageNamed(@"NvPropsForeground");
                break;
            case 4:
                typeString = NvLocalString(@"Background", @"背景");
                self.imageViewType.image = NvImageNamed(@"NvPropsBackground");
                break;
            case 5:
                typeString = NvLocalString(@"Eye", @"眼部");
                self.imageViewType.image = NvImageNamed(@"NvPropsEye");
                break;
            case 6:
                typeString = NvLocalString(@"Mouth", @"嘴部");
                self.imageViewType.image = NvImageNamed(@"NvPropsMouth");
                break;
            case 7:
                typeString = NvLocalString(@"Head", @"头部");
                self.imageViewType.image = NvImageNamed(@"NvPropsHead");
                break;
            case 8:
                typeString = NvLocalString(@"Gesture", @"手势");
                self.imageViewType.image = NvImageNamed(@"NvPropsGesture");
                break;
            default:
                break;
        }
    } else {
        typeString = model.draw;
    }
    self.drawLabel.text = [NSString stringWithFormat:@"%@：%@",_string,typeString];
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
        case NoUser:
            self.download.stateTitle = NvLocalString(@"Not adapted", @"不适配");
            break;
        default:
            break;
    }
    if (self.type == ASSET_ARSCENE) {
        self.imageViewType.hidden = NO;
    } else {
        self.imageViewType.hidden = YES;
    }
}

#pragma mark - 下载按钮点击事件
/*
 下载按钮点击事件
 Download button click event
 
 */
- (void)downloadBtn{
    [_delegate nvMoreFilterCell:self nvBaseModel:self.model];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
