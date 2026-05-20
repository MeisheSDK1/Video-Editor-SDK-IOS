//
//  NvCompoundCaptionTVCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/5.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvCompoundCaptionTVCell.h"
#import "NvCompoundCaptionModel.h"
#import "NVHeader.h"

@interface NvCompoundCaptionTVCell()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation NvCompoundCaptionTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self addMainView];
    }
    
    return self;
}

- (void)addMainView{
    UIImageView *leftImageView = [[UIImageView alloc]init];
    leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    leftImageView.image = [UIImage imageNamed:@"NvTimelineCaption"];
    [self.contentView addSubview:leftImageView];
    [leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(30 * SCREENSCALE);
        make.centerY.equalTo(self.contentView);
        make.width.offset(24*SCREENSCALE);
        make.height.offset(18*SCREENSCALE);
    }];
    
    UIView *textView = [[UIView alloc]init];
    textView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#FF1A1A1A"];
    [self.contentView addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftImageView.mas_right).offset(18 * SCREENSCALE);
        make.right.equalTo(self.contentView).offset(-90*SCREENSCALE);
        make.centerY.equalTo(self.contentView);
        make.height.offset(26*SCREENSCALE);
    }];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.backgroundColor = UIColor.clearColor;
    self.nameLabel.textColor = UIColor.whiteColor;
    self.nameLabel.font = [UIFont systemFontOfSize:11*SCREENSCALE];
    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textView).offset(15 * SCREENSCALE);
        make.right.equalTo(textView).offset(-15 * SCREENSCALE);
        make.centerY.equalTo(textView);
    }];
    
    UILabel *editLab = [[UILabel alloc] init];
    editLab.backgroundColor = [UIColor nv_colorWithHexRGB:@"#4A90E2"];
    editLab.textColor = UIColor.whiteColor;
    editLab.font = [UIFont systemFontOfSize:11*SCREENSCALE];
    editLab.textAlignment = NSTextAlignmentCenter;
    editLab.text = NvLocalString(@"Edit Text", @"编辑文字");
    [self.contentView addSubview:editLab];
    [editLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(textView.mas_right).offset(5 * SCREENSCALE);
        make.right.equalTo(self.contentView).offset(-20 * SCREENSCALE);
        make.centerY.equalTo(self.contentView);
        make.height.offset(22*SCREENSCALE);
    }];
}

- (void)renderCellWithModel:(NvCompoundCaptionModel *)model{
    self.nameLabel.text = model.showName;
}

- (NSString *)getInputText{
    return @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
