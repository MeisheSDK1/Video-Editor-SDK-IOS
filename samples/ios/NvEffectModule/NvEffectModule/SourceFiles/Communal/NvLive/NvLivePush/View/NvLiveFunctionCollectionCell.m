//
//  NvLiveFunctionCollectionCell.m
//  MeicamLive
//
//  Created by ms20180425 on 2020/3/19.
//  Copyright © 2020 ms20180425. All rights reserved.
//

#import "NvLiveFunctionCollectionCell.h"
#import "NvLiveFunctionModel.h"
#import "Masonry.h"
#import "NvLiveARSceneUtils.h"
#import "NvLiveAppEnv.h"

@interface NvLiveFunctionCollectionCell()

@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, strong) UILabel *textlabel;

@end

@implementation NvLiveFunctionCollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addMainView:frame];
    }
    return self;
}

- (void)addMainView:(CGRect)frame{
    self.coverImageView = [[UIImageView alloc]init];
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.coverImageView];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.centerX.equalTo(self.contentView);
        make.width.height.offset(35 * NvScreen(kScale));
    }];
    
    self.textlabel = [[UILabel alloc]init];
    self.textlabel.textColor = UIColor.whiteColor;
    self.textlabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.textlabel];
    [self.textlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.coverImageView.mas_bottom).offset(3*NvScreen(kScale));
        make.centerX.equalTo(self.coverImageView);
    }];
}

- (void)renderCellWithModel:(NvLiveFunctionModel *)model{
    self.textlabel.text = model.name;
    self.coverImageView.image = [NvLiveARSceneUtils imageNamed:model.cover_unselected];
}

@end
