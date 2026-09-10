//
//  NvCompoundCaptionTVCell.h
//  SDKDemo
//
//  Created by ms20180425 on 2020/8/5.
//  Copyright © 2020 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvCompoundCaptionModel;
NS_ASSUME_NONNULL_BEGIN

@interface NvCompoundCaptionTVCell : UITableViewCell

- (void)renderCellWithModel:(NvCompoundCaptionModel *)model;

- (NvCompoundCaptionModel *)getInputText;

@end

NS_ASSUME_NONNULL_END
