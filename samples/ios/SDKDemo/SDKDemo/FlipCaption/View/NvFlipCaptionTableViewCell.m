//
//  NvFlipCaptionTableViewCell.m
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvFlipCaptionTableViewCell.h"
#import "NVHeader.h"

@interface NvFlipCaptionTableViewCell()

@property (strong, nonatomic) UIImageView *selectImage;
@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UILabel *flipCaptionLabel;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NvFlipCaptionModel *model;

@end

@implementation NvFlipCaptionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor nv_colorWithHexRGB:@"#242728"];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UITapGestureRecognizer *contentTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTap:)];
        [self.contentView addGestureRecognizer:contentTap];
        self.selectImage = [[UIImageView alloc] init];
        [self.contentView addSubview:self.selectImage];
        [self.selectImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(20*SCREENSCALE));
            make.centerY.equalTo(self.contentView);
            make.width.height.equalTo(@(10*SCREENSCALE));
        }];
        self.editButton = [[UIButton alloc] init];
        [self.contentView addSubview:self.editButton];
        [self.editButton addTarget:self action:@selector(editTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-10*SCREENSCALE));
            make.centerY.equalTo(self.contentView);
            make.width.height.equalTo(@(40*SCREENSCALE));
        }];
        self.flipCaptionLabel = [[UILabel alloc] init];
        self.flipCaptionLabel.textColor = [UIColor whiteColor];
        self.flipCaptionLabel.alpha = 0.8;
        self.flipCaptionLabel.numberOfLines = 0;
        self.flipCaptionLabel.font = [NvUtils regularFontWithSize:15];
        [self.contentView addSubview:self.flipCaptionLabel];
        [self.flipCaptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.selectImage.mas_right).offset(20*SCREENSCALE);
            make.centerY.equalTo(self.contentView);
            make.right.equalTo(self.editButton.mas_left).offset(-20*SCREENSCALE);
            make.top.equalTo(@(15*SCREENSCALE));
            make.bottom.equalTo(@(-15*SCREENSCALE));
        }];
        
        self.textView = [[UITextView alloc] init];
        self.textView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.textView.font = [NvUtils regularFontWithSize:15];
        [self.contentView addSubview:self.textView];
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.flipCaptionLabel);
        }];
        self.textView.hidden = YES;
        
    }
    return self;
}

- (void)renderCellWithItem:(NvFlipCaptionModel *)model {
    _model = model;
    self.flipCaptionLabel.text = self.model.text;
    if (model.colorString) {
        self.flipCaptionLabel.textColor = [UIColor nv_colorWithHexARGB:model.colorString];
    } else {
        self.flipCaptionLabel.textColor = [UIColor whiteColor];
    }
    
    if (self.model.isSelect) {
        self.selectImage.image = NvImageNamed(@"NvFlipCaptionSelect");
        self.editButton.hidden = NO;
        if (self.model.isEdit) {
            [self.editButton setImage:NvImageNamed(@"NvFlipCaptionOk") forState:UIControlStateNormal];
            self.textView.hidden = NO;
            self.textView.text = self.flipCaptionLabel.text;
        } else {
            [self.editButton setImage:NvImageNamed(@"NvNoteSimpleLineIcons") forState:UIControlStateNormal];
            self.textView.hidden = YES;
        }
        
    } else {
        [self.editButton setImage:NvImageNamed(@"NvFlipCaptionOk") forState:UIControlStateNormal];
        self.editButton.hidden = YES;
        self.selectImage.image = NvImageNamed(@"NvFlipCaptionNoSelect");
        self.textView.hidden = YES;
    }
}

- (void)contentTap:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(flipCaptionTableViewCell:selectForIndexModel:)]) {
        [self.delegate flipCaptionTableViewCell:self selectForIndexModel:self.model];
    }
}

- (void)editTap:(UIButton *)tap {
    if (self.model.isSelect && self.model.isEdit) {
        if ([self.delegate respondsToSelector:@selector(flipCaptionTableViewCell:changeIndexModel:textViewString:)]) {
            [self.delegate flipCaptionTableViewCell:self changeIndexModel:self.model textViewString:self.textView.text];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(flipCaptionTableViewCell:clickIndexModel:)]) {
            [self.delegate flipCaptionTableViewCell:self clickIndexModel:self.model];
        }
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
