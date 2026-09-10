//
//  NvAnimationAssetCell.m
//  SDKDemo
//
//  Created by ms on 2020/8/24.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvAnimationAssetCell.h"
#import "NVHeader.h"
@interface NvAnimationAssetCell()

@property (nonatomic, strong) UILabel *timeLabel;
@end


@implementation NvAnimationAssetCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.coverImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.coverImage.contentMode = UIViewContentModeScaleAspectFill;
        self.coverImage.layer.masksToBounds = YES;
        [self.contentView addSubview:self.coverImage];
        self.coverImage.clipsToBounds = YES;
        self.coverImage.layer.cornerRadius = 3.0f;
        self.coverImage.layer.borderWidth = 2.0f;
        [self.coverImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
        
        
        self.timeLabel = [UILabel new];
        self.timeLabel.textColor = UIColor.whiteColor;
        self.timeLabel.font = [NvUtils fontWithSize:10 * SCREENSCALE];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.text = @"4s";
        [self.contentView addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-3*SCREENSCALE);
            make.bottom.equalTo(self.contentView).offset(-3*SCREENSCALE);
            make.height.mas_equalTo(10*SCREENSCALE);
            make.width.mas_equalTo(30*SCREENSCALE);
        }];
        
        self.maskView = [[UIView alloc]init];
        self.maskView.backgroundColor = [UIColor nv_colorWithHexString:@"#63ABFF" alpha:0.5];
        self.maskView.frame = CGRectMake(0, 0, 0, 0);
        [self.contentView addSubview:self.maskView];
        
        self.contentView.layer.cornerRadius = 3.0f;
        self.contentView.clipsToBounds = YES;
    }
    return self;
}

-(void)setModel:(NvEditDataModel *)model{
    _model = model;

    self.timeLabel.hidden = NO;
    self.timeLabel.text = [NSString stringWithFormat:@"%.0fs", roundf((model.trimOut - model.trimIn) / NV_TIME_BASE)];
    
    self.coverImage.image = model.thumImage;
    
    if (model.animationInfoModel.isSelected) {
        self.coverImage.layer.borderColor = [UIColor nv_colorWithHexRGB:@"#63ABFF"].CGColor;
    }else{
        self.coverImage.layer.borderColor = UIColor.clearColor.CGColor;
    }
    self.maskView.frame = model.animationInfoModel.maskRect;
    
}
@end
