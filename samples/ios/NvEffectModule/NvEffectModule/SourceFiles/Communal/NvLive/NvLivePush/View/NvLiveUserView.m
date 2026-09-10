//
//  NvLiveUserView.m
//  MeicamLive
//
//  Created by ms20180425 on 2020/4/7.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import "NvLiveUserView.h"
#import "UIColor+NvLiveColor.h"
#import "Masonry.h"
#import "NvLiveARSceneUtils.h"
#import "NvLiveAppEnv.h"

@interface NvLiveUserView()

@end

@implementation NvLiveUserView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor nv_colorWithHexARGB:@"#4D000000"];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 22;
        [self addMainView];
    }
    return self;
}

- (void)addMainView{
    UIImageView *avatarImageView = [[UIImageView alloc]init];
    avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
    avatarImageView.image = [NvLiveARSceneUtils imageNamed:@"MSUser1"];
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = 17;
    [self addSubview:avatarImageView];
    [avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.width.height.offset(34);
    }];
    
    UILabel *nameLabel = [[UILabel alloc]init];
    nameLabel.font = [UIFont systemFontOfSize:13];
    nameLabel.text = NvLocalString(@"meishe_user", @"美摄用户");
    nameLabel.textColor = UIColor.whiteColor;
    [self addSubview:nameLabel];
    [nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avatarImageView.mas_right).offset(10);
        make.top.equalTo(avatarImageView);
    }];
    
    UILabel *userIDLabel = [[UILabel alloc]init];
    userIDLabel.font = [UIFont systemFontOfSize:13];
    userIDLabel.text = @"123456789";
    userIDLabel.textColor = UIColor.whiteColor;
    [self addSubview:userIDLabel];
    [userIDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(nameLabel);
        make.bottom.equalTo(avatarImageView);
    }];
}

@end
