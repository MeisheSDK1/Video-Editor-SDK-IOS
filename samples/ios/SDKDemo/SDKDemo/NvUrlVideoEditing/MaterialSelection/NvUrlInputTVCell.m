//
//  NvUrlInputTVCell.m
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/4.
//  Copyright © 2024 meishe. All rights reserved.
//

#import "NvUrlInputTVCell.h"

@implementation NvUrlInputMaterialModel

@end

@interface NvUrlInputTVCell() <UITextFieldDelegate>

@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) NvUrlInputMaterialModel *model;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIView *coverBoxView;
@end

@implementation NvUrlInputTVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        NSString *placeholderStr = NvLocalString(@"urlEditing_home_input_tip", nil);
        NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:placeholderStr];
        [placeholder addAttribute:NSForegroundColorAttributeName value:[UIColor nv_colorWithHexRGB:@"#A4A4A4"] range:NSMakeRange(0, placeholderStr.length)];
        [placeholder addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(0, placeholderStr.length)];
        self.contactTextfield = [[UITextField alloc]init];
        self.contactTextfield.backgroundColor = [UIColor nv_colorWithHexRGB:@"#333333"];
        self.contactTextfield.attributedPlaceholder = placeholder;
        self.contactTextfield.font = [NvUtils fontWithSize:12];
        self.contactTextfield.layer.cornerRadius = 4 * SCREENSCALE;
        self.contactTextfield.delegate = self;
        self.contactTextfield.textColor = [UIColor nv_colorWithHexRGB:@"#A4A4A4"];
        [self.contentView addSubview:self.contactTextfield];
        [self.contactTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(25 * SCREENSCALE);
            make.right.equalTo(self.contentView).offset(-46 * SCREENSCALE);
            make.top.equalTo(self.contentView);
            make.height.offset(30 * SCREENSCALE);
        }];
        
        self.coverView = [[UIImageView alloc] init];
        self.coverView.contentMode = UIViewContentModeScaleToFill;
        self.coverView.layer.cornerRadius = 3;
        
        self.coverBoxView = [[UIView alloc] init];
        [self.coverBoxView addSubview:self.coverView];
        
        self.contactTextfield.leftView = self.coverBoxView;
        self.contactTextfield.leftViewMode = UITextFieldViewModeAlways;
        self.contactTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.editButton setImage:NvImageNamed(@"NvUrlEdit_inputMore") forState:UIControlStateNormal];
        [self.editButton addTarget:self action:@selector(editButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.editButton];
        [self.editButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contactTextfield.mas_right).offset(0 * SCREENSCALE);
            make.centerY.equalTo(self.contactTextfield);
            make.width.offset(30 * SCREENSCALE);
            make.height.offset(30 * SCREENSCALE);
        }];
    }
    return self;
}

- (void)renderCellWithItem:(NvUrlInputMaterialModel *)item {
    self.model = item;
    self.contactTextfield.text = item.urlString;
    if (item.image) {
        self.coverView.image = item.image;
        [self.contactTextfield mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(66 * SCREENSCALE);
        }];
        self.coverView.frame = CGRectMake(5 * SCREENSCALE, 0, 55 * SCREENSCALE, 55 * SCREENSCALE);
        self.coverBoxView.frame = CGRectMake(0 * SCREENSCALE, 0, self.coverView.frame.size.width + self.coverView.frame.origin.x * 2, self.coverView.frame.size.height);
    } else {
        self.coverView.image = nil;
        [self.contactTextfield mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.offset(30 * SCREENSCALE);
        }];
        self.coverView.frame = CGRectMake(0 * SCREENSCALE, 0, 10 * SCREENSCALE, 30 * SCREENSCALE);
        self.coverBoxView.frame = self.coverView.frame;
    }
}

- (void)renderMusicCellWithItem:(NvUrlInputMaterialModel *)item {
    self.model = item;
    self.contactTextfield.text = item.urlString;
    self.coverBoxView.frame = CGRectMake(0 * SCREENSCALE, 0, 10 * SCREENSCALE, 30 * SCREENSCALE);
}

- (void)editButtonClick{
    if ([self.delegate respondsToSelector:@selector(editClick:)]) {
        [self.delegate editClick:self.model];
    }
}

#pragma mark - UITextInputDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(inputBeginEditing:)]) {
        [self.delegate inputBeginEditing:self.model];
    }
    return  YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    self.model.urlString = self.contactTextfield.text;
    if ([self.delegate respondsToSelector:@selector(inputEndEditing:)]) {
        [self.delegate inputEndEditing:self.model];
    }
    return YES;
}


@end
