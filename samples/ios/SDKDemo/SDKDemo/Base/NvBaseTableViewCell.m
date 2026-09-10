//
//  NvBaseTableViewCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2018/5/29.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBaseTableViewCell.h"

@implementation NvBaseTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];

    }
    return self ;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
