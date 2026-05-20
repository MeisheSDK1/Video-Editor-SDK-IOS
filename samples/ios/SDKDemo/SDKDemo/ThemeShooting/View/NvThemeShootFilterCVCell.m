//
//  NvThemeShootFilterCVCell.m
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/4.
//  Copyright © 2020 meishe. All rights reserved.
//

#import "NvThemeShootFilterCVCell.h"
#import "NvThemeShootItemModel.h"
#import "NvCaptureFilterModel.h"
#import "NVHeader.h"

@interface NvThemeShootFilterCVCell()

@property (nonatomic, strong) UIView *filterMaskView;

@end

@implementation NvThemeShootFilterCVCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.filterMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        self.filterMaskView.backgroundColor = [UIColor nv_colorWithHexARGB:@"#B34A90E2"];
        [self.contentView addSubview:self.filterMaskView];
    }
    return self;
}

- (void)renderCellWithFilterModel:(NvCaptureFilterModel *)model{
    self.maskView.hidden = YES;
    if ([model.displayName isEqualToString:NvLocalString(@"None", @"无")]) {
        
        self.coverView.image = [UIImage imageNamed:model.coverName];
    }else{
        
        self.coverView.image = [UIImage imageWithContentsOfFile:model.coverName];
    }
    self.nameLabel.text = model.displayName;
    self.filterMaskView.hidden = !model.selected;
    self.nameLabel.textColor = model.selected?[UIColor nv_colorWithHexRGB:@"#4A90E2"]:UIColor.whiteColor;
}

@end
