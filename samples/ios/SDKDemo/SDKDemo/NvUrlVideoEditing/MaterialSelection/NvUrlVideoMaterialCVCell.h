//
//  NvUrlVideoMaterialCVCell.h
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/2.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NvListMediaInfoModel : NSObject

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, strong) NSString *waveUrl;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *displayNameZhCn;
@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, assign) BOOL selectedModel;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isPlay;

@end

NS_ASSUME_NONNULL_BEGIN

@interface NvUrlVideoMaterialCVCell : UICollectionViewCell

- (void)renderCellWithItem:(NvListMediaInfoModel *)item;

@end

NS_ASSUME_NONNULL_END
