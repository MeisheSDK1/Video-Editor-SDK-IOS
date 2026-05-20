//
//  NvEditBGColorCell.m
//  SDKDemo
//
//  Created by MS on 2020/10/21.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvEditBGColorCell.h"
#import "NVHeader.h"
@interface NvEditBGColorCell ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation NvEditBGColorCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.imageView];
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0);
        }];
      
    }
    return self;
}

-(void)setModel:(NvEditBGColorModel *)model{
    _model = model;
    self.backgroundColor = [UIColor colorWithRed:model.r green:model.g blue:model.b alpha:1.0];
    if (model.isSelect) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor colorWithRed:0.99 green:0.17 blue:0.33 alpha:1.0].CGColor;
    }else{
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor colorWithRed:0.99 green:0.17 blue:0.33 alpha:1.0].CGColor;
    }
    
}
@end
