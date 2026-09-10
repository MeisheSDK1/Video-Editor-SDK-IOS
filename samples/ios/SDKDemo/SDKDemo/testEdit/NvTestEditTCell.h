//
//  NvTestEditTCell.h
//  SDKDemo
//
//  Created by ms20221114 on 2024/12/12.
//  Copyright © 2024 meishe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NvTestEditInfoModel : NSObject

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, assign) BOOL isSelected;

@end

@interface NvTestEditTCell : UITableViewCell

- (void)renderCellWithItem:(NvTestEditInfoModel *)item;

@end

NS_ASSUME_NONNULL_END
