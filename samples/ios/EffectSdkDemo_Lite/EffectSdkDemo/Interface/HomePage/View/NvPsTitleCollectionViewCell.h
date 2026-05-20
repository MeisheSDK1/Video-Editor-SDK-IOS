//
//  NvPsTitleCollectionViewCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2018/8/6.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvPsTitleModel : NSObject

@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) BOOL selected;
@property (nonatomic, strong) NSString *colorStr;
@end

@interface NvPsTitleCollectionViewCell : UICollectionViewCell

/// 绑定数据
/// Bind data
/// @param model 数据模型 Data model 
- (void)renderCellWithString:(NvPsTitleModel *)model;

@end
