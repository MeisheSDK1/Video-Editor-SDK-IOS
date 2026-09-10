//
//  NvFlipCaptionTableViewCell.h
//  SDKDemo
//
//  Created by 刘东旭 on 2018/12/25.
//  Copyright © 2018年 meishe. All rights reserved.
//

#import "NvBaseTableViewCell.h"
#import "NvFlipCaptionModel.h"
NS_ASSUME_NONNULL_BEGIN
@class NvFlipCaptionTableViewCell;

@protocol NvFlipCaptionTableViewCellDelegate <NSObject>

- (void)flipCaptionTableViewCell:(NvFlipCaptionTableViewCell *)flipCaptionTableViewCell selectForIndexModel:(NvFlipCaptionModel *)model;
- (void)flipCaptionTableViewCell:(NvFlipCaptionTableViewCell *)flipCaptionTableViewCell changeIndexModel:(NvFlipCaptionModel *)model textViewString:(NSString *)text;
- (void)flipCaptionTableViewCell:(NvFlipCaptionTableViewCell *)flipCaptionTableViewCell clickIndexModel:(NvFlipCaptionModel *)model;

@end



@interface NvFlipCaptionTableViewCell : NvBaseTableViewCell

@property (nonatomic, weak)id delegate;

@property (nonatomic, strong, readonly) UITextView *textView;
@property (strong, nonatomic, readonly) UIButton *editButton;

- (void)renderCellWithItem:(NvFlipCaptionModel *)model;

@end

NS_ASSUME_NONNULL_END
