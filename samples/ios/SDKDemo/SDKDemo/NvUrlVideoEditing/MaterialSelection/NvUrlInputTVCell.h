//
//  NvUrlInputTVCell.h
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/4.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NvUrlInputTVCell;

@interface NvUrlInputMaterialModel : NSObject

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_BEGIN

@protocol NvUrlInputTVCellDelegate <NSObject>
@optional

- (void)inputBeginEditing:(NvUrlInputMaterialModel *)model;

- (void)inputEndEditing:(NvUrlInputMaterialModel *)model;

- (void)editClick:(NvUrlInputMaterialModel *)item;

@end

@interface NvUrlInputTVCell : UITableViewCell

@property (nonatomic, weak) id<NvUrlInputTVCellDelegate> delegate;

@property (nonatomic, strong) UITextField *contactTextfield;

- (void)renderCellWithItem:(NvUrlInputMaterialModel *)item;

- (void)renderMusicCellWithItem:(NvUrlInputMaterialModel *)item;

@end

NS_ASSUME_NONNULL_END
