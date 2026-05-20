//
//  NvKeyFrameButton.m
//  SDKDemo
//
//  Created by MS on 2020/6/6.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvKeyFrameButton.h"
#import "NvHeader.h"

@interface NvKeyFrameButton ()
@property (nonatomic, strong) NSString *normalString;
@property (nonatomic, strong) NSString *selectedString;
@end
@implementation NvKeyFrameButton
+ (instancetype)buttonWithType:(UIButtonType)buttonType withTitle:(NSString *)title withImageNormal:(NSString *)normal withImageSelected:(NSString *)selected{
    NvKeyFrameButton *btn = [NvKeyFrameButton buttonWithType:buttonType];
    if (btn) {
        btn.normalString = normal;
        btn.btnImageView = [[UIImageView alloc]init];
        btn.btnImageView.contentMode = UIViewContentModeScaleAspectFit;
        if (selected) {
            btn.selectedString = selected;
            if (btn.isSelected) {
                btn.btnImageView.image = NvImageNamed(selected);
            }else{
                btn.btnImageView.image = NvImageNamed(normal);
            }
        }else{
            btn.btnImageView.image = NvImageNamed(normal);
        }
        [btn addSubview:btn.btnImageView];
        [btn.btnImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btn);
            make.centerX.equalTo(btn);
            make.width.offset(20 * SCREENSCALE);
            make.height.offset(20 * SCREENSCALE);
        }];
        
        btn.btnLabel = [[UILabel alloc]init];
        btn.btnLabel.text = title;
        btn.btnLabel.textAlignment = NSTextAlignmentCenter;
        btn.btnLabel.font = [NvUtils regularFontWithSize:8*SCREENSCALE];
        btn.btnLabel.textColor = UIColor.whiteColor;
        [btn addSubview:btn.btnLabel];
        [btn.btnLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btn.btnImageView.mas_bottom);
            make.left.right.offset(0);
            make.centerX.equalTo(btn);
            make.bottom.equalTo(btn);
        }];
        
    }
    return btn;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (self.selectedString) {
        if (selected) {
            self.btnImageView.image = NvImageNamed(self.selectedString);
        }else{
            self.btnImageView.image = NvImageNamed(self.normalString);
        }
    }
}
@end
